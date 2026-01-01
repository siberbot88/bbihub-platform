import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BannerService {
  // Use 10.0.2.2 for Android emulator to access host machine
  static const String baseUrl = 'http://10.0.2.2:8000';
  static const String cacheKeyAdminBanners = 'cached_admin_banners';
  static const Duration cacheDuration = Duration(hours: 1);

  /// Fetch banners for admin homepage
  static Future<List<Banner>> getAdminHomepageBanners() async {
    try {
      print('🔍 [BannerService] Fetching banners from API...');

      // Fetch from API
      final url = '$baseUrl/api/v1/banners/admin-homepage';
      print('📡 [BannerService] Calling: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('📥 [BannerService] Response status: ${response.statusCode}');
      print('📥 [BannerService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        print('🔍 [BannerService] Decoded data: $data');
        
        final bannersData = data['banners'] as List<dynamic>;
        print('📋 [BannerService] Banners array length: ${bannersData.length}');

        final banners = bannersData
            .map((item) {
              print('🏷️ [BannerService] Parsing banner: $item');
              return Banner.fromJson(item as Map<String, dynamic>);
            })
            .toList();

        print('✅ [BannerService] Successfully parsed ${banners.length} banners');
        
        // Cache the results
        await _cacheBanners(banners);

        return banners;
      } else {
        print('❌ [BannerService] API error: ${response.statusCode}');
        throw Exception('Failed to load banners: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ [BannerService] Error fetching banners: $e');
      print('❌ [BannerService] Stack trace: $stackTrace');
      
      // Return cached data as fallback
      final cached = await _getCachedBanners();
      if (cached != null && cached.isNotEmpty) {
        print('✅ [BannerService] Returning ${cached.length} cached banners as fallback');
        return cached;
      }

      print('⚠️ [BannerService] No banners available, returning empty list');
      return [];
    }
  }

  /// Get character image for admin homepage
  static Future<Banner?> getAdminCharacterImage() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/banners/admin-homepage'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final characterData = data['character'];

        if (characterData != null) {
          return Banner.fromJson(characterData as Map<String, dynamic>);
        }
      }
    } catch (e) {
      print('Error fetching character image: $e');
    }

    return null;
  }

  // Cache helpers
  static Future<List<Banner>?> _getCachedBanners() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(cacheKeyAdminBanners);
      final cacheTime = prefs.getInt('${cacheKeyAdminBanners}_time');

      if (cachedJson != null && cacheTime != null) {
        final cacheAge = DateTime.now().millisecondsSinceEpoch - cacheTime;
        
        // Check if cache is still valid
        if (cacheAge < cacheDuration.inMilliseconds) {
          final List<dynamic> jsonList = json.decode(cachedJson);
          return jsonList
              .map((item) => Banner.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      print('Error reading cache: $e');
    }

    return null;
  }

  static Future<void> _cacheBanners(List<Banner> banners) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = banners.map((b) => b.toJson()).toList();
      await prefs.setString(cacheKeyAdminBanners, json.encode(jsonList));
      await prefs.setInt('${cacheKeyAdminBanners}_time', 
          DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error caching banners: $e');
    }
  }

  /// Clear banner cache
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(cacheKeyAdminBanners);
    await prefs.remove('${cacheKeyAdminBanners}_time');
  }
}

/// Banner model
class Banner {
  final int id;
  final String title;
  final String? description;
  final String imageUrl;
  final String placementSlot;
  final String status;

  Banner({
    required this.id,
    required this.title,
    this.description,
    required this.imageUrl,
    required this.placementSlot,
    required this.status,
  });

  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String,
      placementSlot: json['placement_slot'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'placement_slot': placementSlot,
      'status': status,
    };
  }
}
