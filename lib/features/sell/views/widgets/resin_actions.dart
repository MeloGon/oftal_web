import 'package:flutter/material.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

class ResinActions extends StatelessWidget {
  final ResinModel resin;
  final Function() onAddToCart;
  const ResinActions({
    super.key,
    required this.resin,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        InkWell(
          onTap: onAddToCart,
          child: Icon(Icons.add_shopping_cart, size: 20),
        ),
      ],
    );
  }
}
