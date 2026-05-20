import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import axios from 'axios'
import api from '@/api/axios'

// Separate axios instance for non-API endpoints (like sanctum/csrf-cookie)
const sanctum = axios.create({
    baseURL: '/sanctum',
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
            // Get CSRF token from Sanctum endpoint (proxied to backend)
            await sanctum.get('/csrf-cookie')

            // Then login with API
            const response = await api.post('/login', credentials)

            // After login, confirm session by calling /user
            try {
                const userResp = await api.get('/user')
                user.value = userResp.data
            } catch (err) {
                // If GET /user fails, clear user to be safe
                user.value = null
                console.error('Failed to confirm session after login:', err)
                throw err
            }

            return user.value
        } catch (error) {
            // Surface validation errors (422) and others
            console.error('Login failed:', error)
            if (error.response && error.response.status === 422) {
                // return the server validation response for the UI to show
                throw error.response.data
            }
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
