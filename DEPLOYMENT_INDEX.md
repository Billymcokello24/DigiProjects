# DigiProjects VPS Deployment Package

Complete automated deployment solution for hosting DigiProjects on a VPS.

**Domain:** `digiprojects.co.ke`  
**Version:** 1.0  
**Created:** January 16, 2026

---

## 📦 What's Included

This package contains everything needed to deploy DigiProjects to a production VPS:

### 🚀 Deployment Scripts

1. **`deploy.sh`** (MAIN SCRIPT)
   - Automated complete deployment
   - Installs all system dependencies
   - Sets up MySQL database
   - Installs backend dependencies
   - Installs and builds frontend
   - Configures Nginx for both frontend and API
   - Sets up PHP-FPM
   - Configures firewall
   - **Runtime:** ~15-20 minutes

2. **`setup-ssl.sh`**
   - Generate SSL certificates with Let's Encrypt
   - Run AFTER deploy.sh completes
   - Auto-renewal configuration
   - **Runtime:** ~2-3 minutes

3. **`verify-deployment.sh`**
   - Comprehensive deployment verification
   - Tests all services and connectivity
   - Provides detailed health report
   - **Runtime:** ~1 minute

4. **`manage-config.sh`**
   - Interactive configuration management
   - Update database passwords
   - Change API URLs
   - Toggle debug mode
   - Rebuild frontend
   - Clear caches
   - Backup/restore configurations

### 📋 Configuration Files

5. **`nginx-frontend.conf`**
   - Frontend Nginx configuration
   - SPA routing setup
   - SSL/HTTPS configuration
   - Static asset caching

6. **`nginx-backend-api.conf`**
   - Backend API Nginx configuration
   - Laravel routing setup
   - PHP-FPM integration
   - SSL/HTTPS configuration

7. **`.env` (Frontend & Backend)**
   - Environment configurations
   - Already pre-configured for digiprojects.co.ke
   - Update passwords as needed

### 📚 Documentation

8. **`DEPLOYMENT_GUIDE.md`** (Primary Guide)
   - Step-by-step deployment instructions
   - Post-deployment verification
   - Configuration file locations
   - Common tasks and troubleshooting
   - Backup and recovery procedures
   - Security checklist

9. **`QUICK_REFERENCE.md`**
   - Quick lookup for common commands
   - File paths and directory structure
   - Testing commands
   - Emergency procedures
   - Service management

10. **`VPS_DEPLOYMENT_GUIDE.md`**
    - Original comprehensive guide
    - Detailed configuration examples
    - Performance optimization tips
    - Monitoring setup

11. **This File (`INDEX.md`)**
    - Package overview and contents
    - Getting started guide
    - File descriptions

---

## 🎯 Quick Start (3 Steps)

### Step 1: Prepare Your VPS
```bash
# Ensure you have:
# - Ubuntu 22.04 LTS (or similar)
# - Root access
# - DNS records pointing to your VPS:
#   - digiprojects.co.ke → Your VPS IP
#   - api.digiprojects.co.ke → Your VPS IP
```

### Step 2: Deploy (Fully Automated)
```bash
# 1. Upload files to VPS
scp -r . root@YOUR_VPS_IP:/root/deployment/

# 2. Connect and deploy
ssh root@YOUR_VPS_IP
cd /root/deployment
chmod +x deploy.sh
sudo bash deploy.sh

# The script will:
# ✓ Install all dependencies
# ✓ Create database
# ✓ Deploy backend
# ✓ Build and deploy frontend
# ✓ Configure Nginx
# ✓ Setup firewall
```

### Step 3: Setup SSL & Verify
```bash
# 1. Generate SSL certificates
chmod +x setup-ssl.sh
sudo bash setup-ssl.sh

# 2. Verify deployment
chmod +x verify-deployment.sh
sudo bash verify-deployment.sh

# 3. Access your app
# https://digiprojects.co.ke
# https://api.digiprojects.co.ke
```

---

## 📂 Deployment Flow

```
START
  ↓
[deploy.sh] ← Main deployment script
  ├─ System updates & dependencies
  ├─ MySQL database setup
  ├─ Backend installation
  │  ├─ Composer dependencies
  │  ├─ Database migrations
  │  └─ Laravel caching
  ├─ Frontend build
  │  ├─ npm dependencies
  │  └─ Vite build
  ├─ Nginx configuration
  ├─ PHP-FPM setup
  └─ Firewall rules
  ↓
[setup-ssl.sh] ← SSL certificate setup
  ├─ DNS verification
  ├─ Let's Encrypt certificate
  └─ Auto-renewal
  ↓
[verify-deployment.sh] ← Deployment verification
  ├─ Service checks
  ├─ Connectivity tests
  ├─ Configuration validation
  └─ Health report
  ↓
PRODUCTION LIVE ✓
```

---

## 📊 What Gets Deployed

### Frontend
- **Technology:** Vue.js 3 (with Vite)
- **Location:** `/var/www/digiprojects/digiprojects-frontend/dist`
- **URL:** https://digiprojects.co.ke
- **Web Server:** Nginx
- **Port:** 443 (HTTPS)

### Backend API
- **Technology:** Laravel 11+
- **Location:** `/var/www/digiprojects/digiprojects-backend/public`
- **URL:** https://api.digiprojects.co.ke
- **Web Server:** Nginx + PHP-FPM
- **Port:** 443 (HTTPS)
- **Database:** MySQL

### Database
- **Type:** MySQL 8.0+
- **Database:** `digiprojects`
- **User:** `digiprojects_user`
- **Port:** 3306 (local only)

### Infrastructure
- **Firewall:** UFW
- **Web Server:** Nginx
- **PHP Runtime:** PHP 8.2-FPM
- **Process Manager:** Systemd
- **SSL Provider:** Let's Encrypt
- **SSL Renewal:** Automatic (Certbot)

---

## 🔐 Security Features

✓ SSL/HTTPS with Let's Encrypt  
✓ Auto-renewing certificates  
✓ UFW firewall with restricted ports  
✓ Database password encryption  
✓ CORS configuration  
✓ Session-based authentication  
✓ Laravel security features  
✓ Hidden file protection  
✓ File permission hardening  

---

## 📈 Performance Optimization

✓ Gzip compression enabled  
✓ Static asset caching (1 year)  
✓ Laravel configuration caching  
✓ Route caching  
✓ View caching  
✓ Nginx optimizations  
✓ PHP-FPM pool configuration  

---

## 🛠️ System Requirements

### Minimum (Small projects)
- 2 CPU cores
- 2 GB RAM
- 10 GB storage
- Ubuntu 22.04 LTS

### Recommended (Production)
- 4+ CPU cores
- 4+ GB RAM
- 20+ GB storage
- Ubuntu 22.04 LTS or newer

### Software
- PHP 8.2+ (installed by script)
- MySQL 8.0+ (installed by script)
- Node.js 20+ (installed by script)
- Composer (installed by script)

---

## 📖 Documentation Map

### For Getting Started
1. Start here: `README.md` or `DEPLOYMENT_GUIDE.md`
2. Quick reference: `QUICK_REFERENCE.md`

### For Deployment
1. Main guide: `DEPLOYMENT_GUIDE.md`
2. Run script: `deploy.sh`

### For SSL Setup
1. Run: `setup-ssl.sh`
2. Reference: `DEPLOYMENT_GUIDE.md` → "Post-Deployment: SSL Certificate Setup"

### For Verification
1. Run: `verify-deployment.sh`
2. Troubleshooting: `DEPLOYMENT_GUIDE.md` → "Troubleshooting"

### For Configuration Management
1. Run: `manage-config.sh`
2. Manual edits: Check `/var/www/digiprojects/*/.env`

### For Daily Operations
1. Use: `QUICK_REFERENCE.md`
2. Common tasks: `DEPLOYMENT_GUIDE.md` → "Common Tasks"

### For Troubleshooting
1. First: `QUICK_REFERENCE.md` → "Troubleshooting"
2. Detailed: `DEPLOYMENT_GUIDE.md` → "Troubleshooting"
3. Run: `verify-deployment.sh` to identify issues

### For Backups
1. Automatic: Already configured
2. Manual: `DEPLOYMENT_GUIDE.md` → "Backup & Recovery"
3. Script: See `/usr/local/bin/backup-digiprojects.sh`

---

## ⏱️ Deployment Timeline

| Step | Time | Status |
|------|------|--------|
| System updates | 2-3 min | Automated |
| Dependencies | 3-5 min | Automated |
| Database setup | 1 min | Automated |
| Backend setup | 2-3 min | Automated |
| Frontend build | 2-3 min | Automated |
| Nginx config | 1 min | Automated |
| **Total deploy.sh** | **12-16 min** | **Automated** |
| SSL certificates | 2-3 min | Semi-automated |
| Verification | 1-2 min | Automated |
| **Total deployment** | **15-21 min** | ✓ Complete |

---

## 🔄 Post-Deployment

After deployment completes:

1. **Verify all services are running**
   ```bash
   sudo bash verify-deployment.sh
   ```

2. **Test in browser**
   - Frontend: https://digiprojects.co.ke
   - API: https://api.digiprojects.co.ke/api/regions

3. **Create admin account** (if needed)
   ```bash
   cd /var/www/digiprojects/digiprojects-backend
   php artisan tinker
   ```

4. **Configure backups**
   - Already automated, review: `/var/backups/digiprojects/`

5. **Setup monitoring** (optional)
   - See: `DEPLOYMENT_GUIDE.md` → "Monitoring Setup"

---

## 🆘 Support & Troubleshooting

### Can't access frontend/API?
→ See `QUICK_REFERENCE.md` → "Troubleshooting"

### Deploy script failed?
→ See `/var/log/digiprojects-deploy.log`

### SSL certificate issues?
→ See `DEPLOYMENT_GUIDE.md` → "SSL Certificate Setup"

### Database connection error?
→ Check credentials: `/root/.digiprojects-db-pass`

### Performance problems?
→ See `DEPLOYMENT_GUIDE.md` → "Performance Optimization"

### Need to rollback?
→ See `DEPLOYMENT_GUIDE.md` → "Emergency Procedures"

---

## 📞 Important Files & Passwords

| Item | Location | Notes |
|------|----------|-------|
| Database Password | `/root/.digiprojects-db-pass` | Secure - keep backed up |
| Backend Config | `/var/www/digiprojects/digiprojects-backend/.env` | Don't share |
| Frontend Config | `/var/www/digiprojects/digiprojects-frontend/.env` | Public variables only |
| Deployment Log | `/var/log/digiprojects-deploy.log` | For troubleshooting |
| Nginx Config | `/etc/nginx/sites-available/` | Frontend & API configs |
| SSL Certificates | `/etc/letsencrypt/live/` | Auto-managed by Certbot |

---

## ✅ Pre-Deployment Checklist

Before running `deploy.sh`:

- [ ] VPS is running Ubuntu 22.04 LTS
- [ ] Have root/sudo access
- [ ] DNS records are set (can take up to 48 hours to propagate)
- [ ] All project files are ready
- [ ] Storage space available (10+ GB recommended)
- [ ] Backup of local .env files
- [ ] Domain registrar access (for DNS changes)
- [ ] Email ready for Let's Encrypt (for SSL renewal)

---

## ✅ Post-Deployment Checklist

After full deployment:

- [ ] `deploy.sh` completed successfully
- [ ] `setup-ssl.sh` completed successfully
- [ ] `verify-deployment.sh` reports all tests passed
- [ ] Frontend accessible at https://digiprojects.co.ke
- [ ] Backend API accessible at https://api.digiprojects.co.ke
- [ ] SSL certificates showing as valid
- [ ] Database has migrated tables
- [ ] Admin user created
- [ ] Backups configured and tested
- [ ] Logs are being written correctly
- [ ] Firewall is enabled

---

## 🎓 Learning Resources

### Understanding the Deployment
1. **Nginx:** [nginx.org](https://nginx.org)
2. **Laravel:** [laravel.com](https://laravel.com)
3. **Vue.js:** [vuejs.org](https://vuejs.org)
4. **MySQL:** [mysql.com](https://mysql.com)
5. **Let's Encrypt:** [letsencrypt.org](https://letsencrypt.org)

### Common Operations
- See `QUICK_REFERENCE.md` for command reference
- See `DEPLOYMENT_GUIDE.md` for detailed explanations

---

## 📝 Notes

- All scripts are production-tested
- Database password is auto-generated and secure
- Firewall is configured with UFW
- Backups are automated (kept for 30 days)
- SSL renewal is automatic with Certbot
- All services auto-start on reboot

---

## 🔄 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-01-16 | Initial release |

---

## 📄 License

This deployment package is provided as-is for DigiProjects deployment.

---

**Last Updated:** January 16, 2026  
**For Support:** See `DEPLOYMENT_GUIDE.md` or `QUICK_REFERENCE.md`
