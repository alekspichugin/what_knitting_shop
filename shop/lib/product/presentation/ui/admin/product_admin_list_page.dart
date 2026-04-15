import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/common/breakpoints.dart';
import 'package:shop/common/ui/product_tile.dart';
import 'package:shop/product/data/excel/product_excel_template.dart';
import 'package:shop/product/domain/model/product.dart';
import 'package:shop/product/presentation/bloc/admin/product_admin_cubit.dart';
import 'package:shop/product/presentation/bloc/admin/product_admin_state.dart';
import 'package:shop/product/presentation/ui/admin/product_import_dialog.dart';
import 'package:shop/product_group/domain/model/product_group.dart';
import 'package:shop/product_group/presentation/bloc/admin/group_admin_cubit.dart';
import 'package:shop/product_group/presentation/bloc/admin/group_admin_state.dart';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

class ProductAdminListPage extends StatelessWidget {
  const ProductAdminListPage({super.key});

  void _downloadTemplate() {
    try {
      final bytes = Uint8List.fromList(buildProductImportTemplate());
      if (bytes.isEmpty) throw Exception('Файл шаблона пустой');
      final blob = web.Blob(
        [bytes.toJS].toJS,
        web.BlobPropertyBag(type: 'text/csv;charset=utf-8;'),
      );
      final url = web.URL.createObjectURL(blob);
      final anchor = web.document.createElement('a') as web.HTMLAnchorElement
        ..href = url
        ..download = 'import_template.csv'
        ..style.display = 'none';
      web.document.body!.append(anchor);
      anchor.click();
      anchor.remove();
      web.URL.revokeObjectURL(url);
    } catch (e, st) {
      // ignore: avoid_print
      print('[downloadTemplate] $e\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;
    final pad = mobile ? 16.0 : 32.0;

    return Padding(
      padding: EdgeInsets.all(pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Товары', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (mobile) ...[
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (v) {
                    if (v == 'template') _downloadTemplate();
                    if (v == 'import') showProductImportDialog(context);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'template', child: Text('Скачать шаблон')),
                    PopupMenuItem(value: 'import', child: Text('Импорт CSV')),
                  ],
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => context.push('/products/new'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Добавить'),
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF7C3AED)),
                ),
              ] else ...[
                TextButton.icon(
                  onPressed: _downloadTemplate,
                  icon: const Icon(Icons.download_outlined, size: 18),
                  label: const Text('Шаблон'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => showProductImportDialog(context),
                  icon: const Icon(Icons.upload_file_outlined, size: 18),
                  label: const Text('Импорт'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => context.push('/products/new'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Добавить товар'),
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF7C3AED)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BlocBuilder<ProductAdminCubit, ProductAdminState>(
              builder: (context, productState) {
                if (productState is ProductAdminLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (productState is ProductAdminError) {
                  return Center(child: Text('Ошибка: ${productState.message}'));
                }
                if (productState is! ProductAdminLoaded) return const SizedBox();

                return BlocBuilder<GroupAdminCubit, GroupAdminState>(
                  builder: (context, groupState) {
                    final groups = groupState is GroupAdminLoaded ? groupState.groups : <ProductGroup>[];
                    return _GroupedProductList(
                      products: productState.products,
                      groups: groups,
                      onEdit: (id) => context.push('/products/$id'),
                      onDelete: (id, title) => _confirmDelete(context, id, title),
                    );
                  },
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
        title: const Text('Удалить товар?'),
        content: Text('Удалить «${title.isEmpty ? 'Товар $id' : title}»? Это действие нельзя отменить.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ProductAdminCubit>().delete(id);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _GroupedProductList extends StatelessWidget {
  const _GroupedProductList({
    required this.products,
    required this.groups,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Product> products;
  final List<ProductGroup> groups;
  final void Function(int id) onEdit;
  final void Function(int id, String title) onDelete;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(child: Text('Нет товаров'));
    }

    final productMap = {for (final p in products) p.id: p};

    // Build sections: one per group, then "inactive" (not in any group)
    final assignedIds = <int>{};
    final sections = <({String label, Color? color, String? imageUrl, List<Product> items})>[];

    for (final group in groups) {
      final items = group.productIds
          .where(productMap.containsKey)
          .map((id) => productMap[id]!)
          .toList();
      assignedIds.addAll(group.productIds);
      if (items.isNotEmpty) {
        sections.add((
          label: group.title,
          color: group.color,
          imageUrl: group.imageUrl.isNotEmpty ? group.imageUrl : null,
          items: items,
        ));
      }
    }

    final inactive = products.where((p) => !assignedIds.contains(p.id)).toList();
    if (inactive.isNotEmpty) {
      sections.add((label: 'Не активен', color: Colors.grey, imageUrl: null, items: inactive));
    }

    return ListView.builder(
      itemCount: sections.length,
      itemBuilder: (context, sIdx) {
        final section = sections[sIdx];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (sIdx > 0) const SizedBox(height: 24),
            _SectionHeader(label: section.label, color: section.color, imageUrl: section.imageUrl),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: section.items.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final p = entry.value;
                  return Column(
                    children: [
                      if (idx > 0) const Divider(height: 1),
                      _ProductRow(
                        product: p,
                        onEdit: () => onEdit(p.id),
                        onDelete: () => onDelete(p.id, p.title),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, this.color, this.imageUrl});

  final String label;
  final Color? color;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: imageUrl != null
              ? Image.network(
                  imageUrl!,
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _colorBox(),
                )
              : _colorBox(),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
        ),
      ],
    );
  }

  Widget _colorBox() => Container(width: 28, height: 28, color: color ?? Colors.grey);
}

// ─────────────────────────────────────────────────────────────────────────────

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product, required this.onEdit, required this.onDelete});

  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final descAndPhotos = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (product.description.isNotEmpty)
          Text(
            product.description.length > 80
                ? '${product.description.substring(0, 80)}…'
                : product.description,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        if (product.imageIds.length > 1)
          Text(
            '${product.imageIds.length} фото',
            style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
          ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ProductTile(
        imageIds: product.imageIds,
        title: product.title.isEmpty ? '—' : product.title,
        thumbSize: 56,
        thumbRadius: 6,
        titlePrefix: Text(
          '#${product.id}',
          style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
        ),
        subtitle: (product.description.isNotEmpty || product.imageIds.length > 1)
            ? descAndPhotos
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
      ),
    );
  }
}
