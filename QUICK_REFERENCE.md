# DigiProjects VPS Deployment - Quick Reference Card

## 📋 Quick Deployment Summary

| Item | Details |
|------|---------|
| **Domain** | digiprojects.co.ke |
| **API Domain** | api.digiprojects.co.ke |
| **Project Path** | /var/www/digiprojects |
| **Web Server** | Nginx |
| **Database** | MySQL 8.0+ |
| **PHP Version** | 8.2+ |
| **Node Version** | 20+ |
| **Frontend** | Vue.js 3 (Vite) |
| **Backend** | Laravel 11+ |

---

## 🚀 Deployment Steps (Quick)

### Step 1: Prepare VPS
```bash
# SSH into VPS
ssh root@YOUR_VPS_IP

# Create project directory
mkdir -p /var/www/digiprojects
cd /var/www/digiprojects
```

### Step 2: Upload Files
```bash
# From your local machine
scp -r digiprojects-backend/ root@YOUR_VPS_IP:/var/www/digiprojects/
scp -r digiprojects-frontend/ root@YOUR_VPS_IP:/var/www/digiprojects/
scp deploy.sh root@YOUR_VPS_IP:/root/
```

### Step 3: Run Deployment
```bash
# On VPS
cd /root
chmod +x deploy.sh
sudo bash deploy.sh
```

### Step 4: Setup SSL
```bash
chmod +x /root/setup-ssl.sh
sudo bash /root/setup-ssl.sh
```

### Step 5: Verify
```bash
chmod +x /root/verify-deployment.sh
sudo bash /root/verify-deployment.sh
```

---

## 📁 Important Paths

```
/var/www/digiprojects/
├── digiprojects-backend/
│   ├── .env              ← Backend configuration
│   ├── storage/          ← App data & logs
│   ├── app/              ← Laravel code
│   └── public/           ← Web root
└── digiprojects-frontend/
    ├── .env              ← Frontend configuration
    ├── dist/             ← Built files (web root)
    └── src/              ← Vue.js source code

/etc/nginx/sites-available/
├── digiprojects          ← Frontend config
└── digiprojects-api      ← Backend API config

/etc/letsencrypt/live/
├── digiprojects.co.ke/
└── api.digiprojects.co.ke/
```

---

## 🔧 Common Commands

### Start/Stop Services
```bash
sudo systemctl start nginx              # Start Nginx
sudo systemctl stop nginx               # Stop Nginx
sudo systemctl restart nginx            # Restart Nginx
sudo systemctl status nginx             # Check status

sudo systemctl restart php8.2-fpm       # Restart PHP
sudo systemctl restart mysql            # Restart MySQL
```

### View Logs
```bash
tail -f /var/log/nginx/error.log                                    # Nginx errors
tail -f /var/www/digiprojects/digiprojects-backend/storage/logs/laravel.log  # Laravel
tail -f /var/log/php8.2-fpm.log                                    # PHP errors
```

### Rebuild Frontend
```bash
cd /var/www/digiprojects/digiprojects-frontend
npm install
npm run build
```

### Clear Laravel Cache
```bash
cd /var/www/digiprojects/digiprojects-backend
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### Database Commands
```bash
# Access MySQL
mysql -u digiprojects_user -p digiprojects

# Run migrations
php artisan migrate

# Seed database
php artisan db:seed

# Backup database
mysqldump -u digiprojects_user -p digiprojects > backup.sql

# Restore database
mysql -u digiprojects_user -p digiprojects < backup.sql
```

---

## 🔒 Security

### Firewall
```bash
sudo ufw status                  # Check firewall status
sudo ufw enable                  # Enable firewall
sudo ufw allow 22/tcp           # SSH
sudo ufw allow 80/tcp           # HTTP
sudo ufw allow 443/tcp          # HTTPS
```

### SSL Renewal
```bash
sudo certbot renew              # Manually renew certs
sudo certbot renew --dry-run    # Test renewal
```

### File Permissions
```bash
# Frontend
sudo chown -R www-data:www-data /var/www/digiprojects/digiprojects-frontend/dist
sudo chmod -R 755 /var/www/digiprojects/digiprojects-frontend/dist

# Backend storage
sudo chown -R www-data:www-data /var/www/digiprojects/digiprojects-backend/storage
sudo chmod -R 775 /var/www/digiprojects/digiprojects-backend/storage
```

---

## 🧪 Testing

### Test Frontend
```bash
curl -I https://digiprojects.co.ke
# Should return: HTTP/1.1 200 OK
```

### Test Backend
```bash
curl -I https://api.digiprojects.co.ke/api/regions
# Should return: HTTP/1.1 200 OK (with JSON data)
```

### Check DNS
```bash
dig digiprojects.co.ke
dig api.digiprojects.co.ke
```

### Test Database
```bash
mysql -u digiprojects_user -p digiprojects -e "SELECT VERSION();"
```

---

## ⚠️ Troubleshooting

### Frontend Returns 404
```bash
# Check if dist exists
ls -la /var/www/digiprojects/digiprojects-frontend/dist/

# Check Nginx config
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx

# View error log
sudo tail -f /var/log/nginx/error.log
```

### Backend API Returns Error
```bash
# Check Laravel log
tail -f /var/www/digiprojects/digiprojects-backend/storage/logs/laravel.log

# Test database connection
mysql -u digiprojects_user -p digiprojects -e "SELECT 1;"

# Check PHP-FPM
sudo systemctl status php8.2-fpm
```

### CORS Errors
```bash
# Check CORS config
cat /var/www/digiprojects/digiprojects-backend/config/cors.php

# Restart PHP
sudo systemctl restart php8.2-fpm
```

### SSL Certificate Issues
```bash
# Check certificate validity
sudo certbot certificates

# Force renewal
sudo certbot renew --force-renewal

# Test renewal
sudo certbot renew --dry-run
```

---

## 📊 Monitoring

### System Resources
```bash
top                     # CPU & Memory
free -h                 # Memory info
df -h                   # Disk usage
netstat -an             # Network connections
```

### Active Services
```bash
ps aux | grep -E 'php|nginx|mysql'
```

### Open Ports
```bash
sudo ss -tlnp | grep LISTEN
```

---

## 🔄 Backup & Recovery

### Create Backup
```bash
# Database
mysqldump -u digiprojects_user -p digiprojects | gzip > db_backup.sql.gz

# Storage
tar -czf storage_backup.tar.gz /var/www/digiprojects/digiprojects-backend/storage/

# Entire backend
tar -czf backend_backup.tar.gz /var/www/digiprojects/digiprojects-backend/
```

### Restore Backup
```bash
# Database
gunzip < db_backup.sql.gz | mysql -u digiprojects_user -p digiprojects

# Storage
tar -xzf storage_backup.tar.gz -C /

# Backend
tar -xzf backend_backup.tar.gz -C /
```

---

## 📞 Support Info

**Database Credentials:**
- User: `digiprojects_user`
- Database: `digiprojects`
- Password: (stored in `/root/.digiprojects-db-pass`)

**Server Details:**
- PHP Version: `php -v`
- MySQL Version: `mysql --version`
- Node Version: `node --version`
- Nginx Version: `nginx -v`

---

## ✅ Post-Deployment Checklist

- [ ] Frontend accessible at https://digiprojects.co.ke
- [ ] Backend API accessible at https://api.digiprojects.co.ke
- [ ] SSL certificates installed and valid
- [ ] Database migrations completed
- [ ] Frontend .env configured with API URL
- [ ] Backend .env configured with correct DB credentials
- [ ] Firewall enabled and ports open (22, 80, 443)
- [ ] Automated backups configured
- [ ] Email notifications setup (optional)
- [ ] Monitoring tools installed (optional)
- [ ] Admin user created in database
- [ ] Log rotation configured

---

## 🆘 Emergency Procedures

### Emergency Restart All Services
```bash
sudo systemctl restart nginx php8.2-fpm mysql
```

### Emergency Rebuild Frontend
```bash
cd /var/www/digiprojects/digiprojects-frontend
npm run build
```

### Emergency Database Restore
```bash
gunzip < db_backup.sql.gz | mysql -u digiprojects_user -p digiprojects
```

### Emergency Clear Cache
```bash
cd /var/www/digiprojects/digiprojects-backend
php artisan cache:clear
php artisan config:clear
```

---

**Last Updated:** January 16, 2026  
**Version:** 1.0  
**Deployment Date:** [Your Deployment Date]

For detailed information, see `DEPLOYMENT_GUIDE.md`
