<script setup>
import { ref, onMounted, computed } from 'vue'
import api from '@/api/axios'
import BaseCard from '@/components/ui/BaseCard.vue'
import StatCard from '@/components/ui/StatCard.vue'
import StatusBadge from '@/components/ui/StatusBadge.vue'
import BaseButton from '@/components/ui/BaseButton.vue'

const stats = ref({
  total_projects: 0,
  total_submissions: 0,
  total_counties: 0,
  system_health: 'Checking...'
})

const recentActivity = ref([])
const isLoading = ref(false)
const errorMessage = ref('')

const fetchDashboardData = async () => {
  isLoading.value = true
  errorMessage.value = ''
  try {
    const [statsRes, activityRes] = await Promise.all([
      api.get('/submissions/national-stats'),
      api.get('/submissions')
    ])
    stats.value = statsRes.data
    recentActivity.value = activityRes.data.slice(0, 5)
  } catch (err) {
    console.error('Failed to fetch national dashboard data:', err)
    if (err.response?.status === 403) {
      errorMessage.value = 'You do not have admin access to view this data'
    } else if (err.response?.status === 401) {
      errorMessage.value = 'Please log in to view dashboard data'
    } else {
      errorMessage.value = 'Failed to load dashboard data. Please try refreshing.'
    }
  } finally {
    isLoading.value = false
  }
}

onMounted(() => {
  fetchDashboardData()
})
</script>

<template>
  <div class="admin-dashboard">
    <div class="dashboard-header">
      <div class="header-text">
        <h1 class="page-title">National Oversight Dashboard</h1>
        <p class="page-subtitle">Real-time monitoring and control center for DIGIPROJECTS</p>
      </div>
      <div class="header-actions">
        <BaseButton variant="outline" @click="fetchDashboardData" :disabled="isLoading">Refresh Data</BaseButton>
        <BaseButton variant="primary" to="/admin/county-reports">View County Reports</BaseButton>
      </div>
    </div>

    <!-- Error Message -->
    <div v-if="errorMessage" class="alert alert-error">
      {{ errorMessage }}
      <BaseButton variant="text" size="sm" @click="fetchDashboardData">Retry</BaseButton>
    </div>

    <!-- National Stats Panel -->
    <div class="stats-grid">
      <StatCard 
        label="Active Projects" 
        :value="stats.total_projects" 
        icon="🏗️" 
        variant="primary" 
        trend="Across 47 Counties"
      />
      <StatCard 
        label="Total Submissions" 
        :value="stats.total_submissions" 
        icon="📑" 
        variant="success" 
        trend="This Period"
      />
      <StatCard 
        label="Counties" 
        :value="stats.total_counties" 
        icon="🗺️" 
        variant="primary" 
        trend="Nationwide Coverage"
      />
      <StatCard 
        label="System Health" 
        :value="stats.system_health" 
        icon="🛡️" 
        variant="primary" 
        trend="Online"
      />
    </div>

    <div class="dashboard-grid">
      <!-- National Map Placeholder -->
      <div class="map-section">
        <BaseCard title="County Compliance Heatmap">
          <template #header-actions>
            <select class="form-select-sm">
              <option>All Projects</option>
              <option>NOFBI Phase 1</option>
              <option>DSH</option>
            </select>
          </template>
          <div class="map-placeholder">
            <div class="visual-map">
              <!-- Placeholder for Interactive Map -->
              <div class="map-layer">
                <span class="map-text">Interactive National Map Placeholder</span>
                <p>Color-coded counties by compliance status</p>
              </div>
            </div>
            <div class="map-legend">
              <div class="legend-item"><span class="dot compliance-high"></span> Compliant (>90%)</div>
              <div class="legend-item"><span class="dot compliance-med"></span> At Risk (70-90%)</div>
              <div class="legend-item"><span class="dot compliance-low"></span> Lagging (<70%)</div>
            </div>
          </div>
        </BaseCard>
      </div>

      <!-- Recent National Activity -->
      <div class="activity-section">
        <BaseCard title="Recent National Activity">
          <template #header-actions>
            <BaseButton variant="outline" to="/admin/county-reports">View All</BaseButton>
          </template>
          <div class="activity-list">
            <div v-if="isLoading" class="loading-state">Loading activity...</div>
            <div v-else-if="recentActivity.length === 0" class="empty-state">No recent activity</div>
            <div v-for="item in recentActivity" :key="item.id" class="activity-item">
              <div class="activity-avatar">{{ item.site.charAt(0) }}</div>
              <div class="activity-body">
                <div class="activity-title">
                  <strong>{{ item.site }}</strong> 
                  <span class="activity-meta">by {{ item.user?.name || 'Officer' }}</span>
                </div>
                <div class="activity-desc">{{ item.project_type }} - {{ item.phase }}</div>
                <div class="activity-time">{{ new Date(item.created_at).toLocaleTimeString() }}</div>
              </div>
              <div class="activity-badge">
                <StatusBadge :status="item.status === 'UP' ? 'success' : item.status === 'DOWN' ? 'danger' : 'info'">
                  {{ item.status }}
                </StatusBadge>
              </div>
            </div>
          </div>
        </BaseCard>

        <!-- Performance Metrics -->
        <BaseCard title="Regional Performance" class="mt-6">
          <div class="regional-list">
            <div class="region-row">
              <span class="region-name">Nairobi Region</span>
              <div class="region-bar-bg"><div class="region-bar-fill bg-success" style="width: 95%"></div></div>
              <span class="region-val">95%</span>
            </div>
            <div class="region-row">
              <span class="region-name">Coast Region</span>
              <div class="region-bar-bg"><div class="region-bar-fill bg-success" style="width: 88%"></div></div>
              <span class="region-val">88%</span>
            </div>
            <div class="region-row">
              <span class="region-name">Rift Valley</span>
              <div class="region-bar-bg"><div class="region-bar-fill bg-warning" style="width: 72%"></div></div>
              <span class="region-val">72%</span>
            </div>
          </div>
        </BaseCard>
      </div>
    </div>
  </div>
</template>

<style scoped>
.admin-dashboard {
  animation: fadeIn 0.5s ease-out;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.alert {
  padding: 1rem;
  border-radius: 0.5rem;
  margin-bottom: 1.5rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
}

.alert-error {
  background-color: #fee2e2;
  color: #991b1b;
  border: 1px solid #fca5a5;
}

.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.page-title {
  font-size: 1.875rem;
  font-weight: 800;
  color: #111827;
  letter-spacing: -0.025em;
}

.page-subtitle {
  color: #6b7280;
  margin-top: 0.25rem;
}

.header-actions {
  display: flex;
  gap: 1rem;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.dashboard-grid {
  display: grid;
  grid-template-columns: 1.5fr 1fr;
  gap: 1.5rem;
}

.map-placeholder {
  padding: 1rem;
}

.visual-map {
  height: 400px;
  background: #f8fafc;
  border-radius: 12px;
  border: 2px dashed #e2e8f0;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
}

.map-layer {
  text-align: center;
}

.map-text {
  font-size: 1.25rem;
  font-weight: 700;
  color: #94a3b8;
  display: block;
}

.map-placeholder p {
  color: #94a3b8;
  font-size: 0.875rem;
}

.map-legend {
  display: flex;
  gap: 2rem;
  margin-top: 1.5rem;
  justify-content: center;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.875rem;
  color: #4b5563;
}

.dot {
  width: 12px;
  height: 12px;
  border-radius: 50%;
}

.compliance-high { background-color: #059669; }
.compliance-med { background-color: #d97706; }
.compliance-low { background-color: #dc2626; }

.activity-list {
  display: flex;
  flex-direction: column;
}

.activity-item {
  display: flex;
  align-items: flex-start;
  gap: 1rem;
  padding: 1rem 0;
  border-bottom: 1px solid #f1f5f9;
}

.activity-item:last-child {
  border-bottom: none;
}

.activity-avatar {
  width: 40px;
  height: 40px;
  background: #f1f5f9;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  color: #475569;
}

.activity-body {
  flex: 1;
}

.activity-title {
  font-size: 0.9375rem;
  color: #1e293b;
}

.activity-meta {
  color: #64748b;
  font-size: 0.8125rem;
  margin-left: 0.5rem;
}

.activity-desc {
  font-size: 0.875rem;
  color: #475569;
  margin-top: 0.125rem;
}

.activity-time {
  font-size: 0.75rem;
  color: #94a3b8;
  margin-top: 0.25rem;
}

.regional-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.region-row {
  display: grid;
  grid-template-columns: 100px 1fr 40px;
  align-items: center;
  gap: 1rem;
}

.region-name {
  font-size: 0.875rem;
  font-weight: 600;
  color: #475569;
}

.region-bar-bg {
  height: 8px;
  background: #f1f5f9;
  border-radius: 4px;
  overflow: hidden;
}

.region-bar-fill {
  height: 100%;
  border-radius: 4px;
}

.bg-success { background-color: #10b981; }
.bg-warning { background-color: #f59e0b; }

.region-val {
  font-size: 0.875rem;
  font-weight: 700;
  color: #1e293b;
  text-align: right;
}

.form-select-sm {
  padding: 0.25rem 2rem 0.25rem 0.75rem;
  font-size: 0.875rem;
  border: 1px solid #e2e8f0;
  border-radius: 6px;
  background-color: #fff;
}

.mt-6 { margin-top: 1.5rem; }

@media (max-width: 1280px) {
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

  .header-actions {
    flex-direction: column;
    gap: 0.75rem;
    width: 100%;
  }

  .header-actions button {
    width: 100%;
  }
}

@media (max-width: 768px) {
  .admin-dashboard {
    padding: 1rem;
  }

  .dashboard-header {
    flex-direction: column;
    gap: 1rem;
    margin-bottom: 1.5rem;
  }

  .page-title {
    font-size: 1.5rem !important;
  }

  .page-subtitle {
    font-size: 0.875rem;
  }

  .header-actions {
    flex-direction: column;
    gap: 0.5rem;
    width: 100%;
  }

  .header-actions button {
    width: 100%;
    font-size: 0.875rem;
  }

  .stats-grid {
    grid-template-columns: 1fr;
    gap: 0.75rem;
  }

  .dashboard-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
  }

  .activity-item {
    padding: 0.75rem 0;
    gap: 0.75rem;
  }

  .activity-avatar {
    width: 35px;
    height: 35px;
    font-size: 0.8rem;
  }

  .activity-title {
    font-size: 0.85rem;
  }

  .activity-desc {
    font-size: 0.8rem;
  }

  .regional-list {
    gap: 0.75rem;
  }

  .region-row {
    grid-template-columns: 80px 1fr 35px;
    gap: 0.75rem;
  }

  .region-name {
    font-size: 0.8rem;
  }

  .region-val {
    font-size: 0.8rem;
  }

  .form-select-sm {
    padding: 0.25rem 1.75rem 0.25rem 0.5rem;
    font-size: 0.8rem;
  }

  .mt-6 {
    margin-top: 1rem;
  }

  /* Table scrolling for mobile */
  table {
    font-size: 0.8rem;
  }

  table th,
  table td {
    padding: 0.5rem;
  }
}

@media (max-width: 480px) {
  .admin-dashboard {
    padding: 0.75rem;
  }

  .page-title {
    font-size: 1.25rem !important;
  }

  .page-subtitle {
    font-size: 0.75rem;
    display: none;
  }

  .stats-grid {
    grid-template-columns: 1fr;
    gap: 0.5rem;
  }

  .activity-item {
    padding: 0.5rem 0;
    gap: 0.5rem;
  }

  .activity-avatar {
    width: 30px;
    height: 30px;
    font-size: 0.7rem;
  }

  .activity-title {
    font-size: 0.8rem;
  }

  .activity-meta {
    font-size: 0.7rem;
  }

  .activity-desc {
    font-size: 0.75rem;
  }

  .activity-time {
    font-size: 0.65rem;
  }

  .region-row {
    grid-template-columns: 70px 1fr 30px;
    gap: 0.5rem;
  }

  .region-name {
    font-size: 0.75rem;
  }

  .region-val {
    font-size: 0.75rem;
  }

  .region-bar-bg {
    height: 6px;
  }

  table {
    font-size: 0.7rem;
  }

  table th,
  table td {
    padding: 0.25rem;
  }

  .form-select-sm {
    font-size: 0.7rem;
  }
}
</style>
