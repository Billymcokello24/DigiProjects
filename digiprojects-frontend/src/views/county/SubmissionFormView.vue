<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import api from '@/api/axios'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import BaseInput from '@/components/ui/BaseInput.vue'

const router = useRouter()
const route = useRoute()

const isEditMode = computed(() => !!route.params.id)

const form = ref({
  project_id: '',
  phase_id: '',
  site: '',
  status: 'UP',
  remarks: ''
})

const projects = ref([])
const phases = ref([])
const filteredPhases = ref([])
const isSubmitting = ref(false)
const isLoading = ref(false)
const errorMessage = ref('')

const fetchProjects = async () => {
  try {
    const response = await api.get('/projects')
    projects.value = response.data.filter(p => p.is_active)
  } catch (err) {
    console.error('Failed to load projects:', err)
  }
}

const fetchAllPhases = async () => {
  try {
    const response = await api.get('/phases')
    phases.value = response.data.filter(p => p.is_active)
  } catch (err) {
    console.error('Failed to load phases:', err)
  }
}

const updatePhaseOptions = () => {
  if (form.value.project_id) {
    filteredPhases.value = phases.value.filter(p => p.project_id == form.value.project_id)
    form.value.phase_id = ''
  } else {
    filteredPhases.value = []
    form.value.phase_id = ''
  }
}

const fetchSubmission = async () => {
    if (!isEditMode.value) return
    
    isLoading.value = true
    try {
        const response = await api.get(`/submissions/${route.params.id}`)
        const data = response.data
        form.value = {
            project_id: data.project_id || '',
            phase_id: data.phase_id || '',
            site: data.site || '',
            status: data.status || 'UP',
            remarks: data.remarks || ''
        }
        if (form.value.project_id) {
          updatePhaseOptions()
        }
    } catch (err) {
        console.error('Failed to fetch submission:', err)
        errorMessage.value = 'Could not load submission data.'
        setTimeout(() => router.push('/county/submissions'), 2000)
    } finally {
        isLoading.value = false
    }
}

onMounted(() => {
    fetchProjects()
    fetchAllPhases()
    fetchSubmission()
})

const saveDraft = () => {
    alert('Progress saved as draft.')
}

const submitReport = async () => {
  if (!form.value.project_id || !form.value.phase_id || !form.value.site) {
    errorMessage.value = 'Please fill in all required fields (Project, Phase, Site).'
    return
  }

  errorMessage.value = ''
  isSubmitting.value = true
  try {
    const project = projects.value.find(p => p.id == form.value.project_id)
    const phase = phases.value.find(p => p.id == form.value.phase_id)
    
    const submissionData = {
      project_id: parseInt(form.value.project_id),
      phase_id: parseInt(form.value.phase_id),
      project_type: project?.name || '',
      phase: phase?.name || '',
      site: form.value.site,
      status: form.value.status,
      remarks: form.value.remarks
    }

    if (isEditMode.value) {
        await api.put(`/submissions/${route.params.id}`, submissionData)
        alert('Report Updated Successfully!')
    } else {
        await api.post('/submissions', submissionData)
        alert('Report Submitted Successfully!')
    }
    
    router.push('/county/submissions')
  } catch (err) {
    console.error('Operation failed:', err)
    errorMessage.value = err.response?.data?.message || 'An error occurred. Please try again.'
  } finally {
    isSubmitting.value = false
  }
}
</script>

<template>
  <div class="submission-form-view">
    <BaseCard title="New Project Submission" class="form-card">
      <div v-if="errorMessage" class="alert alert-error">
        {{ errorMessage }}
      </div>

      <div v-if="isLoading" class="loading-state">
        Loading submission data...
      </div>

      <form v-else @submit.prevent="submitReport" class="report-form">
        <div class="form-grid">
           <!-- Project Dropdown -->
           <div class="form-group">
             <label class="form-label">Project *</label>
             <select v-model="form.project_id" class="base-select" @change="updatePhaseOptions" required>
               <option value="" disabled>Select a project</option>
               <option v-for="project in projects" :key="project.id" :value="project.id">
                 {{ project.name }}
               </option>
             </select>
           </div>

           <!-- Phase Dropdown (cascading) -->
           <div class="form-group">
             <label class="form-label">Phase *</label>
             <select v-model="form.phase_id" class="base-select" :disabled="!form.project_id" required>
               <option value="" disabled>{{ form.project_id ? 'Select a phase' : 'Select project first' }}</option>
               <option v-for="phase in filteredPhases" :key="phase.id" :value="phase.id">
                 {{ phase.name }}
               </option>
             </select>
           </div>

           <BaseInput 
             id="site"
             v-model="form.site"
             label="Site *"
             placeholder="e.g. Siaya CC, Huduma Center, etc."
             required
           />
           
           <div class="form-group">
             <label class="form-label">Status *</label>
             <select v-model="form.status" class="base-select" required>
               <option>UP</option>
               <option>DOWN</option>
               <option>Ongoing</option>
               <option>No Services</option>
               <option>Pending</option>
             </select>
           </div>
        </div>

        <div class="form-group full-width">
          <label class="form-label">Issue / Remarks</label>
          <textarea 
            v-model="form.remarks"
            class="base-textarea" 
            rows="5" 
            placeholder="e.g. Stable, Faulty switch, Power outage, etc."
          ></textarea>
        </div>

        <div class="form-actions">
           <BaseButton variant="ghost" type="button" @click="$router.push('/county/submissions')">Cancel</BaseButton>
           <BaseButton variant="secondary" type="button" @click="saveDraft">Save Draft</BaseButton>
           <BaseButton variant="primary" :disabled="isSubmitting || !form.project_id || !form.phase_id || !form.site">
             {{ isSubmitting ? 'Submitting...' : 'Submit Report' }}
           </BaseButton>
        </div>
      </form>
    </BaseCard>
  </div>
</template>

<style scoped>
.submission-form-view {
  max-width: 800px;
  margin: 0 auto;
}

.loading-state {
  text-align: center;
  padding: 2rem;
  color: #666;
}

.alert {
  padding: 1rem;
  border-radius: 0.5rem;
  margin-bottom: 1rem;
}

.alert-error {
  background-color: #fee2e2;
  color: #991b1b;
  border: 1px solid #fca5a5;
}

.report-form {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.form-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1.5rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
}

.full-width {
  grid-column: 1 / -1;
}

.form-label {
  font-size: 0.875rem;
  font-weight: 500;
  color: var(--color-text);
}

.form-card {
  border-bottom: 4px solid var(--color-accent);
}

.base-select, .base-textarea {
  width: 100%;
  padding: 0.625rem 0.875rem;
  font-size: 0.95rem;
  color: var(--color-text);
  background: white;
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  font-family: inherit;
  transition: border-color 0.2s, box-shadow 0.2s;
}

.base-select:focus, .base-textarea:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px rgba(0, 0, 0, 0.1);
}

.base-select:disabled {
  background-color: #f3f4f6;
  cursor: not-allowed;
  opacity: 0.6;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid var(--color-border);
}
</style>
