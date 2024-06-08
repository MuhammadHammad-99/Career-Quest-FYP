import 'package:career_quest/Services/api.dart';
import '../Services/global_variables.dart';

class Persistent {
  static List<String> jobCategoryList = [
    'Architecture and Construction',
    'Education and Training',
    'Development - Programming',
    'Business',
    'Information Technology',
    'Human Resources',
    'Marketing',
    'Design',
    'Accounting',
  ];

  void getMyData() {
    ApiManager.getUser().then((value) {
      uid = value.id.toString();
      username = value.name.toString();
      userEmail = value.email.toString();
      userLocation = value.location.toString();
      userImage = value.pic.toString();
    });
  }
}
