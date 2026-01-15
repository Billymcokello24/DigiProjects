<script setup>
import BaseButton from '@/components/ui/BaseButton.vue'
</script>

<template>
  <div class="home-view">
    <!-- Hero Section -->
    <section class="hero">
      <div class="hero-bg">
        <div class="blob blob-1"></div>
        <div class="blob blob-2"></div>
      </div>
      
      <div class="container hero-content">
        <div class="hero-text">
          <div class="badge">ICT Authority Official System</div>
          <h1 class="hero-title">
            Driving Kenya's <br>
            <span class="gradient-text">Digital Future</span>
          </h1>
          <p class="hero-subtitle">
            The central hub for monitoring, managing, and reporting on National ICT Infrastructure projects. 
            Transformed for efficiency, transparency, and impact.
          </p>
          <div class="hero-actions">
            <BaseButton to="/login" variant="primary" size="lg">Access Dashboard</BaseButton>
            <BaseButton to="/public-data" variant="outline" size="lg">Explore Public Data</BaseButton>
          </div>
        </div>
        
        <div class="hero-image">
          <div class="glass-card stat-card-1">
            <div class="stat-number">47</div>
            <div class="stat-label">Counties Connected</div>
          </div>
          <div class="glass-card stat-card-2">
            <div class="stat-number">250+</div>
            <div class="stat-label">Active Projects</div>
          </div>
          <div class="glass-card stat-card-3">
             <div class="stat-icon">📡</div>
             <div class="stat-label">NOFBI Phase II Live</div>
          </div>
        </div>
      </div>
    </section>

    <!-- Specific Projects Section -->
    <section class="programs" id="projects">
      <div class="container">
        <div class="programs-header">
           <h2 class="heading-2">Key Strategic Projects</h2>
           <p class="text-muted">Delivering the digital dream through targeted high-impact initiatives.</p>
        </div>
        
        <div class="programs-grid">
           <!-- Project 1: NOFBI -->
           <div class="program-card">
             <div class="card-image-wrapper">
               <img src="@/assets/nofbi.jpg" alt="NOFBI" class="card-img" />
             </div>
             <div class="card-content">
               <div class="card-header">
                 <h3>NOFBI</h3>
                 <span class="status-badge">Live</span>
               </div>
               <p class="full-name">National Optic Fibre Backbone</p>
               <p class="pillar-desc">Connecting all 47 counties. The digital spine of government service delivery.</p>
             </div>
           </div>
           
           <!-- Project 2: DSH -->
           <div class="program-card">
             <div class="card-image-wrapper">
               <img src="@/assets/dsh.jpg" alt="DSH" class="card-img" />
             </div>
             <div class="card-content">
               <div class="card-header">
                 <h3>DSH</h3>
                 <span class="status-badge">Rolling Out</span>
               </div>
               <p class="full-name">Digital Superhighway</p>
               <p class="pillar-desc">100,000 km of fiber and 25,000 Wi-Fi hotspots for universal access.</p>
             </div>
           </div>

           <!-- Project 3: CCP -->
           <div class="program-card">
             <div class="card-image-wrapper">
               <img src="@/assets/ccp.jpg" alt="CCP" class="card-img" />
             </div>
             <div class="card-content">
               <div class="card-header">
                 <h3>CCP</h3>
                 <span class="status-badge">Active</span>
               </div>
               <p class="full-name">County Connectivity Project</p>
               <p class="pillar-desc">Linking sub-counties to the grid. 753 new government sites connected.</p>
             </div>
           </div>

           <!-- Project 4: Public Wi-Fi -->
           <div class="program-card">
             <div class="card-image-wrapper">
               <img src="@/assets/wifi.jpg" alt="Wi-Fi" class="card-img" />
             </div>
             <div class="card-content">
               <div class="card-header">
                 <h3>WI-FI</h3>
                 <span class="status-badge">Rolling Out</span>
               </div>
               <p class="full-name">Public Wi-Fi Hotspots</p>
               <p class="pillar-desc">25,000 hotspots nationwide to democratize internet access for all citizens.</p>
             </div>
           </div>
           
           <!-- Project 5: JITUME -->
           <div class="program-card">
             <div class="card-image-wrapper">
               <img src="@/assets/jitume.jpg" alt="Jitume" class="card-img" />
             </div>
             <div class="card-content">
               <div class="card-header">
                 <h3>JITUME</h3>
                 <span class="status-badge">Scalable</span>
               </div>
               <p class="full-name">Digital Enablement</p>
               <p class="pillar-desc">170+ Labs empowering youth with digital skills and online jobs.</p>
             </div>
           </div>

           <!-- Project 6: CIH -->
           <div class="program-card">
             <div class="card-image-wrapper">
               <img src="@/assets/cih.jpg" alt="CIH" class="card-img" />
             </div>
             <div class="card-content">
               <div class="card-header">
                 <h3>CIH</h3>
                 <span class="status-badge">Innovation</span>
               </div>
               <p class="full-name">Constituency Innovation Hubs</p>
               <p class="pillar-desc">1,160 Hubs providing devices and internet for grassroots innovation.</p>
             </div>
           </div>

           <!-- Project 7: GIGA -->
           <div class="program-card">
             <div class="card-image-wrapper">
               <img src="@/assets/giga.jpg" alt="GIGA" class="card-img" />
             </div>
             <div class="card-content">
               <div class="card-header">
                 <h3>GIGA</h3>
                 <span class="status-badge">Global</span>
               </div>
               <p class="full-name">School Connectivity</p>
               <p class="pillar-desc">Connecting every school to the internet. Partnering with UNICEF & ITU.</p>
             </div>
           </div>

           <!-- Project 8: KDEAP -->
           <div class="program-card">
             <div class="card-image-wrapper">
               <img src="@/assets/kdeap.jpg" alt="KDEAP" class="card-img" />
             </div>
             <div class="card-content">
               <div class="card-header">
                 <h3>KDEAP</h3>
                 <span class="status-badge">Strategic</span>
               </div>
               <p class="full-name">Digital Economy Acceleration</p>
               <p class="pillar-desc">Strengthening the digital ecosystem to accelerate Kenya's economic transformation.</p>
             </div>
           </div>
        </div>
      </div>
    </section>

    <!-- About Section -->
    <section class="about" id="about">
      <div class="container">
        <div class="about-content">
          <h2 class="heading-1">About DigiProjects</h2>
          <p class="about-description">
            DigiProjects is the official National ICT Projects Management, Monitoring & Reporting System. 
            Designed to centralize data capture, validate project milestones, and provide real-time oversight 
            of Kenya's digital infrastructure investments.
          </p>
          <div class="features-grid">
            <div class="feature-card">
              <div class="feature-icon">🔍</div>
              <h4>Transparency</h4>
              <p>Real-time tracking of project status and resource allocation.</p>
            </div>
            <div class="feature-card">
               <div class="feature-icon">⚡</div>
               <h4>Efficiency</h4>
               <p>Automated reporting workflows reducing manual paperwork.</p>
            </div>
             <div class="feature-card">
               <div class="feature-icon">🤝</div>
               <h4>Accountability</h4>
               <p>Clear ownership and approval trails for every submission.</p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Partners Section -->
    <section class="partners">
      <div class="container">
        <p class="section-label">In Partnership With</p>
        <div class="partners-logos">
          <div class="partner-logo-card">
            <img src="@/assets/partners/gok.png" alt="Government of Kenya" class="partner-img" />
            <p class="partner-name">Government of Kenya</p>
          </div>
          <div class="partner-logo-card">
            <img src="@/assets/partners/world-bank.png" alt="World Bank" class="partner-img" />
            <p class="partner-name">World Bank</p>
          </div>
          <div class="partner-logo-card">
            <img src="@/assets/partners/konza.png" alt="Konza Technopolis" class="partner-img" />
            <p class="partner-name">Konza Technopolis</p>
          </div>
          <div class="partner-logo-card">
            <img src="@/assets/partners/ketraco.png" alt="KETRACO" class="partner-img" />
            <p class="partner-name">KETRACO</p>
          </div>
          <div class="partner-logo-card">
            <img src="@/assets/partners/kenya-power.png" alt="Kenya Power" class="partner-img" />
            <p class="partner-name">Kenya Power</p>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped>
.hero {
  position: relative;
  padding: 8rem 0 6rem;
  overflow: hidden;
  background: radial-gradient(circle at top right, #f8fafc, #fff);
}

.hero-bg {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 0;
  overflow: hidden;
}

.blob {
  position: absolute;
  border-radius: 50%;
  filter: blur(80px);
  opacity: 0.4;
}

.blob-1 {
  top: -10%;
  right: -5%;
  width: 500px;
  height: 500px;
  background: var(--color-accent);
  animation: float 10s ease-in-out infinite;
}

.blob-2 {
  bottom: 0%;
  left: 10%;
  width: 400px;
  height: 400px;
  background: #8b5cf6;
  animation: float 14s ease-in-out infinite reverse;
}

@keyframes float {
  0%, 100% { transform: translate(0, 0); }
  50% { transform: translate(30px, -30px); }
}

.hero-content {
  position: relative;
  z-index: 1;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 4rem;
  align-items: center;
}

.hero-text {
  max-width: 600px;
}

.badge {
  display: inline-block;
  padding: 0.5rem 1rem;
  background: rgba(14, 165, 233, 0.1);
  color: var(--color-accent);
  border-radius: 2rem;
  font-weight: 600;
  font-size: 0.875rem;
  margin-bottom: 2rem;
}

.hero-title {
  font-size: 4rem;
  line-height: 1.1;
  font-weight: 800;
  color: var(--color-primary);
  margin-bottom: 1.5rem;
  letter-spacing: -0.04em;
}

.gradient-text {
  background: linear-gradient(135deg, var(--color-accent) 0%, #8b5cf6 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.hero-subtitle {
  font-size: 1.25rem;
  line-height: 1.6;
  color: var(--color-text-muted);
  margin-bottom: 2.5rem;
}

.hero-actions {
  display: flex;
  gap: 1rem;
}

.hero-image {
  position: relative;
  height: 450px;
  background-image: url('@/assets/nofbi.jpg');
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
  border-radius: var(--radius-xl);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
}

.glass-card {
  position: absolute;
  background: rgba(255, 255, 255, 0.7);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.5);
  padding: 1.5rem;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-xl);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
  animation: float 6s ease-in-out infinite;
}

.stat-card-1 {
  top: 10%;
  left: 10%;
  width: 160px;
}

.stat-card-2 {
  bottom: 20%;
  right: 10%;
  width: 180px;
  animation-delay: 1s;
}

.stat-card-3 {
  top: 40%;
  left: 40%;
  padding: 1rem;
  animation-delay: 2s;
}

.stat-number {
  font-size: 2.5rem;
  font-weight: 800;
  color: var(--color-primary);
}

.stat-label {
  font-size: 0.875rem;
  color: var(--color-text-muted);
  font-weight: 500;
}

.stat-icon {
  font-size: 2rem;
  margin-bottom: 0.5rem;
}


.stats {
  padding: 4rem 0;
  background: #fff;
}

.about {
  padding: 6rem 0;
  background: var(--color-background);
  text-align: center;
}

.about-content {
  max-width: 800px;
  margin: 0 auto;
}

/* Strategic Pillars Card Styles */
.programs-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 2.5rem; /* Increased gap for breathing room */
  margin-top: 3rem;
}

.program-card {
  background: white;
  border-radius: 12px; /* Slightly sharper roundness */
  overflow: hidden;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05); /* Subtle start */
  border: 1px solid #e2e8f0;
  transition: all 0.4s cubic-bezier(0.165, 0.84, 0.44, 1);
  display: flex;
  flex-direction: column;
  position: relative;
}

/* Kenyan Flag Hover Effect */
.program-card::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  width: 100%;
  height: 4px;
  background: linear-gradient(90deg, #000000 33%, #BB0000 33%, #BB0000 66%, #006600 66%);
  transform: scaleX(0);
  transform-origin: left;
  transition: transform 0.4s ease;
}

.program-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
  border-color: transparent; /* Let shadow define edges */
}

.program-card:hover::after {
  transform: scaleX(1);
}

.card-image-wrapper {
  height: 220px; /* Taller image */
  position: relative;
  overflow: hidden;
}

.card-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.7s ease;
}

.program-card:hover .card-img {
  transform: scale(1.1);
}

.card-content {
  padding: 1.75rem;
  flex: 1;
  display: flex;
  flex-direction: column;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.75rem;
  padding-bottom: 0.75rem;
  border-bottom: 1px solid var(--color-border);
}

.program-card h3 {
  font-size: 1.75rem; /* Larger Acronym */
  font-weight: 900;
  color: var(--color-primary);
  margin: 0;
  letter-spacing: -0.02em;
}

.status-badge {
  background: #f0fdf4; /* Light green background */
  color: #15803d; /* Deep green text */
  font-size: 0.7rem;
  font-weight: 700;
  padding: 0.35rem 0.85rem;
  border-radius: 2rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  border: 1px solid #bbf7d0;
  box-shadow: 0 1px 2px rgba(0,0,0,0.05);
}

.full-name {
  font-size: 0.9rem;
  font-weight: 700;
  color: var(--color-accent); /* Red Accent */
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin-bottom: 0.75rem;
  line-height: 1.4;
  min-height: 2.8em;
}

.pillar-desc {
  font-size: 0.95rem;
  color: #475569; /* Slate 600 */
  line-height: 1.7; /* Better readability */
  margin: 0;
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 2rem;
  margin-top: 4rem;
}

.feature-card {
  padding: 2rem;
  background: #fff;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-md);
  transition: 0.3s;
}

.feature-card:hover {
  transform: translateY(-5px);
  box-shadow: var(--shadow-lg);
}

.feature-icon {
  font-size: 2.5rem;
  margin-bottom: 1rem;
}

.feature-card h4 {
  font-size: 1.25rem;
  font-weight: 800;
  color: var(--color-primary);
  margin-bottom: 0.75rem;
}

.feature-card p {
  color: #475569;
  font-size: 0.95rem;
  line-height: 1.6;
}

/* About Section Enhancements */
.about {
  padding: 6rem 0;
  background: linear-gradient(135deg, #ffffff, #f8fafc);
  position: relative;
  text-align: center;
  border-top: 6px solid #bb0000;
  border-bottom: 1px solid #e2e8f0;
}

.about-content {
  max-width: 900px;
  margin: 0 auto;
}

.about-content .heading-1 {
  font-size: 3rem;
  font-weight: 900;
  background: linear-gradient(135deg, #1e293b, #bb0000);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin-bottom: 1.5rem;
  letter-spacing: -0.02em;
}

.about-description {
  font-size: 1.125rem;
  color: #475569;
  line-height: 1.8;
  margin-bottom: 3rem;
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 2rem;
  margin-top: 2rem;
}

.feature-card {
  padding: 2.5rem;
  background: white;
  border-radius: 16px;
  transition: all 0.3s ease;
  border: 2px solid #e2e8f0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

.feature-card:hover {
  background: linear-gradient(135deg, #f0fdf4, #ffffff);
  box-shadow: 0 12px 24px rgba(0, 102, 0, 0.12);
  transform: translateY(-6px);
  border-color: #006600;
}

.feature-icon {
  font-size: 3.5rem;
  margin-bottom: 1.5rem;
  display: inline-block;
  padding: 1.5rem;
  background: #f0fdf4;
  border-radius: 50%;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.feature-card:hover .feature-icon {
  background: #006600;
  transform: scale(1.1) rotateZ(360deg);
}

.feature-card h4 {
  font-size: 1.25rem;
  font-weight: 800;
  color: #1e293b;
  margin-bottom: 0.75rem;
}

.feature-card p {
  color: #64748b;
  font-size: 0.95rem;
  line-height: 1.6;
}

/* Partners Section */
.partners {
  padding: 4rem 0;
  background: linear-gradient(135deg, #1e293b, #0f172a);
  text-align: center;
  border-top: 1px solid #333;
  border-bottom: 6px solid #bb0000;
}

.section-label {
  text-transform: uppercase;
  font-size: 0.85rem;
  font-weight: 700;
  color: #94a3b8;
  letter-spacing: 0.08em;
  margin-bottom: 2.5rem;
}

.partners-logos {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 2.5rem;
  max-width: 1000px;
  margin: 0 auto;
}

.partner-logo-card {
  background: white;
  padding: 2.5rem 1.5rem;
  border-radius: 16px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  border: 2px solid transparent;
}

.partner-logo-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 12px 32px rgba(187, 0, 0, 0.15);
  border-color: #bb0000;
  background: linear-gradient(135deg, #ffffff, #f8fafc);
}

.partner-img {
  height: 80px;
  max-width: 120px;
  object-fit: contain;
  margin-bottom: 1rem;
  filter: grayscale(0%);
  transition: filter 0.3s ease;
}

.partner-logo-card:hover .partner-img {
  filter: grayscale(0%);
}

.partner-name {
  font-size: 0.95rem;
  font-weight: 700;
  color: #1e293b;
  margin: 0;
}

/* Live Data Section */
.live-data {
  padding: 4rem 0;
  background: white;
}

.section-header {
  text-align: center;
  margin-bottom: 3rem;
}

.badge-sm {
  display: inline-block;
  background: rgba(16, 185, 129, 0.1);
  color: #059669;
  font-size: 0.75rem;
  font-weight: 700;
  padding: 0.25rem 0.75rem;
  border-radius: 1rem;
  margin-bottom: 0.5rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.data-wrapper {
  background: white;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-lg);
  border: 1px solid var(--color-border);
  overflow: hidden;
}

.public-table {
  width: 100%;
  border-collapse: collapse;
}

.public-table th, .public-table td {
  padding: 1.25rem;
  text-align: left;
  border-bottom: 1px solid var(--color-border);
}

.public-table th {
  background: var(--color-background);
  font-weight: 600;
  font-size: 0.875rem;
  color: var(--color-text-muted);
}

.progress-bar {
  height: 6px;
  background: var(--color-border);
  border-radius: 3px;
  width: 100px;
  display: inline-block;
  vertical-align: middle;
  margin-right: 0.5rem;
}

.progress-bar .fill {
  height: 100%;
  background: var(--color-accent);
  border-radius: 3px;
}

.progress-text {
  font-size: 0.875rem;
  font-weight: 600;
  color: var(--color-text);
}

.status-dot {
  display: inline-block;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  margin-right: 0.25rem;
}

.status-dot.success { background: var(--color-success); }
.status-dot.warning { background: var(--color-warning); }

/* County Focus Section */
.county-focus {
  padding: 4rem 0;
  background: var(--color-background);
}

.counties-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 2rem;
}

.county-card {
  background: white;
  border-radius: var(--radius-lg);
  overflow: hidden;
  box-shadow: var(--shadow-md);
  transition: 0.3s;
  border: 1px solid var(--color-border);
}

.county-card:hover {
  transform: translateY(-5px);
  box-shadow: var(--shadow-lg);
}

.county-image {
  height: 160px;
  background-color: #e2e8f0;
  position: relative;
}

/* Placeholders using gradients */
.placeholder-mombasa { background: linear-gradient(135deg, #0ea5e9, #bae6fd); }
.placeholder-kisumu { background: linear-gradient(135deg, #8b5cf6, #ddd6fe); }
.placeholder-nairobi { background: linear-gradient(135deg, #10b981, #a7f3d0); }

.county-content {
  padding: 1.5rem;
}

.county-tag {
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
  color: var(--color-accent);
  margin-bottom: 0.5rem;
  display: block;
}

.county-card h4 {
  font-size: 1.125rem;
  font-weight: 700;
  color: var(--color-primary);
  margin-bottom: 0.5rem;
}

.county-card p {
  font-size: 0.95rem;
  color: var(--color-text-muted);
  margin-bottom: 1rem;
  line-height: 1.5;
}

.county-meta {
  font-size: 0.75rem;
  color: var(--color-text-muted);
  border-top: 1px solid var(--color-border);
  padding-top: 0.75rem;
}

/* Mobile Responsive Styles */
@media (max-width: 1024px) {
  .hero-content {
    grid-template-columns: 1fr;
    gap: 2rem;
    text-align: center;
  }

  .programs-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .counties-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .hero-image {
    position: relative;
    width: 100%;
    margin-top: 2rem;
    height: 380px;
    background-image: url('@/assets/nofbi.jpg');
    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;
    border-radius: var(--radius-lg);
  }

  .stat-card-1,
  .stat-card-2,
  .stat-card-3 {
    position: relative !important;
    transform: none !important;
  }
}

@media (max-width: 768px) {
  .container {
    padding: 1rem;
  }

  .hero {
    padding: 2.5rem 0 1.5rem;
    min-height: auto;
    background: radial-gradient(circle at center, #f8fafc, #fff);
  }

  .hero-bg {
    display: none;
  }

  .hero-content {
    grid-template-columns: 1fr;
    gap: 1.5rem;
    align-items: center;
  }

  .hero-text {
    text-align: center;
    max-width: 100%;
    order: 1;
  }

  .badge {
    display: inline-block;
    padding: 0.4rem 0.8rem;
    font-size: 0.75rem;
    margin-bottom: 1rem;
  }

  .hero-title {
    font-size: 1.75rem !important;
    line-height: 1.3;
    margin-bottom: 0.75rem;
    font-weight: 800;
  }

  .hero-title br {
    display: block;
  }

  .gradient-text {
    background: linear-gradient(135deg, var(--color-accent) 0%, #8b5cf6 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    display: block;
  }

  .hero-subtitle {
    font-size: 0.95rem;
    line-height: 1.5;
    margin-bottom: 1.5rem;
    color: var(--color-text-muted);
  }

  .hero-actions {
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
    width: 100%;
  }

  .hero-actions button {
    width: 100%;
    font-size: 1rem;
    padding: 0.75rem 1.5rem !important;
  }

  .hero-image {
    position: relative;
    height: 280px;
    width: 100%;
    margin-top: 1.5rem;
    order: 2;
    background-image: url('@/assets/nofbi.jpg');
    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;
    border-radius: var(--radius-lg);
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .stat-card-1,
  .stat-card-2,
  .stat-card-3 {
    display: none !important;
  }

  .stat-number {
    font-size: 2rem;
    font-weight: 800;
  }

  .stat-label {
    font-size: 0.8rem;
    font-weight: 500;
  }

  .stat-icon {
    font-size: 1.75rem;
    margin-bottom: 0.4rem;
  }

  .programs-header {
    text-align: center;
    margin-bottom: 1.5rem;
  }

  .programs-header h2 {
    font-size: 1.5rem !important;
    margin-bottom: 0.75rem;
  }

  .programs-header p {
    font-size: 0.9rem;
  }

  .programs-grid {
    grid-template-columns: 1fr;
    gap: 1.25rem;
  }

  .program-card {
    height: auto;
    border-radius: var(--radius-lg);
    overflow: hidden;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  }

  .card-image-wrapper {
    height: 200px;
  }

  .card-content {
    padding: 1rem;
  }

  .card-header {
    margin-bottom: 0.5rem;
  }

  .card-header h3 {
    font-size: 1.1rem;
  }

  .full-name {
    font-size: 0.9rem;
    font-weight: 600;
  }

  .pillar-desc {
    font-size: 0.85rem;
    line-height: 1.4;
  }

  .features-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
  }

  .feature-card {
    padding: 1.5rem;
    text-align: center;
  }

  .feature-icon {
    font-size: 2rem;
    margin-bottom: 0.75rem;
  }

  .feature-card h4 {
    font-size: 1rem;
    margin-bottom: 0.5rem;
  }

  .feature-card p {
    font-size: 0.85rem;
  }

  .county-focus {
    padding: 2rem 0;
  }

  .counties-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
  }

  .county-image {
    height: 180px;
  }

  .county-content {
    padding: 1rem;
  }

  .county-card h4 {
    font-size: 1rem;
  }

  .county-card p {
    font-size: 0.85rem;
  }

  .public-section {
    padding: 2rem 0;
  }

  .public-section h2 {
    font-size: 1.5rem !important;
  }

  .public-table {
    font-size: 0.8rem;
  }

  .public-table th,
  .public-table td {
    padding: 0.5rem;
  }

  .progress-bar {
    width: 50px;
    margin-right: 0.25rem;
  }

  .progress-text {
    font-size: 0.75rem;
  }
}

@media (max-width: 480px) {
  .hero {
    padding: 1rem 0;
  }

  .hero-title {
    font-size: 1.25rem !important;
  }

  .hero-subtitle {
    font-size: 0.875rem;
    line-height: 1.4;
    margin-bottom: 1rem;
  }

  .hero-actions {
    gap: 0.5rem;
  }

  .badge {
    font-size: 0.7rem;
    padding: 0.4rem 0.8rem;
  }

  .stat-card-1,
  .stat-card-2,
  .stat-card-3 {
    display: none !important;
  }

  .programs-header h2 {
    font-size: 1.25rem !important;
  }

  .programs-header p {
    font-size: 0.8rem;
  }

  .card-image-wrapper {
    height: 150px;
  }

  .card-header h3 {
    font-size: 0.95rem;
  }

  .card-content {
    padding: 0.75rem;
  }

  .full-name,
  .pillar-desc {
    font-size: 0.75rem;
  }

  .counties-grid {
    grid-template-columns: 1fr;
  }

  .county-image {
    height: 150px;
  }

  .county-content {
    padding: 1rem;
  }

  .county-card h4 {
    font-size: 0.95rem;
  }

  .county-card p {
    font-size: 0.8rem;
  }

  .public-table {
    font-size: 0.7rem;
  }

  .public-table th,
  .public-table td {
    padding: 0.25rem;
  }

  .public-section h2 {
    font-size: 1.25rem !important;
  }
}

@media (max-width: 360px) {
  .hero {
    padding: 1.5rem 0 1rem;
  }

  .container {
    padding: 0.5rem;
  }

  .hero-content {
    gap: 1rem;
  }

  .badge {
    padding: 0.3rem 0.6rem;
    font-size: 0.65rem;
    margin-bottom: 0.5rem;
  }

  .hero-title {
    font-size: 1.15rem !important;
    margin-bottom: 0.4rem;
  }

  .hero-subtitle {
    font-size: 0.8rem;
    line-height: 1.3;
    margin-bottom: 0.75rem;
  }

  .hero-actions {
    gap: 0.5rem;
  }

  .hero-actions button {
    font-size: 0.85rem;
    padding: 0.6rem 1rem !important;
  }

  .hero-image {
    height: 200px;
    margin-top: 0.75rem;
  }

  .stat-card-1,
  .stat-card-2,
  .stat-card-3 {
    display: none !important;
  }

  .programs-header h2 {
    font-size: 1.1rem !important;
  }

  .programs-header p {
    font-size: 0.75rem;
  }

  .programs-grid {
    gap: 0.75rem;
  }

  .card-image-wrapper {
    height: 130px;
  }

  .card-header h3 {
    font-size: 0.9rem;
  }

  .card-content {
    padding: 0.6rem;
  }

  .full-name {
    font-size: 0.8rem;
  }

  .pillar-desc {
    font-size: 0.7rem;
    line-height: 1.3;
  }

  .feature-card {
    padding: 0.75rem;
  }

  .feature-icon {
    font-size: 1.5rem;
    margin-bottom: 0.3rem;
  }

  .feature-card h4 {
    font-size: 0.9rem;
    margin-bottom: 0.3rem;
  }

  .feature-card p {
    font-size: 0.75rem;
  }

  .county-image {
    height: 130px;
  }

  .county-content {
    padding: 0.6rem;
  }

  .county-card h4 {
    font-size: 0.9rem;
  }

  .county-card p {
    font-size: 0.75rem;
  }

  .public-table {
    font-size: 0.65rem;
  }

  .public-table th,
  .public-table td {
    padding: 0.2rem;
  }

  .public-section h2 {
    font-size: 1.1rem !important;
  }

  .features-grid {
    grid-template-columns: 1fr;
  }

  .about {
    padding: 4rem 0;
  }

  .about-content .heading-1 {
    font-size: 2rem;
  }

  .about-description {
    font-size: 0.95rem;
  }

  .partners-logos {
    grid-template-columns: repeat(2, 1fr);
    gap: 1.5rem;
  }

  .partner-logo-card {
    padding: 2rem 1rem;
  }

  .partner-img {
    height: 60px;
    max-width: 100px;
  }
}
</style>
