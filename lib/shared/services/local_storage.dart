import 'dart:convert';

import 'package:oftal_web/shared/models/profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static late SharedPreferences prefs;

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveToken(String token) async {
    await prefs.setString('token', token);
  }

  static Future<void> saveProfile(ProfileModel profile) async {
    await prefs.setString('profile', jsonEncode(profile.toJson()));
  }

  static Future<ProfileModel> getProfile() async {
    final profile = prefs.getString('profile');
    return profile != null
        ? ProfileModel.fromJson(jsonDecode(profile))
        : ProfileModel();
  }
}
