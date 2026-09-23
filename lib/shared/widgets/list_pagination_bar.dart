import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// "Página N  ‹ ›" row shown under paged lists.
///
/// Pass [pageSizes] + [pageSize] + [onPageSizeChanged] to also show a
/// rows-per-page selector.
class ListPaginationBar extends StatelessWidget {
  const ListPaginationBar({
    super.key,
    required this.label,
    required this.canPrev,
    required this.canNext,
    required this.onPrev,
    required this.onNext,
    this.pageSizes,
    this.pageSize,
    this.onPageSizeChanged,
  });

  final String label;
  final bool canPrev;
  final bool canNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final List<int>? pageSizes;
  final int? pageSize;
  final ValueChanged<int>? onPageSizeChanged;

  @override
  Widget build(BuildContext context) {
    final showSizes = pageSizes != null &&
        pageSize != null &&
        onPageSizeChanged != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (showSizes) ...[
          Text(
            'Filas por página',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 8),
          ShadSelect<int>(
            minWidth: 72,
            initialValue: pageSize,
            onChanged: (v) {
              if (v != null) onPageSizeChanged!(v);
            },
            options: pageSizes!
                .map((s) => ShadOption(value: s, child: Text('$s')))
                .toList(),
            selectedOptionBuilder: (_, v) => Text('$v'),
          ),
          const SizedBox(width: 16),
        ],
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 12),
        ShadButton.outline(
          size: ShadButtonSize.sm,
          enabled: canPrev,
          onPressed: onPrev,
          child: const Icon(Icons.chevron_left, size: 16),
        ),
        const SizedBox(width: 6),
        ShadButton.outline(
          size: ShadButtonSize.sm,
          enabled: canNext,
          onPressed: onNext,
          child: const Icon(Icons.chevron_right, size: 16),
        ),
      ],
    );
  }
}
