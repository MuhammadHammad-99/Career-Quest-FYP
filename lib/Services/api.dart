import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:career_quest/Models/job_detail_model.dart';
import 'package:career_quest/Models/user_model.dart';
import 'package:career_quest/Services/global_methods.dart';
import 'package:career_quest/Widgets/job_widget.dart';
import 'package:http/http.dart' as http;
import 'package:career_quest/Services/global_variables.dart';

class ApiManager {
  static signup(Map userData) async {
    var url = Uri.parse("$baseUrl/user/signup");
    try {
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(userData),
      );

      if (res.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(res.body);
        print('sdf ${data}');
        print('User signed up: ${data['user']['name']}');
        TokenManager.saveAccessToken(data['access_token']);
        return data;
      } else {
        Map<String, dynamic> error = jsonDecode(res.body);
        return error;
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static login(Map userData) async {
    var url = Uri.parse("$baseUrl/user/login");
    try {
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(userData),
      );
      print('object123 ${res.body.toString()}');
      if (res.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(res.body);
        TokenManager.saveAccessToken(data['access_token']);
      } else {
        Map<String, dynamic> error = jsonDecode(res.body);
        return error;
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static Future<String> logout() async {
    final String? accessToken = await TokenManager.getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }
    var url = Uri.parse("$baseUrl/user/logout");
    var headers = {"Authorization": "Bearer $accessToken"};
    try {
      final res = await http.get(url, headers: headers);
      if (res.statusCode == 200) {
        TokenManager.deleteAccessToken();
        return "User logged out";
      } else {
        throw Exception("Log out failed!");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static getUser() async {
    final String? accessToken = await TokenManager.getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    var url = Uri.parse("$baseUrl/user");
    var headers = {"Authorization": "Bearer $accessToken"};

    try {
      final res = await http.get(url, headers: headers);
      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        return UserModel.fromJson(jsonData);
      } else {
        var error = jsonDecode(res.body);
        return error;
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  static getUploadedCV() async {
    final String? accessToken = await TokenManager.getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    var url = Uri.parse("$baseUrl/user/file");
    var headers = {"Authorization": "Bearer $accessToken",};

    try {
      final res = await http.get(url, headers: headers);

      if (res.statusCode == 200) {
        final jsonData =jsonDecode(res.body);
        print('sadadasd ${jsonData}');
        return jsonData['file'];
      } else {
        var error = jsonDecode(res.body)['error'];
        return error;
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  static uploadCV(String base64Image) async {
    final String? accessToken = await TokenManager.getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    var headers = {"Authorization": "Bearer $accessToken",};
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/user/upload'));
    request.files.add(await http.MultipartFile.fromPath('file',base64Image));
    request.headers.addAll(headers);


    try {
      http.StreamedResponse res = await request.send();

      if (res.statusCode == 200) {
        final jsonData =jsonDecode(await res.stream.bytesToString());
        print('sadadasd ${jsonData}');
        return jsonData['msg'];
      } else {
        var error = jsonDecode(await res.stream.bytesToString())['error'];
        return error;
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<List<UserModel>> getUserByName(String? name) async {
    final String? accessToken = await TokenManager.getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }
    var url = Uri.parse("$baseUrl/users");
    if (name != null) {
      url = Uri.parse("$baseUrl/users?searchQuery=$name");
    }
    var headers = {"Authorization": "Bearer $accessToken"};

    try {
      final res = await http.get(url, headers: headers);
      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body) as List;
        List<UserModel> users = [];
        for (var item in jsonData) {
          if (item is Map<String, dynamic>) {
            String id = item['id'];
            String name = item['name'];
            String email = item['email'];
            String location = item['location'];
            String phoneNumber = item['phoneNumber'];
            String? pic = item['pic'];

            users.add(UserModel(
                id: id,
                email: email,
                name: name,
                location: location,
                phoneNumber: phoneNumber,
                pic: pic));
          } else {
            print("Invalid item format: $item");
          }
        }
        return users;
      } else {
        var error = jsonDecode(res.body);
        throw Exception(error);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<UserModel> getUserDetail(String id) async {
    final accessToken = await TokenManager.getAccessToken();
    var headers = {"Authorization": "Bearer $accessToken"};
    var url = Uri.parse("$baseUrl/user/detail/$id");

    try {
      final res = await http.get(url, headers: headers);
      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        return UserModel.fromJson(jsonData);
      } else {
        var error = jsonDecode(res.body);
        throw Exception(error);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<List<JobWidget>> getListJobs(
      String? title, String? category) async {
    final String? accessToken = await TokenManager.getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    var headers = {"Authorization": "Bearer $accessToken"};
    var url = Uri.parse("$baseUrl/jobs/");
    if (title != null) {
      url = Uri.parse("$baseUrl/jobs?title=$title");
    } else if (category != null) {
      url = Uri.parse("$baseUrl/jobs?category=$category");
    }

    try {
      final res = await http.get(url, headers: headers);
      if (res.statusCode == 200) {
        final jsonResponse = json.decode(res.body) as List;
        List<JobWidget> jobs = [];
        for (var item in jsonResponse) {
          if (item is Map<String, dynamic>) {
            String id = item['_id'];
            String title = item['title'];
            String description = item['description'];
            String uploadedBy = item['uploadedBy'];
            bool recruitment = item['recruitment'];
            String location = item['location'];
            String category = item['category'];
            jobs.add(JobWidget(
              id: id,
              title: title,
              description: description,
              uploadedBy: uploadedBy,
              recruitment: recruitment,
              location: location,
              category: category,
            ));
          } else {
            print('Invalid item format: $item');
          }
        }
        return jobs;
      } else {
        var error = jsonDecode(res.body);
        throw Exception(error);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<JobDetailModel> getDetailJob(String id) async {
    final accessToken = await TokenManager.getAccessToken();
    var headers = {"Authorization": "Bearer $accessToken"};
    var url = Uri.parse("$baseUrl/jobs/detail/$id");
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return JobDetailModel.fromJson(jsonData);
      } else {
        throw Exception(response.body.toString());
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static deleteJob(String id) async {
    final String? accessToken = await TokenManager.getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }
    var headers = {"Authorization": "Bearer $accessToken"};

    var url = Uri.parse("$baseUrl/jobs/delete/$id");
    try {
      final res = await http.delete(url, headers: headers);
      if (res.statusCode == 204) {
        return "Job Deleted!";
      } else {
        throw Exception("Job not deleted!");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<String> addJob(Map jobData) async {
    final String? accessToken = await TokenManager.getAccessToken();
    if (accessToken == null) {
      print('Access token not found');
      throw Exception('Access token not found');
    }
    var url = Uri.parse("$baseUrl/jobs/create/");
    var headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "Bearer $accessToken"
    };

    final res = await http.post(
      url,
      headers: headers,
      body: jsonEncode(jobData),
    );

    if (res.statusCode == 201) {
      return "Job Created!";
    } else {
      var error = jsonDecode(res.body);
      throw Exception(error);
    }
  }

  static Future<String> updateJob(
      String id, Map<String, dynamic> jobData) async {
    final String? accessToken = await TokenManager.getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    var headers = {
      "Authorization": "Bearer $accessToken",
      'Content-Type': 'application/json; charset=UTF-8'
    };
    var url = Uri.parse("$baseUrl/jobs/update/$id");

    try {
      final res =
          await http.put(url, headers: headers, body: jsonEncode(jobData));
      if (res.statusCode == 201) {
        return res.body;
      } else {
        var error = res.body;
        throw Exception(error.toString());
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
