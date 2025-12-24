import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomBottomNavBarAdmin extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBarAdmin({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> items = [
      {
        'label': 'Beranda',
        'icon_inactive': 'assets/svg/home_tipis.svg',
        'icon_active': 'assets/svg/home_tebal.svg',
      },
      {
        'label': 'Servis',
        'icon_inactive': 'assets/icons/service_tipis.svg',
        'icon_active': 'assets/icons/service_tebal.svg',
      },
      {
        'label': 'Dasbor',
        'icon_inactive': 'assets/icons/dashboard_tipis.svg',
        'icon_active': 'assets/icons/dashboard_tebal.svg',
      },
      {
        'label': 'Profil',
        'icon_inactive': 'assets/svg/profil_tipis.svg',
        'icon_active': 'assets/svg/profil_tebal.svg',
      },
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final itemCount =  items.length;
            final itemWidth = totalWidth / itemCount;

            return Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background merah animasi
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    left: itemWidth * selectedIndex + 8,
                    top: 10,
                    width: itemWidth - 16,
                    height: 58,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(itemCount, (index) {
                      final entry = items[index];
                      final active = index == selectedIndex;

                      double iconSize = 22.0; // Ukuran default
                      if (index == 1) {
                        iconSize = 24.0;
                      } else if (index == 3) {
                        iconSize = 20.0;
                      }

                      return Expanded(
                        child: InkWell(
                          onTap: () => onTap(index),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: SizedBox(
                            height: 70,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Posisi Ikon diatur dari atas
                                Positioned(
                                  top: 12,
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: SvgPicture.asset(
                                      active
                                          ? entry['icon_active']!
                                          : entry['icon_inactive']!,
                                      width: iconSize,
                                     height: iconSize,
                                      ),
                                  ),
                                ),
                                // Posisi Teks diatur dari bawah
                                Positioned(
                                  bottom: 12,
                                  child: Text(
                                    entry['label']!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: active
                                          ? Colors.white
                                          : const Color(0xFF9A9A9A),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}