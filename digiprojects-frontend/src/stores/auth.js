import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import axios from 'axios'
import api from '@/api/axios'

// Separate axios instance for non-API endpoints (like sanctum/csrf-cookie)
const sanctum = axios.create({
    baseURL: 'http://localhost:8000',
    withCredentials: true,
    headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
    }
})

export const useAuthStore = defineStore('auth', () => {
    const user = ref(null)
    const isInitialized = ref(false)

    // Initialize auth state from session
    async function initializeAuth() {
        if (isInitialized.value) return
        
        try {
            // Check if user has active session
            const response = await api.get('/user')
            if (response.data) {
                user.value = response.data
            }
        } catch (error) {
            // No active session, user is not authenticated
            user.value = null
        } finally {
            isInitialized.value = true
        }
    }

    // Real login function
    async function login(credentials) {
        try {
            // Get CSRF token from Sanctum endpoint (outside /api prefix)
            await sanctum.get('/sanctum/csrf-cookie')
            // Then login with API
            const response = await api.post('/login', credentials)
            user.value = response.data
            return user.value
        } catch (error) {
            console.error('Login failed:', error)
            throw error
        }
    }

    async function logout() {
        try {
            await api.post('/logout')
        } catch (error) {
            console.error('Logout failed:', error)
        } finally {
            user.value = null
        }
    }

    const isAuthenticated = computed(() => !!user.value)
    const isCountyOfficer = computed(() => user.value?.role === 'COUNTY_OFFICER')
    const isRegionalOfficer = computed(() => user.value?.role === 'REGIONAL_OFFICER')
    const isAdmin = computed(() => user.value?.role === 'ADMIN')

    return {
        user,
        login,
        logout,
        initializeAuth,
        isInitialized,
        isAuthenticated,
        isCountyOfficer,
        isRegionalOfficer,
        isAdmin
    }
})
