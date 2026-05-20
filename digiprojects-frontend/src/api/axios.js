import axios from 'axios'

const api = axios.create({
    baseURL: '/api', // use relative base so dev proxy will be applied
    withCredentials: true,
    headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
    }
})

// Session-based auth handles cookies automatically with withCredentials: true
// No need for Bearer token interceptor for session auth

export default api
