<script setup>
import { ref, onMounted } from 'vue'
import api from '@/api/axios'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import BaseInput from '@/components/ui/BaseInput.vue'
import BaseTable from '@/components/ui/BaseTable.vue'
import BaseModal from '@/components/ui/BaseModal.vue'
import StatusBadge from '@/components/ui/StatusBadge.vue'

const counties = ref([])
const regions = ref([])
const isLoading = ref(false)
const showModal = ref(false)
const isEditMode = ref(false)
const errorMessage = ref('')
const successMessage = ref('')

const formData = ref({
  id: null,
  name: '',
  region_id: '',
  is_active: true,
})

const columns = ['County Name', 'Region', 'Status', 'Actions']

const fetchCounties = async () => {
  isLoading.value = true
  try {
    const response = await api.get('/counties')
    counties.value = response.data
  } catch (err) {
    errorMessage.value = 'Failed to load counties'
    console.error(err)
  } finally {
    isLoading.value = false
  }
}

const fetchRegions = async () => {
  try {
    const response = await api.get('/regions')
    regions.value = response.data
  } catch (err) {
    console.error('Failed to load regions:', err)
  }
}

const openAddModal = () => {
  isEditMode.value = false
  formData.value = {
    id: null,
    name: '',
    region_id: '',
    is_active: true,
  }
  errorMessage.value = ''
  showModal.value = true
}

const openEditModal = (county) => {
  isEditMode.value = true
  formData.value = {
    id: county.id,
    name: county.name,
    region_id: county.region_id,
    is_active: county.is_active ?? true,
  }
  errorMessage.value = ''
  showModal.value = true
}

const saveCounty = async () => {
  errorMessage.value = ''
  successMessage.value = ''

  if (!formData.value.name || !formData.value.region_id) {
    errorMessage.value = 'County name and region are required'
    return
  }

  try {
    const payload = {
      name: formData.value.name,
      region_id: formData.value.region_id,
      is_active: formData.value.is_active,
    }

    if (isEditMode.value) {
      await api.put(`/counties/${formData.value.id}`, payload)
      successMessage.value = 'County updated successfully'
    } else {
      await api.post('/counties', payload)
      successMessage.value = 'County added successfully'
    }

    showModal.value = false
    await fetchCounties()
  } catch (err) {
    errorMessage.value = err.response?.data?.message || 'Failed to save county'
  }
}

const deleteCounty = async (id) => {
  if (!confirm('Are you sure you want to delete this county?')) return

  try {
    await api.delete(`/counties/${id}`)
    successMessage.value = 'County deleted successfully'
    await fetchCounties()
  } catch (err) {
    errorMessage.value = err.response?.data?.message || 'Failed to delete county'
  }
}

const getRegionName = (regionId) => {
  const region = regions.value.find(r => r.id === regionId)
  return region?.name || 'N/A'
}

onMounted(() => {
  fetchCounties()
  fetchRegions()
})
</script>

<template>
  <div class="counties-view">
    <!-- Success Message -->
    <div v-if="successMessage" class="alert alert-success">
      {{ successMessage }}
    </div>

    <!-- Error Message -->
    <div v-if="errorMessage" class="alert alert-error">
      {{ errorMessage }}
    </div>

    <BaseCard>
      <template #header>
        <div class="header-actions">
          <h3>County Management</h3>
          <BaseButton variant="primary" size="sm" @click="openAddModal">
            ➕ Add County
          </BaseButton>
        </div>
      </template>

      <div v-if="isLoading" class="loading-state">
        Loading counties...
      </div>

      <div v-else-if="counties.length === 0" class="empty-state">
        <p>No counties found. Add one to get started.</p>
        <BaseButton variant="outline" @click="openAddModal">Add First County</BaseButton>
      </div>

      <BaseTable v-else :columns="columns">
        <tr v-for="county in counties" :key="county.id">
          <td class="font-bold">{{ county.name }}</td>
          <td>{{ getRegionName(county.region_id) }}</td>
          <td>
            <StatusBadge :status="county.is_active ? 'success' : 'neutral'">
              {{ county.is_active ? 'Active' : 'Inactive' }}
            </StatusBadge>
          </td>
          <td class="action-buttons">
            <button class="action-btn edit-btn" @click="openEditModal(county)">
              Edit
            </button>
            <button class="action-btn delete-btn" @click="deleteCounty(county.id)">
              Delete
            </button>
          </td>
        </tr>
      </BaseTable>
    </BaseCard>

    <!-- Add/Edit Modal -->
    <BaseModal :show="showModal" :title="isEditMode ? 'Edit County' : 'Add New County'" @close="showModal = false">
      <div class="form-group">
        <label>County Name *</label>
        <BaseInput v-model="formData.name" placeholder="Enter county name" />
      </div>

      <div class="form-group">
        <label>Region *</label>
        <select v-model="formData.region_id" class="form-input">
          <option value="">-- Select Region --</option>
          <option v-for="region in regions" :key="region.id" :value="region.id">
            {{ region.name }}
          </option>
        </select>
      </div>

      <div class="form-group">
        <label class="checkbox-label">
          <input v-model="formData.is_active" type="checkbox" class="checkbox-input" />
          Active
        </label>
      </div>

      <div v-if="errorMessage" class="alert alert-error">
        {{ errorMessage }}
      </div>

      <div class="modal-actions">
        <BaseButton variant="outline" @click="showModal = false">Cancel</BaseButton>
        <BaseButton variant="primary" @click="saveCounty">
          {{ isEditMode ? 'Update' : 'Add' }} County
        </BaseButton>
      </div>
    </BaseModal>
  </div>
</template>

<style scoped>
.counties-view {
  padding: 2rem;
}

.alert {
  padding: 1rem;
  border-radius: 0.5rem;
  margin-bottom: 1rem;
}

.alert-success {
  background-color: #dcfce7;
  color: #166534;
  border: 1px solid #86efac;
}

.alert-error {
  background-color: #fee2e2;
  color: #991b1b;
  border: 1px solid #fca5a5;
}

.header-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.loading-state,
.empty-state {
  padding: 2rem;
  text-align: center;
  color: #666;
}

.action-buttons {
  display: flex;
  gap: 0.5rem;
}

.action-btn {
  padding: 0.4rem 0.8rem;
  border: none;
  border-radius: 0.4rem;
  cursor: pointer;
  font-size: 0.875rem;
  transition: all 0.2s;
}

.edit-btn {
  background-color: #3b82f6;
  color: white;
}

.edit-btn:hover {
  background-color: #2563eb;
}

.delete-btn {
  background-color: #ef4444;
  color: white;
}

.delete-btn:hover {
  background-color: #dc2626;
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #333;
}

.form-input {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #ddd;
  border-radius: 0.4rem;
  font-size: 1rem;
  font-family: inherit;
}

.form-input:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
  font-weight: 500;
  color: #333;
}

.checkbox-input {
  width: 1.25rem;
  height: 1.25rem;
  cursor: pointer;
}

.modal-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
  margin-top: 2rem;
}

.font-bold {
  font-weight: 600;
}
</style>
