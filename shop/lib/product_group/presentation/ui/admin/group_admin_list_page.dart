import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/product_group/domain/model/product_group.dart';
import 'package:shop/product_group/presentation/bloc/admin/group_admin_cubit.dart';
import 'package:shop/product_group/presentation/bloc/admin/group_admin_state.dart';

class GroupAdminListPage extends StatelessWidget {
  const GroupAdminListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Группы товаров', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => context.push('/groups/new'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Добавить группу'),
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF7C3AED)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BlocBuilder<GroupAdminCubit, GroupAdminState>(
              builder: (context, state) {
                if (state is GroupAdminLoading) return const Center(child: CircularProgressIndicator());
                if (state is GroupAdminError) return Center(child: Text('Ошибка: ${state.message}'));
                if (state is! GroupAdminLoaded) return const SizedBox();
                if (state.groups.isEmpty) return const Center(child: Text('Нет групп'));

                return Card(
                  elevation: 1,
                  clipBehavior: Clip.antiAlias,
                  child: ListView.separated(
                    itemCount: state.groups.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, idx) {
                      final g = state.groups[idx];
                      return _GroupRow(
                        group: g,
                        onEdit: () => context.push('/groups/${g.id}'),
                        onDelete: () => _confirmDelete(context, g.id, g.title),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить группу?'),
        content: Text('Удалить «$title»? Это действие нельзя отменить.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<GroupAdminCubit>().delete(id);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}

class _GroupRow extends StatelessWidget {
  const _GroupRow({required this.group, required this.onEdit, required this.onDelete});

  final ProductGroup group;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Thumbnail: image or color box
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: group.imageUrl.isNotEmpty
                ? Image.network(
                    group.imageUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : Container(
                            width: 64,
                            height: 64,
                            color: group.color,
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              ),
                            ),
                          ),
                    errorBuilder: (_, __, ___) => _colorBox(),
                  )
                : _colorBox(),
          ),
          const SizedBox(width: 16),
          // Title + description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '#${group.id}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        group.title,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (group.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    group.description.length > 80
                        ? '${group.description.substring(0, 80)}…'
                        : group.description,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          // Товаров badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${group.productIds.length} товаров',
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ),
          const SizedBox(width: 8),
          // Actions
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            tooltip: 'Редактировать',
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
            tooltip: 'Удалить',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _colorBox() => Container(
        width: 64,
        height: 64,
        color: group.color,
      );
}
