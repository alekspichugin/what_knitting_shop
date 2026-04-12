import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/common/ui/app_shell.dart';
import 'package:shop/home/presentation/bloc/home_cubit.dart';
import 'package:shop/product_group/domain/model/product_group.dart';
import 'package:shop/routes.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (!state.isLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.groups.isEmpty) {
            return const Center(
              child: Text(
                'Нет категорий',
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
                    _GroupsGrid(groups: state.groups),
                    const Gap(32),
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

class _GroupsGrid extends StatelessWidget {
  const _GroupsGrid({required this.groups});

  final List<ProductGroup> groups;

  @override
  Widget build(BuildContext context) {
    const cols = 3;
    final rows = <List<ProductGroup>>[];
    for (var i = 0; i < groups.length; i += cols) {
      rows.add(groups.sublist(i, (i + cols).clamp(0, groups.length)));
    }

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...row.map((g) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: _GroupCard(group: g),
                ),
              )),
              if (row.length < cols)
                ...List.generate(
                  cols - row.length,
                  (_) => const Expanded(child: SizedBox()),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _GroupCard extends StatefulWidget {
  const _GroupCard({required this.group});

  final ProductGroup group;

  @override
  State<_GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<_GroupCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.push('$kProductGroupRoute/${widget.group.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 200,
              transform: _hovered
                  ? (Matrix4.identity()..translate(0.0, -3.0))
                  : Matrix4.identity(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: widget.group.imageUrl.isNotEmpty
                    ? Image.network(
                        widget.group.imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) => progress == null
                            ? child
                            : Container(
                                height: 200,
                                color: widget.group.color,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                ),
                              ),
                        errorBuilder: (_, __, ___) => Container(
                          height: 200,
                          color: widget.group.color,
                        ),
                      )
                    : Container(height: 200, color: widget.group.color),
              ),
            ),
            const Gap(10),
            Text(
              widget.group.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Gap(3),
            Text(
              widget.group.description,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
