import 'dart:convert';
import 'package:csv/csv.dart';

class ProductDraft {
  const ProductDraft({
    required this.title,
    required this.description,
    required this.imageIds,
  });

  final String title;
  final String description;
  final List<String> imageIds;
}

class ProductExcelParseResult {
  const ProductExcelParseResult({
    required this.drafts,
    required this.skippedRows,
  });

  final List<ProductDraft> drafts;
  final List<({int row, String reason})> skippedRows;
}


ProductExcelParseResult parseProductExcel(List<int> bytes) {
  final str = utf8.decode(bytes);

  final List<List<dynamic>> rows = const CsvToListConverter().convert(str);
  print('parseProductExcel str $str');
  print('parseProductExcel rows length ${rows.length}, rows $rows');
  final products = <ProductDraft>[];
  for (final row in rows.skip(1)) {
    print('row str $row');
    try {
      products.add(ProductDraft(
          title: row[0] as String,
          description: row[1] as String,
          imageIds: []));
    } catch (e, s) {
      print('parseProductExcel error: $e, stackTrace: $s');
    }
  }
  print('products ${products.length}');

  return ProductExcelParseResult(drafts: products, skippedRows: []);
}

/// Парсит байты .csv и возвращает [ProductExcelParseResult].
/// Первая строка — заголовок, пропускается.
/// Строки без title пропускаются с указанием причины.
// ProductExcelParseResult parseProductExcel(List<int> bytes) {
//   // Убираем BOM (\uFEFF), который Excel добавляет при сохранении UTF-8 CSV
//   final content = utf8.decode(bytes, allowMalformed: true).replaceFirst('\uFEFF', '');
//   print('OLOLO content ${content}');
//   final lines = content
//       .replaceAll('\r\n', '\n')
//       .replaceAll('\r', '\n')
//       .split('\n')
//       .where((l) => l.trim().isNotEmpty)
//       .toList();

//   if (lines.isEmpty) {
//     return const ProductExcelParseResult(drafts: [], skippedRows: []);
//   }

//   // Автодетект разделителя: Excel в русской локали сохраняет CSV с ; вместо ,
//   final delimiter = ';'; //lines.first.contains(';') ? ';' : ',';

//   // Определяем индексы колонок по Product.importFields
//   final headerCells = _splitCsvRow(lines.first, delimiter);
//   print('OLOLO headerCells ${headerCells}, lines ${lines.length}');
//   final colIndex = <String, int>{};
//   for (var i = 0; i < headerCells.length; i++) {
//     final h = headerCells[i].trim().toLowerCase();
//     for (final field in Product.importFields) {
//       if (h == field.toLowerCase()) colIndex[field] = i;
//     }
//   }

//   if (!colIndex.containsKey('title')) {
//     return const ProductExcelParseResult(
//       drafts: [],
//       skippedRows: [(row: 1, reason: 'Колонка title не найдена')],
//     );
//   }

//   final drafts = <ProductDraft>[];
//   final skipped = <({int row, String reason})>[];

//   for (var i = 1; i < lines.length; i++) {
//     final cells = _splitCsvRow(lines[i], delimiter);
//     final rowNum = i + 1;

//     String cell(String field) {
//       final idx = colIndex[field];
//       if (idx == null || idx >= cells.length) return '';
//       return cells[idx].trim();
//     }

//     final title = cell('title');
//     if (title.isEmpty) {
//       skipped.add((row: rowNum, reason: 'Пустой title'));
//       continue;
//     }

//     final imageIdsRaw = cell('imageIds');
//     final imageIds = imageIdsRaw.isEmpty
//         ? <String>[]
//         : imageIdsRaw
//             .split(',')
//             .map((u) => u.trim())
//             .where((u) => u.isNotEmpty)
//             .toList();

//     drafts.add(ProductDraft(
//       title: title,
//       description: cell('description'),
//       imageIds: imageIds,
//     ));
//   }

//   return ProductExcelParseResult(drafts: drafts, skippedRows: skipped);
// }

/// Разбивает строку CSV с учётом кавычек.
List<String> _splitCsvRow(String row, String delimiter) {
  final cells = <String>[];
  final buf = StringBuffer();
  var inQuotes = false;

  for (var i = 0; i < row.length; i++) {
    final ch = row[i];
    if (ch == '"') {
      if (inQuotes && i + 1 < row.length && row[i + 1] == '"') {
        buf.write('"');
        i++;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (!inQuotes && row.startsWith(delimiter, i)) {
      cells.add(buf.toString());
      buf.clear();
      i += delimiter.length - 1;
    } else {
      buf.write(ch);
    }
  }
  cells.add(buf.toString());
  return cells;
}
