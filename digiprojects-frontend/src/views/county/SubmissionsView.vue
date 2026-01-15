<script setup>
import { computed, ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { generateProfessionalReport } from '@/utils/reportGenerator'
import ictaLogo from '@/assets/icta-logo.png'
import api from '@/api/axios'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import BaseTable from '@/components/ui/BaseTable.vue'
import StatusBadge from '@/components/ui/StatusBadge.vue'
import BaseModal from '@/components/ui/BaseModal.vue'

const authStore = useAuthStore()
const user = computed(() => authStore.user)
const router = useRouter()

const viewMode = ref('list') // 'list' or 'grid'
const isLoading = ref(false)
const submissions = ref([])

// Modal State
const showDetailModal = ref(false)
const selectedSubmission = ref(null)

const fetchSubmissions = async () => {
  isLoading.value = true
  try {
    const response = await api.get('/submissions')
    submissions.value = response.data
  } catch (err) {
    console.error('Failed to fetch submissions:', err)
  } finally {
    isLoading.value = false
  }
}

onMounted(() => {
  fetchSubmissions()
})

const columns = [
  { label: 'Project Type', key: 'projectType' },
  { label: 'Phase', key: 'phase' },
  { label: 'Site', key: 'site' },
  { label: 'Status', key: 'status' },
  { label: 'Issue / Remarks', key: 'remarks' },
  { label: 'Actions', key: 'actions' }
]

const handleView = (sub) => {
  selectedSubmission.value = sub
  showDetailModal.value = true
}

const handleEdit = (id) => {
  router.push(`/county/submission/edit/${id}`)
}

const handleDelete = async (id) => {
  if (confirm('Are you sure you want to delete this submission? This action cannot be undone.')) {
    try {
      await api.delete(`/submissions/${id}`)
      submissions.value = submissions.value.filter(s => s.id !== id)
    } catch (err) {
      console.error('Delete failed:', err)
      alert('Failed to delete. Please try again.')
    }
  }
}

const handleDownload = (sub) => {
  const content = `DIGIPROJECTS SUBMISSION RECEIPT #${sub.id}\n` +
                 `====================================\n` +
                 `Project Type: ${sub.project_type}\n` +
                 `Phase: ${sub.phase}\n` +
                 `Site/Location: ${sub.site}\n` +
                 `Status: ${sub.status.toUpperCase()}\n` +
                 `Issue/Remarks: ${sub.remarks}\n` +
                 `Generated: ${new Date().toLocaleString()}\n`
  
  downloadFile(content, `ICTA_Receipt_${sub.id}.txt`, 'text/plain')
}

const downloadFile = (content, fileName, contentType) => {
  const blob = new Blob([content], { type: contentType })
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = fileName
  link.click()
  URL.revokeObjectURL(url)
}

const exportReport = (format) => {
  if (format === 'excel') {
    const headers = ['Phase', 'Site', 'Status', 'Issue / Remarks']
    const rows = submissions.value.map(s => [
      s.phase,
      `"${s.site}"`, 
      s.status.toUpperCase(), 
      `"${s.remarks}"`
    ].join(','))
    const content = '\ufeff' + [headers.join(','), ...rows].join('\n')
    downloadFile(content, `ICTA_Report_${user.value?.county || 'County'}.csv`, 'text/csv;charset=utf-8')
  } else {
    generateProfessionalReport(submissions.value, user.value, ictaLogo)
  }
}
</script>

<template>
  <div class="submissions-page">
    <div class="page-header">
      <div class="header-text">
        <h2>My Submissions</h2>
        <p>Manage and track all project reports for {{ user?.county || 'your county' }}</p>
      </div>
      <div class="header-actions">
        <div class="view-toggles">
           <button @click="viewMode = 'list'" :class="['toggle-btn', { active: viewMode === 'list' }]" title="List View">
             <span class="icon">☰</span>
           </button>
           <button @click="viewMode = 'grid'" :class="['toggle-btn', { active: viewMode === 'grid' }]" title="Grid View">
             <span class="icon">⊞</span>
           </button>
        </div>
        <BaseButton to="/county/submission/new" variant="primary">New Submission</BaseButton>
      </div>
    </div>

    <!-- Export Actions Bar -->
    <div class="action-bar">
      <div class="count-badge">{{ submissions.length }} Total Submissions</div>
      <div class="export-actions">
        <button @click="exportReport('pdf')" class="export-btn" title="Export PDF">📄 PDF Report</button>
        <button @click="exportReport('excel')" class="export-btn" title="Export Excel">📊 Excel Export</button>
      </div>
    </div>

    <div v-if="isLoading" class="loading-state">
      <div class="spinner"></div>
      <p>Fetching submissions...</p>
    </div>

    <div v-else>
      <!-- List View -->
      <div v-if="viewMode === 'list'" class="list-layout">
        <BaseCard no-padding>
          <BaseTable :columns="columns">
            <tr v-for="sub in submissions" :key="sub.id">
              <td>{{ sub.project_type }}</td>
              <td>{{ sub.phase }}</td>
              <td><strong>{{ sub.site }}</strong></td>
              <td>
                <StatusBadge :status="sub.status === 'UP' || sub.status === 'Stable' ? 'success' : sub.status === 'DOWN' ? 'danger' : 'warning'">
                  {{ sub.status }}
                </StatusBadge>
              </td>
              <td class="text-muted truncate">{{ sub.remarks }}</td>
              <td>
                <div class="row-actions">
                  <button @click="handleView(sub)" class="action-link-view">View</button>
                  <button @click="handleEdit(sub.id)" class="action-btn-sm text-info" title="Edit">🖋️</button>
                  <button @click="handleDelete(sub.id)" class="action-btn-sm text-danger" title="Delete">🗑️</button>
                </div>
              </td>
            </tr>
          </BaseTable>
        </BaseCard>
      </div>

      <!-- Grid View -->
      <div v-else class="grid-layout">
        <div v-for="sub in submissions" :key="sub.id" class="submission-card">
          <div class="card-status-accent" :class="sub.status.toLowerCase()"></div>
          <div class="card-body">
            <div class="card-header">
              <span class="project-type">{{ sub.project_type }}</span>
              <StatusBadge :status="sub.status === 'UP' || sub.status === 'Stable' ? 'success' : sub.status === 'DOWN' ? 'danger' : 'warning'">
                {{ sub.status }}
              </StatusBadge>
            </div>
            
            <h3 class="site-name">{{ sub.site }}</h3>
            <div class="meta-info">
              <span class="meta-label">Phase:</span> {{ sub.phase }}
            </div>
            
            <p class="remarks-preview">{{ sub.remarks }}</p>
            
            <div class="card-actions">
              <button @click="handleView(sub)" class="action-link-view">View Details</button>
              <div class="icon-actions">
                <button @click="handleEdit(sub.id)" class="icon-btn edit" title="Edit">🖋️</button>
                <button @click="handleDelete(sub.id)" class="icon-btn delete" title="Delete">🗑️</button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-if="submissions.length === 0" class="empty-state">
        <span class="empty-icon">📁</span>
        <h3>No Submissions Found</h3>
        <p>Get started by creating your first project report.</p>
        <BaseButton to="/county/submission/new" variant="primary">Create Submission</BaseButton>
      </div>
    </div>

    <!-- Detail Modal -->
    <BaseModal 
      :show="showDetailModal" 
      :title="`Submission Detail: ${selectedSubmission?.site}`"
      @close="showDetailModal = false"
    >
      <div class="submission-details" v-if="selectedSubmission">
        <div class="detail-grid">
          <div class="detail-item">
            <label>Project Type</label>
            <div class="value">{{ selectedSubmission.project_type }}</div>
          </div>
          <div class="detail-item">
            <label>Phase</label>
            <div class="value">{{ selectedSubmission.phase }}</div>
          </div>
          <div class="detail-item">
            <label>Site Name</label>
            <div class="value"><strong>{{ selectedSubmission.site }}</strong></div>
          </div>
          <div class="detail-item">
            <label>Current Status</label>
            <div class="value">
              <StatusBadge :status="selectedSubmission.status === 'UP' || selectedSubmission.status === 'Stable' ? 'success' : selectedSubmission.status === 'DOWN' ? 'danger' : 'warning'">
                {{ selectedSubmission.status }}
              </StatusBadge>
            </div>
          </div>
        </div>
        
        <div class="detail-section">
          <label>Issue / Remarks</label>
          <div class="remarks-box">{{ selectedSubmission.remarks || 'No remarks provided.' }}</div>
        </div>
        
        <div class="detail-section">
          <label>Submission Date</label>
          <div class="value">{{ new Date(selectedSubmission.created_at).toLocaleString() }}</div>
        </div>
      </div>
      
      <template #footer>
        <BaseButton @click="handleDownload(selectedSubmission)" variant="secondary">Download Receipt</BaseButton>
        <BaseButton @click="handleEdit(selectedSubmission.id)" variant="primary">Edit Submission</BaseButton>
      </template>
    </BaseModal>
  </div>
</template>

<style scoped>
.submissions-page {
  animation: fadeIn 0.5s ease-out;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.header-text h2 {
  font-size: 1.75rem;
  font-weight: 800;
  color: #111;
  margin-bottom: 0.25rem;
}

.header-text p {
  color: #6b7280;
  font-size: 0.95rem;
}

.header-actions {
  display: flex;
  gap: 1rem;
  align-items: center;
}

/* View Toggles */
.view-toggles {
  display: flex;
  background: #f3f4f6;
  padding: 4px;
  border-radius: 8px;
}

.toggle-btn {
  width: 40px;
  height: 40px;
  border-radius: 6px;
  border: none;
  background: transparent;
  color: #6b7280;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.25rem;
  transition: all 0.2s;
}

.toggle-btn.active {
  background: #fff;
  color: #BB0000;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

/* Action Bar */
.action-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.count-badge {
  background: #f3f4f6;
  padding: 0.4rem 1rem;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 700;
  color: #4b5563;
}

.export-actions {
  display: flex;
  gap: 0.75rem;
}

.export-btn {
  background: #fff;
  border: 1px solid #e5e7eb;
  padding: 0.5rem 1rem;
  border-radius: 8px;
  font-size: 0.85rem;
  font-weight: 700;
  color: #374151;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.export-btn:hover {
  border-color: #BB0000;
  color: #BB0000;
}

/* Grid Layout */
.grid-layout {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 1.5rem;
}

.submission-card {
  background: #fff;
  border-radius: 12px;
  border: 1px solid #e5e7eb;
  overflow: hidden;
  position: relative;
  transition: all 0.2s;
}

.submission-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 20px -5px rgba(0,0,0,0.05);
}

.card-status-accent {
  height: 4px;
  width: 100%;
}
.card-status-accent.up, .card-status-accent.stable { background: #006600; }
.card-status-accent.down { background: #BB0000; }
.card-status-accent.ongoing, .card-status-accent.pending { background: #f59e0b; }

.card-body {
  padding: 1.5rem;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 1rem;
}

.project-type {
  font-size: 0.75rem;
  font-weight: 800;
  background: #f3f4f6;
  color: #4b5563;
  padding: 0.25rem 0.6rem;
  border-radius: 4px;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.site-name {
  font-size: 1.15rem;
  font-weight: 800;
  margin-bottom: 0.5rem;
  color: #111;
}

.meta-info {
  font-size: 0.9rem;
  color: #4b5563;
  margin-bottom: 1rem;
}

.meta-label {
  color: #9ca3af;
  font-weight: 600;
}

.remarks-preview {
  font-size: 0.9rem;
  color: #6b7280;
  line-height: 1.5;
  margin-bottom: 1.5rem;
  height: 2.25rem;
  overflow: hidden;
  line-clamp: 2;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  display: -webkit-box;
}

.card-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 1rem;
  border-top: 1px solid #f3f4f6;
}

.icon-actions {
  display: flex;
  gap: 0.5rem;
}

.icon-btn {
  width: 34px;
  height: 34px;
  border-radius: 8px;
  border: 1px solid #f3f4f6;
  background: #f9fafb;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s;
}

.icon-btn:hover {
  background: #fff;
  border-color: #d1d5db;
}

.icon-btn.edit:hover { color: #006600; border-color: #006600; }
.icon-btn.delete:hover { color: #BB0000; border-color: #BB0000; }

/* Modal Content Styles */
.detail-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.detail-item label {
  display: block;
  font-size: 0.75rem;
  color: #9ca3af;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin-bottom: 0.5rem;
  font-weight: 700;
}

.detail-item .value {
  font-size: 1.1rem;
  color: #111;
}

.remarks-box {
  background: #f9fafb;
  border: 1px solid #f3f4f6;
  border-radius: 8px;
  padding: 1rem;
  color: #4b5563;
  font-size: 0.95rem;
  line-height: 1.6;
  min-height: 100px;
}

.detail-section label {
  display: block;
  font-size: 0.75rem;
  color: #9ca3af;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin-bottom: 0.75rem;
  font-weight: 700;
  margin-top: 1.5rem;
}

/* Common Styles */
.row-actions {
  display: flex;
  align-items: center;
}

.action-link-view {
  background: transparent;
  border: none;
  color: #006600;
  font-weight: 800;
  font-size: 0.85rem;
  cursor: pointer;
  text-decoration: underline;
  padding: 0;
  margin-right: 1rem;
}

.action-btn-sm {
  width: 32px;
  height: 32px;
  border-radius: 6px;
  cursor: pointer;
  background: transparent;
  border: none;
  color: #9ca3af;
  transition: all 0.2s;
}

.action-btn-sm:hover {
  background: #f3f4f6;
  color: #111;
}

.loading-state, .empty-state {
  padding: 5rem 2rem;
  text-align: center;
  background: #fff;
  border-radius: 12px;
  border: 1px dashed #d1d5db;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 3px solid #f3f4f6;
  border-top-color: #BB0000;
  border-radius: 50%;
  margin: 0 auto 1.5rem;
  animation: spin 1s linear infinite;
}

@keyframes spin { to { transform: rotate(360deg); } }

.empty-icon { font-size: 4rem; display: block; margin-bottom: 1rem; }
.empty-state h3 { margin-bottom: 0.5rem; }
.empty-state p { color: #6b7280; margin-bottom: 2rem; }

.truncate {
  max-width: 250px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 1.5rem;
  }
}
</style>

