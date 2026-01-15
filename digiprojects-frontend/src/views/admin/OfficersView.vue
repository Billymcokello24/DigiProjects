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
const counties = ref([])
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
  county_id: '',
})

const columns = ['Name', 'Email', 'County', 'Role', 'Actions']

const fetchOfficers = async () => {
  isLoading.value = true
  try {
    const response = await api.get('/users')
    officers.value = response.data
  } catch (err) {
    errorMessage.value = 'Failed to load officers'
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
      successMessage.value = 'Officer updated successfully'
    } else {
      await api.post('/users', payload)
      successMessage.value = 'Officer added successfully'
    }

    showModal.value = false
    await fetchOfficers()
  } catch (err) {
    errorMessage.value = err.response?.data?.message || 'Failed to save officer'
  }
}

const deleteOfficer = async (id) => {
  if (!confirm('Are you sure you want to delete this officer?')) return

  try {
    await api.delete(`/users/${id}`)
    successMessage.value = 'Officer deleted successfully'
    await fetchOfficers()
  } catch (err) {
    errorMessage.value = 'Failed to delete officer'
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
  <div class="officers-view">
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
          <h3>County Officers</h3>
          <BaseButton variant="primary" size="sm" @click="openAddModal">
            ➕ Add Officer
          </BaseButton>
        </div>
      </template>

      <div v-if="isLoading" class="loading-state">
        Loading officers...
      </div>

      <div v-else-if="officers.length === 0" class="empty-state">
        <p>No county officers found. Add one to get started.</p>
        <BaseButton variant="outline" @click="openAddModal">Add First Officer</BaseButton>
      </div>

      <BaseTable v-else :columns="columns">
        <tr v-for="officer in officers" :key="officer.id">
          <td class="font-bold">{{ officer.name }}</td>
          <td>{{ officer.email }}</td>
          <td>{{ getCountyName(officer.county_id) }}</td>
          <td>
            <StatusBadge :status="officer.role === 'ADMIN' ? 'danger' : 'success'">
              {{ officer.role }}
            </StatusBadge>
          </td>
          <td class="action-buttons">
            <button 
              v-if="officer.role !== 'ADMIN'"
              class="action-btn edit-btn"
              @click="openEditModal(officer)"
            >
              Edit
            </button>
            <button 
              v-if="officer.role !== 'ADMIN'"
              class="action-btn delete-btn"
              @click="deleteOfficer(officer.id)"
            >
              Delete
            </button>
            <span v-if="officer.role === 'ADMIN'" class="text-gray-500">Admin</span>
          </td>
        </tr>
      </BaseTable>
    </BaseCard>

    <!-- Add/Edit Modal -->
    <BaseModal :show="showModal" :title="isEditMode ? 'Edit Officer' : 'Add New Officer'" @close="showModal = false">
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
        <select v-model="formData.county_id" class="form-input">
          <option value="">-- Select County --</option>
          <option v-for="county in counties" :key="county.id" :value="county.id">
            {{ county.name }}
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
          {{ isEditMode ? 'Update' : 'Add' }} Officer
        </BaseButton>
      </div>
    </BaseModal>
  </div>
</template>

<style scoped>
.officers-view {
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

.modal-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
  margin-top: 2rem;
}

.text-gray-500 {
  color: #6b7280;
}

.font-bold {
  font-weight: 600;
}
</style>
