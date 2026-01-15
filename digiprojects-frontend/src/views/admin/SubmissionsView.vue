<script setup>
import { ref } from 'vue'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import BaseTable from '@/components/ui/BaseTable.vue'
import StatusBadge from '@/components/ui/StatusBadge.vue'

const submissions = ref([
 { id: 101, project: 'NOFBI Phase II', county: 'Mombasa', submittedBy: 'John Doe', date: '2025-10-24', status: 'pending' },
 { id: 102, project: 'Public Wi-Fi', county: 'Nairobi', submittedBy: 'Alice Wambui', date: '2025-10-23', status: 'approved' },
 { id: 103, project: 'Jitume Labs', county: 'Kisumu', submittedBy: 'David Ochieng', date: '2025-10-22', status: 'rejected' },
])

const columns = [
  'Project',
  'County',
  'Submitted By',
  'Date',
  'Status',
  'Actions'
]

const approve = (id) => {
  if(confirm('Approve this submission? This will lock the record.')) {
     alert(`Submission #${id} Approved successfully.`)
  }
}

const reject = (id) => {
  const reason = prompt('Enter rejection reason (feedback for County Officer):')
  if (reason) {
    alert(`Submission #${id} Rejected.\nFeedback sent: "${reason}"`)
  }
}
</script>

<template>
  <div class="submissions-view">
    <BaseCard>
      <template #header>
        <div class="header-actions">
           <h3>Project Submissions</h3>
           <div class="filters">
             <select class="filter-select">
               <option>All Status</option>
               <option>Pending</option>
               <option>Approved</option>
             </select>
           </div>
        </div>
      </template>

      <BaseTable :columns="columns">
        <tr v-for="sub in submissions" :key="sub.id">
          <td class="font-bold">{{ sub.project }}</td>
          <td>{{ sub.county }}</td>
          <td>{{ sub.submittedBy }}</td>
          <td>{{ sub.date }}</td>
          <td>
            <StatusBadge :status="sub.status === 'approved' ? 'success' : sub.status === 'rejected' ? 'danger' : 'warning'">
              {{ sub.status }}
            </StatusBadge>
          </td>
          <td>
             <div v-if="sub.status === 'pending'" class="actions-group">
               <BaseButton variant="primary" size="sm" @click="approve(sub.id)">Approve</BaseButton>
               <BaseButton variant="ghost" size="sm" class="text-danger" @click="reject(sub.id)">Reject</BaseButton>
             </div>
             <BaseButton v-else variant="ghost" size="sm">View Details</BaseButton>
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

.filter-select {
  padding: 0.25rem 0.5rem;
  border: 1px solid var(--color-border);
  border-radius: var(--radius-sm);
}

.font-bold { font-weight: 600; }

.actions-group {
  display: flex;
  gap: 0.5rem;
}

.text-danger { color: var(--color-danger) !important; }
</style>
