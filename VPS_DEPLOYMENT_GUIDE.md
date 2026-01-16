# VPS Deployment Guide for DigiProjects

## Prerequisites
- VPS with PHP 8.2+, Node.js 20+, and composer installed
- MySQL/PostgreSQL database (or SQLite)
- Nginx or Apache web server

---

## Backend Setup (Laravel API)

### 1. Configure Backend .env for Production

Edit `/digiprojects-backend/.env`:

```dotenv
# Change these for production
APP_ENV=production
APP_DEBUG=false
APP_URL=https://your-vps-domain.com  # Change to your VPS domain

# Database Configuration (if using MySQL)
DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=digiprojects
DB_USERNAME=digiprojects_user
DB_PASSWORD=strong_password_here

# Session and CORS
SESSION_DRIVER=database
SESSION_DOMAIN=.your-vps-domain.com  # Allow cookie sharing across domains
```

### 2. Database Setup

```bash
# Create database
mysql -u root -p -e "CREATE DATABASE digiprojects CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -p -e "CREATE USER 'digiprojects_user'@'localhost' IDENTIFIED BY 'strong_password_here';"
mysql -u root -p -e "GRANT ALL PRIVILEGES ON digiprojects.* TO 'digiprojects_user'@'localhost';"
mysql -u root -p -e "FLUSH PRIVILEGES;"
```

### 3. Install Backend Dependencies

```bash
cd digiprojects-backend
composer install --no-dev --optimize-autoloader
php artisan migrate --force  # Run migrations on production
php artisan db:seed  # Seed initial data if needed
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### 4. Set Backend Permissions

```bash
chmod -R 775 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
```

### 5. Configure Nginx for Backend

Create `/etc/nginx/sites-available/digiprojects-api`:

```nginx
server {
    listen 80;
    server_name api.your-vps-domain.com;

    root /path/to/digiprojects-backend/public;
    index index.php;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
```

Enable it:
```bash
ln -s /etc/nginx/sites-available/digiprojects-api /etc/nginx/sites-enabled/
nginx -t && systemctl restart nginx
```

---

## Frontend Setup (Vue.js)

### 1. Create Frontend .env File

Create `/digiprojects-frontend/.env`:

```env
VITE_API_BASE_URL=https://api.your-vps-domain.com/api
```

**For Local Development:**
```env
VITE_API_BASE_URL=http://localhost:8000/api
```

### 2. Build Frontend

```bash
cd digiprojects-frontend
npm install
npm run build
```

### 3. Deploy Built Files

```bash
# Copy the dist folder to your VPS
scp -r dist/ user@your-vps-ip:/path/to/digiprojects-frontend/
```

### 4. Configure Nginx for Frontend

Create `/etc/nginx/sites-available/digiprojects-web`:

```nginx
server {
    listen 80;
    server_name your-vps-domain.com www.your-vps-domain.com;

    root /path/to/digiprojects-frontend/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

Enable it:
```bash
ln -s /etc/nginx/sites-available/digiprojects-web /etc/nginx/sites-enabled/
nginx -t && systemctl restart nginx
```

---

## CORS Configuration (Important!)

Edit `digiprojects-backend/config/cors.php`:

```php
return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => [
        'https://your-vps-domain.com',
        'https://www.your-vps-domain.com',
        // Add more origins as needed
    ],
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => true,  // Important for session cookies
];
```

---

## HTTPS Setup (SSL Certificate)

Use Let's Encrypt with Certbot:

```bash
sudo apt-get install certbot python3-certbot-nginx -y
sudo certbot certonly --nginx -d your-vps-domain.com -d www.your-vps-domain.com -d api.your-vps-domain.com
```

Update Nginx configs to include SSL certificates.

---

## Verification Checklist

- [ ] Backend .env configured with correct APP_URL and database credentials
- [ ] Frontend .env configured with correct VITE_API_BASE_URL
- [ ] Database migrations have run successfully
- [ ] Backend API accessible at `https://api.your-vps-domain.com`
- [ ] Frontend accessible at `https://your-vps-domain.com`
- [ ] CORS configured to allow frontend domain
- [ ] SSL certificates installed and active
- [ ] Test API endpoint: `curl https://api.your-vps-domain.com/api/regions`

---

## Testing Connection

### 1. Test Backend API Directly
```bash
curl -X GET https://api.your-vps-domain.com/api/regions
```

### 2. Test from Frontend Console (in browser dev tools)
```javascript
fetch('https://api.your-vps-domain.com/api/regions')
  .then(r => r.json())
  .then(d => console.log(d))
```

### 3. Check Frontend Network Tab
- Open browser DevTools (F12)
- Go to Network tab
- Make an API call from the app
- Verify the request goes to the correct backend URL

---

## Troubleshooting

**Frontend showing 404 or cannot reach API:**
- Check VITE_API_BASE_URL in frontend .env matches backend domain
- Verify backend is running and accessible
- Check CORS configuration
- Check browser console for errors

**CORS errors:**
- Ensure frontend domain is in `config/cors.php` allowed_origins
- Verify `supports_credentials: true` is set
- Clear browser cache and cookies

**Database connection errors:**
- Verify database credentials in backend .env
- Check if database exists: `mysql -u root -p -e "SHOW DATABASES;"`
- Run migrations: `php artisan migrate`

