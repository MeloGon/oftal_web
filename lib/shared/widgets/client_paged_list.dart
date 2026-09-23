import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oftal_web/shared/widgets/list_pagination_bar.dart';
import 'package:oftal_web/shared/widgets/paged_list_card.dart';

/// [PagedListCard] + [ListPaginationBar] for lists already fully in memory.
///
/// Goes back to the first page whenever [items] changes content, so a
/// list rebuilt with the same elements keeps the current page.
class ClientPagedList<T> extends StatefulWidget {
  const ClientPagedList({
    super.key,
    required this.items,
    required this.pageSize,
    required this.itemBuilder,
    required this.emptyLabel,
    this.emptyIcon = Icons.inbox_outlined,
    this.isLoading = false,
  });

  final List<T> items;
  final int pageSize;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final String emptyLabel;
  final IconData emptyIcon;
  final bool isLoading;

  @override
  State<ClientPagedList<T>> createState() => _ClientPagedListState<T>();
}

class _ClientPagedListState<T> extends State<ClientPagedList<T>> {
  int _page = 0;

  int get _pageCount =>
      widget.items.isEmpty ? 1 : (widget.items.length / widget.pageSize).ceil();

  @override
  void didUpdateWidget(covariant ClientPagedList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageSize != widget.pageSize ||
        !listEquals(oldWidget.items, widget.items)) {
      _page = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final start = _page * widget.pageSize;
    final end = (start + widget.pageSize).clamp(0, widget.items.length);
    final pageItems = widget.items.sublist(start, end);

    return Column(
      spacing: 8,
      children: [
        Expanded(
          child: PagedListCard<T>(
            items: pageItems,
            itemBuilder: widget.itemBuilder,
            emptyLabel: widget.emptyLabel,
            emptyIcon: widget.emptyIcon,
            isLoading: widget.isLoading,
          ),
        ),
        ListPaginationBar(
          label: 'Página ${_page + 1} de $_pageCount',
          canPrev: _page > 0,
          canNext: _page < _pageCount - 1,
          onPrev: () => setState(() => _page--),
          onNext: () => setState(() => _page++),
        ),
      ],
    );
  }
}
