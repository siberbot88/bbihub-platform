# BBIHUB Postman Collection - User Guide

**Collection**: BBIHUB Owner API  
**Version**: 1.0.0  
**Last Updated**: 2025-12-23

---

## 📦 What's Included

This package contains:

1. **`BBIHUB_Owner.postman_collection.json`** - Main API collection
2. **`BBIHUB_Local.postman_environment.json`** - Local environment variables
3. **`README.md`** - This guide

---

## 🚀 Quick Start

### Step 1: Import Collection

1. Open Postman
2. Click **Import** button (top left)
3. Select **`BBIHUB_Owner.postman_collection.json`**
4. Click **Import**

### Step 2: Import Environment

1. Click **Environments** tab (left sidebar)
2. Click **Import**
3. Select **`BBIHUB_Local.postman_environment.json`**
4. Click **Import**

### Step 3: Activate Environment

1. Select **"BBIHUB Local Environment"** from dropdown (top right)
2. Verify `base_url` is set to `http://localhost:8000`

### Step 4: Run Your First Request

1. Expand **"1. Authentication"** folder
2. Click **"Login Owner"**
3. Update email/password if needed
4. Click **Send**
5. ✅ Token automatically saved to environment!

---

## 📋 Collection Structure

```
BBIHUB Owner API Collection
├── 1. Authentication
│   ├── Register Owner
│   ├── Login Owner
│   ├── Get Current User
│   └── Logout
├── 2. Owner Dashboard
│   ├── Get Dashboard Statistics
│   └── Get Dashboard Stats (Filtered)
├── 3. Staff Management
│   ├── List Staff Members
│   ├── Get Staff Performance
│   ├── Add Staff Member
│   └── Update Staff Status
├── 4. Reports & Analytics
│   ├── Get Workshop Analytics
│   └── Get Monthly Report
├── 5. Service Management
│   ├── List Services
│   ├── Get Service Detail
│   └── Assign Mechanic to Service
└── 6. Notifications
    ├── Get Notifications
    └── Mark Notification as Read
```

---

## 🔐 Authentication Flow

### Automatic Token Management

The collection automatically handles authentication tokens:

1. **Login** → Token saved to `{{access_token}}`
2. **All Requests** → Use saved token via Bearer Auth
3. **Logout** → Token cleared from environment

### Manual Token Setup

If needed, you can manually set the token:

1. Send **Login** request
2. Copy token from response
3. Go to **Environments** → **BBIHUB Local Environment**
4. Paste token into `access_token` variable
5. Save environment

---

## 🧪 Running Tests

### Run Single Request

1. Select any request
2. Click **Send**
3. View response and test results in **Test Results** tab

### Run Entire Collection

1. Click **...** (three dots) next to collection name
2. Select **Run collection**
3. Configure run settings
4. Click **Run BBIHUB Owner API**
5. View test summary

### Run Folder

1. Hover over folder (e.g., "1. Authentication")
2. Click **▶** (Run) button
3. All requests in folder execute sequentially

---

## 📊 Test Scripts

All requests include automated test scripts that validate:

- ✅ HTTP status codes
- ✅ Response structure
- ✅ Required fields present
- ✅ Data types correct
- ✅ Response time acceptable

### Example Test Output

```
PASS: Status code is 200
PASS: Response has user and token
PASS: Response time is acceptable (245ms)
```

---

## 🔧 Environment Variables

### Pre-configured Variables

| Variable | Description | Example Value |
|----------|-------------|---------------|
| `base_url` | API base URL | `http://localhost:8000` |
| `access_token` | Auth bearer token | `1|abc123...` (auto-filled) |
| `user_id` | Logged in user ID | `019b36...` (auto-filled) |
| `staff_id` | Created staff ID | `019b42...` (auto-filled) |
| `service_id` | Service ID for tests | `019b43...` (manual) |
| `notification_id` | Notification ID | `019b44...` (manual) |

### How to Update Variables

**Method 1: Via UI**
1. Click **Environments** tab
2. Select **BBIHUB Local Environment**
3. Edit values
4. Click **Save**

**Method 2: Via Request**
Variables are auto-updated by test scripts after successful requests.

---

## 🎯 Common Workflows

### Workflow 1: Complete Authentication Test

```
1. Register Owner (if new account)
2. Login Owner (token auto-saved)
3. Get Current User (verify login)
4. Logout (token cleared)
```

**Expected**: All ✅ Pass

---

### Workflow 2: Dashboard & Analytics

```
1. Login Owner
2. Get Dashboard Statistics
3. Get Dashboard Stats (Filtered)
```

**Expected**: 
- Dashboard loads < 1000ms
- All metrics present
- Charts data accurate

---

### Workflow 3: Staff Management

```
1. Login Owner
2. List Staff Members
3. Add Staff Member (ID auto-saved to {{staff_id}})
4. Get Staff Performance
5. Update Staff Status (using {{staff_id}})
```

**Expected**:
- Staff list returns array
- New staff created
- Performance metrics present
- Status updated successfully

---

### Workflow 4: Service Assignment

```
1. Login Owner
2. List Services
3. Get Service Detail (set {{service_id}} manually)
4. Assign Mechanic to Service (uses {{staff_id}})
```

**Expected**:
- Services listed
- Detail shows full info
- Mechanic assigned successfully

---

## 🐛 Troubleshooting

### Issue: "401 Unauthorized" on Protected Routes

**Solution**:
1. Verify environment is selected (top right dropdown)
2. Run **Login Owner** request first
3. Check `{{access_token}}` is populated in environment
4. Ensure backend server is running

---

### Issue: "404 Not Found"

**Solution**:
1. Check `base_url` in environment: `http://localhost:8000`
2. Verify Laravel backend is running: `php artisan serve`
3. Check API route exists in `routes/api.php`

---

### Issue: "422 Validation Error"

**Solution**:
1. Review request body in **Body** tab
2. Check required fields are present
3. Verify data types match API expectations
4. Check backend validation rules

---

### Issue: "Network Error"

**Solution**:
1. Verify backend server is running
2. Check firewall isn't blocking localhost:8000
3. Try accessing `http://localhost:8000/api/v1/auth/me` in browser
4. Restart Laravel server

---

### Issue: Tests Failing

**Solution**:
1. Check **Test Results** tab for specific failure
2. Verify response structure matches test expectations
3. Update test scripts if API changed
4. Check backend returns correct HTTP status codes

---

## 📝 Adding New Requests

### Step 1: Create Request

1. Right-click on folder (e.g., "5. Service Management")
2. Select **Add Request**
3. Name it (e.g., "Update Service Status")

### Step 2: Configure Request

1. Set method (GET, POST, PUT, DELETE)
2. Enter URL: `{{base_url}}/api/v1/services/{{service_id}}`
3. Add headers if needed
4. Add body (for POST/PUT)

### Step 3: Add Test Scripts

```javascript
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

pm.test("Response has data", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('data');
});
```

### Step 4: Save & Test

1. Click **Save**
2. Click **Send**
3. Verify tests pass

---

## 🔄 Syncing with Team

### Export Collection

1. Right-click collection
2. Select **Export**
3. Choose **Collection v2.1**
4. Save JSON file
5. Share with team

### Import Updates

1. Click **Import**
2. Select updated collection file
3. Choose **Replace** when prompted
4. Verify environment variables

---

## 📊 Generating Reports

### Step 1: Run Collection

1. Click **Runner** (top left)
2. Drag **BBIHUB Owner API** collection
3. Select **BBIHUB Local Environment**
4. Click **Run**

### Step 2: View Results

- Summary shows pass/fail count
- Click on request to see details
- View response times

### Step 3: Export Report

1. Click **Export Results**
2. Choose format (JSON recommended)
3. Save file
4. Share with team or attach to bug reports

---

## 🚀 Advanced Features

### Pre-request Scripts

Add logic to run before request:

```javascript
// Set dynamic timestamp
pm.environment.set("current_time", new Date().toISOString());

// Generate random email
pm.environment.set("random_email", `user${Math.random()}@example.com`);
```

### Chain Requests

Use variables from previous responses:

```javascript
// In "Add Staff" test script:
if (pm.response.code === 201) {
    var jsonData = pm.response.json();
    pm.environment.set("staff_id", jsonData.data.id);
}

// Next request uses {{staff_id}} automatically!
```

### Collections Runner

Automate testing sequences:

1. Open Runner
2. Select collection/folder
3. Set iterations (e.g., 10 times)
4. Add delays between requests
5. Run automated test suite

---

## 📚 Resources

- **Postman Docs**: https://learning.postman.com/
- **API Documentation**: `backend/documentation/API.md`(if exists)
- **Backend Repository**: `e:/BBIHUB/backend`
- **Mobile Repository**: `e:/BBIHUB/mobile`

---

## ✅ Pre-flight Checklist

Before running tests:

- [ ] Backend server is running (`php artisan serve`)
- [ ] Database is seeded with test data
- [ ] Environment is selected in Postman
- [ ] `base_url` points to correct server
- [ ] Owner account exists for login

---

## 🎉 Success Criteria

Collection is working correctly when:

- ✅ All authentication flows pass
- ✅ Dashboard loads within 1 second
- ✅ Staff management CRUD operations work
- ✅ Reports generate successfully
- ✅ Service assignment completes
- ✅ All test scripts pass (100% pass rate)

---

**Happy Testing!** 🚀

For issues or questions, check the troubleshooting section or review test results in Postman console.

---

**Last Updated**: 2025-12-23  
**Maintained By**: BBIHUB Development Team  
**Collection Version**: 1.0.0
