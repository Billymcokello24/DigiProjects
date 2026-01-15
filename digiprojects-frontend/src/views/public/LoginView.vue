<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import api from '@/api/axios'
import BaseInput from '@/components/ui/BaseInput.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import ictaLogo from '@/assets/icta-logo.png'

const email = ref('')
const password = ref('')
const isLoading = ref(false)
const error = ref('')
const showForgotPassword = ref(false)
const forgotEmail = ref('')
const forgotPassword = ref('')
const forgotPasswordConfirm = ref('')
const forgotError = ref('')
const forgotSuccess = ref('')
const forgotLoading = ref(false)

const router = useRouter()
const authStore = useAuthStore()

const handleLogin = async () => {
  if (!email.value || !password.value) {
    error.value = 'Please fill in all fields'
    return
  }
  
  error.value = ''
  isLoading.value = true
  
  try {
    const user = await authStore.login({ email: email.value, password: password.value })
    console.log('Login successful, user:', user)
    console.log('User role:', user.role)
    
    // Wait for auth store to update before redirecting
    await new Promise(resolve => setTimeout(resolve, 100))
    
    if (user.role === 'ADMIN') {
      console.log('Redirecting to /admin')
      await router.push('/admin')
    } else if (user.role === 'REGIONAL_OFFICER') {
      console.log('Redirecting to /region')
      await router.push('/region')
    } else {
      console.log('Redirecting to /county')
      await router.push('/county')
    }
  } catch (err) {
    console.error('Login error:', err)
    error.value = 'Invalid email or password'
  } finally {
    isLoading.value = false
  }
}

const openForgotPassword = () => {
  showForgotPassword.value = true
  forgotError.value = ''
  forgotSuccess.value = ''
  forgotEmail.value = ''
  forgotPassword.value = ''
  forgotPasswordConfirm.value = ''
}

const closeForgotPassword = () => {
  showForgotPassword.value = false
}

const handleForgotPassword = async () => {
  forgotError.value = ''
  forgotSuccess.value = ''
  
  if (!forgotEmail.value || !forgotPassword.value || !forgotPasswordConfirm.value) {
    forgotError.value = 'Please fill in all fields'
    return
  }
  
  if (forgotPassword.value !== forgotPasswordConfirm.value) {
    forgotError.value = 'Passwords do not match'
    return
  }
  
  if (forgotPassword.value.length < 6) {
    forgotError.value = 'Password must be at least 6 characters'
    return
  }
  
  forgotLoading.value = true
  
  try {
    const response = await api.post('/auth/reset-password', {
      email: forgotEmail.value,
      password: forgotPassword.value,
      password_confirmation: forgotPasswordConfirm.value
    })
    
    forgotSuccess.value = 'Password reset successfully! You can now login with your new password.'
    
    // Reset form and close modal after 2 seconds
    setTimeout(() => {
      closeForgotPassword()
    }, 2000)
  } catch (err) {
    console.error('Password reset error:', err)
    forgotError.value = err.response?.data?.message || 'Failed to reset password. Please check your email and try again.'
  } finally {
    forgotLoading.value = false
  }
}
</script>

<template>
  <div class="login-view">
    <div class="login-container">
      <div class="login-header">
        <img :src="ictaLogo" alt="ICTA Logo" class="logo-image" />
        <h1 class="heading-2">Welcome Back</h1>
        <p class="text-muted text-sm">Sign in to DigiProjects Portal</p>
      </div>
      
      <form @submit.prevent="handleLogin" class="login-form">
        <BaseInput 
          id="email" 
          v-model="email" 
          label="Email Address" 
          type="email"
          placeholder="officer@mombasa.go.ke" 
        />
        
        <BaseInput 
          id="password" 
          v-model="password" 
          label="Password" 
          type="password"
          placeholder="••••••••" 
        />
        
        <div v-if="error" class="form-error">
          {{ error }}
        </div>
        
        <BaseButton 
          variant="primary" 
          block 
          size="lg" 
          :disabled="isLoading"
          class="login-btn"
        >
          {{ isLoading ? 'Signing In...' : 'Sign In' }}
        </BaseButton>
        
        <div class="form-footer">
          <button 
            type="button"
            @click="openForgotPassword"
            class="forgot-link"
          >
            Forgot password?
          </button>
        </div>
      </form>
      
      <div class="login-footer">
        <p class="text-sm text-muted">Technical Support: helpdesk@icta.go.ke</p>
      </div>
    </div>

    <!-- Forgot Password Modal -->
    <div v-if="showForgotPassword" class="modal-overlay" @click.self="closeForgotPassword">
      <div class="modal-content">
        <div class="modal-header">
          <h2>Reset Password</h2>
          <button type="button" @click="closeForgotPassword" class="close-btn">✕</button>
        </div>
        
        <div class="modal-body">
          <form @submit.prevent="handleForgotPassword" class="forgot-form">
            <BaseInput 
              id="forgot-email" 
              v-model="forgotEmail" 
              label="Email Address" 
              type="email"
              placeholder="your@email.com"
              :disabled="forgotLoading"
            />
            
            <BaseInput 
              id="forgot-password" 
              v-model="forgotPassword" 
              label="New Password" 
              type="password"
              placeholder="••••••••"
              :disabled="forgotLoading"
            />
            
            <BaseInput 
              id="forgot-password-confirm" 
              v-model="forgotPasswordConfirm" 
              label="Confirm Password" 
              type="password"
              placeholder="••••••••"
              :disabled="forgotLoading"
            />
            
            <div v-if="forgotError" class="form-error">
              {{ forgotError }}
            </div>
            
            <div v-if="forgotSuccess" class="form-success">
              {{ forgotSuccess }}
            </div>
            
            <div class="modal-actions">
              <BaseButton 
                variant="secondary" 
                @click="closeForgotPassword"
                :disabled="forgotLoading"
              >
                Cancel
              </BaseButton>
              <BaseButton 
                variant="primary" 
                type="submit"
                :disabled="forgotLoading"
              >
                {{ forgotLoading ? 'Resetting...' : 'Reset Password' }}
              </BaseButton>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.login-view {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: calc(100vh - 70px); /* Minus navbar */
  padding: 2rem;
  background: radial-gradient(circle at center, #f8fafc 0%, #e2e8f0 100%);
}

.login-container {
  width: 100%;
  max-width: 420px;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(12px);
  border: 1px solid #fff;
  border-radius: var(--radius-xl);
  box-shadow: var(--shadow-xl);
  padding: 2.5rem;
}

.login-header {
  text-align: center;
  margin-bottom: 2rem;
}

.logo-image {
  max-width: 150px;
  height: auto;
  margin-bottom: 1rem;
  object-fit: contain;
}

.login-form {
  margin-bottom: 1.5rem;
}

.login-btn {
  margin-top: 1rem;
}

.form-error {
  background-color: rgba(239, 68, 68, 0.1);
  color: var(--color-danger);
  padding: 0.75rem;
  border-radius: var(--radius-md);
  font-size: 0.875rem;
  margin-bottom: 1rem;
  text-align: center;
}

.form-success {
  background-color: rgba(34, 197, 94, 0.1);
  color: #16a34a;
  padding: 0.75rem;
  border-radius: var(--radius-md);
  font-size: 0.875rem;
  margin-bottom: 1rem;
  text-align: center;
}

.form-footer {
  text-align: center;
  margin-top: 1rem;
}

.forgot-link {
  font-size: 0.875rem;
  color: var(--color-accent);
  background: none;
  border: none;
  cursor: pointer;
  text-decoration: underline;
  padding: 0;
}

.forgot-link:hover {
  opacity: 0.8;
}

.login-footer {
  text-align: center;
  padding-top: 1.5rem;
  border-top: 1px solid var(--color-border);
}

/* Modal Styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 2rem;
}

.modal-content {
  background: white;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-2xl);
  width: 100%;
  max-width: 450px;
  animation: slideIn 0.3s ease-out;
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(-20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  border-bottom: 1px solid var(--color-border);
}

.modal-header h2 {
  margin: 0;
  font-size: 1.25rem;
  color: #1f2937;
}

.close-btn {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: #6b7280;
  padding: 0;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--radius-md);
}

.close-btn:hover {
  background-color: #f3f4f6;
  color: #1f2937;
}

.modal-body {
  padding: 1.5rem;
}

.forgot-form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.modal-actions {
  display: flex;
  gap: 0.75rem;
  justify-content: flex-end;
  margin-top: 1.5rem;
  padding-top: 1rem;
  border-top: 1px solid var(--color-border);
}

.modal-actions button {
  flex: 1;
}

/* Mobile Responsive Styles */
@media (max-width: 768px) {
  .login-view {
    padding: 1rem;
    min-height: calc(100vh - 60px);
  }

  .login-container {
    max-width: 100%;
    padding: 1.5rem;
    border-radius: var(--radius-lg);
  }

  .logo-image {
    max-width: 120px;
    margin-bottom: 0.75rem;
  }

  .login-header h1 {
    font-size: 1.5rem !important;
  }

  .login-header p {
    font-size: 0.75rem;
  }

  .login-form {
    margin-bottom: 1rem;
  }

  .login-btn {
    margin-top: 0.75rem;
  }

  .modal-overlay {
    padding: 1rem;
  }

  .modal-content {
    max-width: 100%;
    border-radius: var(--radius-md);
  }

  .modal-header {
    padding: 1rem;
  }

  .modal-header h2 {
    font-size: 1.1rem;
  }

  .modal-body {
    padding: 1rem;
  }

  .modal-actions {
    flex-direction: column;
    gap: 0.5rem;
  }

  .modal-actions button {
    width: 100%;
  }
}

@media (max-width: 480px) {
  .login-view {
    padding: 0.75rem;
  }

  .login-container {
    padding: 1rem;
  }

  .login-header {
    margin-bottom: 1.5rem;
  }

  .logo-image {
    max-width: 100px;
  }

  .login-header h1 {
    font-size: 1.25rem !important;
  }

  .form-error,
  .form-success {
    font-size: 0.75rem;
    padding: 0.5rem;
  }

  .login-footer {
    padding-top: 1rem;
    font-size: 0.65rem;
  }
}
</style>
