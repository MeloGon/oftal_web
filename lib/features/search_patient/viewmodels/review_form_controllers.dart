import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ReviewFormControllers {
  final reasonConsult = TextEditingController();
  final clinicHistory = TextEditingController();
  final odEsf = TextEditingController();
  final odCil = TextEditingController();
  final odEje = TextEditingController();
  final odAv = TextEditingController();
  final oiEsf = TextEditingController();
  final oiCil = TextEditingController();
  final oiEje = TextEditingController();
  final oiAv = TextEditingController();
  final add = TextEditingController();
  final observationReview = TextEditingController();
  final dip = TextEditingController();
  final odCbLc = TextEditingController();
  final odDiamLc = TextEditingController();
  final oiCbLc = TextEditingController();
  final oiDiamLc = TextEditingController();
  final graduationType = TextEditingController();
  final avSinRxOdLejos = TextEditingController();
  final avSinRxOiLejos = TextEditingController();
  final cvOdLejos = TextEditingController();
  final cvOiLejos = TextEditingController();
  final avSinRxOdCerca = TextEditingController();
  final avSinRxOiCerca = TextEditingController();
  final avConRxOdCerca = TextEditingController();
  final avConRxOiCerca = TextEditingController();
  final optometricDiagnosis = TextEditingController();
  final dateConsult = TextEditingController();
  DateTime selectedConsultDate = DateTime.now();

  void updateConsultDate(DateTime date) {
    selectedConsultDate = date;
    dateConsult.text = DateFormat('dd-MM-yyyy').format(date);
  }

  void clearAll() {
    for (final c in _all) {
      c.clear();
    }
    selectedConsultDate = DateTime.now();
  }

  List<TextEditingController> get _all => [
    reasonConsult, clinicHistory,
    odEsf, odCil, odEje, odAv,
    oiEsf, oiCil, oiEje, oiAv,
    add, observationReview, dip,
    odCbLc, odDiamLc, oiCbLc, oiDiamLc,
    graduationType,
    avSinRxOdLejos, avSinRxOiLejos,
    cvOdLejos, cvOiLejos,
    avSinRxOdCerca, avSinRxOiCerca,
    avConRxOdCerca, avConRxOiCerca,
    optometricDiagnosis, dateConsult,
  ];

  void dispose() {
    for (final c in _all) {
      c.dispose();
    }
  }
}

final reviewFormControllersProvider = Provider.autoDispose<ReviewFormControllers>((ref) {
  final c = ReviewFormControllers();
  ref.onDispose(c.dispose);
  return c;
});
