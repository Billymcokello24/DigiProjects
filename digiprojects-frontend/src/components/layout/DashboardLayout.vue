<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { RouterView, RouterLink, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()
const router = useRouter()
const user = computed(() => authStore.user)

const isCollapsed = ref(false)
const isMobile = ref(false)
const showMobileMenu = ref(false)

const handleLogout = () => {
  authStore.logout()
  router.push('/login')
}

const toggleSidebar = () => {
  if (isMobile.value) {
    showMobileMenu.value = !showMobileMenu.value
  } else {
    isCollapsed.value = !isCollapsed.value
  }
}

const checkMobile = () => {
  isMobile.value = window.innerWidth <= 1024
  if (!isMobile.value) {
    showMobileMenu.value = false
  }
}

onMounted(() => {
  checkMobile()
  window.addEventListener('resize', checkMobile)
})

onUnmounted(() => {
  window.removeEventListener('resize', checkMobile)
})
</script>

<template>
  <div class="duralux-layout" :class="{ 'sidebar-collapsed': isCollapsed, 'mobile-view': isMobile }">
    <!-- Sidebar Overlay for Mobile -->
    <div v-if="isMobile && showMobileMenu" class="mobile-overlay" @click="showMobileMenu = false"></div>

    <!-- Sidebar -->
    <aside class="sidebar" :class="{ 'is-collapsed': isCollapsed, 'show-mobile': showMobileMenu }">
      <div class="sidebar-header">
        <div class="logo">
           <img src="@/assets/icta-logo.png" alt="ICTA Logo" class="logo-img" />
           <span v-if="!isCollapsed" class="logo-text">DigiProjects</span>
        </div>
      </div>
      
      <nav class="sidebar-nav">
        <!-- NAVIGATION GROUPS -->
        <div class="nav-group">
          <label v-if="!isCollapsed">Main</label>
          <RouterLink :to="user?.role === 'ADMIN' ? '/admin' : user?.role === 'REGIONAL_OFFICER' ? '/region' : '/county'" class="nav-item" exact-active-class="active" @click="isMobile ? showMobileMenu = false : null">
            <span class="nav-icon">📊</span>
            <span v-if="!isCollapsed" class="nav-label">{{ user?.role === 'ADMIN' ? 'National Overview' : user?.role === 'REGIONAL_OFFICER' ? 'Regional Overview' : 'Dashboard' }}</span>
          </RouterLink>

          <!-- ADMIN SPECIFIC -->
          <template v-if="user?.role === 'ADMIN'">
            <label v-if="!isCollapsed">Management</label>
            <RouterLink to="/admin/officers" class="nav-item" active-class="active" @click="isMobile ? showMobileMenu = false : null">
              <span class="nav-icon">👮</span>
              <span v-if="!isCollapsed" class="nav-label">County Officers</span>
            </RouterLink>
            <RouterLink to="/admin/regional-officers" class="nav-item" active-class="active" @click="isMobile ? showMobileMenu = false : null">
              <span class="nav-icon">🗺️</span>
              <span v-if="!isCollapsed" class="nav-label">Regional Officers</span>
            </RouterLink>
            <RouterLink to="/admin/counties" class="nav-item" active-class="active" @click="isMobile ? showMobileMenu = false : null">
              <span class="nav-icon">🏛️</span>
              <span v-if="!isCollapsed" class="nav-label">Counties</span>
            </RouterLink>
            <RouterLink to="/admin/projects" class="nav-item" active-class="active" @click="isMobile ? showMobileMenu = false : null">
              <span class="nav-icon">📦</span>
              <span v-if="!isCollapsed" class="nav-label">Projects & Phases</span>
            </RouterLink>
            
            <label v-if="!isCollapsed">Reports</label>
            <RouterLink to="/admin/county-reports" class="nav-item" active-class="active" @click="isMobile ? showMobileMenu = false : null">
              <span class="nav-icon">📋</span>
              <span v-if="!isCollapsed" class="nav-label">County Reports</span>
            </RouterLink>
            
            <label v-if="!isCollapsed">System</label>
            <RouterLink to="/admin/master-data" class="nav-item" active-class="active" @click="isMobile ? showMobileMenu = false : null">
              <span class="nav-icon">🏗️</span>
              <span v-if="!isCollapsed" class="nav-label">System Config</span>
            </RouterLink>
            <RouterLink to="/admin/collaboration" class="nav-item" active-class="active" @click="isMobile ? showMobileMenu = false : null">
              <span class="nav-icon">📣</span>
              <span v-if="!isCollapsed" class="nav-label">Communication</span>
            </RouterLink>
            <RouterLink to="/admin/audit" class="nav-item" active-class="active" @click="isMobile ? showMobileMenu = false : null">
              <span class="nav-icon">🛡️</span>
              <span v-if="!isCollapsed" class="nav-label">Audit Logs</span>
            </RouterLink>
          </template>

          <!-- REGIONAL OFFICER SPECIFIC -->
          <template v-else-if="user?.role === 'REGIONAL_OFFICER'">
            <label v-if="!isCollapsed">Region Management</label>
            <RouterLink to="/region/counties" class="nav-item" active-class="active" @click="isMobile ? showMobileMenu = false : null">
              <span class="nav-icon">🏛️</span>
              <span v-if="!isCollapsed" class="nav-label">Counties</span>
            </RouterLink>
            <RouterLink to="/region/submissions" class="nav-item" active-class="active" @click="isMobile ? showMobileMenu = false : null">
              <span class="nav-icon">📋</span>
              <span v-if="!isCollapsed" class="nav-label">Submissions</span>
            </RouterLink>
            <RouterLink to="/region/officers" class="nav-item" active-class="active" @click="isMobile ? showMobileMenu = false : null">
              <span class="nav-icon">👮</span>
              <span v-if="!isCollapsed" class="nav-label">County Officers</span>
            </RouterLink>
            <RouterLink to="/region/officers/manage" class="nav-item" active-class="active" @click="isMobile ? showMobileMenu = false : null">
              <span class="nav-icon">⚙️</span>
              <span v-if="!isCollapsed" class="nav-label">Manage Officers</span>
            </RouterLink>
            <RouterLink to="/region/reports" class="nav-item" active-class="active" @click="isMobile ? showMobileMenu = false : null">
              <span class="nav-icon">📊</span>
              <span v-if="!isCollapsed" class="nav-label">Reports</span>
            </RouterLink>
          </template>

          <!-- COUNTY SPECIFIC -->
          <template v-else>
            <RouterLink to="/county/submissions" class="nav-item" active-class="active" @click="isMobile ? showMobileMenu = false : null">
              <span class="nav-icon">📑</span>
              <span v-if="!isCollapsed" class="nav-label">My Submissions</span>
            </RouterLink>
            <RouterLink to="/county/submission/new" class="nav-item" active-class="active" @click="isMobile ? showMobileMenu = false : null">
              <span class="nav-icon">➕</span>
              <span v-if="!isCollapsed" class="nav-label">New Submission</span>
            </RouterLink>
          </template>
        </div>

        <div class="nav-group">
           <label v-if="!isCollapsed">System</label>
           <RouterLink v-if="user?.role === 'ADMIN'" to="/admin/settings" class="nav-item" active-class="active" @click="isMobile ? showMobileMenu = false : null">
             <span class="nav-icon">⚙️</span>
             <span v-if="!isCollapsed" class="nav-label">Administration</span>
           </RouterLink>
           <a v-else href="#" class="nav-item">
             <span class="nav-icon">⚙️</span>
             <span v-if="!isCollapsed" class="nav-label">Settings</span>
           </a>
           <button @click="handleLogout" class="nav-item logout-link">
             <span class="nav-icon">🚪</span>
             <span v-if="!isCollapsed" class="nav-label">Logout</span>
           </button>
        </div>
      </nav>
      
      <div v-if="!isCollapsed" class="sidebar-promo">
        <div class="promo-card">
           <h4>ICT Authority</h4>
           <p>Securing Kenya's Digital Future</p>
        </div>
      </div>
    </aside>

    <!-- Main Content Area -->
    <div class="content-area">
      <header class="topbar">
        <div class="topbar-left">
           <button class="menu-toggle" @click="toggleSidebar">☰</button>
           <div class="breadcrumb" v-if="!isMobile">
             <span class="crumb-parent">Home</span>
             <span class="crumb-sep">/</span>
             <span class="crumb-active">Dashboard</span>
           </div>
        </div>
        
        <div class="topbar-right">
           <button class="icon-btn">🔔 <span class="badge-dot"></span></button>
           
           <div class="user-profile">
              <div class="user-avatar text-white bg-kenya-red">
                {{ user?.name?.charAt(0) || 'U' }}
              </div>
              <div class="user-text" v-if="!isMobile">
                <span class="user-name">{{ user?.name || 'User' }}</span>
                <span class="user-role">{{ user?.county || user?.role }}</span>
              </div>
           </div>
        </div>
      </header>
      
      <main class="main-wrapper">
        <RouterView />
      </main>
    </div>
  </div>
</template>

<style scoped>
/* Kenyan Flag Colors */
:root {
  --color-kenya-black: #000000;
  --color-kenya-red: #BB0000;
  --color-kenya-green: #006600;
  --color-kenya-white: #FFFFFF;
}

.bg-kenya-red { background-color: #BB0000; }
.text-white { color: #FFFFFF; }

.duralux-layout {
  display: flex;
  height: 100vh;
  background-color: #f4f7f6;
  font-family: 'Inter', system-ui, sans-serif;
  overflow: hidden;
}

/* Sidebar Styling - Kenyan Flag Theme (Dark/Black base) */
.sidebar {
  width: 280px;
  background: #111111; /* Dark Black */
  color: #94a3b8;
  display: flex;
  flex-direction: column;
  flex-shrink: 0;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  z-index: 1000;
  position: relative;
  border-right: 1px solid rgba(255, 255, 255, 0.05);
}

.sidebar.is-collapsed {
  width: 80px;
}

.sidebar-header {
  height: 70px;
  display: flex;
  align-items: center;
  padding: 0 1.5rem;
  overflow: hidden;
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
}

.logo {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  color: #fff;
  font-weight: 800;
  font-size: 1.25rem;
  white-space: nowrap;
}

.logo-img {
  width: 40px;
  height: 40px;
  object-fit: contain;
  border-radius: 4px;
}

.sidebar-nav {
  flex: 1;
  padding: 1.5rem 1rem;
  overflow-y: auto;
  overflow-x: hidden;
}

.nav-group {
  margin-bottom: 1.5rem;
}

.nav-group label {
  display: block;
  font-size: 0.7rem;
  font-weight: 700;
  text-transform: uppercase;
  color: #4b5563;
  margin-bottom: 0.75rem;
  padding-left: 0.75rem;
  letter-spacing: 0.05em;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 0.875rem 1rem;
  border-radius: 10px;
  color: #94a3b8;
  text-decoration: none;
  font-weight: 500;
  margin-bottom: 0.25rem;
  transition: all 0.2s;
  white-space: nowrap;
}

.nav-item:hover {
  color: #fff;
  background: rgba(255, 255, 255, 0.05);
}

/* Kenyan Flag Green for Active State */
.nav-item.active {
  background: #006600; /* Kenya Green */
  color: white;
  box-shadow: 0 4px 15px rgba(0, 102, 0, 0.2);
}

.nav-icon {
  font-size: 1.25rem;
  min-width: 24px;
  display: flex;
  justify-content: center;
}

.logout-link {
  width: 100%;
  background: none;
  border: none;
  cursor: pointer;
  text-align: left;
}

.logout-link:hover {
  background: rgba(187, 0, 0, 0.1);
  color: #BB0000;
}

.sidebar-promo {
  padding: 1.5rem;
}

.promo-card {
  background: linear-gradient(135deg, #000 0%, #333 100%);
  border: 1px solid rgba(187, 0, 0, 0.3);
  border-radius: 12px;
  padding: 1.25rem;
  text-align: center;
}

.promo-card h4 { color: #BB0000; margin-bottom: 0.25rem; font-size: 0.9rem; font-weight: 700; }
.promo-card p { font-size: 0.75rem; color: #94a3b8; margin: 0; }

/* Main Content Area */
.content-area {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  transition: all 0.3s;
}

/* Topbar */
.topbar {
  height: 70px;
  background: #fff;
  border-bottom: 1px solid #e5e7eb;
  padding: 0 1.5rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
  z-index: 10;
}

.topbar-left {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.menu-toggle {
  width: 40px;
  height: 40px;
  background: #f3f4f6;
  border: none;
  border-radius: 8px;
  font-size: 1.25rem;
  cursor: pointer;
  color: #111;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background 0.2s;
}

.menu-toggle:hover {
  background: #e5e7eb;
}

.breadcrumb {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.85rem;
  font-weight: 500;
}

.crumb-parent { color: #6b7280; }
.crumb-sep { color: #d1d5db; }
.crumb-active { color: #111; font-weight: 600; }

.topbar-right {
  display: flex;
  align-items: center;
  gap: 1.25rem;
}

.icon-btn {
  background: none;
  border: none;
  font-size: 1.2rem;
  color: #4b5563;
  cursor: pointer;
  position: relative;
}

.badge-dot {
  position: absolute;
  top: 0;
  right: 0;
  width: 8px;
  height: 8px;
  background: #BB0000; /* Kenya Red */
  border-radius: 50%;
  border: 2px solid white;
}

.user-profile {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.5rem;
  border-radius: 8px;
  transition: background 0.2s;
}

.user-avatar {
  width: 38px;
  height: 38px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 0.9rem;
}

.user-text {
  display: flex;
  flex-direction: column;
}

.user-name {
  font-size: 0.85rem;
  font-weight: 700;
  color: #111;
  line-height: 1.2;
}

.user-role {
  font-size: 0.7rem;
  color: #6b7280;
}

.main-wrapper {
  flex: 1;
  overflow-y: auto;
  padding: 1.5rem;
}

/* Mobile View Handling */
@media (max-width: 1024px) {
  .sidebar {
    position: fixed;
    top: 0;
    left: -280px;
    height: 100vh;
    width: 280px !important;
  }
  
  .sidebar.show-mobile {
    left: 0;
  }
  
  .mobile-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    background: rgba(0, 0, 0, 0.5);
    z-index: 999;
    backdrop-filter: blur(2px);
  }
  
  .topbar {
    padding: 0 1rem;
  }
  
  .main-wrapper {
    padding: 1rem;
  }

  .sidebar-header {
    height: 60px;
  }

  .logo {
    font-size: 1.1rem;
  }

  .topbar-right {
    gap: 1rem;
  }

  .user-text {
    display: none;
  }

  .user-avatar {
    width: 35px;
    height: 35px;
    font-size: 0.85rem;
  }
}

@media (max-width: 768px) {
  .duralux-layout {
    flex-direction: column;
  }

  .sidebar {
    left: -280px;
    z-index: 1000;
  }

  .sidebar.show-mobile {
    left: 0;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
  }

  .sidebar-header {
    height: 55px;
    padding: 0 1rem;
  }

  .logo {
    font-size: 1rem;
    gap: 0.5rem;
  }

  .logo-img {
    width: 35px;
    height: 35px;
  }

  .logo-text {
    font-size: 0.95rem;
  }

  .sidebar-nav {
    padding: 1rem;
  }

  .nav-group {
    margin-bottom: 1rem;
  }

  .nav-group label {
    font-size: 0.65rem;
    margin-bottom: 0.5rem;
  }

  .nav-item {
    padding: 0.75rem 0.75rem;
    gap: 0.8rem;
    border-radius: 8px;
    margin-bottom: 0.2rem;
  }

  .nav-icon {
    font-size: 1rem;
    flex-shrink: 0;
  }

  .nav-label {
    font-size: 0.85rem;
  }

  .topbar {
    height: 55px;
    padding: 0 0.75rem;
  }

  .breadcrumb {
    display: none;
  }

  .topbar-right {
    gap: 0.75rem;
  }

  .icon-btn {
    font-size: 1rem;
  }

  .user-avatar {
    width: 32px;
    height: 32px;
    font-size: 0.8rem;
  }

  .main-wrapper {
    padding: 0.75rem;
  }
}

@media (max-width: 480px) {
  .sidebar {
    width: 280px !important;
    left: -280px;
  }

  .sidebar-header {
    height: 50px;
    padding: 0 0.75rem;
  }

  .logo {
    font-size: 0.9rem;
    gap: 0.4rem;
  }

  .logo-img {
    width: 30px;
    height: 30px;
  }

  .logo-text {
    font-size: 0.85rem;
  }

  .sidebar-nav {
    padding: 0.75rem;
  }

  .nav-group {
    margin-bottom: 0.75rem;
  }

  .nav-group label {
    font-size: 0.6rem;
    margin-bottom: 0.35rem;
    padding-left: 0.5rem;
  }

  .nav-item {
    padding: 0.65rem 0.6rem;
    gap: 0.6rem;
    font-size: 0.75rem;
    margin-bottom: 0.15rem;
  }

  .nav-icon {
    font-size: 0.95rem;
  }

  .nav-label {
    font-size: 0.8rem;
  }

  .topbar {
    height: 50px;
    padding: 0 0.5rem;
  }

  .topbar-left {
    gap: 0.5rem;
  }

  .hamburger {
    width: 28px;
    height: 28px;
    font-size: 1rem;
  }

  .topbar-right {
    gap: 0.5rem;
  }

  .icon-btn {
    font-size: 0.9rem;
    padding: 0.25rem;
  }

  .badge-dot {
    width: 6px;
    height: 6px;
    border-width: 1px;
  }

  .user-avatar {
    width: 28px;
    height: 28px;
    font-size: 0.7rem;
  }

  .user-text {
    display: none;
  }

  .main-wrapper {
    padding: 0.5rem;
  }

  .breadcrumb {
    display: none;
  }

  .page-title {
    font-size: 1.25rem !important;
  }

  /* Sidebar header to match topbar height */
  .duralux-layout {
    position: relative;
  }

  /* Make mobile menu more accessible */
  .mobile-overlay {
    animation: fadeIn 0.2s ease-in;
  }

  @keyframes fadeIn {
    from {
      opacity: 0;
    }
    to {
      opacity: 1;
    }
  }

  .sidebar.show-mobile {
    animation: slideIn 0.3s ease-out;
  }

  @keyframes slideIn {
    from {
      transform: translateX(-100%);
    }
    to {
      transform: translateX(0);
    }
  }
}

@media (max-width: 360px) {
  .sidebar {
    width: 250px !important;
    left: -250px;
  }

  .sidebar-header {
    height: 45px;
  }

  .logo {
    font-size: 0.8rem;
  }

  .logo-img {
    width: 25px;
    height: 25px;
  }

  .nav-group label {
    font-size: 0.55rem;
  }

  .nav-item {
    padding: 0.5rem 0.5rem;
    font-size: 0.7rem;
  }

  .nav-icon {
    font-size: 0.9rem;
  }

  .topbar {
    height: 45px;
  }

  .icon-btn {
    font-size: 0.8rem;
  }

  .user-avatar {
    width: 25px;
    height: 25px;
    font-size: 0.65rem;
  }
}
</style>
