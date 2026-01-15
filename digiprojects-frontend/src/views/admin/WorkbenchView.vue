<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import api from '@/api/axios'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import BaseModal from '@/components/ui/BaseModal.vue'
import StatusBadge from '@/components/ui/StatusBadge.vue'

// State
const submissions = ref([])
const regions = ref([])
const counties = ref([])
const isLoading = ref(false)
const isSubmitting = ref(false)

// Filters
const filters = ref({
  search: '',
  region_id: '',
  county_id: '',
  project_type: '',
  status: 'pending' // Default to pending
})

// Modal / Review
const selectedSubmission = ref(null)
const isReviewModalOpen = ref(false)
const adminFeedback = ref('')

// Fetching
const fetchRegions = async () => {
  try {
    const res = await api.get('/regions')
    regions.value = res.data
  } catch (err) { console.error('Failed to fetch regions') }
}

const fetchCounties = async () => {
  try {
    const params = filters.value.region_id ? { region_id: filters.value.region_id } : {}
    const res = await api.get('/counties', { params })
    counties.value = res.data
  } catch (err) { console.error('Failed to fetch counties') }
}

const fetchSubmissions = async () => {
  isLoading.value = true
  try {
    // In a real app, filters would be passed to the backend
    const res = await api.get('/submissions')
    submissions.value = res.data
  } catch (err) {
    console.error('Failed to fetch submissions')
  } finally {
    isLoading.value = false
  }
}

// Watch filters
watch(() => filters.value.region_id, () => {
  filters.value.county_id = ''
  fetchCounties()
})

// Computed Submissions (Frontend filtering for now)
const filteredSubmissions = computed(() => {
  return submissions.value.filter(s => {
    const matchesSearch = s.site.toLowerCase().includes(filters.value.search.toLowerCase()) ||
                        s.project_type.toLowerCase().includes(filters.value.search.toLowerCase())
    const matchesStatus = filters.value.status ? s.approval_status === filters.value.status : true
    const matchesRegion = filters.value.region_id ? s.user?.county?.region_id == filters.value.region_id : true
    const matchesCounty = filters.value.county_id ? s.user?.county_id == filters.value.county_id : true
    
    return matchesSearch && matchesStatus && matchesRegion && matchesCounty
  })
})

// Actions
const openReview = (submission) => {
  selectedSubmission.value = submission
  adminFeedback.value = submission.admin_feedback || ''
  isReviewModalOpen.value = true
}

const handleApprove = async () => {
  if (!selectedSubmission.value) return
  isSubmitting.value = true
  try {
    await api.post(`/submissions/${selectedSubmission.value.id}/approve`)
    await fetchSubmissions()
    isReviewModalOpen.value = false
  } catch (err) {
    alert('Failed to approve submission')
  } finally {
    isSubmitting.value = false
  }
}

const handleReject = async () => {
  if (!selectedSubmission.value || !adminFeedback.value) {
    alert('Please provide feedback for rejection')
    return
  }
  isSubmitting.value = true
  try {
    await api.post(`/submissions/${selectedSubmission.value.id}/reject`, {
      admin_feedback: adminFeedback.value
    })
    await fetchSubmissions()
    isReviewModalOpen.value = false
  } catch (err) {
    alert('Failed to reject submission')
  } finally {
    isSubmitting.value = false
  }
}

onMounted(() => {
  fetchRegions()
  fetchCounties()
  fetchSubmissions()
})
</script>

<template>
  <div class="workbench">
    <div class="workbench-header">
      <h1 class="page-title">Approval Workbench</h1>
      <p class="page-subtitle">Centralized queue for cross-county project validation</p>
    </div>

    <!-- Filters Section -->
    <BaseCard class="mb-6">
      <div class="filters-grid">
        <div class="filter-item">
          <label>Search Site</label>
          <input v-model="filters.search" type="text" placeholder="Site name..." class="form-input" />
        </div>
        <div class="filter-item">
          <label>Region</label>
          <select v-model="filters.region_id" class="form-select">
            <option value="">All Regions</option>
            <option v-for="r in regions" :key="r.id" :value="r.id">{{ r.name }}</option>
          </select>
        </div>
        <div class="filter-item">
          <label>County</label>
          <select v-model="filters.county_id" class="form-select">
            <option value="">All Counties</option>
            <option v-for="c in counties" :key="c.id" :value="c.id">{{ c.name }}</option>
          </select>
        </div>
        <div class="filter-item">
          <label>Status</label>
          <select v-model="filters.status" class="form-select">
            <option value="">All Status</option>
            <option value="pending">Pending Review</option>
            <option value="approved">Approved</option>
            <option value="rejected">Rejected</option>
          </select>
        </div>
      </div>
    </BaseCard>

    <!-- Queue Section -->
    <BaseCard title="Submission Queue">
      <div v-if="isLoading" class="loading-overlay">
        <div class="spinner"></div>
        <span>Syncing National Queue...</span>
      </div>

      <div class="table-container">
        <table class="data-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Site/Institution</th>
              <th>Project Type</th>
              <th>Origin</th>
              <th>Submitted</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="sub in filteredSubmissions" :key="sub.id">
              <td>#{{ sub.id }}</td>
              <td>
                <div class="site-cell">
                  <strong>{{ sub.site }}</strong>
                  <span class="sub-text">{{ sub.phase }}</span>
                </div>
              </td>
              <td>{{ sub.project_type }}</td>
              <td>
                <div class="origin-cell">
                  <span>{{ sub.user?.name }}</span>
                  <small>{{ sub.user?.county?.name || 'Loading...' }}</small>
                </div>
              </td>
              <td>{{ new Date(sub.created_at).toLocaleDateString() }}</td>
              <td>
                <StatusBadge :status="sub.approval_status === 'approved' ? 'success' : sub.approval_status === 'rejected' ? 'danger' : 'warning'">
                  {{ sub.approval_status }}
                </StatusBadge>
              </td>
              <td>
                <BaseButton variant="primary" size="sm" @click="openReview(sub)">
                  Review
                </BaseButton>
              </td>
            </tr>
            <tr v-if="filteredSubmissions.length === 0 && !isLoading">
              <td colspan="7" class="empty-row text-center">No submissions found matching criteria</td>
            </tr>
          </tbody>
        </table>
      </div>
    </BaseCard>

    <!-- Review Modal -->
    <BaseModal v-if="isReviewModalOpen" @close="isReviewModalOpen = false" title="Submission Review Interface">
      <div class="review-layout" v-if="selectedSubmission">
        <div class="review-header mb-6">
          <div class="badge-row mb-2">
            <StatusBadge :status="selectedSubmission.status === 'UP' ? 'success' : 'danger'">
              Live Status: {{ selectedSubmission.status }}
            </StatusBadge>
            <span class="submission-meta">Submitted by {{ selectedSubmission.user?.name }} on {{ new Date(selectedSubmission.created_at).toLocaleString() }}</span>
          </div>
          <h3>{{ selectedSubmission.site }} - {{ selectedSubmission.project_type }}</h3>
        </div>

        <div class="comparison-grid">
          <!-- Current Submission -->
          <div class="detail-section">
            <label class="section-label">Submission Details</label>
            <div class="detail-content">
              <div class="detail-row"><span>Phase:</span> <strong>{{ selectedSubmission.phase }}</strong></div>
              <div class="detail-row"><span>Current Status:</span> <strong>{{ selectedSubmission.status }}</strong></div>
              <div class="detail-row"><span>Remarks:</span> <p>{{ selectedSubmission.remarks || 'No remarks provided' }}</p></div>
            </div>
          </div>

          <!-- Historical/Trend Context (Static for Demo) -->
          <div class="context-section">
            <label class="section-label">System Context/Trend</label>
            <div class="trend-card">
              <div class="trend-stat">
                <span class="stat-label">Previous 3 Months</span>
                <span class="stat-val text-success">Stable (UP)</span>
              </div>
              <div class="trend-stat">
                <span class="stat-label">Last Maintenance</span>
                <span class="stat-val">Oct 2025</span>
              </div>
              <p class="trend-note text-sm">Consistent reporting from this site for the last 4 periods.</p>
            </div>
          </div>
        </div>

        <!-- Feedback & Actions -->
        <div class="action-section mt-8">
          <label>Admin Feedback / Resolution Notes</label>
          <textarea v-model="adminFeedback" class="form-textarea" placeholder="Explain your decision to the county officer..."></textarea>
          
          <div class="modal-footer mt-4">
            <BaseButton variant="outline" @click="isReviewModalOpen = false">Close</BaseButton>
            <div class="btn-group">
              <BaseButton variant="danger" :disabled="isSubmitting" @click="handleReject">Reject Submission</BaseButton>
              <BaseButton variant="success" :disabled="isSubmitting" @click="handleApprove">Approve & Publish</BaseButton>
            </div>
          </div>
        </div>
      </div>
    </BaseModal>
  </div>
</template>

<style scoped>
.workbench {
  animation: fadeIn 0.5s ease-out;
}

.workbench-header {
  margin-bottom: 2rem;
}

.page-title {
  font-size: 1.875rem;
  font-weight: 800;
  color: #111827;
}

.page-subtitle {
  color: #6b7280;
}

.filters-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
}

.filter-item label {
  display: block;
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
  color: #4b5563;
  margin-bottom: 0.5rem;
}

.form-input, .form-select {
  width: 100%;
  padding: 0.625rem 0.75rem;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  font-size: 0.875rem;
  transition: border-color 0.2s;
}

.form-input:focus, .form-select:focus {
  outline: none;
  border-color: #006600;
  box-shadow: 0 0 0 3px rgba(0, 102, 0, 0.1);
}

.table-container {
  overflow-x: auto;
}

.data-table {
  width: 100%;
  border-collapse: collapse;
}

.data-table th {
  text-align: left;
  padding: 1rem;
  font-size: 0.75rem;
  text-transform: uppercase;
  color: #64748b;
  border-bottom: 1px solid #e2e8f0;
}

.data-table td {
  padding: 1rem;
  font-size: 0.875rem;
  color: #1e293b;
  border-bottom: 1px solid #f1f5f9;
}

.site-cell strong { display: block; }
.site-cell span { font-size: 0.75rem; color: #64748b; }

.origin-cell span { display: block; font-weight: 600; }
.origin-cell small { display: block; font-size: 0.75rem; color: #64748b; }

.empty-row { padding: 3rem; color: #94a3b8; }

/* Modal Content */
.review-layout {
  min-width: 600px;
}

.comparison-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2rem;
}

.section-label {
  display: block;
  font-size: 0.75rem;
  font-weight: 800;
  text-transform: uppercase;
  color: #006600;
  margin-bottom: 1rem;
  border-bottom: 2px solid #006600;
  padding-bottom: 0.25rem;
}

.detail-row {
  display: flex;
  margin-bottom: 0.75rem;
  gap: 1rem;
}

.detail-row span {
  width: 120px;
  color: #64748b;
  font-size: 0.8125rem;
}

.trend-card {
  background: #f8fafc;
  padding: 1.25rem;
  border-radius: 10px;
  border: 1px solid #e2e8f0;
}

.trend-stat {
  display: flex;
  justify-content: space-between;
  margin-bottom: 0.75rem;
  border-bottom: 1px dashed #e2e8f0;
  padding-bottom: 0.5rem;
}

.trend-note { margin-top: 1rem; color: #64748b; font-style: italic; }

.form-textarea {
  width: 100%;
  height: 120px;
  padding: 0.75rem;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  margin-top: 0.5rem;
  font-family: inherit;
}

.btn-group {
  display: flex;
  gap: 1rem;
}

.modal-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-top: 1px solid #e2e8f0;
  padding-top: 1.5rem;
}

.text-success { color: #10b981; }
.mb-6 { margin-bottom: 1.5rem; }
.mt-8 { margin-top: 2rem; }
.mt-4 { margin-top: 1rem; }

.loading-overlay {
  padding: 3rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
  color: #64748b;
}

@keyframes spin { to { transform: rotate(360deg); } }
.spinner {
  width: 32px;
  height: 32px;
  border: 3px solid #f1f5f9;
  border-top-color: #006600;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}
</style>
