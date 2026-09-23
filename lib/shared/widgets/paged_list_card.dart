import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Card with a divided list of tiles, plus loading and empty states.
class PagedListCard<T> extends StatelessWidget {
  const PagedListCard({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.emptyLabel,
    this.emptyIcon = Icons.inbox_outlined,
    this.isLoading = false,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final String emptyLabel;
  final IconData emptyIcon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      padding: EdgeInsets.zero,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: [
                      Icon(emptyIcon, size: 36, color: Colors.grey.shade300),
                      Text(
                        emptyLabel,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) => itemBuilder(context, items[i]),
                ),
    );
  }
}
