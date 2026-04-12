import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shop/admin/ui/admin_colors.dart';
import 'package:shop/product/presentation/bloc/admin/product_admin_cubit.dart';
import 'package:shop/product/presentation/bloc/admin/product_admin_state.dart';
import 'package:shop/product_group/domain/model/product_group.dart';
import 'package:shop/product_group/presentation/bloc/admin/group_admin_cubit.dart';
import 'package:shop/product_group/presentation/bloc/admin/group_admin_state.dart';
import 'package:web/web.dart' as web;

const _cloudinaryCloud = 'db7wmn9yi';
const _cloudinaryPreset = 'what_kniting_products';

class GroupAdminFormPage extends StatefulWidget {
  const GroupAdminFormPage({super.key, this.groupId});
  final int? groupId;

  @override
  State<GroupAdminFormPage> createState() => _GroupAdminFormPageState();
}

class _GroupAdminFormPageState extends State<GroupAdminFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  Color _selectedColor = Colors.orange;
  String _imageUrl = '';
  bool _uploading = false;
  final Set<int> _selectedProductIds = {};
  ProductGroup? _original;
  bool _loaded = false;

  bool get _isNew => widget.groupId == null;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _tryLoadGroup(GroupAdminLoaded state) {
    if (_loaded) return;
    if (!_isNew) {
      final found = state.groups.where((g) => g.id == widget.groupId).firstOrNull;
      if (found != null) {
        _original = found;
        _titleCtrl.text = found.title;
        _descCtrl.text = found.description;
        _selectedColor = found.color;
        _imageUrl = found.imageUrl;
        _selectedProductIds.addAll(found.productIds);
        _loaded = true;
      }
    } else {
      _loaded = true;
    }
  }

  Future<void> _pickAndUpload() async {
    final picked = await _pickImageFile();
    if (picked == null) return;

    setState(() { _uploading = true; });

    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudinaryCloud/image/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _cloudinaryPreset
        ..files.add(http.MultipartFile.fromBytes('file', picked.bytes, filename: picked.name));

      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();

      if (streamed.statusCode == 200) {
        final json = jsonDecode(body) as Map<String, dynamic>;
        final url = json['secure_url'] as String;
        if (mounted) setState(() { _imageUrl = url; _uploading = false; });
      } else {
        if (mounted) setState(() => _uploading = false);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка загрузки изображения')),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _uploading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  Future<({Uint8List bytes, String name})?> _pickImageFile() {
    final completer = Completer<({Uint8List bytes, String name})?>();

    final input = web.document.createElement('input') as web.HTMLInputElement;
    input.type = 'file';
    input.accept = 'image/*';
    input.style.cssText = 'position:fixed;top:-9999px;left:-9999px;width:1px;height:1px;opacity:0;';
    web.document.body!.append(input);

    input.addEventListener('change', (web.Event _) {
      final files = input.files;
      if (files == null || files.length == 0) {
        input.remove();
        if (!completer.isCompleted) completer.complete(null);
        return;
      }
      final file = files.item(0)!;
      final reader = web.FileReader();
      reader.addEventListener('load', (web.Event _) {
        final buffer = (reader.result as JSArrayBuffer).toDart;
        final bytes = buffer.asUint8List();
        input.remove();
        if (!completer.isCompleted) completer.complete((bytes: bytes, name: file.name));
      }.toJS);
      reader.addEventListener('error', (web.Event _) {
        input.remove();
        if (!completer.isCompleted) completer.complete(null);
      }.toJS);
      reader.readAsArrayBuffer(file);
    }.toJS);

    input.click();
    return completer.future;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<GroupAdminCubit>();
    if (_isNew) {
      await cubit.create(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        color: _selectedColor,
        productIds: _selectedProductIds.toList(),
        imageUrl: _imageUrl,
      );
    } else {
      await cubit.update(_original!.copyWith(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        color: _selectedColor,
        productIds: _selectedProductIds.toList(),
        imageUrl: _imageUrl,
      ));
    }
    if (mounted) context.go('/groups');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupAdminCubit, GroupAdminState>(
        builder: (context, groupState) {
            if (groupState is GroupAdminLoaded) _tryLoadGroup(groupState);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(onPressed: () => context.go('/groups'), icon: const Icon(Icons.arrow_back)),
                      const SizedBox(width: 8),
                      Text(
                        _isNew ? 'Новая группа' : 'Редактировать группу',
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
                            TextFormField(
                              controller: _titleCtrl,
                              decoration: const InputDecoration(labelText: 'Название', border: OutlineInputBorder()),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Обязательное поле' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descCtrl,
                              maxLines: 3,
                              decoration: const InputDecoration(labelText: 'Описание', border: OutlineInputBorder()),
                            ),
                            const SizedBox(height: 16),
                            // Image picker
                            const Text('Обложка группы', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 8),
                            if (_imageUrl.isNotEmpty) ...[
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      _imageUrl,
                                      height: 200,
                                      width: 300,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const SizedBox(),
                                    ),
                                  ),
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: GestureDetector(
                                      onTap: () => setState(() => _imageUrl = ''),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                                      ),
                                    ),
                                  ),
                                ],
              ),
                              const SizedBox(height: 8),
                            ],
                            if (_uploading)
                              const Row(
                                children: [
                                  SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF7C3AED))),
                                  SizedBox(width: 8),
                                  Text('Загрузка...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              )
                            else
                              OutlinedButton.icon(
                                onPressed: _pickAndUpload,
                                icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                                label: Text(_imageUrl.isEmpty ? 'Добавить обложку' : 'Заменить'),
                              ),
                            const SizedBox(height: 16),
                            // Color picker
                            const Text('Цвет (используется как фон если нет обложки)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 8),
                            StatefulBuilder(
                              builder: (ctx, setSt) => Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: kAdminColors.entries.map((e) {
                                  final selected = e.value == _selectedColor;
                                  return GestureDetector(
                                    onTap: () => setState(() => _selectedColor = e.value),
                                    child: Tooltip(
                                      message: e.key,
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: e.value,
                                          borderRadius: BorderRadius.circular(8),
                                          border: selected ? Border.all(color: Colors.black87, width: 3) : null,
                                        ),
                                        child: selected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Product multi-select
                            const Text('Товары в группе', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 8),
                            BlocBuilder<ProductAdminCubit, ProductAdminState>(
                              builder: (ctx, productState) {
                                if (productState is! ProductAdminLoaded) {
                                  return const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
                                }
                                return StatefulBuilder(
                                  builder: (ctx2, setSt2) => Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: productState.products.map((p) {
                                      final selected = _selectedProductIds.contains(p.id);
                                      return FilterChip(
                                        label: Text(p.title.isEmpty ? 'Товар ${p.id}' : p.title),
                                        selected: selected,
                                        onSelected: (v) => setState(() {
                                          if (v) {
                                            _selectedProductIds.add(p.id);
                                          } else {
                                            _selectedProductIds.remove(p.id);
                                          }
                                        }),
                                        selectedColor: const Color(0xFFEDE9FE),
                                        checkmarkColor: const Color(0xFF7C3AED),
                                      );
                                    }).toList(),
                                  ),
                                );
                              },
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
                                  onPressed: () => context.go('/groups'),
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
        },
    );
  }
}
