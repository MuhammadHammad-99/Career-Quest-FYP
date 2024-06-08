import 'package:career_quest/Jobs/job_details.dart';
import 'package:career_quest/Services/api.dart';
import 'package:career_quest/Services/global_methods.dart';
import 'package:flutter/material.dart';

class JobWidget extends StatefulWidget {
  final String id;
  final String title;
  final String description;
  final String uploadedBy;
  final bool recruitment;
  final String location;
  final String category;

  const JobWidget({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.uploadedBy,
    required this.recruitment,
    required this.location,
    required this.category,
  });

  @override
  State<JobWidget> createState() => _JobWidgetState();
}

class _JobWidgetState extends State<JobWidget> {


  @override
  Widget build(BuildContext context) {
    return Card(
      //color: Colors.white24,
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: ListTile(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => JobDetailsScreen(
                        uploadedBy: widget.uploadedBy,
                        jobID: widget.id,
                      )));
        },
        onLongPress: () {
          //_deleteDialog();
        },
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        // leading: Container(
        //   padding: const EdgeInsets.only(right: 12),
        //   decoration: const BoxDecoration(
        //     border: Border(
        //       right: BorderSide(width: 1),
        //     ),
        //   ),
        //   child: Image.network(widget),
        // ),
        title: Text(
          widget.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              widget.category,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(
              height: 2,
            ),
            Text(
              widget.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
              ),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.keyboard_arrow_right,
          size: 30,
          color: Colors.black,
        ),
      ),
    );
  }
}
