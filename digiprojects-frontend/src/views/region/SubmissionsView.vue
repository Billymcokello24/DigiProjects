<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import api from '@/api/axios'
import BaseCard from '@/components/ui/BaseCard.vue'

const authStore = useAuthStore()
const user = computed(() => authStore.user)
const submissions = ref([])
const isLoading = ref(false)

const fetchSubmissions = async () => {
  isLoading.value = true
  try {
    const response = await api.get('/submissions')
    submissions.value = response.data.slice(0, 10) // Limit to first 10
  } catch (err) {
    console.error('Failed to load submissions:', err)
  } finally {
    isLoading.value = false
  }
}

const formatDate = (date) => {
  return new Date(date).toLocaleDateString()
}

onMounted(() => {
  fetchSubmissions()
})
</script>

<template>
  <div class="container">
    <div class="header">
      <h1>Regional Submissions</h1>
      <p class="subtitle">All submissions from your region</p>
    </div>

    <div v-if="isLoading" class="loading">
      <div class="spinner"></div>
      Loading submissions...
    </div>

    <BaseCard v-else class="submissions-card">
      <div v-if="submissions.length === 0" class="empty-state">
        <p>No submissions found.</p>
      </div>
      <div v-else class="table-responsive">
        <table class="submissions-table">
          <thead>
            <tr>
              <th>Project Type</th>
              <th>Site</th>
              <th>Status</th>
              <th>Date</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="submission in submissions" :key="submission.id">
              <td>{{ submission.project_type }}</td>
              <td>{{ submission.site }}</td>
              <td>
                <span class="badge" :class="'badge-' + submission.status.toLowerCase()">
                  {{ submission.status }}
                </span>
              </td>
              <td>{{ formatDate(submission.created_at) }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </BaseCard>
  </div>
</template>

<style scoped>
.container {
  padding: 2rem;
}

.header {
  margin-bottom: 2rem;
}

.header h1 {
  font-size: 2rem;
  font-weight: 700;
  color: #1f2937;
  margin: 0;
}

.subtitle {
  color: #6b7280;
  margin-top: 0.5rem;
}

.loading {
  text-align: center;
  padding: 3rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
  color: #666;
}

.spinner {
  width: 2rem;
  height: 2rem;
  border: 3px solid #e5e7eb;
  border-top-color: #3b82f6;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.submissions-card {
  padding: 1.5rem;
}

.empty-state {
  padding: 2rem;
  text-align: center;
  color: #999;
}

.table-responsive {
  overflow-x: auto;
}

.submissions-table {
  width: 100%;
  border-collapse: collapse;
}

.submissions-table thead {
  background-color: #f3f4f6;
}

.submissions-table th {
  padding: 0.75rem;
  text-align: left;
  font-weight: 600;
  color: #1f2937;
  border-bottom: 2px solid #e5e7eb;
}

.submissions-table td {
  padding: 0.75rem;
  border-bottom: 1px solid #e5e7eb;
}

.submissions-table tbody tr:hover {
  background-color: #f9fafb;
}

.badge {
  display: inline-block;
  padding: 0.25rem 0.75rem;
  border-radius: 9999px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
}

.badge-up {
  background-color: #dcfce7;
  color: #166534;
}

.badge-down {
  background-color: #fee2e2;
  color: #991b1b;
}

.badge-maintenance {
  background-color: #fef3c7;
  color: #92400e;
}
</style>
