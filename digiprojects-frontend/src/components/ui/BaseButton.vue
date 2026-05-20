<script setup>
defineProps({
  variant: {
    type: String,
    default: 'primary', // primary, secondary, outline, ghost
    validator: (value) => ['primary', 'secondary', 'outline', 'ghost', 'text'].includes(value)
  },
  size: {
    type: String,
    default: 'md', // sm, md, lg
    validator: (value) => ['sm', 'md', 'lg'].includes(value)
  },
  block: {
    type: Boolean,
    default: false
  },
  to: {
    type: [String, Object],
    default: null
  }
})
</script>

<template>
  <component
    :is="to ? 'RouterLink' : 'button'"
    :to="to"
    class="base-button"
    :class="[`variant-${variant}`, `size-${size}`, { 'is-block': block }]"
  >
    <slot />
  </component>
</template>

<style scoped>
.base-button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  border-radius: var(--radius-md);
  transition: all 0.2s ease;
  font-family: var(--font-family);
  text-decoration: none;
  border: 1px solid transparent;
  cursor: pointer;
}

.base-button:active {
  transform: translateY(1px);
}

/* Variants */
.variant-primary {
  background-color: var(--color-accent);
  color: #fff;
  box-shadow: 0 4px 14px 0 rgba(14, 165, 233, 0.39);
}

.variant-primary:hover {
  background-color: var(--color-accent-hover);
  box-shadow: 0 6px 20px rgba(14, 165, 233, 0.23);
  transform: translateY(-1px);
}

.variant-secondary {
  background-color: var(--color-primary-light);
  color: var(--color-surface);
  border: 1px solid var(--color-border);
}

.variant-secondary:hover {
  background-color: var(--color-primary);
  border-color: var(--color-text-muted);
}

.variant-outline {
  background-color: transparent;
  border: 1px solid var(--color-accent);
  color: var(--color-accent);
}

.variant-outline:hover {
  background-color: rgba(14, 165, 233, 0.05);
}

.variant-ghost {
  background-color: transparent;
  color: var(--color-text);
}

.variant-ghost:hover {
  background-color: rgba(0, 0, 0, 0.05);
}

.variant-text {
  background-color: transparent;
  color: var(--color-accent);
}

/* Sizes */
.size-sm {
  padding: 0.25rem 0.75rem;
  font-size: 0.875rem;
}

.size-md {
  padding: 0.5rem 1.25rem;
  font-size: 1rem;
}

.size-lg {
  padding: 0.75rem 2rem;
  font-size: 1.125rem;
}

.is-block {
  display: flex;
  width: 100%;
}
</style>
