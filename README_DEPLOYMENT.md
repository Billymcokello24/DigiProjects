# 🚀 DigiProjects Complete VPS Deployment

**Everything you need to deploy DigiProjects to production on your VPS**

---

## ⚡ Quick Start (Copy & Paste)

```bash
# 1. On your local machine, upload everything to VPS
scp -r /path/to/deployment/ root@YOUR_VPS_IP:/root/

# 2. SSH into your VPS
ssh root@YOUR_VPS_IP
cd /root/deployment

# 3. Run the deployment (fully automated, ~15 minutes)
chmod +x deploy.sh
bash deploy.sh

# 4. Setup SSL certificates
chmod +x setup-ssl.sh
bash setup-ssl.sh

# 5. Verify everything is working
chmod +x verify-deployment.sh
bash verify-deployment.sh
```

Then visit:
- **Frontend:** https://digiprojects.co.ke
- **Backend API:** https://api.digiprojects.co.ke

---

## 📦 What's Deployed

| Component | Technology | URL |
|-----------|-----------|-----|
| **Frontend** | Vue.js 3 (Vite) | https://digiprojects.co.ke |
| **Backend** | Laravel 11+ | https://api.digiprojects.co.ke |
| **Database** | MySQL 8.0+ | localhost:3306 |
| **Web Server** | Nginx | Reverse proxy |
| **SSL** | Let's Encrypt | Auto-renewing |
| **PHP Runtime** | PHP 8.2-FPM | Backend processor |

---

## 🎯 What The Script Does

### Automatically Installs & Configures:

✅ System updates and security patches  
✅ PHP 8.2 with all required extensions  
✅ MySQL 8.0 database with dedicated user  
✅ Node.js 20+ for frontend builds  
✅ Nginx with production settings  
✅ Composer for PHP dependencies  
✅ Frontend Vue.js build  
✅ Backend Laravel migrations  
✅ SSL/HTTPS certificate setup framework  
✅ Firewall (UFW) with proper port rules  
✅ Automated backup system  
✅ Queue worker service  
✅ Monitoring and logging  

---

## 📋 Files Included

### 🚀 Deployment Scripts
- **`deploy.sh`** - Main deployment (all-in-one)
- **`setup-ssl.sh`** - SSL certificate generation
- **`verify-deployment.sh`** - Verification & health check
- **`manage-config.sh`** - Configuration management

### 📖 Documentation
- **`DEPLOYMENT_GUIDE.md`** - Detailed guide (Primary)
- **`QUICK_REFERENCE.md`** - Command reference
- **`DEPLOYMENT_INDEX.md`** - Package overview
- **`VPS_DEPLOYMENT_GUIDE.md`** - Alternative guide

### ⚙️ Configuration
- **`nginx-frontend.conf`** - Frontend Nginx config
- **`nginx-backend-api.conf`** - Backend Nginx config
- **`.env.example`** - Environment template

---

## 🔧 System Requirements

**Minimum:**
- 2 CPU cores
- 2 GB RAM
- 10 GB storage
- Ubuntu 22.04 LTS

**Recommended:**
- 4+ cores
- 4+ GB RAM
- 20+ GB storage
- Ubuntu 22.04 LTS

---

## 📝 Pre-Deployment Checklist

Before you start, make sure:

- [ ] You have a VPS with Ubuntu 22.04
- [ ] You have root/sudo access
- [ ] Your domain DNS records are set:
  - `digiprojects.co.ke` → Your VPS IP
  - `api.digiprojects.co.ke` → Your VPS IP
- [ ] You've read this file completely
- [ ] You have an email for SSL renewal notifications
- [ ] You have at least 10GB free disk space

---

## 🚀 Step-by-Step Deployment

### Step 1: Prepare Your VPS

**On your local machine:**
```bash
# Copy all deployment files to VPS
scp -r . root@YOUR_VPS_IP:/root/deployment/

# Or if using git:
git clone <your-repo> /tmp/digiprojects
scp -r /tmp/digiprojects/* root@YOUR_VPS_IP:/root/deployment/
```

### Step 2: Connect to VPS

```bash
ssh root@YOUR_VPS_IP
cd /root/deployment
ls -la  # Verify files are there
```

### Step 3: Run Main Deployment

```bash
chmod +x deploy.sh
bash deploy.sh
```

**What happens:**
- You'll be asked to confirm the deployment
- The database password will be auto-generated
- Installation will take 12-16 minutes
- You'll see progress messages for each step
- A log file is created at `/var/log/digiprojects-deploy.log`

### Step 4: Setup SSL Certificates

**After deploy.sh completes:**

```bash
chmod +x setup-ssl.sh
bash setup-ssl.sh
```

**What happens:**
- Certbot validates your domains
- Let's Encrypt issues SSL certificates
- Nginx is restarted with HTTPS
- Auto-renewal is configured

### Step 5: Verify Deployment

```bash
chmod +x verify-deployment.sh
bash verify-deployment.sh
```

**What you'll see:**
- System services status
- Connectivity tests
- Database status
- SSL certificate validation
- File permissions check
- Overall health report

---

## ✅ After Deployment

### Test Your Application

**In browser:**
```
https://digiprojects.co.ke              # Frontend
https://api.digiprojects.co.ke/api/regions  # API
```

**Via command line:**
```bash
# Test frontend
curl -I https://digiprojects.co.ke

# Test API
curl https://api.digiprojects.co.ke/api/regions
```

### Check Logs

```bash
# Nginx errors
tail -f /var/log/nginx/error.log

# Laravel logs
tail -f /var/www/digiprojects/digiprojects-backend/storage/logs/laravel.log

# Deployment log
cat /var/log/digiprojects-deploy.log
```

### Access Database

```bash
# Get password (saved during deployment)
cat /root/.digiprojects-db-pass

# Connect to MySQL
mysql -u digiprojects_user -p digiprojects
```

---

## 🎮 Common Commands

### Start/Stop Services

```bash
# Restart all services
sudo systemctl restart nginx php8.2-fpm mysql

# Restart individual service
sudo systemctl restart nginx

# Check service status
sudo systemctl status nginx
```

### View Configuration

```bash
# Frontend environment
cat /var/www/digiprojects/digiprojects-frontend/.env

# Backend environment
cat /var/www/digiprojects/digiprojects-backend/.env

# Nginx config
cat /etc/nginx/sites-available/digiprojects
```

### Rebuild Frontend

```bash
cd /var/www/digiprojects/digiprojects-frontend
npm install
npm run build
```

### Clear Cache

```bash
cd /var/www/digiprojects/digiprojects-backend
php artisan cache:clear
php artisan config:cache
php artisan route:cache
```

### Database Operations

```bash
# Backup database
mysqldump -u digiprojects_user -p digiprojects > backup.sql

# Restore database
mysql -u digiprojects_user -p digiprojects < backup.sql

# Run migrations
php artisan migrate

# Seed database
php artisan db:seed
```

---

## 🔒 Security Notes

✅ **SSL/HTTPS:** Let's Encrypt certificates with auto-renewal  
✅ **Firewall:** UFW firewall configured (ports 22, 80, 443)  
✅ **Database:** Dedicated user with strong password  
✅ **Permissions:** Proper file and directory permissions set  
✅ **CORS:** Backend CORS configured for frontend domain  
✅ **Debug Mode:** Disabled in production  
✅ **Database:** Local access only (no remote access by default)

---

## 🐛 Troubleshooting

### Frontend Returns 404

**Solution:**
```bash
# Check files exist
ls -la /var/www/digiprojects/digiprojects-frontend/dist/

# Verify Nginx config
sudo nginx -t

# Rebuild frontend
cd /var/www/digiprojects/digiprojects-frontend
npm run build
```

### Backend API Returns Error

**Solution:**
```bash
# Check Laravel logs
tail -f /var/www/digiprojects/digiprojects-backend/storage/logs/laravel.log

# Test database
mysql -u digiprojects_user -p digiprojects -e "SELECT 1;"

# Check PHP-FPM status
sudo systemctl status php8.2-fpm
```

### SSL Certificate Issues

**Solution:**
```bash
# Check certificate status
sudo certbot certificates

# Force renewal
sudo certbot renew --force-renewal

# Test renewal (dry-run)
sudo certbot renew --dry-run
```

### Can't Connect to Backend

**Solution:**
```bash
# Check CORS configuration
cat /var/www/digiprojects/digiprojects-backend/config/cors.php

# Restart PHP
sudo systemctl restart php8.2-fpm

# Check error log
tail -f /var/log/php8.2-fpm.log
```

---

## 📞 Key Information

### Database
- **User:** `digiprojects_user`
- **Database:** `digiprojects`
- **Password:** Saved in `/root/.digiprojects-db-pass`
- **Host:** localhost
- **Port:** 3306

### File Locations
```
Frontend:  /var/www/digiprojects/digiprojects-frontend/dist/
Backend:   /var/www/digiprojects/digiprojects-backend/
Config:    /etc/nginx/sites-available/
Logs:      /var/log/nginx/
Backups:   /var/backups/digiprojects/
```

### Websites
```
Frontend:  https://digiprojects.co.ke
Backend:   https://api.digiprojects.co.ke
API:       https://api.digiprojects.co.ke/api
```

---

## 📚 Detailed Documentation

For more details, see:

| Document | Purpose |
|----------|---------|
| `DEPLOYMENT_GUIDE.md` | Complete guide (read this for details) |
| `QUICK_REFERENCE.md` | Command reference & cheat sheet |
| `DEPLOYMENT_INDEX.md` | Package overview & structure |
| `/var/log/digiprojects-deploy.log` | Deployment log file |

---

## 🆘 Emergency Procedures

### Emergency Restart All Services

```bash
sudo systemctl restart nginx php8.2-fpm mysql
```

### Emergency Rebuild Frontend

```bash
cd /var/www/digiprojects/digiprojects-frontend
npm install
npm run build
```

### Emergency Database Restore

```bash
# List backups
ls -la /var/backups/digiprojects/

# Restore (example)
gunzip < /var/backups/digiprojects/db_20260116_120000.sql.gz | \
  mysql -u digiprojects_user -p digiprojects
```

---

## ✅ Deployment Checklist

After deployment is complete, verify:

- [ ] Frontend loads at https://digiprojects.co.ke
- [ ] Backend API responds at https://api.digiprojects.co.ke/api/regions
- [ ] SSL certificates are valid (green lock in browser)
- [ ] Database is working (`mysql -u digiprojects_user -p`)
- [ ] Logs are being written (`tail -f /var/log/nginx/error.log`)
- [ ] Firewall is active (`sudo ufw status`)
- [ ] All services are running (`sudo systemctl status nginx`)
- [ ] Backups are configured (`ls -la /var/backups/digiprojects/`)

---

## 🎓 Need Help?

1. **Read the logs:** `/var/log/digiprojects-deploy.log`
2. **Run verification:** `sudo bash verify-deployment.sh`
3. **Check guides:** `DEPLOYMENT_GUIDE.md` or `QUICK_REFERENCE.md`
4. **Review common issues:** See "Troubleshooting" above

---

## 🔄 Regular Maintenance

### Weekly
- Monitor disk space: `df -h`
- Check logs for errors: `tail -f /var/log/nginx/error.log`

### Monthly
- Test backup restoration
- Review database size: `du -sh /var/lib/mysql`
- Check certificate expiration: `sudo certbot certificates`

### Quarterly
- Security updates: `sudo apt update && sudo apt upgrade`
- Review access logs for anomalies
- Update documentation

---

## 📞 Support Resources

- **Laravel Docs:** https://laravel.com/docs
- **Vue.js Docs:** https://vuejs.org
- **Nginx Docs:** https://nginx.org/en/docs/
- **MySQL Docs:** https://dev.mysql.com/doc/
- **Let's Encrypt:** https://letsencrypt.org/docs/

---

## 📝 Notes

- The deployment script is idempotent (can be run multiple times safely)
- Database password is auto-generated and secure
- All services are configured to auto-start on reboot
- SSL certificates auto-renew 30 days before expiration
- Backups are kept for 30 days by default

---

## 🎉 You're Ready!

Your VPS is configured and ready for production. Your DigiProjects application is now live at:

- **https://digiprojects.co.ke** (Frontend)
- **https://api.digiprojects.co.ke** (Backend API)

**Enjoy your deployment!** 🚀

---

**Deployment Package Version:** 1.0  
**Created:** January 16, 2026  
**For:** digiprojects.co.ke

For detailed information, see `DEPLOYMENT_GUIDE.md`
