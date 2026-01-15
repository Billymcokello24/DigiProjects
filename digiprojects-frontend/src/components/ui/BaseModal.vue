<script setup>
import { onMounted, onUnmounted } from 'vue'

const props = defineProps({
  show: {
    type: Boolean,
    required: true
  },
  title: {
    type: String,
    default: 'Details'
  },
  size: {
    type: String,
    default: 'md' // sm, md, lg, xl
  }
})

const emit = defineEmits(['close'])

const closeOnEsc = (e) => {
  if (e.key === 'Escape' && props.show) {
    emit('close')
  }
}

onMounted(() => window.addEventListener('keydown', closeOnEsc))
onUnmounted(() => window.removeEventListener('keydown', closeOnEsc))
</script>

<template>
  <Teleport to="body">
    <Transition name="modal-fade">
      <div v-if="show" class="modal-backdrop" @click.self="emit('close')">
        <div :class="['modal-container', `modal-${size}`]">
          <div class="modal-header">
            <h3>{{ title }}</h3>
            <button class="close-btn" @click="emit('close')">&times;</button>
          </div>
          
          <div class="modal-body">
            <slot></slot>
          </div>
          
          <div class="modal-footer" v-if="$slots.footer">
            <slot name="footer"></slot>
          </div>
          <div class="modal-footer v-else">
            <button class="modal-close-action" @click="emit('close')">Close</button>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.modal-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.4);
  backdrop-filter: blur(4px);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 9999;
  padding: 1rem;
}

.modal-container {
  background: #fff;
  border-radius: 16px;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
  display: flex;
  flex-direction: column;
  max-height: 90vh;
  width: 100%;
  animation: modal-slide-up 0.3s ease-out;
}

@keyframes modal-slide-up {
  from { transform: translateY(20px); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}

.modal-sm { max-width: 400px; }
.modal-md { max-width: 600px; }
.modal-lg { max-width: 800px; }
.modal-xl { max-width: 1140px; }

.modal-header {
  padding: 1.5rem;
  border-bottom: 1px solid #f3f4f6;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-header h3 {
  margin: 0;
  font-size: 1.25rem;
  font-weight: 800;
  color: #111;
}

.close-btn {
  background: transparent;
  border: none;
  font-size: 1.5rem;
  color: #6b7280;
  cursor: pointer;
  padding: 0.5rem;
  line-height: 1;
  transition: color 0.2s;
}

.close-btn:hover {
  color: #BB0000;
}

.modal-body {
  padding: 1.5rem;
  overflow-y: auto;
}

.modal-footer {
  padding: 1rem 1.5rem;
  border-top: 1px solid #f3f4f6;
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
}

.modal-close-action {
  background: #f3f4f6;
  border: none;
  padding: 0.6rem 1.25rem;
  border-radius: 8px;
  font-weight: 700;
  color: #374151;
  cursor: pointer;
  transition: all 0.2s;
}

.modal-close-action:hover {
  background: #e5e7eb;
}

/* Transitions */
.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity 0.3s ease;
}

.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
}
</style>
