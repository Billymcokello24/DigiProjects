import axios from 'axios'

const api = axios.create({
    baseURL: 'http://localhost:8000/api',
    withCredentials: true,
    headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
    }
})

// Session-based auth handles cookies automatically with withCredentials: true
// No need for Bearer token interceptor for session auth

export default api

