import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SellView extends StatelessWidget {
  const SellView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 50),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: IntrinsicHeight(
        child: ShadCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Vender'),
            ],
          ),
        ),
      ),
    );
  }
}
