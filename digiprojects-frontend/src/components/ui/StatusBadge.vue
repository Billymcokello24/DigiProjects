<script setup>
defineProps({
  status: {
    type: String, // success, warning, danger, info, neutral
    default: 'neutral'
  }
})
</script>

<template>
  <span class="status-badge" :class="`status-${status}`">
    <slot />
  </span>
</template>

<style scoped>
.status-badge {
  display: inline-flex;
  align-items: center;
  padding: 0.25rem 0.625rem;
  font-size: 0.75rem;
  font-weight: 600;
  border-radius: 999px;
  text-transform: uppercase;
  letter-spacing: 0.025em;
  white-space: nowrap;
}

.status-success {
  background-color: rgba(16, 185, 129, 0.1);
  color: #059669;
}

.status-warning {
  background-color: rgba(245, 158, 11, 0.1);
  color: #d97706;
}

.status-danger {
  background-color: rgba(239, 68, 68, 0.1);
  color: #dc2626;
}

.status-info {
  background-color: rgba(14, 165, 233, 0.1);
  color: #0284c7;
}

.status-neutral {
  background-color: rgba(100, 116, 139, 0.1);
  color: #475569;
}
</style>
