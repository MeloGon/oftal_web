import 'package:flutter/material.dart';
import 'package:oftal_web/features/sell/views/widgets/label_item_to_add_cart.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ItemToAddCart extends StatelessWidget {
  const ItemToAddCart({super.key, required this.mount});
  final MountModel mount;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: LabelItemToAddCart(
        title: 'Marca',
        content: mount.brand.toUpperCase(),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabelItemToAddCart(
            title: 'Modelo',
            content: mount.model.toUpperCase(),
          ),
          LabelItemToAddCart(
            title: 'Existencias',
            content: mount.stock.toString(),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Text(
            's/. ${mount.price.toStringAsFixed(2)}',
            style: ShadTheme.of(context).textTheme.large,
          ),
          ShadIconButton(
            icon: Icon(Icons.add_shopping_cart),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
