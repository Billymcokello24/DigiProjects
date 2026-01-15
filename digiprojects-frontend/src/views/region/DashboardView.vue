<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import api from '@/api/axios'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import BaseTable from '@/components/ui/BaseTable.vue'
import StatCard from '@/components/ui/StatCard.vue'

const router = useRouter()
const authStore = useAuthStore()
const user = computed(() => authStore.user)

const isLoading = ref(false)
const stats = ref({
  total_counties: 0,
  total_submissions: 0,
  total_officers: 0,
  active_projects: 0,
  submissions_status: {}
})

const counties = ref([])
const recentSubmissions = ref([])
const countiesColumns = ['County Name', 'Officers', 'Submissions', 'Status', 'Actions']
const submissionsColumns = ['Site', 'Project', 'Phase', 'Status', 'Officer', 'Date']

const fetchRegionalStats = async () => {
  try {
    const response = await api.get('/submissions/regional-stats')
    const data = response.data

    counties.value = data.counties
    stats.value = {
      total_counties: data.total_counties,
      total_submissions: data.total_submissions,
      total_officers: data.total_officers,
      active_projects: data.active_projects,
      submissions_status: data.submissions_status
    }
    recentSubmissions.value = data.recent_submissions
  } catch (err) {
    console.error('Failed to fetch regional stats:', err)
  } finally {
    isLoading.value = false
  }
}

const getCountyStats = (countyId) => {
  const county = counties.value.find(c => c.id === countyId)
  if (!county) return { submissions: 0, officers: 0 }
  return {
    submissions: county.submissions_count || 0,
    officers: county.officers_count || 0
  }
}

const getCountyOfficers = (countyId) => {
  const county = counties.value.find(c => c.id === countyId)
  return county?.officers_count || 0
}

const getCountyStatus = (countyId) => {
  const county = counties.value.find(c => c.id === countyId)
  if (!county) return 'NO_DATA'
  
  const submissions = recentSubmissions.value.filter(s => s.user?.county_id === countyId)
  if (submissions.length === 0) return county.is_active ? 'ACTIVE' : 'INACTIVE'
  
  const statuses = submissions.map(s => s.status)
  if (statuses.includes('DOWN')) return 'ALERT'
  if (statuses.includes('Ongoing')) return 'IN_PROGRESS'
  return 'OPERATIONAL'
}

const getStatusBadgeColor = (status) => {
  const colors = {
    'UP': '#10b981',
    'DOWN': '#ef4444',
    'Ongoing': '#f59e0b',
    'Pending': '#8b5cf6',
    'No Services': '#6b7280',
    'OPERATIONAL': '#10b981',
    'ALERT': '#ef4444',
    'IN_PROGRESS': '#f59e0b',
    'NO_DATA': '#9ca3af',
    'ACTIVE': '#10b981',
    'INACTIVE': '#6b7280'
  }
  return colors[status] || '#6b7280'
}

const formatDate = (date) => {
  return new Date(date).toLocaleDateString('en-KE', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}

const viewCountyDetails = (countyId) => {
  router.push(`/region/counties/${countyId}`)
}

onMounted(() => {
  isLoading.value = true
  fetchRegionalStats()
})
</script>

<template>
  <div class="region-dashboard">
    <!-- Welcome Banner -->
    <div class="welcome-banner">
      <div class="banner-content">
        <h1>Welcome, {{ user?.name || 'Regional Officer' }}</h1>
        <p>{{ user?.region }} Region Management Dashboard</p>
      </div>
      <BaseButton to="/region/officers/manage" variant="primary">➕ Add County Officer</BaseButton>
    </div>

    <!-- Loading State -->
    <div v-if="isLoading" class="loading-state">
      Loading regional data...
    </div>

    <template v-else>
      <!-- Statistics Cards -->
      <div class="stats-grid">
        <StatCard 
          label="Counties" 
          :value="stats.total_counties" 
          icon="🏛️" 
          variant="primary"
          trend="In Region"
        />
        <StatCard 
          label="Total Submissions" 
          :value="stats.total_submissions" 
          icon="📋" 
          variant="success"
          trend="All Time"
        />
        <StatCard 
          label="County Officers" 
          :value="stats.total_officers" 
          icon="👮" 
          variant="primary"
          trend="Active"
        />
        <StatCard 
          label="Active Projects" 
          :value="stats.active_projects" 
          icon="🏗️" 
          variant="warning"
          trend="Ongoing"
        />
      </div>

      <!-- Submission Status Overview -->
      <BaseCard style="margin-top: 2rem;">
        <template #header>
          <h3>Submission Status Overview</h3>
        </template>
        <div class="status-overview">
          <div v-for="(count, status) in stats.submissions_status" :key="status" class="status-item">
            <div class="status-badge" :style="{ backgroundColor: getStatusBadgeColor(status) }">
              {{ count }}
            </div>
            <div class="status-label">{{ status }}</div>
          </div>
        </div>
      </BaseCard>

      <!-- Counties in Region -->
      <BaseCard style="margin-top: 2rem;">
        <template #header>
          <h3>Counties in {{ user?.region }} Region</h3>
        </template>
        <div v-if="counties.length === 0" class="empty-state">
          <p>No counties found in this region.</p>
        </div>
        <BaseTable v-else :columns="countiesColumns">
          <tr v-for="county in counties" :key="county.id">
            <td class="font-bold">{{ county.name }}</td>
            <td class="text-center">{{ getCountyOfficers(county.id) }}</td>
            <td class="text-center">{{ getCountyStats(county.id).submissions }}</td>
            <td>
              <span class="badge" :style="{ backgroundColor: getStatusBadgeColor(getCountyStatus(county.id)) }">
                {{ getCountyStatus(county.id) }}
              </span>
            </td>
            <td>
              <BaseButton variant="primary" size="sm" @click="viewCountyDetails(county.id)">View Details</BaseButton>
            </td>
          </tr>
        </BaseTable>
      </BaseCard>

      <!-- Recent Submissions -->
      <BaseCard style="margin-top: 2rem;">
        <template #header>
          <h3>Recent Submissions (Last 10)</h3>
        </template>
        <div v-if="recentSubmissions.length === 0" class="empty-state">
          <p>No submissions yet.</p>
        </div>
        <BaseTable v-else :columns="submissionsColumns">
          <tr v-for="submission in recentSubmissions" :key="submission.id">
            <td>{{ submission.site }}</td>
            <td>{{ submission.project_type || 'N/A' }}</td>
            <td>{{ submission.phase || 'N/A' }}</td>
            <td>
              <span class="badge" :style="{ backgroundColor: getStatusBadgeColor(submission.status) }">
                {{ submission.status }}
              </span>
            </td>
            <td>{{ submission.user?.name || 'Unknown' }}</td>
            <td class="text-muted">{{ formatDate(submission.created_at) }}</td>
          </tr>
        </BaseTable>
      </BaseCard>

      <!-- Quick Actions -->
      <BaseCard style="margin-top: 2rem;">
        <template #header>
          <h3>Quick Actions</h3>
        </template>
        <div class="quick-actions">
          <BaseButton to="/region/counties" variant="primary" size="sm">View All Counties</BaseButton>
          <BaseButton to="/region/submissions" variant="secondary" size="sm">View All Submissions</BaseButton>
          <BaseButton to="/region/officers/manage" variant="secondary" size="sm">Manage Officers</BaseButton>
          <BaseButton to="/region/reports" variant="primary" size="sm">📊 Download Report</BaseButton>
        </div>
      </BaseCard>
    </template>
  </div>
</template>

<style scoped>
.region-dashboard {
  padding: 0;
}

/* Welcome Banner - Kenyan Theme */
.welcome-banner {
  background: linear-gradient(135deg, #000000 0%, #333333 100%);
  color: #fff;
  padding: 2.5rem 3rem;
  border-radius: 12px;
  margin-bottom: 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  position: relative;
  overflow: hidden;
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

.banner-content h1 {
  font-size: 1.75rem;
  font-weight: 800;
  margin: 0 0 0.5rem 0;
  letter-spacing: -0.01em;
}

.banner-content p {
  margin: 0;
  color: #d1d5db;
  font-size: 0.95rem;
  opacity: 0.85;
}

.loading-state {
  text-align: center;
  padding: 3rem;
  color: #6b7280;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.status-overview {
  display: flex;
  flex-wrap: wrap;
  gap: 2rem;
  padding: 1rem;
}

.status-item {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.status-badge {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 50px;
  height: 50px;
  border-radius: 50%;
  color: white;
  font-size: 1.5rem;
  font-weight: bold;
}

.status-label {
  font-size: 0.95rem;
  font-weight: 500;
  color: #374151;
}

.empty-state {
  padding: 2rem;
  text-align: center;
  color: #6b7280;
}

.badge {
  display: inline-block;
  padding: 0.25rem 0.75rem;
  border-radius: 9999px;
  font-size: 0.75rem;
  font-weight: 600;
  color: white;
}

.text-center {
  text-align: center;
}

.text-muted {
  color: #6b7280;
  font-size: 0.875rem;
}

.font-bold {
  font-weight: 600;
}

.quick-actions {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
  padding: 1rem;
}

@media (max-width: 768px) {
  .region-dashboard {
    padding: 1rem;
  }

  .welcome-banner {
    flex-direction: column;
    gap: 1rem;
    align-items: flex-start;
    padding: 1.5rem;
    border-radius: var(--radius-lg);
  }

  .banner-content h1 {
    font-size: 1.5rem;
  }

  .banner-content p {
    font-size: 0.85rem;
  }

  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 1rem;
  }

  .status-overview {
    gap: 1rem;
    padding: 0.75rem;
    flex-wrap: wrap;
  }

  .status-item {
    gap: 0.75rem;
  }

  .status-badge {
    width: 40px;
    height: 40px;
    font-size: 1.25rem;
  }

  .status-label {
    font-size: 0.85rem;
  }

  .quick-actions {
    flex-direction: column;
    gap: 0.5rem;
    padding: 0.75rem;
  }

  .quick-actions button {
    width: 100%;
  }

  /* Table mobile styles */
  :deep(table) {
    font-size: 0.8rem;
  }

  :deep(table th),
  :deep(table td) {
    padding: 0.5rem;
  }

  :deep(table thead) {
    display: none;
  }

  :deep(table tbody tr) {
    display: block;
    border: 1px solid #e5e7eb;
    margin-bottom: 1rem;
    border-radius: 0.375rem;
    background-color: #f9fafb;
  }

  :deep(table tbody td) {
    display: grid;
    grid-template-columns: 120px 1fr;
    gap: 0.5rem;
    padding: 0.75rem;
    border: none;
    border-bottom: 1px solid #e5e7eb;
  }

  :deep(table tbody td:before) {
    content: attr(data-label);
    font-weight: 600;
    color: #1f2937;
  }

  :deep(table tbody td:last-child) {
    border-bottom: none;
  }

  :deep(.text-center) {
    text-align: left;
  }

  :deep(.font-bold) {
    grid-column: 1 / -1;
  }
}

@media (max-width: 480px) {
  .region-dashboard {
    padding: 0.75rem;
  }

  .welcome-banner {
    padding: 1rem;
    border-radius: 8px;
  }

  .welcome-banner::after {
    height: 3px;
  }

  .banner-content h1 {
    font-size: 1.25rem;
    margin-bottom: 0.25rem;
  }

  .banner-content p {
    font-size: 0.75rem;
  }

  .stats-grid {
    grid-template-columns: 1fr;
    gap: 0.75rem;
    margin-bottom: 1.5rem;
  }

  .status-overview {
    flex-direction: column;
    gap: 0.75rem;
    padding: 0.5rem;
  }

  .status-item {
    width: 100%;
    gap: 0.75rem;
  }

  .status-badge {
    width: 35px;
    height: 35px;
    font-size: 1rem;
    flex-shrink: 0;
  }

  .status-label {
    font-size: 0.8rem;
  }

  .quick-actions {
    gap: 0.5rem;
    padding: 0.5rem;
    flex-direction: column;
  }

  .quick-actions button {
    font-size: 0.8rem;
    width: 100%;
  }

  .loading-state {
    padding: 1.5rem;
    font-size: 0.9rem;
  }

  .empty-state {
    padding: 1rem;
    font-size: 0.85rem;
  }

  :deep(.badge) {
    font-size: 0.65rem;
    padding: 0.2rem 0.6rem;
  }

  :deep(.text-muted) {
    font-size: 0.8rem;
  }

  :deep(table) {
    font-size: 0.75rem;
    width: 100%;
  }

  :deep(table th),
  :deep(table td) {
    padding: 0.4rem;
  }

  :deep(table tbody td) {
    grid-template-columns: 100px 1fr;
    gap: 0.35rem;
    padding: 0.5rem;
  }

  :deep(.page-subtitle) {
    display: none;
  }
}

@media (max-width: 1024px) {
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>
