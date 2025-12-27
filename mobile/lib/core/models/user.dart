import 'package:bengkel_online_flutter/core/models/employment.dart';
import 'package:bengkel_online_flutter/core/models/workshop.dart';

class User {
  final String id;
  final String name;
  final String username;
  final String email;
  final String? photo;
  final String? photoUrl; // Added

  final String role;
  final List<Workshop>? workshops;
  final Employment? employment;
  final bool mustChangePassword;
  final String? subscriptionStatus; // 'active', 'pending', expired, 'trial', null
  final String? subscriptionPlanName;
  final DateTime? subscriptionExpiredAt;
  
  // Trial fields
  final DateTime? trialEndsAt;
  final bool trialUsed;
  final int? trialDaysRemaining;
  final bool hasPremiumAccess;
  final DateTime? emailVerifiedAt;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.photo,
    this.photoUrl,
    required this.role,
    this.workshops,
    this.employment,
    this.mustChangePassword = false,
    this.subscriptionStatus,
    this.subscriptionPlanName,
    this.subscriptionExpiredAt,
    this.trialEndsAt,
    this.trialUsed = false,
    this.trialDaysRemaining,
    this.hasPremiumAccess = false,
    this.emailVerifiedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String userRole = 'user';
    if (json['roles'] is List && (json['roles'] as List).isNotEmpty) {
      final first = (json['roles'] as List).first;
      if (first is Map && first['name'] is String) {
        userRole = first['name'] as String;
      }
    }

    // Parsing workshops
    List<Workshop>? parsedWorkshops;
    if (json['workshops'] is List) {
      try {
        parsedWorkshops = (json['workshops'] as List)
            .whereType<Map<String, dynamic>>()
            .map(Workshop.fromJson)
            .toList();
      } catch (_) {
        parsedWorkshops = null;
      }
    } else if (json['workshops'] == null) {
      parsedWorkshops = null;
    }

    // Parsing employment
    Employment? parsedEmployment;
    if (json['employment'] is Map<String, dynamic>) {
      try {
        parsedEmployment =
            Employment.fromJson(json['employment'] as Map<String, dynamic>);
      } catch (_) {
        parsedEmployment = null;
      }
    }

    // Parse subscription status & details
    String? subStatus;
    String? subPlanName;
    DateTime? subExpiredAt;

    if (json['owner_subscription'] is Map<String, dynamic>) {
      final sub = json['owner_subscription'];
      subStatus = sub['status']?.toString();
      
      // Parse Plan Name
      final planData = sub['plan'] ?? sub['subscription_plan'];
      if (planData is Map<String, dynamic>) {
        subPlanName = planData['name']?.toString();
      }
      
      // Parse Expiry
      if (sub['expires_at'] != null) {
        subExpiredAt = DateTime.tryParse(sub['expires_at'].toString());
      }
    } else if (json['subscription_status'] is String) {
       // Fallback flattened
       subStatus = json['subscription_status'];
    }

    // Parse must_change_password dengan aman
    bool parseMustChange(dynamic v) {
      if (v is bool) return v;
      if (v is num) return v == 1;
      if (v is String) {
        final s = v.trim().toLowerCase();
        return s == '1' || s == 'true' || s == 'yes';
      }
      return false;
    }

    // Parse trial information
    DateTime? trialEnds;
    if (json['trial_ends_at'] != null) {
      try {
        trialEnds = DateTime.parse(json['trial_ends_at'].toString());
      } catch (_) {}
    }

    return User(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      photo: _fixImageUrl(json['photo']),
      photoUrl: _fixImageUrl(json['photo_url']), // Added
      role: userRole,
      workshops: parsedWorkshops,
      employment: parsedEmployment,
      mustChangePassword: parseMustChange(
          json['must_change_password'] ?? json['mustChangePassword']),
      subscriptionStatus: json['subscription_status'] ?? subStatus,
      subscriptionPlanName: subPlanName,
      subscriptionExpiredAt: subExpiredAt,
      
      // Trial data
      trialEndsAt: trialEnds,
      trialUsed: json['trial_used'] ?? false,
      trialDaysRemaining: json['trial_days_remaining'],

      hasPremiumAccess: json['has_premium_access'] ?? false,
      emailVerifiedAt: json['email_verified_at'] != null 
          ? DateTime.tryParse(json['email_verified_at'].toString()) 
          : null,
    );
  }

  static String? _fixImageUrl(dynamic url) {
    if (url == null || url.toString().isEmpty) return null;
    String finalUrl = url.toString();
    // Fix for Android Emulator 127.0.0.1 -> 10.0.2.2
    if (finalUrl.contains("127.0.0.1")) {
      finalUrl = finalUrl.replaceAll("127.0.0.1", "10.0.2.2");
    } else if (finalUrl.contains("localhost")) {
      finalUrl = finalUrl.replaceAll("localhost", "10.0.2.2");
    }
    return finalUrl;
  }

  bool hasRole(String roleName) => role == roleName;
  String? get workshopUuid {
    if (workshops != null && workshops!.isNotEmpty) {
      return workshops!.first.id;
    }
    if (employment != null && employment!.workshop != null) {
      return employment!.workshop!.id;
    }
    return null;
  }
  
  // Membership/Subscription helpers
  
  // Check if user is in trial
  bool get isInTrial {
    if (trialEndsAt == null) return false;
    return trialEndsAt!.isAfter(DateTime.now());
  }
  
  // Premium access includes both paid subscription AND trial
  bool get isPremium => hasPremiumAccess || subscriptionStatus == 'active' || isInTrial;
  
  String? get membershipStatus => subscriptionStatus; // Alias for backward compatibility
}