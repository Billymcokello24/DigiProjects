<script setup>
import { ref, onMounted } from 'vue'
import api from '@/api/axios'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import BaseTable from '@/components/ui/BaseTable.vue'
import StatusBadge from '@/components/ui/StatusBadge.vue'

const counties = ref([])
const isLoading = ref(false)
const errorMessage = ref('')

const columns = [
  'Code',
  'County Name',
  'Region',
  'Status',
  'Actions'
]

const fetchCounties = async () => {
  isLoading.value = true
  errorMessage.value = ''
  try {
    const response = await api.get('/counties')
    counties.value = response.data.map((county, index) => ({
      id: county.id,
      code: String(index + 1).padStart(3, '0'),
      name: county.name,
      region: county.region?.name || 'Unknown',
      status: 'active'
    }))
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
           <h3>County Registry</h3>
           <BaseButton variant="outline" size="sm" @click="fetchCounties" :disabled="isLoading">{{ isLoading ? 'Loading...' : 'Refresh' }}</BaseButton>
        </div>
      </template>

      <div v-if="errorMessage" class="alert alert-error">
        {{ errorMessage }}
        <BaseButton variant="text" size="sm" @click="fetchCounties">Retry</BaseButton>
      </div>

      <div v-if="isLoading" class="loading">Loading counties...</div>

      <BaseTable v-else :columns="columns">
        <tr v-for="county in counties" :key="county.id">
          <td class="font-mono">{{ county.code }}</td>
          <td class="font-bold">{{ county.name }}</td>
          <td>{{ county.region }}</td>
          <td>
            <StatusBadge :status="county.status === 'active' ? 'success' : 'neutral'">
              {{ county.status }}
            </StatusBadge>
          </td>
          <td>
             <button class="action-btn">Manage Officers</button>
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

.font-mono { font-family: monospace; }
.font-bold { font-weight: 600; }

.action-btn {
  font-size: 0.875rem;
  color: var(--color-accent);
}
</style>
