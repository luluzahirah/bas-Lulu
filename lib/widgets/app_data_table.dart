import 'package:flutter/material.dart';

import '../theme.dart';

/// Kolom definisi untuk [AppDataTable].
class AppDataTableColumn {
  const AppDataTableColumn({
    required this.title,
    this.numeric = false,
    this.width,
  });

  final String title;
  final bool numeric;
  final double? width;
}

/// Baris data untuk [AppDataTable].
class AppDataTableRow {
  const AppDataTableRow({
    required this.cells,
    this.onTap,
    this.color,
  });

  final List<Widget> cells;
  final VoidCallback? onTap;
  final Color? color;
}

/// Komponen DataTable reusable, responsif (scrollable horizontal),
/// dan konsisten dengan tema BAS.
class AppDataTable extends StatelessWidget {
  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.footer,
    this.minWidth = 600,
  });

  final List<AppDataTableColumn> columns;
  final List<AppDataTableRow> rows;
  final Widget? footer;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Horizontal scroll wrapper agar tidak pernah terjadi overflow di mobile
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: minWidth),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFFF1F5F9),
                ),
                headingRowHeight: 46,
                dataRowMinHeight: 46,
                dataRowMaxHeight: 56,
                columnSpacing: 18,
                horizontalMargin: 16,
                dividerThickness: 0.8,
                columns: columns.map((AppDataTableColumn col) {
                  return DataColumn(
                    numeric: col.numeric,
                    label: Text(
                      col.title,
                      style: AppText.body.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                        fontSize: 13,
                      ),
                    ),
                  );
                }).toList(),
                rows: List<DataRow>.generate(rows.length, (int index) {
                  final AppDataTableRow row = rows[index];
                  final bool isEven = index.isEven;
                  return DataRow(
                    color: WidgetStateProperty.all(
                      row.color ??
                          (isEven
                              ? Colors.white
                              : const Color(0xFFF8FAFC)),
                    ),
                    onSelectChanged: row.onTap != null
                        ? (_) => row.onTap!()
                        : null,
                    cells: row.cells.map((Widget cell) {
                      return DataCell(cell);
                    }).toList(),
                  );
                }),
              ),
            ),
          ),
          if (footer != null) ...<Widget>[
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                color: Color(0xFFF8FAFC),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: footer!,
            ),
          ],
        ],
      ),
    );
  }
}
