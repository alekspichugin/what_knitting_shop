import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/about/domain/model/about_content.dart';
import 'package:shop/about/presentation/bloc/about_cubit.dart';
import 'package:shop/common/breakpoints.dart';
import 'package:shop/common/cloudinary.dart';

class AboutAdminPage extends StatelessWidget {
  const AboutAdminPage({
    super.key,
    this.pageTitle = 'О нас',
    this.editRoute = '/about/edit',
  });

  final String pageTitle;
  final String editRoute;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AboutCubit, AboutState>(
      builder: (context, state) {
        final content = switch (state) {
          AboutLoaded(content: final c) => c,
          AboutSaving(content: final c) => c,
          _ => null,
        };

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Страница «$pageTitle»',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                  ),
                  const Spacer(),
                  if (!context.isMobile)
                    FilledButton.icon(
                      onPressed: () => context.go(editRoute),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Редактировать'),
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF7C3AED)),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              if (state is AboutLoading)
                const Center(child: CircularProgressIndicator())
              else if (content == null || content.rows.isEmpty)
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 48),
                      const Icon(Icons.article_outlined, size: 48, color: Color(0xFFD1D5DB)),
                      const SizedBox(height: 16),
                      const Text('Страница пустая', style: TextStyle(color: Color(0xFF9CA3AF))),
                      if (!context.isMobile) ...[
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => context.go(editRoute),
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Добавить контент'),
                          style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF7C3AED)),
                        ),
                      ],
                    ],
                  ),
                )
              else
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: _Preview(content: content),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Preview ──────────────────────────────────────────────────────────────────

class _Preview extends StatelessWidget {
  const _Preview({required this.content});
  final AboutContent content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: content.rows.map((r) => _PreviewRow(row: r)).toList(),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({super.key, required this.row});
  final AboutRow row;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < row.blocks.length; i++) ...[
              if (i > 0) const SizedBox(width: 24),
              Expanded(child: _PreviewBlock(block: row.blocks[i])),
            ],
          ],
        ),
      ),
    );
  }
}

class _PreviewBlock extends StatelessWidget {
  const _PreviewBlock({super.key, required this.block});
  final AboutBlock block;

  @override
  Widget build(BuildContext context) {
    switch (block.type) {
      case AboutBlockType.heading:
        return Text(
          block.content,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
        );
      case AboutBlockType.text:
        return Text(block.content, style: const TextStyle(fontSize: 15, color: Color(0xFF4B5563), height: 1.7));
      case AboutBlockType.image:
        if (block.content.isEmpty) return const SizedBox();
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            cloudinaryUrl(block.content, size: CloudinarySize.medium),
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (_, __, ___) => Container(
              height: 120,
              color: const Color(0xFFF3F4F6),
              child: const Center(child: Icon(Icons.broken_image, color: Color(0xFFD1D5DB))),
            ),
          ),
        );
    }
  }
}
