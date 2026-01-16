# ✅ Configuration Update Complete

**Date:** January 16, 2026  
**Project:** DigiProjects  
**Domain:** digiprojects.co.ke  
**API Path:** /api (not subdomain)

---

## 🎯 Changes Made

### 1. ✅ API Domain Structure Changed
- **Before:** api.digiprojects.co.ke (separate subdomain)
- **After:** digiprojects.co.ke/api (path-based)

**Benefits:**
- Single SSL certificate needed
- Simpler DNS configuration
- Better for same-origin policy
- Easier CORS configuration
- Single Nginx server block

### 2. ✅ Database Configuration Updated
- **Before:** SQLite (file-based)
- **After:** MySQL/MariaDB (production database)

**Database Settings:**
```
Host: localhost (127.0.0.1)
Port: 3306
Database: digiprojects
User: digiprojects_user
Password: [Auto-generated during deployment]
Connection: MySQL via PDO
```

### 3. ✅ Configuration Files Updated

#### Backend (.env)
```dotenv
✓ APP_URL=https://digiprojects.co.ke (was: api subdomain)
✓ APP_NAME=DigiProjects
✓ DB_CONNECTION=mysql (was: sqlite)
✓ DB_HOST=127.0.0.1
✓ DB_PORT=3306
✓ DB_DATABASE=digiprojects
✓ DB_USERNAME=digiprojects_user
✓ SESSION_DOMAIN=.digiprojects.co.ke
✓ MAIL_FROM_ADDRESS=noreply@digiprojects.co.ke
```

#### Frontend (.env)
```env
✓ VITE_API_BASE_URL=https://digiprojects.co.ke/api (was: subdomain)
```

### 4. ✅ Nginx Configuration Updated

**Single Unified Configuration:**
- **File:** `/etc/nginx/sites-available/digiprojects`
- **Server Block:** One HTTPS block for digiprojects.co.ke
- **Frontend:** Served from `/var/www/digiprojects/digiprojects-frontend/dist`
- **API Routing:** Location `/api/` proxies to Laravel backend
- **SPA Routing:** All non-API routes serve index.html

**Removed:**
- ❌ Separate api.digiprojects.co.ke subdomain config
- ❌ digiprojects-api site config

### 5. ✅ Deployment Scripts Updated

#### deploy.sh
- Updated to single domain setup
- Removed API subdomain configuration
- Single Nginx config generation
- Updated SSL certificate request (only digiprojects.co.ke)
- Updated all references and paths

#### setup-ssl.sh
- Generate cert for digiprojects.co.ke only (+ www)
- Removed api.digiprojects.co.ke from cert request
- Updated verification tests

#### verify-deployment.sh
- Removed API subdomain DNS check
- Updated API endpoint tests
- Uses single domain verification

### 6. ✅ Nginx Configuration File

**New File:** `nginx-digiprojects.conf`
- Frontend root: `/var/www/digiprojects/digiprojects-frontend/dist`
- API location: `/api/` proxies to `/var/www/digiprojects/digiprojects-backend/public`
- PHP-FPM integration for API requests
- SPA routing for frontend
- Security headers configured
- Gzip compression enabled
- Asset caching configured (1 year for static files)

---

## 🚀 How This Works Now

### User Access Flow:

```
User Browser
    ↓
https://digiprojects.co.ke
    ↓
Nginx (digiprojects.co.ke:443)
    ├─→ Request to /
    │   └─→ Frontend SPA (index.html)
    │       └─→ [Served from frontend/dist]
    │
    ├─→ Request to /api/*
    │   └─→ Backend API
    │       └─→ [Proxied to Laravel]
    │
    └─→ Request to /assets/*
        └─→ Static files (cached 1 year)
```

### Before (Old Structure):

```
digiprojects.co.ke → Frontend
api.digiprojects.co.ke → Backend API
[Required 2 SSL certificates, 2 subdomains]
```

### After (New Structure):

```
digiprojects.co.ke → Frontend + API at /api
[Single SSL certificate, single domain]
```

---

## 📋 API Endpoints

### Before:
```
https://api.digiprojects.co.ke/api/regions
https://api.digiprojects.co.ke/api/login
https://api.digiprojects.co.ke/api/user
```

### After:
```
https://digiprojects.co.ke/api/regions
https://digiprojects.co.ke/api/login
https://digiprojects.co.ke/api/user
```

**Note:** Frontend automatically uses the new URL from `.env` file

---

## 🔧 Key Technical Details

### Nginx Location Blocks:

```nginx
# API requests route here
location /api/ {
    root /var/www/digiprojects/digiprojects-backend/public;
    try_files $uri $uri/ /index.php?$query_string;
    
    # PHP-FPM processes .php files
    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        # ... PHP configuration
    }
}

# All other requests (frontend routes)
location ~ ^/(?!api/) {
    root /var/www/digiprojects/digiprojects-frontend/dist;
    try_files $uri $uri/ /index.html;  # SPA routing
}
```

### Database Connection:

```php
// Laravel uses PDO for MySQL
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=digiprojects
DB_USERNAME=digiprojects_user
DB_PASSWORD=[secure]
```

---

## ✅ Deployment Checklist

When you deploy with the updated files:

- [ ] Run `deploy.sh` (will use new configs automatically)
- [ ] Run `setup-ssl.sh` (generates single certificate)
- [ ] Run `verify-deployment.sh` (verifies new structure)
- [ ] Frontend loads at: https://digiprojects.co.ke
- [ ] API responds at: https://digiprojects.co.ke/api/regions
- [ ] Database is MySQL (not SQLite)
- [ ] Single Nginx config file in use
- [ ] SSL certificate issued for single domain

---

## 📊 Before vs After

| Aspect | Before | After |
|--------|--------|-------|
| **Frontend Domain** | digiprojects.co.ke | digiprojects.co.ke |
| **API Domain** | api.digiprojects.co.ke | digiprojects.co.ke/api |
| **Nginx Configs** | 2 separate blocks | 1 unified block |
| **SSL Certificates** | 2 certificates | 1 certificate |
| **Database** | SQLite | MySQL/MariaDB |
| **API URL** | https://api... | https://domain/api |
| **Same-Origin** | ❌ Different domain | ✅ Same domain |
| **CORS** | Required | Simpler |
| **Cookies** | Cross-domain | Same-domain |

---

## 🔐 CORS & Cookies

With the new structure, CORS is simpler:

**Before:** Had to handle cross-origin because different domains
```
Frontend: digiprojects.co.ke
API: api.digiprojects.co.ke
→ Different origins, needed CORS headers
```

**After:** Same-origin, no cross-origin issues
```
Frontend: https://digiprojects.co.ke
API: https://digiprojects.co.ke/api
→ Same origin, cookies work automatically
```

---

## 📝 Files Modified

### Configuration Files:
1. ✅ `/digiprojects-backend/.env` - Updated APP_URL, database config
2. ✅ `/digiprojects-frontend/.env` - Updated API URL
3. ✅ `nginx-digiprojects.conf` - New unified configuration

### Deployment Scripts:
4. ✅ `deploy.sh` - Updated for new structure
5. ✅ `setup-ssl.sh` - Single domain SSL setup
6. ✅ `verify-deployment.sh` - Updated verification tests

### New Files:
7. ✅ `nginx-digiprojects.conf` - Single server block config

### Removed/Obsolete:
- ❌ `nginx-backend-api.conf` (no longer needed)
- ❌ Old API subdomain references

---

## 🚀 Ready for Deployment

All files are now configured for:
- ✅ Single domain: digiprojects.co.ke
- ✅ API at: digiprojects.co.ke/api
- ✅ MySQL/MariaDB database
- ✅ Single SSL certificate
- ✅ Unified Nginx configuration
- ✅ Production-ready setup

**Next Step:** Upload all files to your VPS and run `deploy.sh`

---

## 📞 Quick Reference

### Frontend URL:
```
https://digiprojects.co.ke
```

### API Endpoint:
```
https://digiprojects.co.ke/api
```

### Test API:
```bash
curl https://digiprojects.co.ke/api/regions
```

### Test Frontend:
```bash
curl -I https://digiprojects.co.ke
```

---

## 💡 Benefits of New Structure

1. **Simpler DNS** - Only need A record for digiprojects.co.ke
2. **Single SSL** - One certificate handles everything
3. **Better CORS** - Same-origin, no cross-domain issues
4. **Easier Deployment** - One Nginx config block
5. **Better Security** - No subdomain enumeration
6. **Production Ready** - MySQL for data persistence
7. **Scalable** - Can add caching layers later
8. **Cloudflare Compatible** - Works better with CDNs

---

## ⚡ Performance Improvements

- Fewer SSL handshakes (one domain, one cert)
- Better browser cache (same-origin)
- Cookies work across frontend & API
- Simplified Nginx routing
- Easier to configure caching

---

**Status:** ✅ Complete and Ready for Deployment

All configuration files have been updated and are ready to deploy to your VPS.

Use `deploy.sh` to automate the entire installation process!
