import 'package:flutter/material.dart';
import 'package:shop/common/cloudinary.dart';

/// Generic reusable product tile with thumbnail, title, optional subtitle and trailing widget.
/// Used in cart, order summary, and admin product list.
class ProductTile extends StatelessWidget {
  const ProductTile({
    super.key,
    required this.imageIds,
    required this.title,
    required this.thumbSize,
    this.thumbRadius = 8.0,
    this.titlePrefix,
    this.subtitle,
    this.trailing,
  });

  final List<String> imageIds;
  final String title;
  final double thumbSize;
  final double thumbRadius;
  /// Optional widget shown before the title (e.g. an ID badge).
  final Widget? titlePrefix;
  final Widget? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final titleRow = titlePrefix != null
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              titlePrefix!,
              const SizedBox(width: 6),
              Flexible(child: _Title(text: title, thumbSize: thumbSize)),
            ],
          )
        : _Title(text: title, thumbSize: thumbSize);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _Thumbnail(
          imageIds: imageIds,
          size: thumbSize,
          radius: thumbRadius,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: subtitle != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    titleRow,
                    const SizedBox(height: 2),
                    subtitle!,
                  ],
                )
              : titleRow,
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          trailing!,
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Title extends StatelessWidget {
  const _Title({required this.text, required this.thumbSize});
  final String text;
  final double thumbSize;

  @override
  Widget build(BuildContext context) {
    final fontSize = thumbSize >= 70 ? 15.0 : (thumbSize >= 56 ? 14.0 : 13.0);
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: fontSize,
        color: const Color(0xFF111827),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.imageIds,
    required this.size,
    required this.radius,
  });

  final List<String> imageIds;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = imageIds.isNotEmpty
        ? cloudinaryUrl(imageIds.first, size: CloudinarySize.thumbnail)
        : '';
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: url.isNotEmpty
          ? Image.network(
              url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) =>
                  progress == null ? child : _placeholder(loading: true),
              errorBuilder: (_, __, ___) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder({bool loading = false}) => Container(
        width: size,
        height: size,
        color: const Color(0xFFF3F4F6),
        child: Center(
          child: loading
              ? SizedBox(
                  width: size * 0.35,
                  height: size * 0.35,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.grey.shade400,
                  ),
                )
              : Icon(
                  Icons.image_outlined,
                  color: const Color(0xFFD1D5DB),
                  size: size * 0.4,
                ),
        ),
      );
}
