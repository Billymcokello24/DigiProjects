# DigiProjects Backend - Admin Management System

## Overview
The admin can now manage county officers, counties, and view aggregated county reports without the approval workflow.

## Database Structure

### Users (County Officers)
- **Table**: `users`
- **Role**: `COUNTY_OFFICER`
- **Fields**:
  - `id` - Primary key
  - `name` - Officer name
  - `email` - Officer email
  - `password` - Hashed password
  - `role` - User role (ADMIN, COUNTY_OFFICER)
  - `county_id` - Foreign key to counties table
  - `timestamps` - created_at, updated_at

### Counties
- **Table**: `counties`
- **Fields**:
  - `id` - Primary key
  - `name` - County name
  - `region_id` - Foreign key to regions table
  - `is_active` - Boolean flag
  - `timestamps` - created_at, updated_at

### Submissions
- **Table**: `submissions`
- **Fields**:
  - `id` - Primary key
  - `user_id` - Foreign key to users (county officers)
  - `project_type` - Type of project
  - `phase` - Project phase
  - `site` - Site name
  - `status` - Submission status (UP, DOWN, Stable, etc.)
  - `remarks` - Optional remarks
  - `timestamps` - created_at, updated_at

### Removed Fields
- `approval_status` - No longer needed
- `admin_feedback` - No longer needed
- `reviewed_by` - No longer needed
- `reviewed_at` - No longer needed

## API Endpoints

### County Officer Management

#### List All County Officers
```
GET /api/users
Response: Array of county officers with their county details
```

#### Create County Officer
```
POST /api/users
Payload: {
  "name": "Officer Name",
  "email": "officer@county.gov",
  "password": "password123",
  "county_id": 1
}
Response: Created user object
```

#### Update County Officer
```
PUT /api/users/{id}
Payload: (same as create, any field optional)
```

#### Delete County Officer
```
DELETE /api/users/{id}
Response: Success message
```

### County Management

#### List All Counties
```
GET /api/counties
Query params: ?region_id=1 (optional)
Response: Array of counties with region details
```

#### Create County
```
POST /api/counties
Payload: {
  "name": "County Name",
  "region_id": 1,
  "is_active": true
}
Response: Created county object
```

#### Update County
```
PUT /api/counties/{id}
Payload: (same as create, any field optional)
```

#### Delete County
```
DELETE /api/counties/{id}
Response: Success message (fails if county has officers)
```

### Submissions Management

#### Get All Submissions
```
GET /api/submissions
Response: Array of all submissions
(Officers see only their submissions, Admin sees all)
```

#### Create Submission
```
POST /api/submissions
Payload: {
  "project_type": "Infrastructure",
  "phase": "Phase 1",
  "site": "Site Name",
  "status": "UP",
  "remarks": "Optional remarks"
}
Response: Created submission object
```

#### Update Submission
```
PUT /api/submissions/{id}
Payload: (same fields as create)
```

#### Delete Submission
```
DELETE /api/submissions/{id}
```

### Reports & Statistics

#### National Statistics
```
GET /api/submissions/national-stats
Authentication: Admin only
Response: {
  "total_projects": 10,
  "total_submissions": 50,
  "total_counties": 5,
  "system_health": "Stable"
}
```

#### County Aggregated Reports
```
GET /api/submissions/county-reports
Authentication: Admin only
Response: [
  {
    "county": {
      "id": 1,
      "name": "Mombasa",
      "region": "Coast",
      "is_active": true,
      "officers_count": 2
    },
    "report": {
      "total_submissions": 10,
      "total_projects": 3,
      "statuses": {
        "UP": 7,
        "DOWN": 2,
        "Stable": 1
      },
      "submissions": [
        {
          "id": 1,
          "project_type": "Water Supply",
          "phase": "Implementation",
          "site": "Mombasa Central",
          "status": "UP",
          "remarks": null,
          "officer_name": "John Doe",
          "created_at": "2026-01-14T...",
          "updated_at": "2026-01-14T..."
        }
      ]
    }
  },
  ...
]
```

#### Officer Personal Statistics
```
GET /api/submissions/stats
Authentication: Required (all roles)
Response: {
  "total_projects": 3,
  "monthly_submissions": 2,
  "action_required": 1
}
```

## Data Flow

1. **Admin Creates County**
   - POST `/api/counties` with name, region_id, is_active

2. **Admin Adds County Officers**
   - POST `/api/users` with name, email, password, county_id
   - Officer is linked to specific county

3. **County Officer Submits Data**
   - POST `/api/submissions` with project details
   - Submission is automatically linked to officer's county

4. **Admin Views Aggregated Reports**
   - GET `/api/submissions/county-reports`
   - Returns all counties with their aggregated submissions
   - Format: County → Report (with all submissions from all officers in that county)

5. **No Approval Workflow**
   - Submissions are tracked directly without approval status
   - Admin can view all data in real-time

## Model Relationships

```
County
  ├─ hasMany Users (county officers)
  ├─ hasManyThrough Submissions (via users)
  └─ belongsTo Region

User (County Officer)
  ├─ belongsTo County
  ├─ hasMany Submissions
  └─ belongsTo User (if reviewer - removed)

Submission
  ├─ belongsTo User (officer who submitted)
  └─ belongs through User to County
```

## Authentication

- All endpoints except `/api/login` require Sanctum token
- Admin-only endpoints require `role = 'ADMIN'`
- Officers see only their own submissions unless they're admin

## Server
Running on: `http://127.0.0.1:8001`
