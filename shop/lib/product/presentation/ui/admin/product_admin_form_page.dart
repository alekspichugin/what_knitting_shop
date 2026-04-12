import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shop/common/cloudinary.dart';
import 'package:shop/product/domain/model/product.dart';
import 'package:shop/product/presentation/bloc/admin/product_admin_cubit.dart';
import 'package:shop/product/presentation/bloc/admin/product_admin_state.dart';
import 'package:shop/product_group/domain/model/product_group.dart';
import 'package:shop/product_group/presentation/bloc/admin/group_admin_cubit.dart';
import 'package:shop/product_group/presentation/bloc/admin/group_admin_state.dart';
import 'package:web/web.dart' as web;

const _cloudinaryCloud = 'db7wmn9yi';
const _cloudinaryPreset = 'what_kniting_products';

class ProductAdminFormPage extends StatefulWidget {
  const ProductAdminFormPage({super.key, this.productId});

  /// null = создание, иначе = редактирование
  final int? productId;

  @override
  State<ProductAdminFormPage> createState() => _ProductAdminFormPageState();
}

class _ProductAdminFormPageState extends State<ProductAdminFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  List<String> _imageIds = [];
  bool _uploading = false;
  int _uploadingCurrent = 0;
  int _uploadingTotal = 0;
  Product? _original;
  bool _loaded = false;
  int? _selectedGroupId;
  bool _groupInitialized = false;

  bool get _isNew => widget.productId == null;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _tryLoadProduct(ProductAdminLoaded state) {
    if (_loaded) return;
    if (!_isNew) {
      final found = state.products.where((p) => p.id == widget.productId).firstOrNull;
      if (found != null) {
        _original = found;
        _titleCtrl.text = found.title;
        _descCtrl.text = found.description;
        _imageIds = List.from(found.imageIds);
        _loaded = true;
      }
    } else {
      _loaded = true;
    }
  }

  void _tryInitGroup(GroupAdminLoaded state) {
    if (_groupInitialized || _original == null) return;
    final group = state.groups.firstWhereOrNull((g) => g.productIds.contains(_original!.id));
    _selectedGroupId = group?.id;
    _groupInitialized = true;
  }

  Future<void> _pickAndUpload() async {
    final picked = await _pickImageFiles();
    if (picked.isEmpty) return;

    setState(() {
      _uploading = true;
      _uploadingCurrent = 0;
      _uploadingTotal = picked.length;
    });

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudinaryCloud/image/upload');
    int failed = 0;

    for (final file in picked) {
      if (!mounted) break;
      setState(() => _uploadingCurrent++);
      try {
        final request = http.MultipartRequest('POST', uri)
          ..fields['upload_preset'] = _cloudinaryPreset
          ..files.add(http.MultipartFile.fromBytes('file', file.bytes, filename: file.name));

        final streamed = await request.send();
        final body = await streamed.stream.bytesToString();

        if (streamed.statusCode == 200) {
          final json = jsonDecode(body) as Map<String, dynamic>;
          final publicId = json['public_id'] as String;
          if (mounted) setState(() => _imageIds.add(publicId));
        } else {
          failed++;
        }
      } catch (_) {
        failed++;
      }
    }

    if (mounted) {
      setState(() { _uploading = false; _uploadingCurrent = 0; _uploadingTotal = 0; });
      if (failed > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось загрузить: $failed из ${picked.length}')),
        );
      }
    }
  }

  Future<List<({Uint8List bytes, String name})>> _pickImageFiles() {
    final completer = Completer<List<({Uint8List bytes, String name})>>();

    final input = web.document.createElement('input') as web.HTMLInputElement;
    input.type = 'file';
    input.accept = 'image/*';
    input.multiple = true;
    input.style.cssText = 'position:fixed;top:-9999px;left:-9999px;width:1px;height:1px;opacity:0;';
    web.document.body!.append(input);

    input.addEventListener('change', (web.Event _) {
      final files = input.files;
      if (files == null || files.length == 0) {
        input.remove();
        if (!completer.isCompleted) completer.complete([]);
        return;
      }

      final futures = <Future<({Uint8List bytes, String name})>>[];
      for (var i = 0; i < files.length; i++) {
        final file = files.item(i)!;
        final c = Completer<({Uint8List bytes, String name})>();
        final reader = web.FileReader();
        reader.addEventListener('load', (web.Event _) {
          final buffer = (reader.result as JSArrayBuffer).toDart;
          c.complete((bytes: buffer.asUint8List(), name: file.name));
        }.toJS);
        reader.addEventListener('error', (web.Event _) {
          c.completeError('read error');
        }.toJS);
        reader.readAsArrayBuffer(file);
        futures.add(c.future);
      }

      Future.wait(futures, eagerError: false).then((results) {
        input.remove();
        if (!completer.isCompleted) completer.complete(results);
      }).catchError((_) {
        input.remove();
        if (!completer.isCompleted) completer.complete([]);
      });
    }.toJS);

    input.click();
    return completer.future;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final productCubit = context.read<ProductAdminCubit>();
    final groupCubit = context.read<GroupAdminCubit>();
    final groupState = groupCubit.state;
    final groups = groupState is GroupAdminLoaded ? groupState.groups : <ProductGroup>[];

    if (_isNew) {
      final product = await productCubit.create(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        imageIds: _imageIds,
      );
      if (_selectedGroupId != null) {
        final group = groups.firstWhereOrNull((g) => g.id == _selectedGroupId);
        if (group != null && !group.productIds.contains(product.id)) {
          await groupCubit.update(group.copyWith(
            productIds: [...group.productIds, product.id],
          ));
        }
      }
    } else {
      await productCubit.update(_original!.copyWith(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        imageIds: _imageIds,
      ));

      final oldGroup = groups.firstWhereOrNull((g) => g.productIds.contains(_original!.id));
      if (oldGroup?.id != _selectedGroupId) {
        if (oldGroup != null) {
          await groupCubit.update(oldGroup.copyWith(
            productIds: oldGroup.productIds.where((id) => id != _original!.id).toList(),
          ));
        }
        if (_selectedGroupId != null) {
          final newGroup = groups.firstWhereOrNull((g) => g.id == _selectedGroupId);
          if (newGroup != null && !newGroup.productIds.contains(_original!.id)) {
            await groupCubit.update(newGroup.copyWith(
              productIds: [...newGroup.productIds, _original!.id],
            ));
          }
        }
      }
    }

    if (mounted) context.go('/products');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupAdminCubit, GroupAdminState>(
      builder: (context, groupState) {
        if (groupState is GroupAdminLoaded && _loaded) _tryInitGroup(groupState);

        return BlocBuilder<ProductAdminCubit, ProductAdminState>(
          builder: (context, state) {
            if (state is ProductAdminLoaded) {
              _tryLoadProduct(state);
              if (groupState is GroupAdminLoaded) _tryInitGroup(groupState);
            }

            final groups = groupState is GroupAdminLoaded ? groupState.groups : <ProductGroup>[];

            return _buildContent(groups);
          },
        );
      },
    );
  }

  Widget _buildContent(List<ProductGroup> groups) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.go('/products'),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 8),
              Text(
                _isNew ? 'Новый товар' : 'Редактировать товар',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _field(controller: _titleCtrl, label: 'Название', required: true),
                    const SizedBox(height: 16),
                    _field(controller: _descCtrl, label: 'Описание', maxLines: 4),
                    const SizedBox(height: 16),
                    _MultiImagePicker(
                      imageIds: _imageIds,
                      uploading: _uploading,
                      uploadingCurrent: _uploadingCurrent,
                      uploadingTotal: _uploadingTotal,
                      onAdd: _pickAndUpload,
                      onRemove: (i) => setState(() => _imageIds.removeAt(i)),
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex--;
                          final item = _imageIds.removeAt(oldIndex);
                          _imageIds.insert(newIndex, item);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _GroupDropdown(
                      groups: groups,
                      selectedGroupId: _selectedGroupId,
                      onChanged: (id) => setState(() => _selectedGroupId = id),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        FilledButton(
                          onPressed: _uploading ? null : _save,
                          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF7C3AED)),
                          child: const Text('Сохранить'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () => context.go('/products'),
                          child: const Text('Отмена'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    bool required = false,
    int maxLines = 1,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Обязательное поле' : null : null,
    );
  }
}

// =============================================================================

class _MultiImagePicker extends StatelessWidget {
  const _MultiImagePicker({
    required this.imageIds,
    required this.uploading,
    required this.uploadingCurrent,
    required this.uploadingTotal,
    required this.onAdd,
    required this.onRemove,
    required this.onReorder,
  });

  final List<String> imageIds;
  final bool uploading;
  final int uploadingCurrent;
  final int uploadingTotal;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Фотографии', style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        if (imageIds.isNotEmpty) ...[
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: imageIds.length,
            onReorder: onReorder,
            itemBuilder: (context, i) {
              return Padding(
                key: ValueKey(imageIds[i]),
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    ReorderableDragStartListener(
                      index: i,
                      child: const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(Icons.drag_handle, color: Colors.grey),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        cloudinaryUrl(imageIds[i], size: CloudinarySize.thumbnail),
                        width: 80,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 60,
                          color: const Color(0xFFF3F4F6),
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (i == 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Главное',
                          style: TextStyle(fontSize: 11, color: Color(0xFF7C3AED)),
                        ),
                      ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => onRemove(i),
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 4),
        ],
        if (uploading)
          Row(
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF7C3AED)),
              ),
              const SizedBox(width: 8),
              Text(
                uploadingTotal > 1
                    ? 'Загрузка $uploadingCurrent из $uploadingTotal...'
                    : 'Загрузка...',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          )
        else
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
            label: Text(imageIds.isEmpty ? 'Добавить фото' : 'Добавить ещё'),
          ),
      ],
    );
  }
}

// =============================================================================

class _GroupDropdown extends StatelessWidget {
  const _GroupDropdown({
    required this.groups,
    required this.selectedGroupId,
    required this.onChanged,
  });

  final List<ProductGroup> groups;
  final int? selectedGroupId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final validIds = {null, ...groups.map((g) => g.id)};
    final safeValue = validIds.contains(selectedGroupId) ? selectedGroupId : null;

    return DropdownButtonFormField<int?>(
      value: safeValue,
      decoration: const InputDecoration(
        labelText: 'Группа товаров',
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<int?>(
          value: null,
          child: Text('Не активен'),
        ),
        ...groups.map((g) => DropdownMenuItem<int?>(
              value: g.id,
              child: Text(g.title),
            )),
      ],
      onChanged: onChanged,
    );
  }
}
