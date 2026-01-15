<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import api from '@/api/axios'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import BaseTable from '@/components/ui/BaseTable.vue'

const authStore = useAuthStore()
const user = computed(() => authStore.user)

const counties = ref([])
const isLoading = ref(false)
const errorMessage = ref('')

const columns = ['County', 'Officers', 'Submissions', 'Status']

const fetchCounties = async () => {
  isLoading.value = true
  try {
    const response = await api.get('/counties')
    counties.value = response.data
  } catch (err) {
    errorMessage.value = 'Failed to load counties'
    console.error(err)
  } finally {
    isLoading.value = false
  }
}

onMounted(() => {
  fetchCounties()
})
</script>

<template>
  <div class="counties-view">
    <BaseCard>
      <template #header>
        <div class="header-actions">
          <h3>Counties in {{ user?.region }} Region</h3>
          <BaseButton variant="outline" size="sm" @click="fetchCounties" :disabled="isLoading">
            {{ isLoading ? 'Loading...' : 'Refresh' }}
          </BaseButton>
        </div>
      </template>

      <div v-if="errorMessage" class="alert alert-error">
        {{ errorMessage }}
        <BaseButton variant="text" size="sm" @click="fetchCounties">Retry</BaseButton>
      </div>

      <div v-if="isLoading" class="loading">Loading counties...</div>

      <div v-else-if="counties.length === 0" class="empty-state">
        <p>No counties found in your region.</p>
      </div>

      <BaseTable v-else :columns="columns">
        <tr v-for="county in counties" :key="county.id">
          <td class="font-bold">{{ county.name }}</td>
          <td class="text-center">{{ county.officers_count || 0 }}</td>
          <td class="text-center">{{ county.submissions_count || 0 }}</td>
          <td class="text-center">
            <span class="status-badge">{{ county.is_active ? 'ACTIVE' : 'INACTIVE' }}</span>
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
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
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
