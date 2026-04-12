import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/news/presentation/bloc/admin/news_admin_cubit.dart';
import 'package:shop/news/presentation/bloc/admin/news_admin_state.dart';

class NewsAdminListPage extends StatelessWidget {
  const NewsAdminListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Информация', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => context.push('/news/new'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Добавить'),
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF7C3AED)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: BlocBuilder<NewsAdminCubit, NewsAdminState>(
                builder: (context, state) {
                  if (state is NewsAdminLoading) return const Center(child: CircularProgressIndicator());
                  if (state is NewsAdminError) return Center(child: Text('Ошибка: ${state.message}'));
                  if (state is NewsAdminLoaded) {
                    if (state.news.isEmpty) return const Center(child: Text('Нет записей'));
                    return Card(
                      elevation: 1,
                      clipBehavior: Clip.antiAlias,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columnSpacing: 24,
                          columns: const [
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('Заголовок')),
                            DataColumn(label: Text('Описание')),
                            DataColumn(label: Text('Дата')),
                            DataColumn(label: Text('Цвет')),
                            DataColumn(label: Text('Действия')),
                          ],
                          rows: state.news.map((n) {
                            final dateStr = '${n.date.day.toString().padLeft(2, '0')}.${n.date.month.toString().padLeft(2, '0')}.${n.date.year}';
                            return DataRow(cells: [
                              DataCell(Text(n.id.toString())),
                              DataCell(Text(n.title)),
                              DataCell(Text(n.description.length > 40 ? '${n.description.substring(0, 40)}…' : n.description)),
                              DataCell(Text(dateStr)),
                              DataCell(Container(
                                width: 20, height: 20,
                                decoration: BoxDecoration(color: n.color, borderRadius: BorderRadius.circular(4)),
                              )),
                              DataCell(Row(children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  tooltip: 'Редактировать',
                                  onPressed: () => context.push('/news/${n.id}'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                  tooltip: 'Удалить',
                                  onPressed: () => _confirmDelete(context, n.id, n.title),
                                ),
                              ])),
                            ]);
                          }).toList(),
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
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
        title: const Text('Удалить новость?'),
        content: Text('Удалить «$title»? Это действие нельзя отменить.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<NewsAdminCubit>().delete(id);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
