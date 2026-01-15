<script setup>
defineProps({
  columns: {
    type: Array, // Strings or Objects { key, label }
    default: () => []
  }
})
</script>

<template>
  <div class="table-container">
    <table class="base-table">
      <thead>
        <tr>
          <th v-for="(col, i) in columns" :key="i">
            {{ typeof col === 'string' ? col : col.label }}
          </th>
        </tr>
      </thead>
      <tbody>
        <slot />
      </tbody>
    </table>
  </div>
</template>

<style scoped>
.table-container {
  width: 100%;
  overflow-x: auto;
}

.base-table {
  width: 100%;
  border-collapse: collapse;
}

.base-table :deep(th), 
.base-table :deep(td) {
  padding: 0.75rem 1rem;
  text-align: left;
  border: 1px solid #e2e8f0; /* Light gray borders */
}

.base-table :deep(th) {
  background: var(--color-primary); /* Black Header */
  color: white;
  font-weight: 700;
  text-transform: uppercase;
  font-size: 0.8rem;
  letter-spacing: 0.05em;
  border: 1px solid #333; /* Darker border */
}

.base-table :deep(tr:nth-child(even)) {
  background-color: #f8fafc; /* Very light slate for striping */
}

.base-table :deep(tr:hover) {
  background-color: rgba(187, 0, 0, 0.05); /* Slight Red Tint on Hover for effect */
}

.base-table :deep(td) {
  font-size: 0.9rem;
  color: #334155;
}
</style>
