# DigiProjects Frontend - Admin Management System

## Overview
The frontend has been completely redesigned to support the new admin management system for county officers, counties, and aggregated reports without the approval workflow.

## New Pages

### 1. County Officers Management (`/admin/officers`)
**File**: `src/views/admin/OfficersView.vue`

Features:
- View all county officers
- Add new county officer with:
  - Name
  - Email
  - Password
  - County assignment
- Edit officer details
- Delete officers (except ADMIN role)
- Real-time form validation
- Success/error notifications

**API Endpoints Used**:
- `GET /api/users` - List officers
- `POST /api/users` - Create officer
- `PUT /api/users/{id}` - Update officer
- `DELETE /api/users/{id}` - Delete officer

### 2. County Management (`/admin/counties`)
**File**: `src/views/admin/CountyOfficersView.vue`

Features:
- View all counties with their regions
- Add new county with:
  - County name
  - Region assignment
  - Active/Inactive status
- Edit county details
- Delete counties (with validation)
- Active/Inactive status tracking

**API Endpoints Used**:
- `GET /api/counties` - List counties
- `POST /api/counties` - Create county
- `PUT /api/counties/{id}` - Update county
- `DELETE /api/counties/{id}` - Delete county
- `GET /api/regions` - Get regions list

### 3. County Reports (`/admin/county-reports`)
**File**: `src/views/admin/CountyReportsView.vue`

Features:
- View all counties with their aggregated reports
- Expandable county sections showing:
  - County name, region, officers count
  - Total submissions and projects
  - Status summary (UP, DOWN, Stable, etc.)
  - Detailed submissions table with:
    - Project type, phase, site
    - Status with color coding
    - Officer name
    - Submission date/time
  - Remarks section for special notes
- Status color coding:
  - Green (success): UP
  - Red (danger): DOWN
  - Blue (info): Stable
  - Yellow (warning): Maintenance
- Responsive design
- Refresh capability

**API Endpoints Used**:
- `GET /api/submissions/county-reports` - Get aggregated reports

## Updated Navigation

### Admin Sidebar Menu
**File**: `src/components/layout/DashboardLayout.vue`

New structure:
```
📊 National Overview (Dashboard)
├─ Management
│  ├─ 👮 County Officers
│  ├─ 🏛️ Counties
├─ Reports
│  └─ 📋 County Reports
├─ System
│  ├─ 🏗️ System Config
│  ├─ 📣 Communication
│  └─ 🛡️ Audit Logs
└─ ⚙️ Administration
```

**Removed**:
- ⚖️ Approval Workbench (no longer needed)

## Updated Routes

**File**: `src/router/index.js`

New routes:
```javascript
/admin/officers         // County Officers Management
/admin/counties         // County Management
/admin/county-reports   // County Reports View
```

Removed:
```javascript
/admin/workbench        // Approval Workbench (removed)
/admin/users            // User Management (replaced with officers)
/admin/reports          // National Reports (functionality moved to county-reports)
```

## Updated Dashboard

**File**: `src/views/admin/DashboardView.vue`

Changes:
- Removed "Pending Review" stat card
- Updated button to link to County Reports instead of General Reports
- Changed activity list to show submission status instead of approval_status
- Updated activity header button to link to County Reports

## Component Structure

### Reusable Components Used

1. **BaseCard.vue** - Card container for content sections
2. **BaseButton.vue** - Consistent button styling
3. **BaseInput.vue** - Consistent input fields
4. **BaseTable.vue** - Data table display
5. **BaseModal.vue** - Modal dialogs for add/edit forms
6. **StatusBadge.vue** - Status indicators with color coding
7. **StatCard.vue** - Statistics display cards

## Form Validations

### County Officer Form
- Name: Required, max 255 characters
- Email: Required, valid email format, unique
- Password: Required for new (min 6 chars), optional for edit
- County: Required, must exist in database

### County Form
- Name: Required, max 255 characters, unique
- Region: Required, must exist in database
- Active: Boolean flag

## Data Flow

1. **Add County Officer**
   - Admin fills form → Validates → POST to `/api/users`
   - County officer linked to specific county
   - Officer can now submit reports

2. **Add County**
   - Admin fills form → Validates → POST to `/api/counties`
   - County ready to receive officers

3. **View County Reports**
   - Admin views `/admin/county-reports`
   - Fetches aggregated data → GET `/api/submissions/county-reports`
   - Displays all counties with their submissions
   - Can expand/collapse each county

## Styling

- **Color Scheme**:
  - Primary: #3b82f6 (Blue)
  - Success: #10b981 (Green)
  - Danger: #ef4444 (Red)
  - Warning: #f59e0b (Yellow)
  - Info: #06b6d4 (Cyan)

- **Status Colors**:
  - UP: Green (active, working)
  - DOWN: Red (not working)
  - Stable: Blue (stable operation)
  - Maintenance: Yellow (under maintenance)

- **Responsive Design**:
  - Mobile-first approach
  - Sidebar collapses on mobile
  - Tables become horizontally scrollable
  - Forms stack vertically

## Authentication & Authorization

- All routes require `auth:sanctum` token
- Admin-only pages check for `role === 'ADMIN'`
- Officers see only their own data
- Failed auth redirects to login

## Error Handling

- Network errors show user-friendly messages
- Form validation errors highlighted inline
- API errors displayed in alert boxes
- Try-catch blocks with console logging for debugging

## API Integration

**File**: `src/api/axios.js`

- All requests include authentication token
- Default base URL: `http://localhost:8001/api`
- Handles 403 Unauthorized errors
- Automatic request/response interceptors

## Usage Examples

### Add County Officer
```
1. Navigate to /admin/officers
2. Click "Add Officer" button
3. Fill in:
   - Name: "John Doe"
   - Email: "john@county.go.ke"
   - Password: "secure_password"
   - County: "Mombasa"
4. Click "Add Officer"
5. Officer appears in list immediately
```

### View County Reports
```
1. Navigate to /admin/county-reports
2. See all counties listed with summary
3. Click on county to expand details
4. View all submissions for that county
5. See officer names and submission dates
6. Scroll remarks section for special notes
```

## Future Enhancements

- Export reports to PDF/Excel
- Advanced filtering by status, date range
- Bulk actions for multiple submissions
- Email notifications for new submissions
- Dashboard charts and analytics
- Submission timeline view
- Officer performance metrics
