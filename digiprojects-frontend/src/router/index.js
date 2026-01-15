import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes: [
        {
            path: '/',
            component: () => import('../components/layout/PublicLayout.vue'),
            children: [
                {
                    path: '',
                    name: 'home',
                    component: () => import('../views/public/HomeView.vue')
                },
                {
                    path: 'login',
                    name: 'login',
                    component: () => import('../views/public/LoginView.vue')
                },
                {
                    path: 'public-data',
                    name: 'public-data',
                    component: () => import('../views/public/PublicDataView.vue')
                }
            ]
        },
        {
            path: '/admin',
            component: () => import('../components/layout/DashboardLayout.vue'),
            meta: { requiresAuth: true, role: 'ADMIN' },
            children: [
                {
                    path: '',
                    name: 'admin-dashboard',
                    component: () => import('../views/admin/DashboardView.vue'),
                    meta: { title: 'National Overview' }
                },
                {
                    path: 'officers',
                    name: 'admin-officers',
                    component: () => import('../views/admin/OfficersView.vue'),
                    meta: { title: 'County Officers' }
                },
                {
                    path: 'regional-officers',
                    name: 'admin-regional-officers',
                    component: () => import('../views/admin/RegionalOfficersView.vue'),
                    meta: { title: 'Regional Officers' }
                },
                {
                    path: 'counties',
                    name: 'admin-counties',
                    component: () => import('../views/admin/CountyOfficersView.vue'),
                    meta: { title: 'County Management' }
                },
                {
                    path: 'county-reports',
                    name: 'admin-county-reports',
                    component: () => import('../views/admin/CountyReportsView.vue'),
                    meta: { title: 'County Reports' }
                },
                {
                    path: 'master-data',
                    name: 'admin-master-data',
                    component: () => import('../views/admin/MasterDataView.vue'),
                    meta: { title: 'System Configuration' }
                },
                {
                    path: 'collaboration',
                    name: 'admin-collaboration',
                    component: () => import('../views/admin/CollaborationView.vue'),
                    meta: { title: 'Communication Hub' }
                },
                {
                    path: 'audit',
                    name: 'admin-audit',
                    component: () => import('../views/admin/AuditView.vue'),
                    meta: { title: 'Audit Logs' }
                },
                {
                    path: 'settings',
                    name: 'admin-settings',
                    component: () => import('../views/admin/SettingsView.vue'),
                    meta: { title: 'Administration' }
                },
                {
                    path: 'projects',
                    name: 'admin-projects',
                    component: () => import('../views/admin/ProjectsView.vue'),
                    meta: { title: 'Projects & Phases' }
                }
            ]
        },
        {
            path: '/county',
            component: () => import('../components/layout/DashboardLayout.vue'),
            meta: { requiresAuth: true, role: 'COUNTY_OFFICER' },
            children: [
                {
                    path: '',
                    name: 'county-dashboard',
                    component: () => import('../views/county/DashboardView.vue'),
                    meta: { title: 'County Overview' }
                },
                {
                    path: 'submissions',
                    name: 'county-submissions',
                    component: () => import('../views/county/SubmissionsView.vue'),
                    meta: { title: 'My Submissions' }
                },
                {
                    path: 'submission/new',
                    name: 'new-submission',
                    component: () => import('../views/county/SubmissionFormView.vue'),
                    meta: { title: 'New Report' }
                },
                {
                    path: 'submission/edit/:id',
                    name: 'edit-submission',
                    component: () => import('../views/county/SubmissionFormView.vue'),
                    meta: { title: 'Edit Report' }
                }
            ]
        },
        {
            path: '/region',
            component: () => import('../components/layout/DashboardLayout.vue'),
            meta: { requiresAuth: true, role: 'REGIONAL_OFFICER' },
            children: [
                {
                    path: '',
                    name: 'region-dashboard',
                    component: () => import('../views/region/DashboardView.vue'),
                    meta: { title: 'Regional Overview' }
                },
                {
                    path: 'counties',
                    name: 'region-counties',
                    component: () => import('../views/region/CountiesView.vue'),
                    meta: { title: 'Regional Counties' }
                },
                {
                    path: 'counties/:id',
                    name: 'region-county-detail',
                    component: () => import('../views/region/CountyDetailView.vue'),
                    meta: { title: 'County Details' }
                },
                {
                    path: 'submissions',
                    name: 'region-submissions',
                    component: () => import('../views/region/SubmissionsView.vue'),
                    meta: { title: 'Regional Submissions' }
                },
                {
                    path: 'officers',
                    name: 'region-officers',
                    component: () => import('../views/region/OfficersView.vue'),
                    meta: { title: 'County Officers' }
                },
                {
                    path: 'officers/manage',
                    name: 'region-officers-manage',
                    component: () => import('../views/region/OfficersManageView.vue'),
                    meta: { title: 'Manage County Officers' }
                },
                {
                    path: 'reports',
                    name: 'region-reports',
                    component: () => import('../views/region/ReportsView.vue'),
                    meta: { title: 'Regional Reports' }
                }
            ]
        }
    ]
})

router.beforeEach(async (to, from, next) => {
    const authStore = useAuthStore()

    // Initialize auth state on first load
    if (!authStore.isInitialized) {
        await authStore.initializeAuth()
    }

    // Check if route requires authentication
    if (to.meta.requiresAuth) {
        if (!authStore.isAuthenticated) {
            // User is not authenticated, redirect to login
            next('/login')
        } else if (to.meta.role && authStore.user.role !== to.meta.role) {
            // User doesn't have the required role
            next('/login')
        } else {
            next()
        }
    } else {
        next()
    }
})

export default router
