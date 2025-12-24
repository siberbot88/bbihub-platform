import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

/// Custom AppBar with gradient background, roundels, and stats pill
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int todayTasks;
  final DateTime? date;
  final String userName;
  final String roleLabel;
  final ImageProvider? avatar;
  final VoidCallback? onAvatarTap;

  final double greetingSize;
  final double subtitleSize;
  final double appNameSize;
  final double roleSize;
  final double dateValueSize;
  final double taskValueSize;
  final double labelSize;

  const HomeAppBar({
    super.key,
    this.todayTasks = 12,
    this.date,
    this.userName = 'AHASS',
    this.roleLabel = 'admin workshop',
    this.avatar,
    this.onAvatarTap,
    this.greetingSize = 26,
    this.subtitleSize = 15,
    this.appNameSize = 14,
    this.roleSize = 12,
    this.dateValueSize = 20,
    this.taskValueSize = 20,
    this.labelSize = 12,
  });

  @override
  Size get preferredSize => const Size.fromHeight(324);

  @override
  Widget build(BuildContext context) {
    final now = date ?? DateTime.now();
    final tanggal = _formatTanggalID(now);
    final waktu = _greeting(now);

    return AppBar(
      elevation: 3,
      foregroundColor: Colors.white,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withAlpha(64),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleSpacing: 0,
      title: const SizedBox.shrink(),
      flexibleSpace: Stack(
        fit: StackFit.expand,
        children: [
          // gradient utama
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFDC2626), Color(0xFF000000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // roundels
          const Positioned(
            right: -40,
            top: -10,
            child: _Roundel(
              size: 240,
              innerColor: Color(0xFFDC2626),
              outerColor: Color(0xFF000000),
              opacity: 0.55,
            ),
          ),
          const Positioned(
            left: -60,
            top: -30,
            child: _Roundel(
              size: 200,
              innerColor: Color(0xFFDC2626),
              outerColor: Color(0xFF000000),
              opacity: 0.35,
            ),
          ),
          const Positioned(
            left: -20,
            bottom: -70,
            child: _Roundel(
              size: 280,
              innerColor: Color(0xFF000000),
              outerColor: Color(0xFF000000),
              opacity: 0.35,
            ),
          ),

          // Marquez image
          Positioned(
            right: 0,
            bottom: 0,
            child: Transform.translate(
              offset: const Offset(0, 20),
              child: Image.asset(
                "assets/image/marquez.png",
                height: 300,
                fit: BoxFit.contain,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BBI HUB +',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: appNameSize,
                                letterSpacing: .3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              roleLabel,
                              style: TextStyle(
                                color: Colors.white.withAlpha(217),
                                fontSize: roleSize,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: onAvatarTap,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white.withAlpha(230),
                          backgroundImage: avatar,
                          child: avatar == null
                              ? const Icon(Icons.person, color: Colors.black)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 76),
                  const Padding(padding: EdgeInsets.only(left: 20)),
                  Text(
                    'Selamat $waktu, $userName',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: greetingSize,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Yuk Kelola Operasional Hari ini 🔥',
                    style: TextStyle(
                      color: Colors.white.withAlpha(235),
                      fontSize: subtitleSize,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Center(
                    child: _StatsPill(
                      tanggal: tanggal,
                      tasks: todayTasks,
                      dateValueSize: dateValueSize,
                      taskValueSize: taskValueSize,
                      labelSize: labelSize,
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Decorative roundel (circle with radial gradient)
class _Roundel extends StatelessWidget {
  final double size;
  final Color innerColor;
  final Color outerColor;
  final double opacity;

  const _Roundel({
    required this.size,
    required this.innerColor,
    required this.outerColor,
    this.opacity = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.2, -0.2),
            radius: 0.8,
            colors: [
              innerColor.withValues(alpha: opacity),
              Color.lerp(innerColor, outerColor, 0.5)!
                  .withValues(alpha: opacity * 0.6),
              outerColor.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
      ),
    );
  }
}

/// Stats pill showing date and tasks count
class _StatsPill extends StatelessWidget {
  final String tanggal;
  final int tasks;
  final double dateValueSize;
  final double taskValueSize;
  final double labelSize;

  const _StatsPill({
    required this.tanggal,
    required this.tasks,
    this.dateValueSize = 20,
    this.taskValueSize = 20,
    this.labelSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final double pillWidth = math.min(364.0, math.max(240.0, sw - 32.0));

    return Container(
      width: pillWidth,
      constraints: const BoxConstraints(minHeight: 92.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(36),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withAlpha(56), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(46),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tanggal sekarang',
                  style: TextStyle(
                    color: Colors.white.withAlpha(217),
                    fontSize: labelSize,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tanggal,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 44,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: Colors.white.withAlpha(64),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Tugas hari ini',
                  style: TextStyle(
                    color: Colors.white.withAlpha(217),
                    fontSize: labelSize,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$tasks',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: taskValueSize,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ========== Helper Functions ==========

String _formatTanggalID(DateTime d) {
  const bulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  return '${d.day} ${bulan[d.month - 1]} ${d.year}';
}

String _greeting(DateTime d) {
  final h = d.hour;
  if (h >= 4 && h < 11) return 'Pagi';
  if (h >= 11 && h < 15) return 'Siang';
  if (h >= 15 && h < 19) return 'Sore';
  return 'Malam';
}
