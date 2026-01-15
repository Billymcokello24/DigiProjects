<script setup>
defineProps({
  modelValue: {
    type: [String, Number],
    default: ''
  },
  label: {
    type: String,
    default: ''
  },
  type: {
    type: String,
    default: 'text'
  },
  placeholder: {
    type: String,
    default: ''
  },
  id: {
    type: String,
    required: true
  },
  error: {
    type: String,
    default: ''
  }
})

defineEmits(['update:modelValue'])
</script>

<template>
  <div class="base-input-wrapper">
    <label v-if="label" :for="id" class="input-label">{{ label }}</label>
    <div class="input-container">
      <input
        :id="id"
        :type="type"
        :value="modelValue"
        :placeholder="placeholder"
        @input="$emit('update:modelValue', $event.target.value)"
        class="base-input"
        :class="{ 'has-error': error }"
      />
    </div>
    <span v-if="error" class="input-error">{{ error }}</span>
  </div>
</template>

<style scoped>
.base-input-wrapper {
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
  margin-bottom: 1rem;
}

.input-label {
  font-size: 0.875rem;
  font-weight: 500;
  color: var(--color-text);
}

.base-input {
  width: 100%;
  padding: 0.625rem 0.875rem;
  font-size: 0.95rem;
  line-height: 1.5;
  color: var(--color-text);
  background-color: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  transition: all 0.2s ease;
  font-family: inherit;
}

.base-input:focus {
  outline: none;
  border-color: var(--color-accent);
  box-shadow: 0 0 0 3px rgba(14, 165, 233, 0.1);
}

.base-input::placeholder {
  color: var(--color-text-muted);
  opacity: 0.7;
}

.base-input.has-error {
  border-color: var(--color-danger);
}

.base-input.has-error:focus {
  box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.1);
}

.input-error {
  font-size: 0.75rem;
  color: var(--color-danger);
}
</style>
