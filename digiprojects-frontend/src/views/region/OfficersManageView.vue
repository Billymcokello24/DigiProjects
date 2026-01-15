<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import api from '@/api/axios'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import BaseInput from '@/components/ui/BaseInput.vue'
import BaseTable from '@/components/ui/BaseTable.vue'
import BaseModal from '@/components/ui/BaseModal.vue'

const authStore = useAuthStore()
const user = computed(() => authStore.user)

const officers = ref([])
const counties = ref([])
const isLoading = ref(false)
const showModal = ref(false)
const isEditMode = ref(false)
const errorMessage = ref('')
const successMessage = ref('')
const isSubmitting = ref(false)

const formData = ref({
  id: null,
  name: '',
  email: '',
  password: '',
  county_id: '',
})

const columns = ['Name', 'Email', 'County', 'Actions']

const fetchOfficers = async () => {
  isLoading.value = true
  try {
    const response = await api.get('/users')
    officers.value = response.data
  } catch (err) {
    errorMessage.value = 'Failed to load county officers'
    console.error(err)
  } finally {
    isLoading.value = false
  }
}

const fetchCounties = async () => {
  try {
    const response = await api.get('/counties')
    counties.value = response.data
  } catch (err) {
    console.error('Failed to load counties:', err)
  }
}

const openAddModal = () => {
  isEditMode.value = false
  formData.value = {
    id: null,
    name: '',
    email: '',
    password: '',
    county_id: '',
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
    county_id: officer.county_id || '',
  }
  errorMessage.value = ''
  showModal.value = true
}

const saveOfficer = async () => {
  errorMessage.value = ''
  successMessage.value = ''

  if (!formData.value.name || !formData.value.email || !formData.value.county_id) {
    errorMessage.value = 'Name, email, and county are required'
    return
  }

  if (!isEditMode.value && !formData.value.password) {
    errorMessage.value = 'Password is required for new officers'
    return
  }

  isSubmitting.value = true
  try {
    const payload = {
      name: formData.value.name,
      email: formData.value.email,
      county_id: formData.value.county_id,
    }

    if (formData.value.password) {
      payload.password = formData.value.password
    }

    if (isEditMode.value) {
      await api.put(`/users/${formData.value.id}`, payload)
      successMessage.value = 'County officer updated successfully'
    } else {
      await api.post('/users', payload)
      successMessage.value = 'County officer added successfully'
    }

    showModal.value = false
    await fetchOfficers()
  } catch (err) {
    errorMessage.value = err.response?.data?.message || 'Failed to save county officer'
    console.error(err)
  } finally {
    isSubmitting.value = false
  }
}

const deleteOfficer = async (id) => {
  if (!confirm('Are you sure you want to delete this county officer?')) return

  try {
    await api.delete(`/users/${id}`)
    successMessage.value = 'County officer deleted successfully'
    await fetchOfficers()
  } catch (err) {
    errorMessage.value = 'Failed to delete county officer'
    console.error(err)
  }
}

const getCountyName = (countyId) => {
  const county = counties.value.find(c => c.id === countyId)
  return county?.name || 'N/A'
}

onMounted(() => {
  fetchOfficers()
  fetchCounties()
})
</script>

<template>
  <div class="officers-manage-view">
    <!-- Success Message -->
    <div v-if="successMessage" class="alert alert-success">
      {{ successMessage }}
    </div>

    <!-- Error Message (Global) -->
    <div v-if="errorMessage && !showModal" class="alert alert-error">
      {{ errorMessage }}
    </div>

    <BaseCard>
      <template #header>
        <div class="header-actions">
          <h3>Manage County Officers - {{ user?.region }} Region</h3>
          <BaseButton variant="primary" size="sm" @click="openAddModal">
            ➕ Add County Officer
          </BaseButton>
        </div>
      </template>

      <div v-if="isLoading" class="loading-state">
        Loading county officers...
      </div>

      <div v-else-if="officers.length === 0" class="empty-state">
        <p>No county officers found. Add one to get started.</p>
        <BaseButton variant="outline" @click="openAddModal">Add First County Officer</BaseButton>
      </div>

      <BaseTable v-else :columns="columns">
        <tr v-for="officer in officers" :key="officer.id">
          <td class="font-bold">{{ officer.name }}</td>
          <td>{{ officer.email }}</td>
          <td>{{ getCountyName(officer.county_id) }}</td>
          <td class="action-buttons">
            <button class="action-btn edit-btn" @click="openEditModal(officer)" title="Edit">
              ✎ Edit
            </button>
            <button class="action-btn delete-btn" @click="deleteOfficer(officer.id)" title="Delete">
              🗑 Delete
            </button>
          </td>
        </tr>
      </BaseTable>
    </BaseCard>

    <!-- Add/Edit Modal -->
    <BaseModal :show="showModal" :title="isEditMode ? 'Edit County Officer' : 'Add New County Officer'" @close="showModal = false">
      <div v-if="errorMessage" class="alert alert-error" style="margin-bottom: 1rem;">
        {{ errorMessage }}
      </div>

      <div class="form-group">
        <label>Officer Name *</label>
        <BaseInput v-model="formData.name" placeholder="Enter officer name" />
      </div>

      <div class="form-group">
        <label>Email *</label>
        <BaseInput v-model="formData.email" type="email" placeholder="Enter email" />
      </div>

      <div class="form-group">
        <label>County *</label>
        <select v-model="formData.county_id" class="form-select">
          <option value="">Select a county</option>
          <option v-for="county in counties" :key="county.id" :value="county.id">
            {{ county.name }}
          </option>
        </select>
      </div>

      <div class="form-group">
        <label>{{ isEditMode ? 'New Password (leave empty to keep current)' : 'Password' }} *</label>
        <BaseInput 
          v-model="formData.password" 
          type="password" 
          :placeholder="isEditMode ? 'Leave empty to keep current password' : 'Enter password'"
        />
      </div>

      <div class="modal-actions">
        <BaseButton variant="outline" @click="showModal = false" :disabled="isSubmitting">Cancel</BaseButton>
        <BaseButton variant="primary" @click="saveOfficer" :disabled="isSubmitting">
          {{ isSubmitting ? 'Saving...' : (isEditMode ? 'Update' : 'Add') }} County Officer
        </BaseButton>
      </div>
    </BaseModal>
  </div>
</template>

<style scoped>
.header-actions {
  display: flex;
  justify-content: space-between;
  width: 100%;
  align-items: center;
}

.font-bold { font-weight: 600; }

.alert {
  padding: 1rem;
  border-radius: 0.5rem;
  margin-bottom: 1rem;
  border-left: 4px solid;
}

.alert-success {
  background-color: #dcfce7;
  color: #166534;
  border-left-color: #86efac;
}

.alert-error {
  background-color: #fee2e2;
  color: #991b1b;
  border-left-color: #fca5a5;
}

.loading-state {
  padding: 2rem;
  text-align: center;
  color: #666;
}

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
  border: 1px solid #d1d5db;
  border-radius: 0.4rem;
  cursor: pointer;
  font-size: 0.875rem;
  transition: all 0.2s;
  background: white;
}

.action-btn:hover {
  background: #f3f4f6;
}

.edit-btn {
  color: #3b82f6;
}

.edit-btn:hover {
  border-color: #3b82f6;
  background: #dbeafe;
}

.delete-btn {
  color: #ef4444;
}

.delete-btn:hover {
  border-color: #ef4444;
  background: #fee2e2;
}

.form-group {
  margin-bottom: 1rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #374151;
  font-size: 0.875rem;
}

.form-select {
  width: 100%;
  padding: 0.5rem;
  border: 1px solid #d1d5db;
  border-radius: 0.375rem;
  font-size: 0.875rem;
  background: white;
}

.form-select:focus {
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

@media (max-width: 768px) {
  .header-actions {
    flex-direction: column;
    gap: 1rem;
    align-items: flex-start;
  }

  .action-buttons {
    flex-direction: column;
  }
}
</style>
