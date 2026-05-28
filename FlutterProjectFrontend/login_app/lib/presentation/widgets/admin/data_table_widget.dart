import 'package:flutter/material.dart';
import 'package:login_app/core/constants/app_colors.dart';

class DataTableWidget extends StatelessWidget {
  final List<String> columns;
  final List<List<String>> rows;
  final List<VoidCallback>? editCallbacks;
  final List<VoidCallback>? deleteCallbacks;

  const DataTableWidget({
    Key? key,
    required this.columns,
    required this.rows,
    this.editCallbacks,
    this.deleteCallbacks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        headingRowHeight: 48,
        headingRowColor:
            WidgetStateColor.resolveWith((_) => AppColors.primary.withValues(alpha: 0.08)),
        dividerThickness: 0.8,
        columns: columns
            .map((column) => DataColumn(
                  label: Text(
                    column,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                ))
            .toList(),
        rows: List.generate(
          rows.length,
          (index) => DataRow(
            color: WidgetStateColor.resolveWith(
              (_) => index.isEven
                  ? Colors.white
                  : AppColors.grey100.withValues(alpha: 0.5),
            ),
            cells: [
              ...rows[index]
                  .map((cell) => DataCell(
                    Text(
                      cell,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ))
                  .toList(),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (editCallbacks != null && index < editCallbacks!.length)
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
                        onPressed: editCallbacks![index],
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                        iconSize: 18,
                      ),
                    if (deleteCallbacks != null && index < deleteCallbacks!.length)
                      IconButton(
                        icon: const Icon(Icons.delete_rounded, color: AppColors.error),
                        onPressed: deleteCallbacks![index],
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                        iconSize: 18,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
