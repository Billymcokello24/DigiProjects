# DigiProjects Complete VPS Deployment Guide

## Overview
This guide walks you through deploying DigiProjects on your VPS with everything configured for production.

**Domain:** `digiprojects.co.ke`  
**API Domain:** `api.digiprojects.co.ke`  
**Frontend:** Vue.js (served from dist/)  
**Backend:** Laravel API  
**Database:** MySQL  
**Web Server:** Nginx  
**SSL:** Let's Encrypt

---

## Prerequisites

- VPS running Ubuntu 22.04 LTS (or similar)
- Root/sudo access
- Domains pointing to your VPS IP:
  - `digiprojects.co.ke` → Your VPS IP
  - `www.digiprojects.co.ke` → Your VPS IP
  - `api.digiprojects.co.ke` → Your VPS IP

---

## Deployment Steps

### Step 1: Upload Project Files to VPS

On your local machine:
```bash
scp -r digiprojects-backend root@YOUR_VPS_IP:/var/www/digiprojects/
scp -r digiprojects-frontend root@YOUR_VPS_IP:/var/www/digiprojects/
scp deploy.sh root@YOUR_VPS_IP:/root/
```

### Step 2: Connect to VPS

```bash
ssh root@YOUR_VPS_IP
cd /root
```

### Step 3: Run Automated Deployment Script

```bash
chmod +x deploy.sh
sudo bash deploy.sh
```

**What this script does automatically:**
- ✅ Updates system packages
- ✅ Installs PHP, MySQL, Node.js, Nginx
- ✅ Creates database and user
- ✅ Installs backend dependencies (composer)
- ✅ Runs database migrations
- ✅ Caches Laravel configuration
- ✅ Installs frontend dependencies (npm)
- ✅ Builds frontend Vue.js app
- ✅ Configures Nginx for both frontend and backend
- ✅ Configures PHP-FPM
- ✅ Sets up firewall rules
- ✅ Creates backup scripts

---

## Post-Deployment: SSL Certificate Setup

### Step 1: Verify DNS Resolution

```bash
# Should return your VPS IP
nslookup digiprojects.co.ke
nslookup api.digiprojects.co.ke
```

### Step 2: Generate SSL Certificates

On your VPS:
```bash
sudo certbot certonly --nginx -d digiprojects.co.ke -d www.digiprojects.co.ke -d api.digiprojects.co.ke
```

Follow the prompts to:
- Enter your email address
- Agree to terms
- Enable auto-renewal

### Step 3: Restart Nginx

```bash
sudo systemctl restart nginx
```

### Step 4: Verify SSL

```bash
# Check certificate details
sudo certbot certificates

# Test HTTPS
curl https://digiprojects.co.ke
curl https://api.digiprojects.co.ke/api/regions
```

---

## Testing & Verification

### Test Frontend Access
```bash
curl -I https://digiprojects.co.ke
# Should return 200 OK
```

### Test Backend API
```bash
curl https://api.digiprojects.co.ke/api/regions
# Should return JSON data
```

### Test from Browser
1. Open `https://digiprojects.co.ke`
2. Check browser console (F12 → Console tab)
3. Verify no CORS or network errors

### Check Logs

**Nginx errors:**
```bash
sudo tail -f /var/log/nginx/error.log
```

**Laravel logs:**
```bash
sudo tail -f /var/www/digiprojects/digiprojects-backend/storage/logs/laravel.log
```

**PHP-FPM logs:**
```bash
sudo tail -f /var/log/php8.2-fpm.log
```

---

## Configuration Files Location

| Component | Config File | Path |
|-----------|-------------|------|
| Frontend | .env | `/var/www/digiprojects/digiprojects-frontend/.env` |
| Backend | .env | `/var/www/digiprojects/digiprojects-backend/.env` |
| Nginx (Frontend) | nginx config | `/etc/nginx/sites-available/digiprojects` |
| Nginx (Backend) | nginx config | `/etc/nginx/sites-available/digiprojects-api` |
| PHP-FPM | php-fpm config | `/etc/php/8.2/fpm/pool.d/www.conf` |
| SSL Certificates | | `/etc/letsencrypt/live/digiprojects.co.ke/` |
| Database credentials | | `/root/.digiprojects-db-pass` |

---

## Common Tasks

### Restart Services

```bash
# Restart everything
sudo systemctl restart nginx php8.2-fpm mysql

# Restart just one service
sudo systemctl restart nginx
sudo systemctl restart php8.2-fpm
sudo systemctl restart mysql
```

### View Service Status

```bash
sudo systemctl status nginx
sudo systemctl status php8.2-fpm
sudo systemctl status mysql
```

### Check Open Ports

```bash
sudo ss -tlnp | grep LISTEN
```

### View Active Connections

```bash
sudo netstat -an | grep ESTABLISHED | wc -l
```

---

## Backup & Recovery

### Create Backup

```bash
sudo bash /usr/local/bin/backup-digiprojects.sh
```

### List Backups

```bash
ls -lah /var/backups/digiprojects/
```

### Restore Database

```bash
gunzip < /var/backups/digiprojects/db_YYYYMMDD_HHMMSS.sql.gz | mysql -u digiprojects_user -p digiprojects
```

---

## Troubleshooting

### Issue: Frontend shows 404

**Solution:**
1. Check Nginx config: `sudo nginx -t`
2. Verify frontend files exist: `ls -la /var/www/digiprojects/digiprojects-frontend/dist/`
3. Check Nginx error log: `sudo tail -f /var/log/nginx/error.log`

### Issue: API returns error

**Solution:**
1. Check Laravel logs: `sudo tail -f /var/www/digiprojects/digiprojects-backend/storage/logs/laravel.log`
2. Verify database connection: `mysql -u digiprojects_user -p digiprojects`
3. Check PHP-FPM status: `sudo systemctl status php8.2-fpm`

### Issue: CORS errors in browser

**Solution:**
1. Check CORS config: `/var/www/digiprojects/digiprojects-backend/config/cors.php`
2. Verify allowed_origins includes your domain
3. Restart PHP-FPM: `sudo systemctl restart php8.2-fpm`

### Issue: SSL certificate not renewing

**Solution:**
```bash
# Manual renewal
sudo certbot renew --force-renewal

# Check renewal status
sudo certbot renew --dry-run
```

---

## Performance Optimization

### Enable Opcache (PHP)

```bash
sudo phpenmod opcache
sudo systemctl restart php8.2-fpm
```

### Enable Redis Cache

```bash
sudo systemctl start redis-server
sudo systemctl enable redis-server

# Update backend .env:
# CACHE_STORE=redis
```

### Compress Responses

Already enabled in Nginx configuration (gzip).

### CDN Setup (Optional)

For static assets, consider using Cloudflare:
1. Add your domain to Cloudflare
2. Update nameservers with your registrar
3. Enable caching in Cloudflare dashboard

---

## Security Checklist

- [ ] SSH key-based authentication enabled (no password login)
- [ ] Firewall (UFW) configured and enabled
- [ ] Failed login attempts limited
- [ ] Regular backups enabled and tested
- [ ] SSL certificates installed and auto-renewing
- [ ] PHP display_errors disabled in production
- [ ] Database backups encrypted
- [ ] Server updates applied regularly
- [ ] Monitoring/alerts set up
- [ ] DDoS protection enabled (Cloudflare, etc.)

---

## Monitoring Setup

### Install Monitoring Tools (Optional)

```bash
# Monit for service monitoring
sudo apt-get install monit

# Netdata for system monitoring
wget -O /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh
sh /tmp/netdata-kickstart.sh --stable-channel --disable-telemetry
```

### Check CPU/Memory Usage

```bash
top
# or
free -h
df -h
```

---

## Support & Maintenance

### Regular Maintenance Tasks

**Weekly:**
- Check error logs
- Monitor disk space

**Monthly:**
- Test backups by restoring to staging
- Review and update packages

**Quarterly:**
- Security audit
- Performance review

### Database Maintenance

```bash
# Optimize tables
sudo mysql -u digiprojects_user -p digiprojects -e "OPTIMIZE TABLE users, projects, submissions, etc;"

# Check table status
sudo mysql -u digiprojects_user -p digiprojects -e "CHECK TABLE users;"
```

---

## Useful Commands

```bash
# Check if domain is properly configured
dig digiprojects.co.ke
dig api.digiprojects.co.ke

# Test API endpoint
curl -v https://api.digiprojects.co.ke/api/regions

# Check database connection
mysql -u digiprojects_user -p -e "SELECT VERSION();"

# View deployed app
ps aux | grep -E 'php|nginx|mysql'

# Monitor real-time traffic
sudo tail -f /var/log/nginx/access.log

# Count active database connections
mysql -e "SHOW PROCESSLIST;"
```

---

## Emergency Procedures

### Emergency Restart

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
# Restore from backup
gunzip < /var/backups/digiprojects/db_latest.sql.gz | mysql -u digiprojects_user -p digiprojects
```

---

## After Deployment Checklist

- [ ] Visited https://digiprojects.co.ke and confirmed frontend loads
- [ ] Visited https://api.digiprojects.co.ke/api/regions and confirmed API responds
- [ ] Tested user login functionality
- [ ] Tested creating/editing data in the app
- [ ] Checked that SSL certificates are valid (green lock in browser)
- [ ] Configured automated backups
- [ ] Set up monitoring alerts
- [ ] Created admin user account
- [ ] Updated DNS MX records (if using email)
- [ ] Notified stakeholders of deployment

---

That's it! Your DigiProjects application is now live on your VPS.
