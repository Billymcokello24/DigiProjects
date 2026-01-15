<script setup>
import { ref, onMounted } from 'vue'
import api from '@/api/axios'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import BaseInput from '@/components/ui/BaseInput.vue'
import BaseTable from '@/components/ui/BaseTable.vue'
import BaseModal from '@/components/ui/BaseModal.vue'

const projects = ref([])
const phases = ref([])
const isLoading = ref(false)
const showProjectModal = ref(false)
const showPhaseModal = ref(false)
const isEditMode = ref(false)
const errorMessage = ref('')
const successMessage = ref('')
const activeProjectForPhases = ref(null)

const projectFormData = ref({
  id: null,
  name: '',
  description: '',
  is_active: true,
})

const phaseFormData = ref({
  id: null,
  name: '',
  description: '',
  project_id: '',
  order: 1,
  is_active: true,
})

const projectColumns = ['Name', 'Description', 'Status', 'Phases', 'Actions']
const phaseColumns = ['Name', 'Project', 'Order', 'Status', 'Actions']

const fetchProjects = async () => {
  isLoading.value = true
  try {
    const response = await api.get('/projects')
    projects.value = response.data
  } catch (err) {
    errorMessage.value = 'Failed to load projects'
    console.error(err)
  } finally {
    isLoading.value = false
  }
}

const fetchPhases = async () => {
  try {
    const response = await api.get('/phases')
    phases.value = response.data
  } catch (err) {
    console.error('Failed to load phases:', err)
  }
}

const openAddProjectModal = () => {
  isEditMode.value = false
  projectFormData.value = {
    id: null,
    name: '',
    description: '',
    is_active: true,
  }
  errorMessage.value = ''
  showProjectModal.value = true
}

const openEditProjectModal = (project) => {
  isEditMode.value = true
  projectFormData.value = {
    id: project.id,
    name: project.name,
    description: project.description || '',
    is_active: project.is_active,
  }
  errorMessage.value = ''
  showProjectModal.value = true
}

const openAddPhaseModal = (project) => {
  activeProjectForPhases.value = project
  isEditMode.value = false
  phaseFormData.value = {
    id: null,
    name: '',
    description: '',
    project_id: project.id,
    order: 1,
    is_active: true,
  }
  errorMessage.value = ''
  showPhaseModal.value = true
}

const openEditPhaseModal = (phase) => {
  activeProjectForPhases.value = phase.project
  isEditMode.value = true
  phaseFormData.value = {
    id: phase.id,
    name: phase.name,
    description: phase.description || '',
    project_id: phase.project_id,
    order: phase.order,
    is_active: phase.is_active,
  }
  errorMessage.value = ''
  showPhaseModal.value = true
}

const saveProject = async () => {
  errorMessage.value = ''
  successMessage.value = ''

  if (!projectFormData.value.name) {
    errorMessage.value = 'Project name is required'
    return
  }

  try {
    const payload = {
      name: projectFormData.value.name,
      description: projectFormData.value.description,
      is_active: projectFormData.value.is_active,
    }

    if (isEditMode.value) {
      await api.put(`/projects/${projectFormData.value.id}`, payload)
      successMessage.value = 'Project updated successfully'
    } else {
      await api.post('/projects', payload)
      successMessage.value = 'Project added successfully'
    }

    showProjectModal.value = false
    await fetchProjects()
  } catch (err) {
    errorMessage.value = err.response?.data?.message || 'Failed to save project'
    console.error(err)
  }
}

const savePhase = async () => {
  errorMessage.value = ''
  successMessage.value = ''

  if (!phaseFormData.value.name) {
    errorMessage.value = 'Phase name is required'
    return
  }

  try {
    const payload = {
      name: phaseFormData.value.name,
      description: phaseFormData.value.description,
      project_id: phaseFormData.value.project_id,
      order: phaseFormData.value.order,
      is_active: phaseFormData.value.is_active,
    }

    if (isEditMode.value) {
      await api.put(`/phases/${phaseFormData.value.id}`, payload)
      successMessage.value = 'Phase updated successfully'
    } else {
      await api.post('/phases', payload)
      successMessage.value = 'Phase added successfully'
    }

    showPhaseModal.value = false
    await fetchPhases()
    await fetchProjects()
  } catch (err) {
    errorMessage.value = err.response?.data?.message || 'Failed to save phase'
    console.error(err)
  }
}

const deleteProject = async (id) => {
  if (!confirm('Are you sure? This will also delete all phases for this project.')) return

  try {
    await api.delete(`/projects/${id}`)
    successMessage.value = 'Project deleted successfully'
    await fetchProjects()
    await fetchPhases()
  } catch (err) {
    errorMessage.value = 'Failed to delete project'
  }
}

const deletePhase = async (id) => {
  if (!confirm('Are you sure you want to delete this phase?')) return

  try {
    await api.delete(`/phases/${id}`)
    successMessage.value = 'Phase deleted successfully'
    await fetchPhases()
    await fetchProjects()
  } catch (err) {
    errorMessage.value = 'Failed to delete phase'
  }
}

const getProjectName = (projectId) => {
  const project = projects.value.find(p => p.id === projectId)
  return project?.name || 'Unknown'
}

const getPhaseCount = (projectId) => {
  return phases.value.filter(p => p.project_id === projectId).length
}

onMounted(() => {
  fetchProjects()
  fetchPhases()
})
</script>

<template>
  <div class="projects-view">
    <!-- Success Message -->
    <div v-if="successMessage" class="alert alert-success">
      {{ successMessage }}
    </div>

    <!-- Error Message -->
    <div v-if="errorMessage" class="alert alert-error">
      {{ errorMessage }}
    </div>

    <!-- Projects Section -->
    <BaseCard>
      <template #header>
        <div class="header-actions">
          <h3>Projects & Phases</h3>
          <BaseButton variant="primary" size="sm" @click="openAddProjectModal">
            ➕ Add Project
          </BaseButton>
        </div>
      </template>

      <div v-if="isLoading" class="loading-state">
        Loading projects...
      </div>

      <div v-else-if="projects.length === 0" class="empty-state">
        <p>No projects found. Add one to get started.</p>
        <BaseButton variant="outline" @click="openAddProjectModal">Add First Project</BaseButton>
      </div>

      <BaseTable v-else :columns="projectColumns">
        <tr v-for="project in projects" :key="project.id">
          <td class="font-bold">{{ project.name }}</td>
          <td class="description">{{ project.description || '-' }}</td>
          <td>
            <span class="badge" :class="project.is_active ? 'badge-active' : 'badge-inactive'">
              {{ project.is_active ? 'ACTIVE' : 'INACTIVE' }}
            </span>
          </td>
          <td class="text-center">{{ getPhaseCount(project.id) }} phase(s)</td>
          <td class="action-buttons">
            <button class="action-btn edit-btn" @click="openEditProjectModal(project)">
              Edit
            </button>
            <button v-if="getPhaseCount(project.id) === 0" class="action-btn delete-btn" @click="deleteProject(project.id)">
              Delete
            </button>
            <button class="action-btn phase-btn" @click="openAddPhaseModal(project)">
              Add Phase
            </button>
          </td>
        </tr>
      </BaseTable>
    </BaseCard>

    <!-- Phases Section -->
    <BaseCard style="margin-top: 2rem;">
      <template #header>
        <h3>Project Phases</h3>
      </template>

      <div v-if="phases.length === 0" class="empty-state">
        <p>No phases found. Add phases to projects above.</p>
      </div>

      <BaseTable v-else :columns="phaseColumns">
        <tr v-for="phase in phases" :key="phase.id">
          <td class="font-bold">{{ phase.name }}</td>
          <td>{{ getProjectName(phase.project_id) }}</td>
          <td class="text-center">{{ phase.order }}</td>
          <td>
            <span class="badge" :class="phase.is_active ? 'badge-active' : 'badge-inactive'">
              {{ phase.is_active ? 'ACTIVE' : 'INACTIVE' }}
            </span>
          </td>
          <td class="action-buttons">
            <button class="action-btn edit-btn" @click="openEditPhaseModal(phase)">
              Edit
            </button>
            <button class="action-btn delete-btn" @click="deletePhase(phase.id)">
              Delete
            </button>
          </td>
        </tr>
      </BaseTable>
    </BaseCard>

    <!-- Project Modal -->
    <BaseModal :show="showProjectModal" :title="isEditMode ? 'Edit Project' : 'Add New Project'" @close="showProjectModal = false">
      <div class="form-group">
        <label>Project Name *</label>
        <BaseInput v-model="projectFormData.name" placeholder="Enter project name" />
      </div>

      <div class="form-group">
        <label>Description</label>
        <textarea v-model="projectFormData.description" class="form-textarea" placeholder="Enter project description"></textarea>
      </div>

      <div class="form-group">
        <label>
          <input v-model="projectFormData.is_active" type="checkbox" />
          Active
        </label>
      </div>

      <div v-if="errorMessage" class="alert alert-error">
        {{ errorMessage }}
      </div>

      <div class="modal-actions">
        <BaseButton variant="outline" @click="showProjectModal = false">Cancel</BaseButton>
        <BaseButton variant="primary" @click="saveProject">
          {{ isEditMode ? 'Update' : 'Add' }} Project
        </BaseButton>
      </div>
    </BaseModal>

    <!-- Phase Modal -->
    <BaseModal :show="showPhaseModal" :title="isEditMode ? 'Edit Phase' : 'Add New Phase'" @close="showPhaseModal = false">
      <div class="form-group">
        <label>Phase Name *</label>
        <BaseInput v-model="phaseFormData.name" placeholder="Enter phase name" />
      </div>

      <div class="form-group">
        <label>Description</label>
        <textarea v-model="phaseFormData.description" class="form-textarea" placeholder="Enter phase description"></textarea>
      </div>

      <div class="form-group">
        <label>Project</label>
        <input type="text" class="form-input" :value="getProjectName(phaseFormData.project_id)" disabled />
      </div>

      <div class="form-group">
        <label>Order</label>
        <BaseInput v-model.number="phaseFormData.order" type="number" placeholder="Enter phase order" min="1" />
      </div>

      <div class="form-group">
        <label>
          <input v-model="phaseFormData.is_active" type="checkbox" />
          Active
        </label>
      </div>

      <div v-if="errorMessage" class="alert alert-error">
        {{ errorMessage }}
      </div>

      <div class="modal-actions">
        <BaseButton variant="outline" @click="showPhaseModal = false">Cancel</BaseButton>
        <BaseButton variant="primary" @click="savePhase">
          {{ isEditMode ? 'Update' : 'Add' }} Phase
        </BaseButton>
      </div>
    </BaseModal>
  </div>
</template>

<style scoped>
.projects-view {
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

.description {
  max-width: 200px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 0.875rem;
  color: #6b7280;
}

.text-center {
  text-align: center;
}

.badge {
  display: inline-block;
  padding: 0.25rem 0.75rem;
  border-radius: 9999px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
}

.badge-active {
  background-color: #dcfce7;
  color: #166534;
}

.badge-inactive {
  background-color: #fee2e2;
  color: #991b1b;
}

.action-buttons {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.action-btn {
  padding: 0.4rem 0.8rem;
  border: none;
  border-radius: 0.4rem;
  cursor: pointer;
  font-size: 0.875rem;
  transition: all 0.2s;
  white-space: nowrap;
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

.phase-btn {
  background-color: #10b981;
  color: white;
}

.phase-btn:hover {
  background-color: #059669;
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

.form-group input[type="checkbox"] {
  margin-right: 0.5rem;
}

.form-textarea {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 0.375rem;
  font-size: 1rem;
  font-family: inherit;
  resize: vertical;
  min-height: 80px;
}

.form-textarea:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
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

.form-input:disabled {
  background-color: #f3f4f6;
  cursor: not-allowed;
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
