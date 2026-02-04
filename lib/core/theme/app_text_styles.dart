import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AppTextStyles {
  final BuildContext context;

  AppTextStyles(this.context);

  TextStyle get small12 => ShadTheme.of(context).textTheme.small.copyWith(
    fontSize: 12,
    fontFamily: GoogleFonts.poppins().fontFamily,
  );

  TextStyle get small13 => ShadTheme.of(context).textTheme.small.copyWith(
    fontSize: 13,
    fontFamily: GoogleFonts.poppins().fontFamily,
  );

  TextStyle get small13Bold => ShadTheme.of(context).textTheme.small.copyWith(
    fontSize: 13,
    fontFamily: GoogleFonts.poppins().fontFamily,
    fontWeight: FontWeight.bold,
  );

  TextStyle get small14Bold => ShadTheme.of(context).textTheme.small.copyWith(
    fontSize: 14,
    fontFamily: GoogleFonts.poppins().fontFamily,
    fontWeight: FontWeight.bold,
  );

  TextStyle get small => ShadTheme.of(context).textTheme.small.copyWith(
    fontFamily: GoogleFonts.poppins().fontFamily,
  );

  TextStyle get large => ShadTheme.of(context).textTheme.large.copyWith(
    fontFamily: GoogleFonts.poppins().fontFamily,
  );

  TextStyle get largeBold => ShadTheme.of(context).textTheme.large.copyWith(
    fontFamily: GoogleFonts.poppins().fontFamily,
    fontWeight: FontWeight.bold,
  );
}
