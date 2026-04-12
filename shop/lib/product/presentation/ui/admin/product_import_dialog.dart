import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/product/data/excel/product_excel_parser.dart';
import 'package:shop/product/presentation/bloc/admin/product_admin_cubit.dart';
import 'package:shop/product/presentation/bloc/admin/product_admin_state.dart';

/// Открывает диалог импорта товаров из Excel.
/// Возвращает true, если импорт был выполнен (даже частично).
Future<bool> showProductImportDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => BlocProvider.value(
          value: context.read<ProductAdminCubit>(),
          child: const _ProductImportDialog(),
        ),
      ) ??
      false;
}

class _ProductImportDialog extends StatefulWidget {
  const _ProductImportDialog();

  @override
  State<_ProductImportDialog> createState() => _ProductImportDialogState();
}

class _ProductImportDialogState extends State<_ProductImportDialog> {
  _Step _step = _Step.pick;
  ProductExcelParseResult? _parsed;
  String? _pickError;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductAdminCubit, ProductAdminState>(
      listener: (context, state) {
        if (state is ProductAdminImportDone) {
          setState(() => _step = _Step.done);
        }
      },
      child: AlertDialog(
        title: const Text('Импорт товаров'),
        content: SizedBox(
          width: 480,
          child: _buildContent(),
        ),
        actions: _buildActions(),
      ),
    );
  }

  Widget _buildContent() {
    return switch (_step) {
      _Step.pick => _PickStep(error: _pickError),
      _Step.preview => _PreviewStep(parsed: _parsed!),
      _Step.importing => BlocBuilder<ProductAdminCubit, ProductAdminState>(
          builder: (_, state) {
            if (state is ProductAdminImporting) {
              return _ImportingStep(current: state.current, total: state.total);
            }
            return const _ImportingStep(current: 0, total: 0);
          },
        ),
      _Step.done => BlocBuilder<ProductAdminCubit, ProductAdminState>(
          builder: (_, state) {
            if (state is ProductAdminImportDone) {
              return _DoneStep(created: state.created, failed: state.failed);
            }
            // Уже перешли в Loaded после reload — показываем последний результат
            return const _DoneStep(created: 0, failed: 0);
          },
        ),
    };
  }

  List<Widget> _buildActions() {
    return switch (_step) {
      _Step.pick => [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: _pickFile,
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF7C3AED)),
            child: const Text('Выбрать файл'),
          ),
        ],
      _Step.preview => [
          TextButton(
            onPressed: () => setState(() {
              _step = _Step.pick;
              _parsed = null;
              _pickError = null;
            }),
            child: const Text('Назад'),
          ),
          FilledButton(
            onPressed: _parsed!.drafts.isEmpty ? null : _startImport,
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF7C3AED)),
            child: Text('Создать ${_parsed!.drafts.length} товаров'),
          ),
        ],
      _Step.importing => [],
      _Step.done => [
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF7C3AED)),
            child: const Text('Готово'),
          ),
        ],
    };
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );

    if (result == null || result.files.single.bytes == null) return;

    try {
      final parsed = parseProductExcel(result.files.single.bytes!);
      setState(() {
        _parsed = parsed;
        _step = _Step.preview;
        _pickError = null;
      });
    } catch (e) {
      setState(() => _pickError = 'Не удалось прочитать файл: $e');
    }
  }

  void _startImport() {
    setState(() => _step = _Step.importing);
    context.read<ProductAdminCubit>().importProducts(_parsed!.drafts);
  }
}

// ─────────────────────────────────────────────────────────────────────────────

enum _Step { pick, preview, importing, done }

// ─────────────────────────────────────────────────────────────────────────────

class _PickStep extends StatelessWidget {
  const _PickStep({this.error});
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.upload_file_outlined, size: 48, color: Color(0xFF7C3AED)),
        const SizedBox(height: 12),
        const Text(
          'Выберите файл .csv с товарами.\nОжидаемые колонки: title, description, imageIds.',
          textAlign: TextAlign.center,
        ),
        if (error != null) ...[
          const SizedBox(height: 12),
          Text(error!, style: const TextStyle(color: Colors.red)),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PreviewStep extends StatelessWidget {
  const _PreviewStep({required this.parsed});
  final ProductExcelParseResult parsed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoRow(
          icon: Icons.check_circle_outline,
          color: Colors.green,
          text: 'Готово к созданию: ${parsed.drafts.length} товаров',
        ),
        if (parsed.skippedRows.isNotEmpty) ...[
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.warning_amber_outlined,
            color: Colors.orange,
            text: 'Пропущено строк: ${parsed.skippedRows.length}',
          ),
          const SizedBox(height: 4),
          ...parsed.skippedRows.map(
            (s) => Padding(
              padding: const EdgeInsets.only(left: 28, top: 2),
              child: Text(
                'Строка ${s.row}: ${s.reason}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ),
          ),
        ],
        if (parsed.drafts.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              'Нет строк для импорта.',
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ImportingStep extends StatelessWidget {
  const _ImportingStep({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? current / total : 0.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          color: const Color(0xFF7C3AED),
        ),
        const SizedBox(height: 12),
        Text('Создаётся $current из $total...'),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DoneStep extends StatelessWidget {
  const _DoneStep({required this.created, required this.failed});
  final int created;
  final int failed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.task_alt, size: 48, color: Colors.green),
        const SizedBox(height: 12),
        Text(
          'Создано товаров: $created',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        if (failed > 0) ...[
          const SizedBox(height: 4),
          Text(
            'Не удалось создать: $failed',
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.color, required this.text});
  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}
