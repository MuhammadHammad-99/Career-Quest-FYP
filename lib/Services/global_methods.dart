import 'dart:convert';
import 'dart:io';

import 'package:career_quest/cv/cv_input_from_user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

class TokenManager {
  static FlutterSecureStorage storage = const FlutterSecureStorage();

  static Future<String?> getAccessToken() async {
    return await storage.read(key: 'accessToken');
  }

  static void saveAccessToken(String token) {
    const storage = FlutterSecureStorage();
    storage.write(key: 'accessToken', value: token);
  }

  static void deleteAccessToken() async {
    await storage.delete(key: 'accessToken');
  }

  static void saveCVDP(File file) {
    const storage = FlutterSecureStorage();
    storage.write(key: 'cv_dp', value: file.path);
  }

  static Future<String?> getCVDp() async {
    return await storage.read(key: 'cv_dp');
  }

  static void saveCVName(String name) {
    const storage = FlutterSecureStorage();
    storage.write(key: 'cv_name', value: name);
  }

  static Future<String?> getCVName() async {
    return await storage.read(key: 'cv_name');
  }

  static void saveCVOccupation(String occ) {
    const storage = FlutterSecureStorage();
    storage.write(key: 'cv_occ', value: occ);
  }

  static Future<String?> getCVOccupation() async {
    return await storage.read(key: 'cv_occ');
  }

  static void saveCVLocation(String loc) {
    const storage = FlutterSecureStorage();
    storage.write(key: 'cv_location', value: loc);
  }

  static Future<String?> getCVLocation() async {
    return await storage.read(key: 'cv_location');
  }

  static void saveCVDescription(String desc) {
    const storage = FlutterSecureStorage();
    storage.write(key: 'cv_desc', value: desc);
  }

  static Future<String?> getCVDescription() async {
    return await storage.read(key: 'cv_desc');
  }

  static void saveCVEmail(String email) {
    const storage = FlutterSecureStorage();
    storage.write(key: 'cv_email', value: email);
  }

  static Future<String?> getCVEmail() async {
    return await storage.read(key: 'cv_email');
  }

  static void setOnboardingStatus(String value) {
    const storage = FlutterSecureStorage();
    storage.write(key: 'onboardingStatus', value: value);
  }

  static Future<String?> getOnboardingStatus() async {
    return await storage.read(key: 'onboardingStatus');
  }

  static void saveContact(String contact) {
    const storage = FlutterSecureStorage();
    storage.write(key: 'cv_contact', value: contact);
  }

  static Future<String?> getCVContact() async {
    return await storage.read(key: 'cv_contact');
  }

  static Future<List<SkillsModel>> getSkills() async {
    final String? storedObjects = await storage.read(key: 'skills');

    if (storedObjects != null) {
      Iterable decoded = jsonDecode(storedObjects);
      if (decoded is List) {
        List<SkillsModel> loadedSkills = decoded
            .map<SkillsModel>((e) => SkillsModel.fromJson(jsonDecode(e)))
            .toList();

        return loadedSkills;
      } else {
        print('Unexpected format for stored skills');
        return [];
      }
      // List<SkillsModel> loadedObjects =
      //     decoded.map((e) => SkillsModel.fromJson(e)).toList();
    } else {
      return [];
    }
  }

  static Future<void> saveSkills(List<SkillsModel> skillsList) async {
    const storage = FlutterSecureStorage();
    List<String> encodedObjects =
        skillsList.map((e) => jsonEncode(e.toJson())).toList();
    await storage.write(key: 'skills', value: jsonEncode(encodedObjects));
  }

  static Future<List<ExperienceModel>> getExp() async {
    final String? storedObjects = await storage.read(key: 'exp');

    if (storedObjects != null) {
      Iterable decoded = jsonDecode(storedObjects);
      if (decoded is List) {
        List<ExperienceModel> loadedSkills = decoded
            .map<ExperienceModel>(
                (e) => ExperienceModel.fromJson(jsonDecode(e)))
            .toList();
        return loadedSkills;
      } else {
        print('Unexpected format for stored skills');
        return [];
      }
      // List<SkillsModel> loadedObjects =
      //     decoded.map((e) => SkillsModel.fromJson(e)).toList();
    } else {
      return [];
    }
  }

  static Future<void> saveExp(List<ExperienceModel> expList) async {
    const storage = FlutterSecureStorage();
    List<String> encodedObjects =
        expList.map((e) => jsonEncode(e.toJson())).toList();
    await storage.write(key: 'exp', value: jsonEncode(encodedObjects));
  }

  static Future<List<EducationModel>> getEdu() async {
    final String? storedObjects = await storage.read(key: 'edu');

    if (storedObjects != null) {
      Iterable decoded = jsonDecode(storedObjects);
      if (decoded is List) {
        List<EducationModel> loadedSkills = decoded
            .map<EducationModel>((e) => EducationModel.fromJson(jsonDecode(e)))
            .toList();
        return loadedSkills;
      } else {
        print('Unexpected format for stored skills');
        return [];
      }
      // List<SkillsModel> loadedObjects =
      //     decoded.map((e) => SkillsModel.fromJson(e)).toList();
    } else {
      return [];
    }
  }

  static Future<void> saveEdu(List<EducationModel> eduList) async {
    const storage = FlutterSecureStorage();
    List<String> encodedObjects =
        eduList.map((e) => jsonEncode(e.toJson())).toList();
    await storage.write(key: 'edu', value: jsonEncode(encodedObjects));
  }

  static Future<List<SocialModel>> getSocial() async {
    final String? storedObjects = await storage.read(key: 'social');

    if (storedObjects != null) {
      Iterable decoded = jsonDecode(storedObjects);
      if (decoded is List) {
        List<SocialModel> loadedSkills = decoded
            .map<SocialModel>((e) => SocialModel.fromJson(jsonDecode(e)))
            .toList();
        return loadedSkills;
      } else {
        print('Unexpected format for stored skills');
        return [];
      }
      // List<SkillsModel> loadedObjects =
      //     decoded.map((e) => SkillsModel.fromJson(e)).toList();
    } else {
      return [];
    }
  }

  static Future<void> saveSocial(List<SocialModel> socialList) async {
    const storage = FlutterSecureStorage();
    List<String> encodedObjects =
        socialList.map((e) => jsonEncode(e.toJson())).toList();
    await storage.write(key: 'social', value: jsonEncode(encodedObjects));
  }
}

class GlobalMethod {
  static void showErrorDialog(
      {required String error, required BuildContext ctx}) {
    showDialog(
        context: ctx,
        builder: (context) {
          return AlertDialog(
            title: const Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.logout,
                    color: Colors.grey,
                    size: 35,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Error Occurred',
                  ),
                ),
              ],
            ),
            content: Text(
              error,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontStyle: FontStyle.italic),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        });
  }
}
