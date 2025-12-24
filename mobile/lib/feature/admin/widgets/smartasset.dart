import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; 

class SmartAsset extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, Object?, StackTrace?)? errorBuilder;

   const SmartAsset({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
     this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
 // Jika file adalah SVG
    if (path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        fit: fit,
        placeholderBuilder: (context) => const Center(
          child: CircularProgressIndicator(strokeWidth: 1.5),
        ),
      );
    }

    // Jika file bukan SVG (misalnya PNG/JPG)
    return Image.asset(
      path,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // Jika ada errorBuilder custom, pakai itu
        if (errorBuilder != null) {
          return errorBuilder!(context, error, stackTrace);
        }
        // Default: tampilkan ikon error
        return const Icon(Icons.broken_image, color: Colors.grey);
      },
    );
  }
}
