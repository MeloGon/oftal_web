import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SellFormControllers {
  final search = TextEditingController();
  final searchItemToSell = TextEditingController();
  final import_ = TextEditingController();
  final discount = TextEditingController();
  final total = TextEditingController();
  final account = TextEditingController();
  final rest = TextEditingController();
  final date = TextEditingController();
  DateTime selectedDate = DateTime.now();

  SellFormControllers() {
    date.text = DateFormat('dd-MM-yyyy').format(selectedDate);
  }

  void updateDate(DateTime newDate) {
    selectedDate = newDate;
    date.text = DateFormat('dd-MM-yyyy').format(newDate);
  }

  void clearAll() {
    search.clear();
    searchItemToSell.clear();
    import_.clear();
    discount.clear();
    total.clear();
    account.clear();
    rest.clear();
    selectedDate = DateTime.now();
    date.text = DateFormat('dd-MM-yyyy').format(selectedDate);
  }

  void resetTotals() {
    import_.text = '0';
    discount.text = '0';
    total.text = '0';
    account.text = '0';
    rest.text = '0';
  }

  void dispose() {
    search.dispose();
    searchItemToSell.dispose();
    import_.dispose();
    discount.dispose();
    total.dispose();
    account.dispose();
    rest.dispose();
    date.dispose();
  }
}

final sellFormControllersProvider = Provider.autoDispose<SellFormControllers>((ref) {
  final c = SellFormControllers();
  ref.onDispose(c.dispose);
  return c;
});
