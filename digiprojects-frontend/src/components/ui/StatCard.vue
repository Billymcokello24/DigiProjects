<script setup>
defineProps({
  label: {
    type: String,
    required: true
  },
  value: {
    type: [String, Number],
    required: true
  },
  icon: {
    type: String,
    default: '📊'
  },
  trend: {
    type: String,
    default: ''
  },
  variant: {
    type: String,
    default: 'primary' // primary, success, warning, danger
  }
})
</script>

<template>
  <div :class="['stat-card', variant]">
    <div class="stat-icon-bg">{{ icon }}</div>
    <div class="stat-content">
      <div class="stat-header">
        <span class="stat-label">{{ label }}</span>
        <div class="stat-icon-circle">{{ icon }}</div>
      </div>
      <div class="stat-main">
        <h2 class="stat-value">{{ value }}</h2>
        <span v-if="trend" class="stat-trend">{{ trend }}</span>
      </div>
    </div>
    <div class="stat-footer-accent"></div>
  </div>
</template>

<style scoped>
.stat-card {
  position: relative;
  background: #fff;
  border-radius: 16px;
  padding: 1.5rem;
  border: 1px solid #e5e7eb;
  overflow: hidden;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  min-height: 140px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.05);
}

.stat-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.05), 0 10px 10px -5px rgba(0, 0, 0, 0.02);
  border-color: #d1d5db;
}

/* Watermark Icon */
.stat-icon-bg {
  position: absolute;
  right: -10px;
  bottom: -10px;
  font-size: 5rem;
  opacity: 0.03;
  transform: rotate(-15deg);
  pointer-events: none;
}

.stat-content {
  position: relative;
  z-index: 2;
}

.stat-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.stat-label {
  font-size: 0.85rem;
  font-weight: 700;
  color: #6b7280;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.stat-icon-circle {
  width: 36px;
  height: 36px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
  background: #f3f4f6;
}

.stat-main {
  display: flex;
  align-items: baseline;
  gap: 0.5rem;
}

.stat-value {
  font-size: 2.25rem;
  font-weight: 900;
  color: #111;
  margin: 0;
  line-height: 1;
}

.stat-trend {
  font-size: 0.75rem;
  font-weight: 800;
  padding: 0.2rem 0.5rem;
  border-radius: 20px;
  background: rgba(0, 102, 0, 0.1);
  color: #006600;
}

.stat-footer-accent {
  position: absolute;
  bottom: 0;
  left: 0;
  width: 30%;
  height: 4px;
  background: #BB0000;
  border-radius: 0 4px 0 0;
}

/* Variants */
.primary .stat-footer-accent { background: #000; }
.primary .stat-icon-circle { background: rgba(0,0,0,0.05); color: #000; }

.success .stat-footer-accent { background: #006600; }
.success .stat-icon-circle { background: rgba(0, 102, 0, 0.1); color: #006600; }

.warning .stat-footer-accent { background: #f59e0b; }
.warning .stat-icon-circle { background: rgba(245, 158, 11, 0.1); color: #f59e0b; }
.warning .stat-value { color: #d97706; }

.danger .stat-footer-accent { background: #BB0000; }
.danger .stat-icon-circle { background: rgba(187, 0, 0, 0.1); color: #BB0000; }
.danger .stat-value { color: #BB0000; }

@media (max-width: 640px) {
  .stat-value { font-size: 1.75rem; }
}
</style>
