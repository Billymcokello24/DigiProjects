<script setup>
import { computed, ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { generateProfessionalReport } from '@/utils/reportGenerator'
import ictaLogo from '@/assets/icta-logo.png'
import api from '@/api/axios'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import BaseTable from '@/components/ui/BaseTable.vue'
import StatusBadge from '@/components/ui/StatusBadge.vue'
import StatCard from '@/components/ui/StatCard.vue'
import BaseModal from '@/components/ui/BaseModal.vue'

const authStore = useAuthStore()
const user = computed(() => authStore.user)

const submissions = ref([])
const isLoading = ref(false)
const dbStats = ref({
    total_projects: 0,
    monthly_submissions: 0,
    pending_approval: 0,
    action_required: 0
})

// Modal State
const showDetailModal = ref(false)
const selectedSubmission = ref(null)

const handleViewDetail = (sub) => {
  selectedSubmission.value = sub
  showDetailModal.value = true
}

const recentSubmissions = computed(() => {
    return [...submissions.value].slice(0, 4)
})

const fetchDashboardData = async () => {
  isLoading.value = true
  try {
    const [subRes, statsRes] = await Promise.all([
        api.get('/submissions'),
        api.get('/submissions/stats')
    ])
    submissions.value = subRes.data
    dbStats.value = statsRes.data
  } catch (err) {
    console.error('Failed to fetch dashboard data:', err)
  } finally {
    isLoading.value = false
  }
}

onMounted(() => {
  fetchDashboardData()
})

const notifications = [
  { id: 1, title: 'Submission Logged', message: 'New project report synced with DB.', type: 'info', time: 'Just now' },
  { id: 2, title: 'Monthly Deadline', message: 'Submit October reports by Friday.', type: 'warning', time: '1d ago' },
  { id: 3, title: 'System Update', message: 'Maintenance scheduled for tonight.', type: 'info', time: '2d ago' },
]

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
  const data = recentSubmissions.value
  
  if (format === 'excel') {
    const headers = ['Phase', 'Site', 'Date', 'Status', 'Issue / Remarks']
    const rows = data.map(s => [s.phase, `"${s.site}"`, s.created_at, s.status.toUpperCase(), `"${s.remarks}"`].join(','))
    const content = '\ufeff' + [headers.join(','), ...rows].join('\n')
    downloadFile(content, `Recent_Activity_${new Date().getTime()}.csv`, 'text/csv;charset=utf-8')
  } else {
    generateProfessionalReport(data, user.value, ictaLogo)
  }
}
</script>

<template>
  <div class="county-dashboard">
    <div class="welcome-banner">
      <div class="banner-content">
        <h2>Welcome, {{ user?.name || 'Officer' }}</h2>
        <p>{{ user?.county || 'County' }} Dashboard Specifications</p>
        <BaseButton to="/county/submission/new" variant="primary">New Submission</BaseButton>
      </div>
    </div>

    <!-- Stats Panel -->
    <div class="stats-grid">
      <StatCard 
        label="Total Projects" 
        :value="dbStats.total_projects" 
        icon="🏗️" 
        variant="primary"
        trend="Active"
      />
      <StatCard 
        label="Monthly Reports" 
        :value="dbStats.monthly_submissions" 
        icon="📅" 
        variant="success"
        :trend="dbStats.monthly_submissions > 0 ? '+New' : 'Zero'"
      />
      <StatCard 
        label="Pending Review" 
        :value="dbStats.pending_approval" 
        icon="⏳" 
        variant="warning"
        trend="In Queue"
      />
      <StatCard 
        label="Action Required" 
        :value="dbStats.action_required" 
        icon="⚠️" 
        variant="danger"
        :trend="dbStats.action_required > 0 ? 'Urgent' : 'Clear'"
      />
    </div>

    <div class="dashboard-grid">
      <!-- Main Content: Recent Activity Summary -->
      <div class="main-content">
        <BaseCard title="Recent Activity">
           <template #header>
              <div class="card-header-flex">
                 <h3>Recent Activity</h3>
                 <div class="export-actions">
                    <button @click="exportReport('pdf')" class="export-btn">📄 PDF</button>
                    <button @click="exportReport('excel')" class="export-btn">📊 Excel</button>
                 </div>
              </div>
           </template>
           <div class="activity-list">
             <div 
               v-for="sub in recentSubmissions" 
               :key="sub.id" 
               class="activity-item" 
               @click="handleViewDetail(sub)"
               role="button"
               title="Click to view details"
             >
                <div class="activity-info">
                   <div class="activity-project">{{ sub.site }}</div>
                   <div class="activity-meta">{{ sub.project_type }} - {{ sub.phase }}</div>
                </div>
                <div class="activity-status">
                   <StatusBadge :status="sub.status === 'UP' || sub.status === 'Stable' ? 'success' : sub.status === 'DOWN' ? 'danger' : 'warning'">
                    {{ sub.status }}
                  </StatusBadge>
                </div>
             </div>
           </div>
           <template #footer>
             <BaseButton to="/county/submissions" variant="ghost" class="w-full">View All Submissions</BaseButton>
           </template>
        </BaseCard>
      </div>

      <!-- Right Sidebar: Notifications -->
      <aside class="sidebar-content">
        <BaseCard title="Notifications">
           <div class="timeline-list">
             <div v-for="note in notifications" :key="note.id" class="notification-item">
                <div class="note-icon" :class="`text-${note.type}`"></div>
                <div class="note-body">
                   <div class="note-title">{{ note.title }}</div>
                   <div class="note-message">{{ note.message }}</div>
                   <div class="note-time">{{ note.time }}</div>
                </div>
             </div>
           </div>
        </BaseCard>
      </aside>
    </div>

    <!-- Detail Modal -->
    <BaseModal 
      :show="showDetailModal" 
      :title="`Submision Detail: ${selectedSubmission?.site}`"
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
      </div>
      
      <template #footer>
        <BaseButton @click="showDetailModal = false" variant="secondary">Close</BaseButton>
        <BaseButton :to="`/county/submission/edit/${selectedSubmission?.id}`" variant="primary">Edit Submission</BaseButton>
      </template>
    </BaseModal>
  </div>
</template>

<style scoped>
/* Kenyan Flag Dashboard Theme */

/* Top Banner - Kenyan Identity */
.welcome-banner {
  position: relative;
  background: linear-gradient(135deg, #000000 0%, #333333 100%);
  color: #fff;
  padding: 2.5rem 3rem;
  border-radius: 12px;
  position: relative;
  overflow: hidden;
  margin-bottom: 1.5rem;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  border-left: 6px solid #BB0000; /* Kenya Red */
}

.welcome-banner::after {
  content: '';
  position: absolute;
  top: 0;
  right: 0;
  width: 100%;
  height: 4px;
  background: linear-gradient(to right, #000000 0%, #BB0000 33.3%, #ffffff 33.3%, #ffffff 66.6%, #006600 66.6%, #006600 100%);
}

.banner-content {
  position: relative;
  z-index: 10;
}

.banner-content h2 {
  font-size: 1.75rem;
  font-weight: 800;
  margin-bottom: 0.5rem;
  letter-spacing: -0.01em;
}

.banner-content p {
  opacity: 0.85;
  font-size: 0.95rem;
  font-weight: 400;
  max-width: 600px;
}

/* Stats */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 1.25rem;
  margin-bottom: 2rem;
}

:deep(.base-card) {
  background: #fff;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.02);
  transition: all 0.2s ease-in-out;
}

:deep(.base-card:hover) {
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.08);
  transform: translateY(-2px);
  border-color: #d1d5db;
}

:deep(.card-body) {
  display: flex !important;
  align-items: center;
  padding: 1.25rem !important;
}

.stat-icon-wrapper {
  width: 48px;
  height: 48px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.4rem;
  margin-right: 1.25rem;
  flex-shrink: 0;
}

/* Kenyan Flag Soft Accents */
.bg-primary-light { background-color: rgba(0, 0, 0, 0.05); color: #000000; }
.bg-success-light { background-color: rgba(0, 102, 0, 0.1); color: #006600; }
.bg-warning-light { background-color: rgba(234, 179, 8, 0.1); color: #eab308; }
.bg-danger-light { background-color: rgba(187, 0, 0, 0.1); color: #BB0000; }

.stat-content {
  display: flex;
  flex-direction: column;
}

.stat-value {
  font-size: 1.5rem;
  font-weight: 800;
  color: #111;
  line-height: 1.2;
}

.stat-label {
  font-size: 0.8rem;
  font-weight: 600;
  color: #6b7280;
  text-transform: uppercase;
  letter-spacing: 0.02em;
}

/* Main Layout */
.dashboard-grid {
  display: grid;
  grid-template-columns: 2.5fr 1.2fr;
  gap: 1.5rem;
}

/* Recent Activity List */
.activity-list {
  display: flex;
  flex-direction: column;
}

.activity-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 0;
  border-bottom: 1px solid #f3f4f6;
  cursor: pointer;
  transition: all 0.2s ease;
  padding-left: 0.5rem;
  padding-right: 0.5rem;
  border-radius: 8px;
  margin-bottom: 2px;
}

.activity-item:hover {
  background-color: #f9fafb;
  transform: translateX(4px);
}

.activity-item:last-child {
  border-bottom: none;
}

.activity-project {
  font-weight: 700;
  color: #111;
  font-size: 0.95rem;
}

.activity-meta {
  font-size: 0.8rem;
  color: #6b7280;
  margin-top: 0.15rem;
}

.w-full {
  width: 100%;
}

/* Header & Tabs (Kept for consistency if needed elsewhere, but mostly moved) */
.card-header-flex {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.25rem;
  border-bottom: 1px solid #f3f4f6;
  padding-bottom: 1rem;
}

.tabs-header {
  display: flex;
  gap: 1.25rem;
}

.tab-btn {
  background: transparent;
  border: none;
  border-bottom: 2px solid transparent;
  padding: 0.5rem 0;
  color: #6b7280;
  font-weight: 700;
  font-size: 0.85rem;
  cursor: pointer;
  transition: all 0.2s;
  text-transform: uppercase;
  letter-spacing: 0.03em;
}

.tab-btn.active {
  color: #BB0000; /* Kenya Red */
  border-color: #BB0000;
}

.tab-btn:hover {
  color: #111;
}

/* Exports */
.export-actions {
  display: flex;
  gap: 0.5rem;
}

.export-btn {
  background: #f9fafb;
  border: 1px solid #e5e7eb;
  color: #374151;
  padding: 0.4rem 0.75rem;
  font-size: 0.75rem;
  font-weight: 700;
  border-radius: 6px;
  cursor: pointer;
}

.export-btn:hover {
  background: #fff;
  border-color: #BB0000;
  color: #BB0000;
}

/* Notifications Timeline */
.timeline-list {
  display: flex;
  flex-direction: column;
  position: relative;
  padding-left: 1rem;
}

.notification-item {
  display: flex;
  gap: 1rem;
  padding-bottom: 1.75rem;
  position: relative;
}

.notification-item::before {
  content: '';
  position: absolute;
  left: -11px;
  top: 15px;
  bottom: 0;
  width: 2px;
  background: #f3f4f6;
}

.notification-item:last-child {
  padding-bottom: 0;
}

.notification-item:last-child::before {
  display: none;
}

.note-icon {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  flex-shrink: 0;
  margin-top: 6px;
  left: -15px;
  position: absolute;
  outline: 4px solid #fff;
  z-index: 10;
}

/* Kenyan Colors for dots */
.note-icon.text-danger { background-color: #BB0000; }
.note-icon.text-warning { background-color: #eab308; }
.note-icon.text-info { background-color: #006600; }

.note-body {
  flex: 1;
}

.note-title {
  font-size: 0.85rem;
  font-weight: 700;
  color: #111;
  margin-bottom: 0.15rem;
}

.note-message {
  font-size: 0.8rem;
  color: #4b5563;
  line-height: 1.4;
}

.note-time {
  font-size: 0.7rem;
  color: #9ca3af;
  margin-top: 0.25rem;
}

/* Table Refinements */
:deep(th) {
  background: #f9fafb;
  color: #4b5563;
  font-size: 0.75rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

/* Mobile Responsiveness */
@media (max-width: 1200px) {
  .dashboard-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 1024px) {
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 1rem;
  }

  .dashboard-grid {
    grid-template-columns: 1fr;
  }

  .card-header-flex {
    flex-direction: column;
    gap: 0.75rem;
  }
}

@media (max-width: 768px) {
  .county-dashboard {
    padding: 1rem;
  }

  .welcome-banner {
    padding: 1.5rem;
    border-radius: var(--radius-lg);
  }

  .welcome-banner h2 {
    font-size: 1.5rem;
  }

  .welcome-banner p {
    font-size: 0.875rem;
    margin-bottom: 1rem;
  }

  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 0.75rem;
    margin-bottom: 1.5rem;
  }

  .dashboard-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
  }

  .card-header-flex {
    flex-direction: column;
    gap: 0.75rem;
    align-items: flex-start;
  }

  .card-header-flex button {
    width: 100%;
  }

  .tabs-header {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
    margin-bottom: 1rem;
    padding-bottom: 0.5rem;
  }

  .tabs-header button {
    white-space: nowrap;
    font-size: 0.85rem;
    padding: 0.5rem 1rem;
  }

  /* Table mobile styles */
  table {
    font-size: 0.8rem;
  }

  table th,
  table td {
    padding: 0.5rem;
  }

  .timeline-list {
    padding-left: 0.75rem;
  }

  .notification-item {
    gap: 0.75rem;
    padding-bottom: 1.25rem;
  }

  .notification-item::before {
    left: -8px;
    top: 12px;
  }

  .note-icon {
    left: -11px;
  }

  .note-title {
    font-size: 0.8rem;
  }

  .note-message {
    font-size: 0.75rem;
  }

  .note-time {
    font-size: 0.65rem;
  }

  .export-btn {
    font-size: 0.8rem;
    padding: 0.4rem 0.8rem;
  }

  :deep(th) {
    font-size: 0.7rem;
    padding: 0.4rem;
  }

  :deep(td) {
    font-size: 0.8rem;
  }
}

@media (max-width: 480px) {
  .county-dashboard {
    padding: 0.75rem;
  }

  .welcome-banner {
    padding: 1rem;
  }

  .welcome-banner h2 {
    font-size: 1.25rem;
  }

  .welcome-banner p {
    font-size: 0.8rem;
    margin-bottom: 0.75rem;
  }

  .welcome-banner button {
    width: 100%;
    font-size: 0.8rem;
  }

  .stats-grid {
    grid-template-columns: 1fr;
    gap: 0.5rem;
    margin-bottom: 1rem;
  }

  .card-header-flex {
    flex-direction: column;
    gap: 0.5rem;
  }

  .card-header-flex button {
    width: 100%;
    font-size: 0.75rem;
  }

  .tabs-header {
    margin-bottom: 0.75rem;
  }

  .tabs-header button {
    font-size: 0.75rem;
    padding: 0.4rem 0.8rem;
  }

  .timeline-list {
    padding-left: 0.5rem;
  }

  .notification-item {
    gap: 0.5rem;
    padding-bottom: 1rem;
  }

  .notification-item::before {
    left: -6px;
    top: 10px;
    width: 1px;
  }

  .note-icon {
    width: 8px;
    height: 8px;
    left: -10px;
    margin-top: 4px;
    outline: 3px solid #fff;
  }

  .note-title {
    font-size: 0.75rem;
    margin-bottom: 0.1rem;
  }

  .note-message {
    font-size: 0.7rem;
    line-height: 1.3;
  }

  .note-time {
    font-size: 0.6rem;
  }

  .export-btn {
    font-size: 0.7rem;
    padding: 0.3rem 0.6rem;
  }

  /* Table mobile scroll */
  table {
    font-size: 0.7rem;
    min-width: 100%;
  }

  table th {
    font-size: 0.65rem;
    padding: 0.3rem;
  }

  table td {
    font-size: 0.7rem;
    padding: 0.3rem;
    white-space: nowrap;
  }

  /* Horizontal scroll wrapper for tables */
  :deep(.table-wrapper) {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
  }

  :deep(.card-header-flex) {
    flex-wrap: wrap;
  }
}

/* Utilities */
.text-danger { color: #BB0000; }
.text-warning { color: #eab308; }
</style>
