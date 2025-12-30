import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

import 'package:bengkel_online_flutter/core/services/api_service.dart';
import 'package:bengkel_online_flutter/core/models/employment.dart';
import 'package:bengkel_online_flutter/core/models/service.dart';
import 'package:bengkel_online_flutter/feature/admin/providers/admin_service_provider.dart';
import 'package:provider/provider.dart';

class AssignMechanicSheet extends StatefulWidget {
  const AssignMechanicSheet({super.key});

  @override
  State<AssignMechanicSheet> createState() => _AssignMechanicSheetState();
}

class _AssignMechanicSheetState extends State<AssignMechanicSheet> {
  // Use AdminServiceProvider instead of direct API
  late AdminServiceProvider _adminProvider;
  
  List<Map<String, dynamic>> _mechanics = [];
  bool _isLoading = true;
  String? _error;
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    // Defer provider access until context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _adminProvider = context.read<AdminServiceProvider>();
      _fetchMechanics();
    });
  }

  Future<void> _fetchMechanics() async {
    try {
      final mechanics = await _adminProvider.fetchMechanicsForAssignment();
      setState(() {
        _mechanics = mechanics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32), 
          topRight: Radius.circular(32),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Pilih Mekanik",
                  style: AppTextStyles.heading4().copyWith(fontSize: 20),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.grey), 
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    padding: const EdgeInsets.all(8),
                    minimumSize: const Size(40, 40),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, color: Color(0xFFEEEEEE)),

          // List
          Flexible(
            child: _buildBody(),
          ),
          
          // Button
          Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_isLoading || _mechanics.isEmpty || _selectedIndex == -1) 
                    ? null 
                    : () {
                        final m = _mechanics[_selectedIndex];
                        Navigator.pop(context, {
                          'id': m['id'],
                          'name': m['name'],
                          'avatar': m['photo_url'] ?? 'https://ui-avatars.com/api/?name=${m['name']}',
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  "Konfirmasi",
                  style: AppTextStyles.heading5(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text("Gagal memuat mekanik", style: AppTextStyles.heading5()),
              TextButton(onPressed: _fetchMechanics, child: const Text("Coba Lagi")),
            ],
          ),
        ),
      );
    }

    if (_mechanics.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.engineering_outlined, color: Colors.grey, size: 64),
            const SizedBox(height: 16),
            Text("Tidak ada mekanik tersedia", style: AppTextStyles.bodyMedium(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: _mechanics.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final mechanic = _mechanics[index];
        final isSelected = _selectedIndex == index;
        
        // Data from API
        final name = mechanic['name'] ?? 'Unknown';
        final photoUrl = mechanic['photo_url'] ?? 'https://ui-avatars.com/api/?name=$name';
        final activeCount = mechanic['active_services_count'] ?? 0;
        final maxSlots = mechanic['max_slots'] ?? 5;
        final availableSlots = mechanic['available_slots'] ?? 0;
        final isAvailable = (mechanic['is_available'] == true) || (availableSlots > 0);
        
        return GestureDetector(
          onTap: isAvailable ? () {
            setState(() {
              _selectedIndex = index;
            });
          } : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppColors.primaryRed.withOpacity(0.04) 
                  : (isAvailable ? Colors.white : Colors.grey[50]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primaryRed : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Avatar
                _buildAvatar(name, ServiceModel.sanitizeUrl(photoUrl), isAvailable),
                const SizedBox(width: 16),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.bodyMedium(
                          color: isAvailable ? AppColors.textPrimary : Colors.grey,
                        ).copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isAvailable ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isAvailable ? Icons.check_circle : Icons.cancel,
                                  size: 12, 
                                  color: isAvailable ? Colors.green : Colors.red
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isAvailable ? "Tersedia ($availableSlots Slot)" : "Penuh ($activeCount/$maxSlots)",
                                  style: AppTextStyles.caption().copyWith(
                                    color: isAvailable ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isAvailable && activeCount > 0)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                "Aktif: $activeCount",
                                style: AppTextStyles.caption(color: Colors.grey),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryRed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 16, color: Colors.white),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _buildAvatar(String name, String? photoUrl, bool isAvailable) {
    // If photoUrl is valid (not placeholder), show image. 
    // Otherwise show initials.
    
    // Check if URL is effectively empty or placeholder
    final bool hasPhoto = photoUrl != null && 
        photoUrl.isNotEmpty && 
        !photoUrl.contains('placehold.co') && 
        !photoUrl.contains('ui-avatars.com') &&
        !photoUrl.contains('localhost') && // Filter out un-sanitized localhost
        !photoUrl.contains('127.0.0.1');

    Widget avatarContent;

    if (hasPhoto) {
       avatarContent = Container(
         width: 50,
         height: 50,
         decoration: BoxDecoration(
           shape: BoxShape.circle,
           image: DecorationImage(
             image: NetworkImage(photoUrl!),
             fit: BoxFit.cover,
             onError: (_, __) {}, 
           ),
         ),
       );
    } else {
       // Initials
       avatarContent = Container(
         width: 50,
         height: 50,
         alignment: Alignment.center,
         decoration: BoxDecoration(
           shape: BoxShape.circle,
           color: _generateColor(name),
         ),
         child: Text(
           _getInitials(name),
           style: const TextStyle(
             color: Colors.white, 
             fontWeight: FontWeight.bold, 
             fontSize: 18
           ),
         ),
       );
    }

    // Wrap with availability dimming
    return Stack(
      children: [
        avatarContent,
        if (!isAvailable)
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "?";
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      if (parts[0].isNotEmpty && parts[1].isNotEmpty) {
          return "${parts[0][0]}${parts[1][0]}".toUpperCase();
      }
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
        return parts[0][0].toUpperCase();
    }
    return "?";
  }

  Color _generateColor(String name) {
    if (name.isEmpty) return Colors.blue;
    // Simple deterministic color generation
    final colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange, 
      Colors.purple, Colors.teal, Colors.pink, Colors.deepPurple, Colors.indigo
    ];
    return colors[name.codeUnitAt(0) % colors.length];
  }
}
