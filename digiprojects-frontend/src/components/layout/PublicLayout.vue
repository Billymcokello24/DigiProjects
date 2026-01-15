<script setup>
import { RouterView } from 'vue-router'
import { ref } from 'vue'
import BaseButton from '../ui/BaseButton.vue'

const isMobileMenuOpen = ref(false)

const toggleMobileMenu = () => {
  isMobileMenuOpen.value = !isMobileMenuOpen.value
}

const closeMobileMenu = () => {
  isMobileMenuOpen.value = false
}
</script>

<template>
  <div class="public-layout">
    <header class="navbar">
      <div class="kenya-ribbon"></div>
      <div class="container navbar-content">
        <div class="logo">
          <img src="@/assets/icta-logo.jpg" alt="ICT Authority" class="logo-img" />
          <div class="logo-text-group">
            <span class="logo-main">DigiProjects</span>
            <span class="logo-sub">ICT AUTHORITY</span>
          </div>
        </div>
        <nav class="nav-links" :class="{ 'mobile-nav-open': isMobileMenuOpen }">
          <RouterLink to="/" class="nav-link" @click="closeMobileMenu">Home</RouterLink>
          <a href="#about" class="nav-link" @click="closeMobileMenu">About</a>
          <RouterLink to="/public-data" class="nav-link" @click="closeMobileMenu">Public Data</RouterLink>
        </nav>
        <div class="nav-actions">
          <button class="hamburger-menu" @click="toggleMobileMenu" :class="{ 'is-open': isMobileMenuOpen }">
            <span></span>
            <span></span>
            <span></span>
          </button>
           <BaseButton to="/login" variant="primary" size="sm">Officer Login</BaseButton>
        </div>
      </div>

      <!-- Mobile Menu Overlay -->
      <div v-if="isMobileMenuOpen" class="mobile-menu-overlay" @click="closeMobileMenu"></div>
    </header>

    <main class="main-content">
      <RouterView />
    </main>

    <footer class="footer">
      <div class="container">
        <p>&copy; 2026 ICT Authority. All Rights Reserved.</p>
      </div>
    </footer>
  </div>
</template>

<style scoped>
.public-layout {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background-color: var(--color-background);
}

.navbar {
  height: 70px;
  display: flex;
  align-items: center;
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 100;
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(12px);
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
}

.navbar-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.logo {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 800;
  font-size: 1.25rem;
  color: var(--color-primary);
}

.logo-icon {
  font-size: 1.5rem;
  filter: drop-shadow(0 0 10px rgba(14, 165, 233, 0.5));
}

.nav-links {
  display: flex;
  gap: 2rem;
}

.nav-link {
  color: var(--color-text-muted);
  font-weight: 500;
  font-size: 0.95rem;
}

.nav-link:hover, .nav-link.router-link-active {
  color: var(--color-accent);
}

.main-content {
  flex: 1;
  padding-top: 70px; /* Navbar height */
}

.footer {
  padding: 2rem 0;
  text-align: center;
  color: var(--color-text-muted);
  font-size: 0.875rem;
  background: black; /* ICTA Modern Footer */
  color: white;
  border-top: 4px solid var(--color-accent);
}

.kenya-ribbon {
  height: 4px;
  width: 100%;
  background: linear-gradient(to right, black 25%, #BB0000 25%, #BB0000 50%, #006600 50%, #006600 75%, white 75%);
  position: absolute;
  top: 0;
  left: 0;
}

.logo-img {
  height: 45px;
  width: auto;
  margin-right: 0.75rem;
}

.logo-text-group {
  display: flex;
  flex-direction: column;
  line-height: 1.1;
}

.logo-main {
  font-weight: 800;
  font-size: 1.25rem;
  color: var(--color-primary);
  text-transform: uppercase;
}

.logo-sub {
  font-size: 0.65rem;
  font-weight: 700;
  color: var(--color-accent); /* Red text */
  letter-spacing: 0.1em;
}

.logo-divider {
  display: none;
}

/* Hamburger Menu */
.hamburger-menu {
  display: none;
  flex-direction: column;
  gap: 0.35rem;
  background: none;
  border: none;
  cursor: pointer;
  padding: 0.5rem;
  z-index: 1001;
}

.hamburger-menu span {
  width: 24px;
  height: 2px;
  background: var(--color-text);
  border-radius: 1px;
  transition: all 0.3s ease;
  display: block;
}

.hamburger-menu.is-open span:nth-child(1) {
  transform: rotate(45deg) translate(8px, 8px);
}

.hamburger-menu.is-open span:nth-child(2) {
  opacity: 0;
}

.hamburger-menu.is-open span:nth-child(3) {
  transform: rotate(-45deg) translate(7px, -7px);
}

/* Mobile Menu Overlay */
.mobile-menu-overlay {
  display: none;
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.3);
  z-index: 999;
  backdrop-filter: blur(2px);
}

/* Mobile Responsive Navbar */
@media (max-width: 1024px) {
  .navbar-content {
    padding: 0 1rem;
  }

  .nav-links {
    gap: 1.5rem;
  }

  .nav-link {
    font-size: 0.9rem;
  }
}

@media (max-width: 768px) {
  .navbar {
    height: 60px;
  }

  .main-content {
    padding-top: 60px;
  }

  .navbar-content {
    padding: 0 0.75rem;
    position: relative;
  }

  .logo {
    gap: 0.35rem;
    font-size: 1rem;
  }

  .logo-img {
    height: 35px;
  }

  .logo-main {
    font-size: 1rem;
  }

  .logo-sub {
    font-size: 0.5rem;
  }

  .nav-links {
    position: fixed;
    top: 60px;
    left: -100%;
    width: 100%;
    height: calc(100vh - 60px);
    background: white;
    flex-direction: column;
    padding: 2rem 1rem;
    gap: 1rem;
    z-index: 1000;
    transition: left 0.3s ease;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
    overflow-y: auto;
  }

  .nav-links.mobile-nav-open {
    left: 0;
  }

  .nav-link {
    font-size: 1rem;
    padding: 0.75rem 0;
    border-bottom: 1px solid #f0f0f0;
    display: block;
  }

  .nav-link:last-child {
    border-bottom: none;
  }

  .nav-actions {
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }

  .hamburger-menu {
    display: flex;
  }

  .mobile-menu-overlay {
    display: block;
  }

  :deep(.nav-actions button) {
    font-size: 0.75rem;
    padding: 0.4rem 0.8rem !important;
  }
}

@media (max-width: 480px) {
  .navbar {
    height: 55px;
    padding: 0;
  }

  .main-content {
    padding-top: 55px;
  }

  .navbar-content {
    padding: 0 0.5rem;
    gap: 0.5rem;
  }

  .kenya-ribbon {
    height: 3px;
  }

  .logo {
    gap: 0.25rem;
    font-size: 0.85rem;
    min-width: 0;
  }

  .logo-img {
    height: 30px;
    margin-right: 0.4rem;
  }

  .logo-text-group {
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .logo-main {
    font-size: 0.85rem;
  }

  .logo-sub {
    font-size: 0.45rem;
  }

  .nav-links {
    top: 55px;
    height: calc(100vh - 55px);
    padding: 1rem 0.75rem;
  }

  .nav-link {
    font-size: 0.9rem;
    padding: 0.6rem 0.75rem;
  }

  .hamburger-menu {
    gap: 0.3rem;
    padding: 0.35rem;
  }

  .hamburger-menu span {
    width: 20px;
    height: 1.5px;
  }

  .nav-actions {
    gap: 0.35rem;
  }

  :deep(.nav-actions button) {
    font-size: 0.7rem;
    padding: 0.3rem 0.6rem !important;
    white-space: nowrap;
  }

  .footer {
    padding: 1rem 0;
    font-size: 0.75rem;
  }

  .footer p {
    padding: 0 0.5rem;
  }
}

@media (max-width: 360px) {
  .navbar {
    height: 50px;
  }

  .main-content {
    padding-top: 50px;
  }

  .navbar-content {
    gap: 0.25rem;
  }

  .logo {
    font-size: 0.75rem;
  }

  .logo-img {
    height: 25px;
    margin-right: 0.25rem;
  }

  .logo-main {
    font-size: 0.75rem;
  }

  .logo-sub {
    font-size: 0.4rem;
  }

  .nav-links {
    top: 50px;
    height: calc(100vh - 50px);
    padding: 1rem 0.5rem;
  }

  .nav-link {
    font-size: 0.85rem;
    padding: 0.5rem 0.5rem;
  }

  .hamburger-menu {
    gap: 0.25rem;
    padding: 0.25rem;
  }

  .hamburger-menu span {
    width: 18px;
    height: 1.5px;
  }

  :deep(.nav-actions button) {
    font-size: 0.65rem;
    padding: 0.25rem 0.5rem !important;
  }
}
</style>
