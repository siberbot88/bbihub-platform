# 🔐 Premium Feature Gating - Implementation Guide

## Quick Start

The `PremiumFeatureLock` widget makes it easy to gate premium features with professional blur effects and upgrade prompts.

---

## 📝 Step-by-Step Implementation

### **Step 1: Import Required Packages**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/premium_feature_lock.dart';
import '../../../core/services/auth_provider.dart';
```

### **Step 2: Check User's Premium Status**

```dart
class _YourScreenState extends State<YourScreen> {
  // Method 1: Inside widget (reactive to changes)
  bool _isPremium(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return auth.user?.membershipStatus == 'active';
  }
  
  // Method 2: One-time check
  bool get _isPremium {
    final auth = context.read<AuthProvider>();
    return auth.user?.membershipStatus == 'active';
  }
}
```

### **Step 3: Wrap Features with PremiumFeatureLock**

```dart
// Example: Lock analytics chart for free users
PremiumFeatureLock(
  isLocked: !_isPremium,  // false = premium user, true = free user
  featureName: 'Grafik Tren Premium',
  featureDescription: 'Pantau pertumbuhan bengkel dengan grafik interaktif',
  child: YourAnalyticsWidget(),
)
```

---

## 🎨 Usage Examples

### **Example 1: Lock Entire Chart Section**

```dart
Widget _buildTrendChart(ReportData data) {
  return PremiumFeatureLock(
    isLocked: !_isPremium,
    featureName: 'Grafik Tren Analytics',
    featureDescription: 'Lihat tren pendapatan dengan grafik interaktif',
    child: Container(
      // Your existing chart widget
      child: LineChart(...),
    ),
  );
}
```

**Result:**
- ✅ Premium users: See chart normally
- 🔒 Free users: See blurred chart + upgrade prompt

---

### **Example 2: Add Premium Badge to Headers**

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text('Grafik Tren', style: titleStyle),
    if (!_isPremium)  // Show badge only for free users
      const PremiumBadge(),
  ],
)
```

**Result:**
- Shows golden "PREMIUM" badge next to title for free users
- Provides visual cue that feature is locked

---

### **Example 3: Conditional Content Rendering**

```dart
Widget _buildStaffPerformance() {
  if (_isPremium) {
    // Premium: Show full staff list with metrics
    return ListView.builder(
      itemCount: allStaff.length,
      itemBuilder: (context, index) => StaffCard(allStaff[index]),
    );
  } else {
    // Free: Show limited preview (first 2 staff) + upgrade prompt
    return Column(
      children: [
        StaffCard(allStaff[0]),
        StaffCard(allStaff[1]),
        UpgradePromptCard(
          message: 'Lihat ${allStaff.length - 2} staff lainnya',
          onTap: _showUpgradeSheet,
        ),
      ],
    );
  }
}
```

**Result:**
- ✅ Premium: Full staff list
- 🔒 Free: Preview of 2 staff + "Unlock more" button

---

### **Example 4: Lock Export Buttons**

```dart
PremiumFeatureLock(
  isLocked: !_isPremium,
  featureName: 'Export Laporan',
  featureDescription: 'Download laporan PDF untuk audit dan pajak',
  child: ElevatedButton.icon(
    onPressed: () => _exportPDF(),
    icon: Icon(Icons.picture_as_pdf),
    label: Text('Export PDF'),
  ),
)
```

**Result:**
- ✅ Premium: Button works
- 🔒 Free: Button blurred, shows upgrade prompt on tap

---

## 🚀 Applying to Existing Screens

### **For `report_pages.dart`:**

1. **Add imports:**
```dart
import '../../../core/widgets/premium_feature_lock.dart';
import '../../../core/services/auth_provider.dart';
import 'package:provider/provider.dart';
```

2. **Add premium check:**
```dart
class _ReportPageState extends State<ReportPage> {
  // ... existing code ...
  
  bool get _isPremium {
    final auth = context.read<AuthProvider>();
    return auth.user?.membershipStatus == 'active';
  }
}
```

3. **Wrap chart widgets (find around line 377):**
```dart
// Find this:
Widget _buildTrendChart(ReportData d) {
  return Container(
    // ... chart code ...
  );
}

// Change to:
Widget _buildTrendChart(ReportData d) {
  return PremiumFeatureLock(
    isLocked: !_isPremium,
    featureName: 'Grafik Tren Premium',
    featureDescription: 'Pantau pertumbuhan dengan grafik interaktif',
    child: Container(
      // ... keep existing chart code ...
    ),
  );
}
```

4. **Add premium badge to chart headers:**
```dart
// Find chart title row:
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Column(/* title */),
    // ADD THIS:
    Row(
      children: [
        if (!_isPremium) const PremiumBadge(),
        const SizedBox(width: 8),
        Container(/* existing more icon */),
      ],
    ),
  ],
)
```

---

### **For Staff Performance (`staff_management.dart`):**

```dart
// Wrap staff metrics section
PremiumFeatureLock(
  isLocked: !_isPremium,
  featureName: 'Staff Performance Tracking',
  featureDescription: 'Pantau produktivitas tim Anda secara detail',
  child: StaffPerformanceWidget(),
)
```

---

## 🎨 Customization Options

### **Custom Blur Intensity**

The default blur is `sigmaX: 8, sigmaY: 8`. To adjust:

```dart
// In premium_feature_lock.dart, line ~31:
ImageFilter.blur(
  sigmaX: 10,  // More blur
  sigmaY: 10,
)
```

### **Custom Upgrade Action**

```dart
PremiumFeatureLock(
  isLocked: !_isPremium,
  featureName: 'Custom Feature',
  featureDescription: 'Amazing feature description',
  onUpgrade: () {
    // Custom action instead of showing bottom sheet
    Navigator.pushNamed(context, '/custom-pricing-page');
  },
  child: YourWidget(),
)
```

### **Different Lock Icons**

```dart
// In premium_feature_lock.dart, change icon around line ~50:
Icon(
  Icons.lock_outline,  // Change to any icon
  size: 48,
  color: Color(0xFFFFD700),
)
```

---

## ✅ Features to Gate (Priority Order)

Based on the implementation plan, gate these features first:

### **High Priority (Week 1)**
1. ✅ **Grafik Tren Charts** - `report_pages.dart` line ~377
2. ✅ **PDF Export Button** - `report_pages.dart` header
3. ✅ **Staff Performance** - `staff_management.dart`

### **Medium Priority (Week 2)**
4. ⏳ **Service Breakdown BarChart** - `report_pages.dart` line ~456
5. ⏳ **Peak Hours BarChart** - `report_pages.dart` line ~529
6. ⏳ **Extended Date Ranges** - Disable weekly/daily for free users

### **Low Priority (Week 3+)**
7. ⏳ **Service/Customer Limits** - Show usage count "38/50 services"
8. ⏳ **Customer Analytics** - Entire new section (build premium-only)

---

## 🧪 Testing Checklist

- [ ] Free user sees blurred features
- [ ] Tapping blurred area shows upgrade bottom sheet
- [ ] Premium users see all features normally
- [ ] Premium badge displays correctly
- [ ] Upgrade button navigates to membership screen
- [ ] Hot reload preserves premium status
- [ ] App doesn't crash if membership status is null

---

## 📸 Expected Result

**Free User:**
- Blurred chart with dark gradient overlay
- Golden crown icon in center
- "Upgrade ke Premium" button
- Premium badge on section headers

**Premium User:**
- Normal clear chart
- No overlay or blur
- No premium badges
- All features accessible

---

## 🚨 Common Issues

**Issue:** `_isPremium` always returns false

**Solution:** Check if `membershipStatus` field exists in User model:
```dart
// In user.dart, add:
final String? membershipStatus; // 'active', 'expired', null
```

**Issue:** Context not available for `context.read<AuthProvider>()`

**Solution:** Use `Consumer<AuthProvider>` widget:
```dart
Consumer<AuthProvider>(
  builder: (context, auth, _) {
    final isPremium = auth.user?.membershipStatus == 'active';
    return PremiumFeatureLock(isLocked: !isPremium, ...);
  },
)
```

---

## 📚 Next Steps

1. Review [premium_feature_example.dart](file:///e:/BBIHUB/mobile/lib/core/examples/premium_feature_example.dart) for complete working examples
2. Apply to `report_pages.dart` first (highest value feature)
3. Test with both free and premium user accounts
4. Adjust blur/styling to match app design
5. Implement usage limits (services/month counter)

---

**Need Help?** Check the example file or review the implementation plan artifact! 🚀
