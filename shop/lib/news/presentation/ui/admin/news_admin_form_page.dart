import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/admin/ui/admin_colors.dart';
import 'package:shop/news/domain/model/news_item.dart';
import 'package:shop/news/presentation/bloc/admin/news_admin_cubit.dart';
import 'package:shop/news/presentation/bloc/admin/news_admin_state.dart';

class NewsAdminFormPage extends StatefulWidget {
  const NewsAdminFormPage({super.key, this.newsId});
  final int? newsId;

  @override
  State<NewsAdminFormPage> createState() => _NewsAdminFormPageState();
}

class _NewsAdminFormPageState extends State<NewsAdminFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  Color _selectedColor = Colors.redAccent;
  DateTime _selectedDate = DateTime.now();
  NewsItem? _original;
  bool _loaded = false;

  bool get _isNew => widget.newsId == null;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _tryLoad(NewsAdminLoaded state) {
    if (_loaded) return;
    if (!_isNew) {
      final found = state.news.where((n) => n.id == widget.newsId).firstOrNull;
      if (found != null) {
        _original = found;
        _titleCtrl.text = found.title;
        _descCtrl.text = found.description;
        _selectedColor = found.color;
        _selectedDate = found.date;
        _loaded = true;
      }
    } else {
      _loaded = true;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<NewsAdminCubit>();
    if (_isNew) {
      await cubit.create(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        date: _selectedDate,
        color: _selectedColor,
      );
    } else {
      await cubit.update(_original!.copyWith(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        date: _selectedDate,
        color: _selectedColor,
      ));
    }
    if (mounted) context.go('/news');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewsAdminCubit, NewsAdminState>(
        builder: (context, state) {
          if (state is NewsAdminLoaded) _tryLoad(state);

          final dateStr = '${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(onPressed: () => context.go('/news'), icon: const Icon(Icons.arrow_back)),
                    const SizedBox(width: 8),
                    Text(
                      _isNew ? 'Новая запись' : 'Редактировать запись',
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
                            decoration: const InputDecoration(labelText: 'Заголовок', border: OutlineInputBorder()),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Обязательное поле' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descCtrl,
                            maxLines: 4,
                            decoration: const InputDecoration(labelText: 'Описание', border: OutlineInputBorder()),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Обязательное поле' : null,
                          ),
                          const SizedBox(height: 16),
                          // Date picker
                          Row(
                            children: [
                              Expanded(
                                child: InputDecorator(
                                  decoration: const InputDecoration(labelText: 'Дата', border: OutlineInputBorder()),
                                  child: Text(dateStr),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                onPressed: _pickDate,
                                icon: const Icon(Icons.calendar_today, size: 16),
                                label: const Text('Выбрать'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Color picker
                          const Text('Цвет', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 8),
                          Wrap(
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
                          const SizedBox(height: 28),
                          Row(
                            children: [
                              FilledButton(
                                onPressed: _save,
                                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF7C3AED)),
                                child: const Text('Сохранить'),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton(
                                onPressed: () => context.go('/news'),
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
