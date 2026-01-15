<script setup>
import { ref, computed, onMounted } from 'vue'
import BaseCard from '@/components/ui/BaseCard.vue'
import StatusBadge from '@/components/ui/StatusBadge.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import api from '@/api/axios'

const selectedCounty = ref(null)
const selectedFilter = ref('All')
const nationalStats = ref(null)
const counties = ref([])
const recentUpdates = ref([])
const regions = ref([])
const phases = ref([])
const projectsPhases = ref([])
const loading = ref(true)

// Fetch county summary data from API
const fetchCountyData = async () => {
  try {
    loading.value = true
    const response = await api.get('/public/counties-summary')
    nationalStats.value = response.data.national_stats
    counties.value = response.data.counties
    recentUpdates.value = response.data.recent_updates || []
    regions.value = response.data.regions || []
    phases.value = response.data.phases || []
    projectsPhases.value = response.data.projects_phases || []
    console.log('Fetched National Stats:', nationalStats.value)
    console.log('Fetched Counties:', counties.value.length)
    console.log('Fetched Regions:', regions.value.length)
    console.log('Fetched Phases:', phases.value.length)
    console.log('Fetched Projects with Phases:', projectsPhases.value.length)
  } catch (err) {
    console.error('Failed to fetch county data:', err)
  } finally {
    loading.value = false
  }
}

const availableCounties = computed(() => counties.value.map(c => c.name))

const regionalStats = computed(() => {
  const groupedByRegion = {}
  counties.value.forEach(county => {
    if (!groupedByRegion[county.region]) {
      groupedByRegion[county.region] = {
        region: county.region,
        activeProjects: 0,
        completion: 0,
        lastUpdate: 'Recently',
        status: 'success',
        counties: []
      }
    }
    groupedByRegion[county.region].activeProjects += county.stats.total_projects
    groupedByRegion[county.region].counties.push(county)
  })
  
  return Object.values(groupedByRegion).map(region => {
    const totalSubmissions = region.counties.reduce((sum, c) => sum + c.stats.total_submissions, 0)
    const completedSubmissions = region.counties.reduce((sum, c) => sum + c.stats.completed, 0)
    const completion = totalSubmissions > 0 ? Math.round((completedSubmissions / totalSubmissions) * 100) : 0
    
    return {
      ...region,
      completion,
      status: completion >= 75 ? 'success' : completion >= 50 ? 'warning' : 'neutral'
    }
  })
})

const currentTableData = computed(() => {
  if (selectedCounty.value) {
    return []
  }
  return regionalStats.value
})

const selectCounty = (countyName) => {
  const county = counties.value.find(c => c.name === countyName)
  if (county) {
    selectedCounty.value = county
    selectedFilter.value = countyName
  }
}

const clearSelection = () => {
  selectedCounty.value = null
  selectedFilter.value = 'All'
}

onMounted(() => {
  fetchCountyData()
})

// Helper function to map status to badge type
const getStatusBadge = (status) => {
  const statusMap = {
    'COMPLETED': 'success',
    'ONGOING': 'warning',
    'DELAYED': 'warning',
    'PENDING': 'neutral'
  }
  return statusMap[status] || 'neutral'
}

const projectsTable = computed(() => {
  const grouped = {}
  projectsPhases.value.forEach(item => {
    if (!grouped[item.site]) {
      grouped[item.site] = []
    }
    grouped[item.site].push(item.phase)
  })
  
  return Object.entries(grouped).map(([site, phases]) => ({
    site,
    phases: phases.sort().join(', ')
  }))
})
</script>

<template>
  <div class="public-data-view">
    <!-- Header Section -->
    <div class="header-section">
      <div class="container">
        <h1 class="heading-1">Public Data Explorer</h1>
        <p class="text-muted">Real-time transparency into National ICT Projects. Data uploaded directly by County Officers.</p>
        
        <!-- National Stats Summary -->
        <div v-if="nationalStats && !loading" class="national-stats-grid">
          <div class="stat-card stat-card-black">
            <div class="stat-value">{{ nationalStats.total_counties }}</div>
            <div class="stat-label">Counties</div>
          </div>
          <div class="stat-card stat-card-red">
            <div class="stat-value">{{ nationalStats.total_projects }}</div>
            <div class="stat-label">Projects</div>
          </div>
          <div class="stat-card stat-card-green">
            <div class="stat-value">{{ nationalStats.total_regions }}</div>
            <div class="stat-label">Regions</div>
          </div>
          <div class="stat-card stat-card-white">
            <div class="stat-value">{{ nationalStats.total_phases }}</div>
            <div class="stat-label">Phases</div>
          </div>
        </div>

        <!-- Filter -->
        <div class="filter-bar">
          <div class="filter-group">
            <label>Filter by County:</label>
            <select v-model="selectedFilter" @change="selectedFilter !== 'All' ? selectCounty(selectedFilter) : clearSelection()" class="custom-select">
              <option value="All">All Regions</option>
              <option v-for="county in availableCounties" :key="county" :value="county">{{ county }}</option>
            </select>
          </div>
          <BaseButton v-if="selectedCounty" @click="clearSelection" variant="secondary" size="sm">Clear Filter</BaseButton>
        </div>
      </div>
    </div>

    <!-- County Profile (Conditional) -->
    <section v-if="selectedCounty" class="county-profile-section">
      <div class="container">
        <div class="county-profile-card">
          <div class="profile-header" style="background: linear-gradient(135deg, #0ea5e9, #bae6fd)">
            <h2 class="profile-title">{{ selectedCounty.name }} County</h2>
            <p class="profile-subtitle">{{ selectedCounty.region }} Region</p>
          </div>
          <div class="profile-body">
            <div class="profile-stats-grid">
              <div class="profile-stat">
                <div class="stat-value">{{ selectedCounty.stats.total_submissions }}</div>
                <div class="stat-label">Total Submissions</div>
              </div>
              <div class="profile-stat">
                <div class="stat-value">{{ selectedCounty.stats.total_projects }}</div>
                <div class="stat-label">Projects</div>
              </div>
              <div class="profile-stat">
                <div class="stat-value">{{ selectedCounty.stats.completed }}</div>
                <div class="stat-label">Completed</div>
              </div>
              <div class="profile-stat">
                <div class="stat-value">{{ selectedCounty.stats.ongoing }}</div>
                <div class="stat-label">Ongoing</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Regional Stats Table -->
    <section v-if="!selectedCounty && !loading" class="stats-section">
      <div class="container">
        <BaseCard title="Regional Project Summary">
          <div v-if="currentTableData.length === 0" class="empty-state">
            <p>No regional data available</p>
          </div>
          <table v-else class="public-table">
            <thead>
              <tr>
                <th>Region</th>
                <th>Active Projects</th>
                <th>Counties</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="stat in currentTableData" :key="stat.region">
                <td><strong>{{ stat.region }}</strong></td>
                <td>{{ stat.activeProjects }}</td>
                <td>{{ stat.counties.length }}</td>
              </tr>
            </tbody>
          </table>
        </BaseCard>
      </div>
    </section>

    <!-- County Details Table -->
    <section v-if="selectedCounty && !loading" class="stats-section">
      <div class="container">
        <BaseCard :title="`${selectedCounty.name} - Project Submissions`">
          <!-- Summary Stats -->
          <div class="county-details-grid">
            <div class="detail-card">
              <span class="detail-label">Total Submissions</span>
              <span class="detail-value">{{ selectedCounty.stats.total_submissions }}</span>
            </div>
            <div class="detail-card">
              <span class="detail-label">Completed</span>
              <span class="detail-value completed">{{ selectedCounty.stats.completed }}</span>
            </div>
            <div class="detail-card">
              <span class="detail-label">Ongoing</span>
              <span class="detail-value ongoing">{{ selectedCounty.stats.ongoing }}</span>
            </div>
            <div class="detail-card">
              <span class="detail-label">Delayed</span>
              <span class="detail-value delayed">{{ selectedCounty.stats.delayed }}</span>
            </div>
            <div class="detail-card">
              <span class="detail-label">Pending</span>
              <span class="detail-value pending">{{ selectedCounty.stats.pending }}</span>
            </div>
          </div>

          <!-- Submissions Table -->
          <div v-if="selectedCounty.submissions && selectedCounty.submissions.length > 0" class="submissions-table-wrapper">
            <h3 class="table-title">Submissions Details</h3>
            <table class="submissions-table">
              <thead>
                <tr>
                  <th>Project Type</th>
                  <th>Phase</th>
                  <th>Site</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="submission in selectedCounty.submissions" :key="submission.id">
                  <td><strong>{{ submission.project_type }}</strong></td>
                  <td>{{ submission.phase }}</td>
                  <td>{{ submission.site }}</td>
                  <td>
                    <StatusBadge :status="getStatusBadge(submission.status)">{{ submission.status }}</StatusBadge>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          <div v-else class="empty-state">
            <p>No submissions for this county</p>
          </div>
        </BaseCard>
      </div>
    </section>

    <!-- Loading State -->
    <section v-if="loading" class="stats-section">
      <div class="container">
        <div class="loading-state">
          <p>Loading data from database...</p>
        </div>
      </div>
    </section>

    <!-- Projects and Phases Section -->
    <section v-if="!loading && projectsPhases.length > 0" class="data-section">
      <div class="container">
        <BaseCard :title="`Projects and Phases (${projectsTable.length})`">
          <table class="submissions-table">
            <thead>
              <tr>
                <th>Project Site</th>
                <th>Phases</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="project in projectsTable" :key="project.site">
                <td><strong>{{ project.site }}</strong></td>
                <td>{{ project.phases }}</td>
              </tr>
            </tbody>
          </table>
        </BaseCard>
      </div>
    </section>

    <!-- County Updates from Database -->
    <section class="county-news">
      <div class="container">
        <h2 class="heading-2 mb-4">Latest County Updates</h2>
        <div v-if="recentUpdates.length > 0" class="news-grid">
          <div v-for="(update, idx) in recentUpdates" :key="idx" class="news-card" v-show="!selectedCounty || update.county === selectedCounty.name">
            <div class="news-header">
              <span class="county-badge">{{ update.county }}</span>
              <span class="news-date">{{ update.date }}</span>
            </div>
            <h3 class="news-title">{{ update.title }}</h3>
            <p class="news-desc">{{ update.desc }}</p>
            <div class="news-footer">
              <span class="officer-name">Reported by: {{ update.officer }}</span>
            </div>
          </div>
        </div>
        <div v-else class="empty-state">
          <p>No recent updates</p>
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped>
.public-data-view {
  padding-bottom: 4rem;
}

.header-section {
  padding: 4rem 0 2rem;
  background: white;
  text-align: center;
  border-bottom: 1px solid var(--color-border);
}

.national-stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 1.5rem;
  margin: 2rem 0;
}

.stat-card {
  background: linear-gradient(135deg, #f8fafc, #f1f5f9);
  padding: 1.5rem;
  border-radius: var(--radius-lg);
  border: 1px solid var(--color-border);
  text-align: center;
}

.stat-card-black {
  background: linear-gradient(135deg, #1e293b, #0f172a);
  color: white;
  border-color: #000000;
}

.stat-card-black .stat-value {
  color: white;
}

.stat-card-black .stat-label {
  color: rgba(255, 255, 255, 0.8);
}

.stat-card-red {
  background: linear-gradient(135deg, #bb0000, #8b0000);
  color: white;
  border-color: #bb0000;
}

.stat-card-red .stat-value {
  color: white;
}

.stat-card-red .stat-label {
  color: rgba(255, 255, 255, 0.8);
}

.stat-card-green {
  background: linear-gradient(135deg, #006600, #004d00);
  color: white;
  border-color: #006600;
}

.stat-card-green .stat-value {
  color: white;
}

.stat-card-green .stat-label {
  color: rgba(255, 255, 255, 0.8);
}

.stat-card-white {
  background: linear-gradient(135deg, #ffffff, #f8f9fa);
  border: 2px solid #000000;
}

.stat-card-white .stat-value {
  color: #000000;
}

.stat-card-white .stat-label {
  color: #000000;
}

.stat-value {
  font-size: 2.5rem;
  font-weight: 800;
  color: var(--color-primary);
  line-height: 1;
}

.stat-label {
  font-size: 0.875rem;
  color: var(--color-text-muted);
  margin-top: 0.75rem;
  font-weight: 600;
}

.filter-bar {
  margin-top: 2rem;
  display: flex;
  justify-content: center;
  gap: 1rem;
  align-items: flex-end;
}

.filter-group {
  text-align: left;
}

.filter-group label {
  display: block;
  font-size: 0.875rem;
  color: var(--color-text-muted);
  margin-bottom: 0.5rem;
  font-weight: 600;
}

.custom-select {
  padding: 0.75rem 1rem;
  border-radius: var(--radius-md);
  border: 1px solid var(--color-border);
  font-family: inherit;
  font-size: 1rem;
  min-width: 250px;
  background: white;
  transition: border-color 0.2s;
}

.custom-select:focus {
  outline: none;
  border-color: var(--color-accent);
  box-shadow: 0 0 0 3px rgba(14, 165, 233, 0.1);
}

.county-profile-section {
  padding: 2rem 0;
}

.county-profile-card {
  background: white;
  border-radius: var(--radius-lg);
  overflow: hidden;
  box-shadow: var(--shadow-lg);
  border: 1px solid var(--color-border);
}

.profile-header {
  padding: 3rem 2rem;
  color: white;
}

.profile-title {
  font-size: 2rem;
  font-weight: 800;
  margin: 0 0 0.5rem;
}

.profile-subtitle {
  font-size: 1rem;
  font-weight: 500;
  opacity: 0.9;
  margin: 0;
}

.profile-body {
  padding: 2rem;
}

.profile-stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 2rem;
}

.profile-stat {
  text-align: center;
  padding: 1.5rem;
  background: var(--color-background);
  border-radius: var(--radius-md);
}

.profile-stat .stat-value {
  display: block;
  font-size: 2rem;
  margin-bottom: 0.5rem;
}

.profile-stat .stat-label {
  display: block;
  margin: 0;
}

.stats-section {
  padding: 3rem 0;
  background: white;
  border-top: 4px solid #bb0000;
}

.public-table {
  width: 100%;
  border-collapse: collapse;
}

.public-table th,
.public-table td {
  padding: 1.5rem;
  text-align: left;
  border-bottom: 1px solid #e2e8f0;
  font-weight: 500;
  color: #1e293b;
}

.public-table th {
  font-weight: 700;
  color: white;
  background: linear-gradient(135deg, #1e293b, #000000);
  text-transform: uppercase;
  letter-spacing: 0.08em;
  font-size: 0.8rem;
  border-bottom: 3px solid #bb0000;
}

.public-table tbody tr {
  transition: all 0.3s ease;
  border-left: 4px solid transparent;
}

.public-table tbody tr:hover {
  background: #f0fdf4;
  border-left-color: #006600;
  box-shadow: inset 0 0 8px rgba(0, 102, 0, 0.1);
}

.public-table tbody tr:last-child td {
  border-bottom: none;
}

.public-table strong {
  color: #1e293b;
  font-weight: 700;
}

.progress-cell {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.progress-bar {
  flex-shrink: 0;
  width: 100px;
  height: 6px;
  background: var(--color-border);
  border-radius: 3px;
  overflow: hidden;
}

.progress-bar .fill {
  height: 100%;
  border-radius: 3px;
  transition: width 0.3s ease;
}

.progress-text {
  font-size: 0.875rem;
  font-weight: 600;
  min-width: 40px;
}

.county-details-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 1.5rem;
  margin-top: 1rem;
}

.detail-card {
  background: var(--color-background);
  padding: 1.5rem;
  border-radius: var(--radius-md);
  border-left: 4px solid var(--color-accent);
  display: flex;
  flex-direction: column;
}

.detail-label {
  font-size: 0.875rem;
  color: var(--color-text-muted);
  margin-bottom: 0.5rem;
}

.detail-value {
  font-size: 2rem;
  font-weight: 800;
  color: var(--color-primary);
}

.detail-value.completed {
  color: #10b981;
}

.detail-value.ongoing {
  color: #0ea5e9;
}

.detail-value.delayed {
  color: #f59e0b;
}

.detail-value.pending {
  color: #8b5cf6;
}

.loading-state,
.empty-state {
  text-align: center;
  padding: 2rem;
  color: var(--color-text-muted);
}

.submissions-table-wrapper {
  margin-top: 2rem;
}

.table-title {
  font-size: 1.1rem;
  font-weight: 700;
  color: var(--color-primary);
  margin-bottom: 1rem;
}

.submissions-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1rem;
}

.submissions-table th,
.submissions-table td {
  padding: 1.5rem;
  text-align: left;
  border-bottom: 1px solid #e2e8f0;
  font-size: 0.95rem;
  color: #1e293b;
  font-weight: 500;
}

.submissions-table strong {
  color: #1e293b;
  font-weight: 700;
}

.submissions-table th {
  font-weight: 700;
  color: white;
  background: linear-gradient(135deg, #1e293b, #000000);
  text-transform: uppercase;
  letter-spacing: 0.08em;
  font-size: 0.8rem;
  border-bottom: 3px solid #bb0000;
}

.submissions-table tbody tr {
  transition: all 0.3s ease;
  border-left: 4px solid transparent;
}

.submissions-table tbody tr:hover {
  background: #f0fdf4;
  border-left-color: #006600;
  box-shadow: inset 0 0 8px rgba(0, 102, 0, 0.1);
}

.submissions-table td small {
  color: var(--color-text-muted);
}

.submissions-table tbody tr:last-child td {
  border-bottom: none;
}

.county-news {
  padding: 2rem 0;
  background: var(--color-background);
}

.mb-4 {
  margin-bottom: 2rem;
}

.heading-2 {
  font-size: 1.875rem;
  font-weight: 800;
  margin: 0;
  padding: 0.5rem 0 0.5rem 1rem;
  border-left: 5px solid #bb0000;
  color: #1e293b;
}

.news-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 2rem;
}

.news-card {
  background: white;
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: 1.5rem;
  transition: all 0.2s;
}

.news-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-lg);
  border-color: var(--color-accent);
}

.news-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.75rem;
}

.county-badge {
  background: var(--color-accent);
  color: white;
  font-size: 0.7rem;
  font-weight: 700;
  padding: 0.35rem 0.75rem;
  border-radius: 2rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.news-date {
  font-size: 0.875rem;
  color: var(--color-text-muted);
}

.news-title {
  font-size: 1.125rem;
  font-weight: 700;
  color: var(--color-primary);
  margin: 0 0 0.5rem;
}

.news-desc {
  color: var(--color-text);
  line-height: 1.6;
  margin-bottom: 1rem;
  font-size: 0.95rem;
}

.news-footer {
  border-top: 1px solid var(--color-border);
  padding-top: 0.75rem;
  font-size: 0.875rem;
  color: var(--color-text-muted);
  font-style: italic;
}

.data-section {
  padding: 3rem 0;
  background: white;
  border-bottom: 1px solid var(--color-border);
}

.items-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  gap: 1rem;
}

.item-card {
  background: white;
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  padding: 1.5rem;
  text-align: center;
  transition: all 0.2s ease;
}

.item-card:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
  border-color: var(--color-accent);
}

.item-number {
  font-size: 0.8rem;
  color: var(--color-accent);
  font-weight: 700;
  text-transform: uppercase;
  margin-bottom: 0.5rem;
}

.item-name {
  font-size: 1rem;
  font-weight: 600;
  color: var(--color-primary);
}

.mb-4 {
  margin-bottom: 2rem;
}

@media (max-width: 768px) {
  .national-stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .profile-stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .county-details-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .news-grid {
    grid-template-columns: 1fr;
  }
}
</style>
