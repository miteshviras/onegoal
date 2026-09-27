import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final String avatarUrl;
  final double size;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final Widget? placeholder;

  const UserAvatar({
    super.key,
    required this.avatarUrl,
    this.size = 40,
    this.border,
    this.boxShadow,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (avatarUrl.startsWith('assets/')) {
      imageWidget = Image.asset(
        avatarUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => _buildFallback(),
      );
    } else if (avatarUrl.startsWith('http://') ||
        avatarUrl.startsWith('https://')) {
      imageWidget = Image.network(
        avatarUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => _buildFallback(),
      );
    } else if (avatarUrl.isNotEmpty) {
      try {
        final file = File(avatarUrl);
        if (file.existsSync()) {
          imageWidget = Image.file(
            file,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) => _buildFallback(),
          );
        } else {
          imageWidget = _buildFallback();
        }
      } catch (_) {
        imageWidget = _buildFallback();
      }
    } else {
      imageWidget = _buildFallback();
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border ??
            Border.all(
              color: AppColors.darkOutlineVariant.withValues(alpha: 0.4),
            ),
        boxShadow: boxShadow,
      ),
      child: ClipOval(child: imageWidget),
    );
  }

  Widget _buildFallback() {
    return placeholder ??
        Container(
          width: size,
          height: size,
          color: AppColors.darkSurfaceContainerHigh,
          child: Icon(
            Icons.person,
            size: size * 0.55,
            color: AppColors.primary,
          ),
        );
  }
}
