import 'package:flutter/material.dart';

class LoadingDialog {
  Future<void> show(BuildContext context) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,

      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: SizedBox.square(
            dimension: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SizedBox(
                  width: 55,
                  height: 55,
                  child: CircularProgressIndicator(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
