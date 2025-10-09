import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/features/sell/viewmodels/sell_provider.dart';
import 'package:oftal_web/features/sell/views/widgets/label_item_to_add_cart.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ItemToAddCart extends ConsumerWidget {
  const ItemToAddCart({super.key, this.mount, this.resin});
  final MountModel? mount;
  final ResinModel? resin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (mount != null) {
      return ListTile(
        title: LabelItemToAddCart(
          title: 'Marca',
          content: mount?.brand.toUpperCase() ?? '',
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LabelItemToAddCart(
              title: 'Modelo',
              content: mount?.model.toUpperCase() ?? '',
            ),
            LabelItemToAddCart(
              title: 'Existencias',
              content: mount?.stock.toString() ?? '',
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            Text(
              's/. ${mount?.price.toStringAsFixed(2) ?? ''}',
              style: ShadTheme.of(context).textTheme.large,
            ),
            ShadIconButton(
              icon: Icon(Icons.add_shopping_cart),
              onPressed: () {
                ref.read(sellProvider.notifier).selectItemToSell(mount!);
              },
            ),
          ],
        ),
      );
    } else {
      return ListTile(
        title: LabelItemToAddCart(
          title: 'Resina',
          content: resin?.description!.toUpperCase() ?? '',
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LabelItemToAddCart(
              title: 'Diseño',
              content: resin?.design!.toUpperCase() ?? '',
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            Text(
              's/. ${resin?.price?.toStringAsFixed(2) ?? ''}',
              style: ShadTheme.of(context).textTheme.large,
            ),
            ShadIconButton(
              icon: Icon(Icons.add_shopping_cart),
              onPressed: () {
                ref.read(sellProvider.notifier).selectItemToSell(resin!);
              },
            ),
          ],
        ),
      );
    }
  }
}
