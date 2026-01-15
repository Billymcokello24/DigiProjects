<script setup>
import { ref, onMounted } from 'vue'
import api from '@/api/axios'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import BaseInput from '@/components/ui/BaseInput.vue'
import BaseTable from '@/components/ui/BaseTable.vue'
import BaseModal from '@/components/ui/BaseModal.vue'
import StatusBadge from '@/components/ui/StatusBadge.vue'

const officers = ref([])
const regions = ref([])
const isLoading = ref(false)
const showModal = ref(false)
const isEditMode = ref(false)
const errorMessage = ref('')
const successMessage = ref('')

const formData = ref({
  id: null,
  name: '',
  email: '',
  password: '',
  region_id: '',
})

const columns = ['Name', 'Email', 'Region', 'Actions']

const fetchOfficers = async () => {
  isLoading.value = true
  try {
    const response = await api.get('/regional-officers')
    officers.value = response.data
  } catch (err) {
    errorMessage.value = 'Failed to load regional officers'
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
    email: '',
    password: '',
    region_id: '',
  }
  errorMessage.value = ''
  showModal.value = true
}

const openEditModal = (officer) => {
  isEditMode.value = true
  formData.value = {
    id: officer.id,
    name: officer.name,
    email: officer.email,
    password: '',
    region_id: officer.region_id || '',
  }
  errorMessage.value = ''
  showModal.value = true
}

const saveOfficer = async () => {
  errorMessage.value = ''
  successMessage.value = ''

  if (!formData.value.name || !formData.value.email || !formData.value.region_id) {
    errorMessage.value = 'Name, email, and region are required'
    return
  }

  if (!isEditMode.value && !formData.value.password) {
    errorMessage.value = 'Password is required for new officers'
    return
  }

  try {
    const payload = {
      name: formData.value.name,
      email: formData.value.email,
      region_id: formData.value.region_id,
    }

    if (formData.value.password) {
      payload.password = formData.value.password
    }

    if (isEditMode.value) {
      await api.put(`/regional-officers/${formData.value.id}`, payload)
      successMessage.value = 'Regional officer updated successfully'
    } else {
      await api.post('/regional-officers', payload)
      successMessage.value = 'Regional officer added successfully'
    }

    showModal.value = false
    await fetchOfficers()
  } catch (err) {
    errorMessage.value = err.response?.data?.message || 'Failed to save regional officer'
    console.error(err)
  }
}

const deleteOfficer = async (id) => {
  if (!confirm('Are you sure you want to delete this regional officer?')) return

  try {
    await api.delete(`/regional-officers/${id}`)
    successMessage.value = 'Regional officer deleted successfully'
    await fetchOfficers()
  } catch (err) {
    errorMessage.value = 'Failed to delete regional officer'
    console.error(err)
  }
}

const getRegionName = (regionId) => {
  const region = regions.value.find(r => r.id === regionId)
  return region?.name || 'N/A'
}

onMounted(() => {
  fetchOfficers()
  fetchRegions()
})
</script>

<template>
  <div class="regional-officers-view">
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
          <h3>Regional Officers</h3>
          <BaseButton variant="primary" size="sm" @click="openAddModal">
            ➕ Add Regional Officer
          </BaseButton>
        </div>
      </template>

      <div v-if="isLoading" class="loading-state">
        Loading regional officers...
      </div>

      <div v-else-if="officers.length === 0" class="empty-state">
        <p>No regional officers found. Add one to get started.</p>
        <BaseButton variant="outline" @click="openAddModal">Add First Regional Officer</BaseButton>
      </div>

      <BaseTable v-else :columns="columns">
        <tr v-for="officer in officers" :key="officer.id">
          <td class="font-bold">{{ officer.name }}</td>
          <td>{{ officer.email }}</td>
          <td>{{ getRegionName(officer.region_id) }}</td>
          <td class="action-buttons">
            <button class="action-btn edit-btn" @click="openEditModal(officer)">
              Edit
            </button>
            <button class="action-btn delete-btn" @click="deleteOfficer(officer.id)">
              Delete
            </button>
          </td>
        </tr>
      </BaseTable>
    </BaseCard>

    <!-- Add/Edit Modal -->
    <BaseModal :show="showModal" :title="isEditMode ? 'Edit Regional Officer' : 'Add New Regional Officer'" @close="showModal = false">
      <div class="form-group">
        <label>Officer Name *</label>
        <BaseInput v-model="formData.name" placeholder="Enter officer name" />
      </div>

      <div class="form-group">
        <label>Email *</label>
        <BaseInput v-model="formData.email" type="email" placeholder="Enter email" />
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
        <label>{{ isEditMode ? 'New Password (leave empty to keep current)' : 'Password *' }}</label>
        <BaseInput 
          v-model="formData.password" 
          type="password" 
          placeholder="Enter password"
        />
      </div>

      <div v-if="errorMessage" class="alert alert-error">
        {{ errorMessage }}
      </div>

      <div class="modal-actions">
        <BaseButton variant="outline" @click="showModal = false">Cancel</BaseButton>
        <BaseButton variant="primary" @click="saveOfficer">
          {{ isEditMode ? 'Update' : 'Add' }} Regional Officer
        </BaseButton>
      </div>
    </BaseModal>
  </div>
</template>

<style scoped>
.regional-officers-view {
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

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
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
  color: #374151;
}

.form-input {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 0.375rem;
  font-size: 1rem;
}

.form-input:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.modal-actions {
  display: flex;
  gap: 1rem;
  margin-top: 2rem;
  justify-content: flex-end;
}

.font-bold {
  font-weight: 600;
}
</style>
