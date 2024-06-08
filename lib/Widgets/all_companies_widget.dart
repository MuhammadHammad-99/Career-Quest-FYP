import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../Search/profile_company.dart';

class AllWorkersWidget extends StatefulWidget {
  final String userID;
  final String userName;
  final String userEmail;
  final String phoneNumber;
  final String? userImageUrl;

  const AllWorkersWidget({super.key, 
    required this.userID,
    required this.userName,
    required this.userEmail,
    required this.phoneNumber,
    this.userImageUrl,
  });

  @override
  State<AllWorkersWidget> createState() => _AllWorkersWidgetState();
}

class _AllWorkersWidgetState extends State<AllWorkersWidget> {
  void _mailTo() async {
    var mailUrl = 'mailto: ${widget.userEmail}';
    print('widget.userEmail ${widget.userEmail}');

    if (await canLaunchUrlString(mailUrl)) {
      await launchUrlString(mailUrl);
    } else {
      print('Error');
      throw 'Error Occurred';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
        onTap: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfileScreen(userID: widget.userID)));
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.only(right: 12),
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(width: 1),
            ),
          ),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 20,
            child: Image.network(widget.userImageUrl ?? 'https://cdn.icon-icons.com/icons2/2643/PNG/512/male_boy_person_people_avatar_icon_159358.png'),
          ),
        ),
        title: Text(
          widget.userName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontSize: 18
          ),
        ),
        subtitle: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Visit Profile',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward,
          size: 30,
          color: Colors.green,
        ),
        // IconButton(
        //   icon: const Icon(
        //     Icons.arrow_forward,
        //     size: 30,
        //     color: Colors.green,
        //   ),
        //   onPressed: () {
        //     //_mailTo();
        //   },
        // ),
      ),
    );
  }
}
