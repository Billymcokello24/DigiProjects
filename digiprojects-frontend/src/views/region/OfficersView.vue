<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import api from '@/api/axios'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseTable from '@/components/ui/BaseTable.vue'

const authStore = useAuthStore()
const user = computed(() => authStore.user)

const officers = ref([])
const counties = ref([])
const isLoading = ref(false)
const errorMessage = ref('')

const columns = ['Name', 'Email', 'County', 'Status']

const fetchOfficers = async () => {
  isLoading.value = true
  try {
    const response = await api.get('/users')
    officers.value = response.data
  } catch (err) {
    errorMessage.value = 'Failed to load county officers'
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
    <BaseCard>
      <template #header>
        <div class="header-actions">
          <h3>County Officers in {{ user?.region }} Region</h3>
        </div>
      </template>

      <div v-if="errorMessage" class="alert alert-error">
        {{ errorMessage }}
      </div>

      <div v-if="isLoading" class="loading">Loading county officers...</div>

      <div v-else-if="officers.length === 0" class="empty-state">
        <p>No county officers found in your region.</p>
      </div>

      <BaseTable v-else :columns="columns">
        <tr v-for="officer in officers" :key="officer.id">
          <td class="font-bold">{{ officer.name }}</td>
          <td>{{ officer.email }}</td>
          <td class="text-center">
            <span class="badge">{{ getCountyName(officer.county_id) }}</span>
          </td>
          <td class="text-center">
            <span class="status-badge">ACTIVE</span>
          </td>
        </tr>
      </BaseTable>
    </BaseCard>
  </div>
</template>

<style scoped>
.header-actions {
  display: flex;
  justify-content: space-between;
  width: 100%;
  align-items: center;
}

.font-bold { font-weight: 600; }
.text-center { text-align: center; }

.alert {
  padding: 1rem;
  border-radius: 0.5rem;
  margin-bottom: 1rem;
  border-left: 4px solid;
}

.alert-error {
  background-color: #fee2e2;
  color: #991b1b;
  border-left-color: #fca5a5;
}

.loading {
  padding: 2rem;
  text-align: center;
  color: #666;
}

.empty-state {
  padding: 2rem;
  text-align: center;
  color: #666;
}

.badge {
  display: inline-block;
  padding: 0.35rem 1rem;
  border-radius: 9999px;
  font-size: 0.75rem;
  font-weight: 600;
  background-color: #dbeafe;
  color: #1e40af;
}

.status-badge {
  display: inline-block;
  padding: 0.35rem 1rem;
  border-radius: 9999px;
  font-size: 0.75rem;
  font-weight: 600;
  background-color: #dcfce7;
  color: #166534;
}

@media (max-width: 768px) {
  .header-actions {
    flex-direction: column;
    align-items: flex-start;
  }
}
</style>
