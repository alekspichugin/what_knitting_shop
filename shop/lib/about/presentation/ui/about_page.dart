import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/about/domain/model/about_content.dart';
import 'package:shop/about/presentation/bloc/about_cubit.dart';
import 'package:shop/common/cloudinary.dart';
import 'package:shop/common/ui/app_shell.dart';

const _kBrand = Color(0xFF7C3AED);

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AboutCubit, AboutState>(
      builder: (context, state) {
        if (state is AboutLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AboutError) {
          return const Center(
            child: Text('Ошибка загрузки', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16)),
          );
        }
        final content = switch (state) {
          AboutLoaded(content: final c) => c,
          AboutSaving(content: final c) => c,
          _ => AboutContent(rows: []),
        };

        return ListView(
          children: [
            ContentBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 52),
                  // Brand accent line
                  Container(
                    width: 52,
                    height: 4,
                    decoration: BoxDecoration(color: _kBrand, borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(height: 32),
                  if (content.rows.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(child: Text('Страница пустая', style: TextStyle(color: Color(0xFF9CA3AF)))),
                    )
                  else
                    ...content.rows.map((row) => _Row(row: row)),
                  const SizedBox(height: 72),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.row});
  final AboutRow row;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < row.blocks.length; i++) ...[
              if (i > 0) const SizedBox(width: 32),
              Expanded(child: _Block(block: row.blocks[i])),
            ],
          ],
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.block});
  final AboutBlock block;

  @override
  Widget build(BuildContext context) {
    switch (block.type) {
      case AboutBlockType.heading:
        return Text(
          block.content,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
            letterSpacing: -0.5,
            height: 1.2,
          ),
        );
      case AboutBlockType.text:
        return Text(
          block.content,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF4B5563),
            height: 1.75,
          ),
        );
      case AboutBlockType.image:
        if (block.content.isEmpty) return const SizedBox();
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              cloudinaryUrl(block.content, size: CloudinarySize.medium),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFF3F4F6),
                child: const Center(child: Icon(Icons.broken_image, color: Color(0xFFD1D5DB), size: 40)),
              ),
            ),
          ),
        );
    }
  }
}
