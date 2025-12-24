# Manual Black Box Testing Guide - Owner POV

**Application**: BBIHUB Mobile App  
**Test Perspective**: Owner (Workshop Owner)  
**Platform**: Android & iOS  
**Version**: 1.0.0  
**Last Updated**: 2025-12-23

---

## 📋 Test Overview

This document contains **comprehensive black box test cases** for all Owner features in the BBIHUB mobile application.

### Test Coverage

| Module | Test Cases | Priority |
|--------|------------|----------|
| Authentication | 10 | HIGH |
| Onboarding | 5 | HIGH |
| Dashboard | 15 | HIGH |
| Staff Management | 20 | HIGH |
| Reports & Analytics | 15 | MEDIUM |
| Service Management | 20 | MEDIUM |
| Profile & Settings | 10 | MEDIUM |
| Notifications | 10 | LOW |
| **Total** | **105** | |

---

## 🔐 Module 1: Authentication & Onboarding

### TC-001: Register as Workshop Owner

**Priority**: HIGH  
**Prerequisite**: None

**Test Steps**:
1. Open BBIHUB app
2. Tap "Daftar" (Register) button
3. Fill in registration form:
   - Name: "Workshop Makmur"
   - Email: "owner.test@example.com"
   - Phone: "081234567890"
   - Password: "TestPassword123!@#"
   - Confirm Password: "TestPassword123!@#"
4. Tap "Daftar" button

**Expected Result**:
- ✅ Registration successful
- ✅ Redirect to dashboard or workshop setup
- ✅ User logged in automatically
- ✅ Success message displayed

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-002: Login with Valid Credentials

**Priority**: HIGH  
**Prerequisite**: Account already registered

**Test Steps**:
1. Open BBIHUB app
2. Tap "Masuk" (Login) button
3. Enter email: "owner@example.com"
4. Enter password: "password"
5. Tap "Masuk" button

**Expected Result**:
- ✅ Login successful
- ✅ Redirect to Owner Dashboard
- ✅ User data loaded (name, workshop info)
- ✅ Bottom navigation visible

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-003: Login with Invalid Password

**Priority**: HIGH  

**Test Steps**:
1. Open BBIHUB app
2. Enter valid email
3. Enter wrong password: "wrongpassword"
4. Tap "Masuk"

**Expected Result**:
- ✅ Error message: "Email atau password salah"
- ✅ No redirect, stay on login screen
- ✅ Password field cleared

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-004: Forgot Password Flow

**Priority**: MEDIUM

**Test Steps**:
1. On login screen, tap "Lupa Password?"
2. Enter email: "owner@example.com"
3. Tap "Kirim Link Reset"
4. Check email inbox
5. Click reset link
6. Enter new password
7. Confirm new password
8. Submit

**Expected Result**:
- ✅ Email sent confirmation
- ✅ Reset link received in email
- ✅ Password reset successful
- ✅ Can login with new password

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-005: Logout

**Priority**: HIGH

**Test Steps**:
1. Login as owner
2. Navigate to Profile tab
3. Scroll down
4. Tap "Keluar" (Logout) button
5. Confirm logout on dialog

**Expected Result**:
- ✅ Confirmation dialog appears
- ✅ After confirm, redirect to login screen
- ✅ Session cleared
- ✅ Cannot access protected screens

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

## 🏠 Module 2: Owner Dashboard

### TC-010: View Dashboard Statistics

**Priority**: HIGH  
**Prerequisite**: Logged in as owner

**Test Steps**:
1. Login as owner
2. Land on Home/Dashboard tab
3. Observe all statistics cards

**Expected Result**:
- ✅ Dashboard loads within 2 seconds
- ✅ Shows total services today
- ✅ Shows services in progress
- ✅ Shows completed services
- ✅ Shows revenue (if implemented)
- ✅ All numbers are correct

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-011: View Service Trend Chart

**Priority**: HIGH

**Test Steps**:
1. On dashboard, scroll to "Trend Layanan" section
2. Observe weekly chart
3. Tap on "Monthly" tab

**Expected Result**:
- ✅ Weekly chart shows last 7 days data
- ✅ Monthly chart shows last 6 months
- ✅ Charts are interactive (can tap on bars/lines)
- ✅ Data is accurate

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-012: View Mechanic Performance

**Priority**: HIGH

**Test Steps**:
1. On dashboard, scroll to "Performa Mekanik" section
2. View top mechanics list
3. Tap on a mechanic card

**Expected Result**:
- ✅ Shows top 5 mechanics
- ✅ Each shows: name, completed jobs, active jobs
- ✅ Sorted by completed jobs (highest first)
- ✅ Tap opens mechanic detail (if implemented)

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-013: Pull to Refresh Dashboard

**Priority**: MEDIUM

**Test Steps**:
1. On dashboard
2. Pull down from top to refresh
3. Wait for refresh to complete

**Expected Result**:
- ✅ Refresh indicator shows
- ✅ Data reloads from server
- ✅ Updated data displayed
- ✅ Refresh completes within 3 seconds

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-014: Dashboard with No Data

**Priority**: MEDIUM  
**Prerequisite**: New workshop with no services

**Test Steps**:
1. Login with new workshop account
2. View dashboard

**Expected Result**:
- ✅ Empty state messages shown
- ✅ "Belum ada data" or similar message
- ✅ Helpful instructions displayed
- ✅ No errors or crashes

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-015: Dashboard Performance

**Priority**: MEDIUM

**Test Steps**:
1. Login as owner with lots of data (100+ services)
2. Navigate to dashboard
3. Scroll through all sections

**Expected Result**:
- ✅ Loads within 3 seconds
- ✅ Smooth scrolling, no lag
- ✅ All data displays correctly
- ✅ No memory issues

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

## 👥 Module 3: Staff Management

### TC-020: View Staff List

**Priority**: HIGH  
**Prerequisite**: Workshop has staff members

**Test Steps**:
1. Navigate to "Karyawan" or Staff tab
2. View list of staff members

**Expected Result**:
- ✅ All staff members displayed
- ✅ Shows: name, role, status (active/inactive)
- ✅ List is scrollable
- ✅ Loads within 2 seconds

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-021: Search Staff by Name

**Priority**: HIGH

**Test Steps**:
1. On staff list screen
2. Tap search bar
3. Type mechanic name: "Budi"
4. Observe filtered results

**Expected Result**:
- ✅ Search filters in real-time
- ✅ Shows only matching staff
- ✅ Case-insensitive search
- ✅ Shows "Tidak ditemukan" if no match

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-022: Filter Staff by Role

**Priority**: MEDIUM

**Test Steps**:
1. On staff list
2. Tap filter icon
3. Select "Mekanik" role filter
4. Apply filter

**Expected Result**:
- ✅ Filter dialog opens
- ✅ Shows role options (Mekanik, Admin, etc)
- ✅ List updates to show only mechanics
- ✅ Filter badge shows on filter icon

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-023: View Staff Performance Details

**Priority**: HIGH

**Test Steps**:
1. On staff list
2. Tap on a staff member card
3. View detail page

**Expected Result**:
- ✅ Shows staff profile info
- ✅ Shows performance stats:
  - Total completed jobs
  - Average rating
  - Active jobs
  - Join date
- ✅ Shows recent activities
- ✅ Has edit/deactivate buttons

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-024: Add New Staff Member

**Priority**: HIGH

**Test Steps**:
1. On staff list, tap "+" or "Tambah Karyawan"
2. Fill form:
   - Email: "newmechanic@example.com"
   - Role: "Mekanik"
3. Tap "Simpan"

**Expected Result**:
- ✅ Form validation works
- ✅ Staff added successfully
- ✅ Success message shown
- ✅ New staff appears in list
- ✅ Invitation email sent to user

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-025: Add Staff with Existing Email

**Priority**: MEDIUM

**Test Steps**:
1. Try to add staff with email already in system
2. Submit form

**Expected Result**:
- ✅ Error message: "Email sudah terdaftar"
- ✅ Form not submitted
- ✅ Email field highlighted in red

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-026: Edit Staff Details

**Priority**: HIGH

**Test Steps**:
1. Open staff detail page
2. Tap "Edit" button
3. Change role from "Mekanik" to "Admin"
4. Save changes

**Expected Result**:
- ✅ Edit form opens with current data
- ✅ Changes saved successfully
- ✅ Updated data shown immediately
- ✅ Success message displayed

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-027: Deactivate Staff Member

**Priority**: HIGH

**Test Steps**:
1. Open staff detail
2. Tap "Nonaktifkan" button
3. Confirm on dialog

**Expected Result**:
- ✅ Confirmation dialog appears
- ✅ Staff status changed to "inactive"
- ✅ Staff still in list but marked inactive
- ✅ Cannot assign services to inactive staff

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-028: Reactivate Staff Member

**Priority**: MEDIUM

**Test Steps**:
1. View inactive staff
2. Tap on inactive staff
3. Tap "Aktifkan Kembali"

**Expected Result**:
- ✅ Status changed to active
- ✅ Can assign services again
- ✅ Success message shown

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-029: Delete Staff Member

**Priority**: MEDIUM

**Test Steps**:
1. Open staff detail
2. Tap "Hapus" button (if available)
3. Confirm deletion

**Expected Result**:
- ✅ Warning dialog appears
- ✅ Staff deleted from system
- ✅ Removed from list
- ✅ Cannot undo (or has undo option)

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-030: View Staff Attendance (if implemented)

**Priority**: LOW

**Test Steps**:
1. Open staff detail
2. Navigate to "Kehadiran" tab
3. View attendance history

**Expected Result**:
- ✅ Shows attendance calendar
- ✅ Shows present/absent days
- ✅ Can filter by month
- ✅ Accurate data

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

## 📊 Module 4: Reports & Analytics

### TC-040: Generate Monthly Report

**Priority**: HIGH  
**Prerequisite**: Workshop has transaction data

**Test Steps**:
1. Navigate to "Laporan" (Reports) tab
2. Select "Laporan Bulanan"
3. Choose month: "Desember 2025"
4. Tap "Lihat Laporan"

**Expected Result**:
- ✅ Report loads within 3 seconds
- ✅ Shows summary:
  - Total services
  - Total revenue
  - Average rating
- ✅ Shows breakdown by category
- ✅ Charts display correctly

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-041: View Revenue Analytics

**Priority**: HIGH

**Test Steps**:
1. On reports screen
2. Tap "Analisa Pendapatan"
3. View revenue charts

**Expected Result**:
- ✅ Shows monthly revenue trend (last 6 months)
- ✅ Shows revenue breakdown by service type
- ✅ Shows comparison to previous period
- ✅ Data is accurate

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-042: Export Report as PDF

**Priority**: MEDIUM

**Test Steps**:
1. View any report
2. Tap "Export PDF" button
3. Choose save location

**Expected Result**:
- ✅ PDF generated successfully
- ✅ File saved to downloads
- ✅ PDF contains all report data
- ✅ Formatted professionally

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-043: Share Report

**Priority**: MEDIUM

**Test Steps**:
1. View report
2. Tap "Bagikan" (Share) button
3. Choose WhatsApp
4. Send to contact

**Expected Result**:
- ✅ Share sheet opens
- ✅ Report formatted for sharing
- ✅ Can share via email, WhatsApp, etc
- ✅ Recipient receives readable format

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-044: Filter Report by Date Range

**Priority**: HIGH

**Test Steps**:
1. On reports screen
2. Tap date filter
3. Select "Custom Range"
4. Choose: 1 Oct 2025 - 31 Oct 2025
5. Apply filter

**Expected Result**:
- ✅ Date picker opens
- ✅ Can select custom range
- ✅ Report updates with filtered data
- ✅ Shows correct data for selected period

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-045: View Service Category Breakdown

**Priority**: MEDIUM

**Test Steps**:
1. View monthly report
2. Scroll to "Kategori Layanan" section
3. View pie chart

**Expected Result**:
- ✅ Pie chart shows service categories
- ✅ Shows percentage for each category
- ✅ Shows count for each category
- ✅ Can tap to see details

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

## 🔧 Module 5: Service Management

### TC-050: View All Services

**Priority**: HIGH

**Test Steps**:
1. Navigate to "Layanan" (Services) tab
2. View service list

**Expected Result**:
- ✅ All services displayed
- ✅ Shows: customer name, vehicle, status, date
- ✅ Paginated (load more on scroll)
- ✅ Loads quickly

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-051: Filter Services by Status

**Priority**: HIGH

**Test Steps**:
1. On services list
2. Tap filter
3. Select "In Progress" status
4. Apply

**Expected Result**:
- ✅ Shows only in-progress services
- ✅ Filter badge visible
- ✅ Can clear filter
- ✅ Count updates

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-052: Search Service by Code

**Priority**: HIGH

**Test Steps**:
1. On services list
2. Tap search
3. Enter service code: "SRV-001"

**Expected Result**:
- ✅ Finds matching service
- ✅ Shows service details
- ✅ Search is fast
- ✅ Shows "Not found" if no match

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-053: View Service Detail

**Priority**: HIGH

**Test Steps**:
1. Tap on a service card
2. View detail page

**Expected Result**:
- ✅ Shows all service info:
  - Customer details
  - Vehicle details
  - Service type
  - Mechanic assigned
  - Status
  - Timeline
  - Items/parts used
- ✅ Shows transaction details
- ✅ All data accurate

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-054: Assign Mechanic to Service

**Priority**: HIGH

**Test Steps**:
1. Open service detail
2. Tap "Tugaskan Mekanik"
3. Select mechanic from list
4. Confirm

**Expected Result**:
- ✅ Mechanic list shows active mechanics
- ✅ Shows current workload for each
- ✅ Assignment saved
- ✅ Notification sent to mechanic
- ✅ Service status updated

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-055: Reassign Mechanic

**Priority**: MEDIUM

**Test Steps**:
1. Open service with assigned mechanic
2. Tap "Ganti Mekanik"
3. Select different mechanic
4. Confirm with reason

**Expected Result**:
- ✅ Confirmation dialog shown
- ✅ Asks for reason
- ✅ Reassignment successful
- ✅ Both mechanics notified

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-056: Update Service Status

**Priority**: HIGH

**Test Steps**:
1. Open service in "pending" status
2. Tap "Ubah Status"
3. Select "In Progress"
4. Save

**Expected Result**:
- ✅ Status dropdown shows valid transitions
- ✅ Status updated successfully
- ✅ Timeline updated
- ✅ Customer notified

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-057: Mark Service as Completed

**Priority**: HIGH

**Test Steps**:
1. Open in-progress service
2. Tap "Selesaikan Layanan"
3. Fill completion form (if any)
4. Confirm

**Expected Result**:
- ✅ Completion confirmation shown
- ✅ Status changed to "completed"
- ✅ Completion timestamp recorded
- ✅ Customer can now provide feedback

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-058: View Service notes/Comments

**Priority**: MEDIUM

**Test Steps**:
1. Open service detail
2. Scroll to "Catatan" section
3. View all notes

**Expected Result**:
- ✅ Shows all notes chronologically
- ✅ Shows who added each note
- ✅ Shows timestamp
- ✅ Can add new note

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-059: Add Note to Service

**Priority**: MEDIUM

**Test Steps**:
1. On service detail
2. Tap "Tambah Catatan"
3. Type: "Ganti oli dan filter"
4. Save

**Expected Result**:
- ✅ Note added successfully
- ✅ Appears in timeline
- ✅ Visible to assigned mechanic
- ✅ Timestamp accurate

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

## 👤 Module 6: Profile & Settings

### TC-070: View Owner Profile

**Priority**: MEDIUM

**Test Steps**:
1. Navigate to Profile tab
2. View profile information

**Expected Result**:
- ✅ Shows owner name
- ✅ Shows email
- ✅ Shows phone
- ✅ Shows workshop info
- ✅ Profile picture displayed (if uploaded)

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-071: Edit Profile Information

**Priority**: MEDIUM

**Test Steps**:
1. On profile, tap "Edit Profil"
2. Change name to "Workshop Makmur Jaya"
3. Change phone to "081234567899"
4. Save

**Expected Result**:
- ✅ Edit form opens
- ✅ Current data pre-filled
- ✅ Changes saved successfully
- ✅ Updated info displayed immediately

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-072: Change Password

**Priority**: HIGH

**Test Steps**:
1. On profile, tap "Ganti Password"
2. Enter current password
3. Enter new password
4. Confirm new password
5. Save

**Expected Result**:
- ✅ Validates current password
- ✅ Validates new password strength
- ✅ Password changed successfully
- ✅ Can login with new password

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-073: Upload Profile Picture

**Priority**: LOW

**Test Steps**:
1. Tap on profile picture
2. Choose "Upload Foto"
3. Select image from gallery
4. Crop if needed
5. Save

**Expected Result**:
- ✅ Image picker opens
- ✅ Can select from gallery or camera
- ✅ Image uploads successfully
- ✅ New picture displayed immediately

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-074: View Workshop Settings

**Priority**: MEDIUM

**Test Steps**:
1. On profile, tap "Pengaturan Bengkel"
2. View workshop settings

**Expected Result**:
- ✅ Shows workshop name
- ✅ Shows address
- ✅ Shows operating hours
- ✅ Shows contact info
- ✅ Can edit each field

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-075: Update Workshop Operating Hours

**Priority**: MEDIUM

**Test Steps**:
1. In workshop settings
2. Tap "Jam Operasional"
3. Change Monday hours: 08:00 - 17:00
4. Save

**Expected Result**:
- ✅ Time picker opens
- ✅ Can set different hours per day
- ✅ Changes saved
- ✅ Reflected in customer app

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

## 🔔 Module 7: Notifications

### TC-080: View Notifications List

**Priority**: MEDIUM

**Test Steps**:
1. Tap notification icon in header
2. View notification list

**Expected Result**:
- ✅ All notifications displayed
- ✅ Shows: title, message, timestamp
- ✅ Unread notifications highlighted
- ✅ Shows notification badge count

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-081: Mark Notification as Read

**Priority**: LOW

**Test Steps**:
1. Open notifications
2. Tap on unread notification

**Expected Result**:
- ✅ Notification marked as read
- ✅ Badge count decreases
- ✅ Highlight removed

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-082: Notification Deep Link

**Priority**: HIGH

**Test Steps**:
1. Receive notification: "Service baru ditugaskan"
2. Tap notification
3. App opens

**Expected Result**:
- ✅ App opens to relevant screen (service detail)
- ✅ Correct service shown
- ✅ Deep link works from killed app state

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-083: Push Notification Received

**Priority**: HIGH  
**Prerequisite**: Enable notifications in device settings

**Test Steps**:
1. Have another user create a service
2. Service assigned to your workshop
3. Observe notification

**Expected Result**:
- ✅ Push notification received
- ✅ Notification shows in system tray
- ✅ Shows service details
- ✅ Tap opens app to service detail

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-084: Notification Preferences

**Priority**: LOW

**Test Steps**:
1. On profile, go to Settings
2. Tap "Notifikasi"
3. Toggle notification types on/off

**Expected Result**:
- ✅ Shows notification categories
- ✅ Can enable/disable each type
- ✅ Changes saved
- ✅ Settings applied immediately

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

## 🌐 Module 8: Offline & Network Handling

### TC-090: App Behavior When Offline

**Priority**: HIGH

**Test Steps**:
1. Login to app
2. Enable airplane mode
3. Try to refresh dashboard

**Expected Result**:
- ✅ Shows offline indicator
- ✅ Error message: "Tidak ada koneksi internet"
- ✅ Cached data still visible
- ✅ App doesn't crash

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-091: Resume After Network Restore

**Priority**: HIGH

**Test Steps**:
1. Start with offline mode
2. Restore internet connection
3. Try action (e.g., refresh)

**Expected Result**:
- ✅ App detects network restoration
- ✅ Automatically syncs data
- ✅ Shows success message
- ✅ All features work normally

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-092: Slow Network Handling

**Priority**: MEDIUM  
**Prerequisite**: Simulate slow network (via dev tools)

**Test Steps**:
1. Enable slow 3G simulation
2. Navigate to dashboard
3. Observe loading behavior

**Expected Result**:
- ✅ Loading indicators shown
- ✅ Timeout handled gracefully
- ✅ Error message if timeout
- ✅ Can retry

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

## 📱 Module 9: UI/UX & Responsiveness

### TC-095: Portrait/Landscape Orientation

**Priority**: MEDIUM

**Test Steps**:
1. On dashboard
2. Rotate device to landscape
3. Rotate back to portrait

**Expected Result**:
- ✅ Layout adapts to orientation
- ✅ No UI elements cut off
- ✅ Data preserved during rotation
- ✅ Smooth transition

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-096: Different Screen Sizes

**Priority**: MEDIUM  
**Prerequisite**: Test on different devices

**Test Devices**:
- [ ] Small phone (5" screen)
- [ ] Medium phone (6" screen)
- [ ] Large phone (6.5"+ screen)
- [ ] Tablet (10" screen)

**Expected Result**:
- ✅ UI scales properly on all sizes
- ✅ Text readable on small screens
- ✅ Buttons tap-able (min 44px)
- ✅ No horizontal scrolling

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

### TC-097: App Performance & Smoothness

**Priority**: MEDIUM

**Test Steps**:
1. Navigate through all major screens
2. Perform common actions
3. Scroll through lists

**Expected Result**:
- ✅ No lag or stuttering
- ✅ Smooth animations (60fps)
- ✅ Quick screen transitions
- ✅ No memory leaks

**Actual Result**: _______  
**Status**: [ ] Pass [ ] Fail  
**Notes**: _______

---

## ✅ Test Execution Summary

### Statistics

| Status | Count | Percentage |
|--------|-------|------------|
| **Pass** | ___ | ___% |
| **Fail** | ___ | ___% |
| **Blocked** | ___ | ___% |
| **Not Tested** | ___ | ___% |
| **Total** | 105 | 100% |

### Critical Bugs Found

| Bug ID | Module | Description | Severity | Status |
|--------|--------|-------------|----------|--------|
| | | | | |
| | | | | |

### Test Environment

- **Device**: ___________________
- **OS Version**: ___________________
- **App Version**: ___________________
- **Backend URL**: ___________________
- **Test Date**: ___________________
- **Tester Name**: ___________________

---

## 📝 Notes & Observations

_Add any additional observations, suggestions, or issues not covered by specific test cases:_

---

**Report Completed**: _________  
**Signed By**: _________  
**Ready for Production**: [ ] Yes [ ] No
