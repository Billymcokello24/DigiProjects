<script setup>
defineProps({
  title: {
    type: String,
    default: ''
  }
})
</script>

<template>
  <div class="base-card">
    <div v-if="title || $slots.header" class="card-header">
      <h3 v-if="title" class="card-title">{{ title }}</h3>
      <slot name="header" />
    </div>
    
    <div class="card-body">
      <slot />
    </div>
    
    <div v-if="$slots.footer" class="card-footer">
      <slot name="footer" />
    </div>
  </div>
</template>

<style scoped>
.base-card {
  background: #fff;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
  border: 1px solid var(--color-border);
  overflow: hidden;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.card-header {
  padding: 1.25rem 1.5rem;
  border-bottom: 1px solid var(--color-border);
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.card-title {
  font-size: 1.125rem;
  font-weight: 600;
  color: var(--color-primary);
  margin: 0;
}

.card-body {
  padding: 1.5rem;
  flex: 1;
}

.card-footer {
  padding: 1rem 1.5rem;
  background: var(--color-background);
  border-top: 1px solid var(--color-border);
}
</style>
