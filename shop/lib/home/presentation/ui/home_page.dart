import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:shop/common/ui/app_shell.dart';
import 'package:shop/home/presentation/bloc/home_cubit.dart';
import 'package:shop/news/domain/model/news_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (!state.isLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.news.isEmpty) {
            return const Center(
              child: Text(
                'Нет информации',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
              ),
            );
          }
          return ListView(
            children: [
              ContentBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionHeader(title: 'Информация'),
                    const Gap(16),
                    _NewsGrid(news: state.news),
                    const Gap(48),
                  ],
                ),
              ),
            ],
          );
        },
    );
  }
}

// =============================================================================

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Color(0xFF111827),
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}

// =============================================================================

class _NewsGrid extends StatelessWidget {
  const _NewsGrid({required this.news});

  final List<NewsItem> news;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth > 800 ? 3 : 2;
        final rows = <List<NewsItem>>[];
        for (var i = 0; i < news.length; i += cols) {
          rows.add(news.sublist(i, (i + cols).clamp(0, news.length)));
        }

        return Column(
          children: rows.map((row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...row.map((item) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: _NewsCard(item: item),
                        ),
                      )),
                  if (row.length < cols)
                    ...List.generate(
                        cols - row.length, (_) => const Expanded(child: SizedBox())),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _NewsCard extends StatefulWidget {
  const _NewsCard({required this.item});

  final NewsItem item;

  @override
  State<_NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<_NewsCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${widget.item.date.day} '
        '${_monthName(widget.item.date.month)} '
        '${widget.item.date.year}';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hovered ? const Color(0xFFD1D5DB) : const Color(0xFFE5E7EB),
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 140, color: widget.item.color),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(6),
                  Text(
                    widget.item.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(10),
                  Text(
                    dateStr,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      '', 'янв', 'фев', 'мар', 'апр', 'май', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек',
    ];
    return names[month];
  }
}
