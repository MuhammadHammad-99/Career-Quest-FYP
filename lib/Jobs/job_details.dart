import 'dart:convert';
import 'dart:io';

import 'package:career_quest/cv/cv_input_from_user.dart';
import 'package:mail_sender/mail_sender.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:career_quest/Jobs/job_screen.dart';
import 'package:career_quest/Persistent/persistent.dart';
import 'package:career_quest/Services/api.dart';
import 'package:career_quest/Services/global_variables.dart';
import 'package:career_quest/cv/generate_cv.dart';
import 'package:flutter/material.dart';
import 'package:career_quest/Services/global_methods.dart';
import 'package:career_quest/Widgets/comments_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class JobDetailsScreen extends StatefulWidget {
  final String uploadedBy;
  final String jobID;

  const JobDetailsScreen({
    super.key,
    required this.uploadedBy,
    required this.jobID,
  });

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  String category = "";
  String description = "";
  String title = "";
  bool recruitment = false;
  DateTime? postedDate;
  DateTime? deadlineDate;
  List<dynamic> comments = [];
  String? location;
  String emailUploader = '';
  String nameUploader = '';
  int applicants = 0;

  bool isDeadlineAvailable = false;
  bool _isCommenting = false;
  bool showComment = false;
  bool isLoading = false;

  String byte = '';
  File file = File('');

  void getJobData() {
    setState(() {
      isLoading = true;
    });
    ApiManager.getDetailJob(widget.jobID).then((job) {
      String createdAt = job.createdAt;
      DateFormat createdFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
      DateTime jobPostedDate = createdFormat.parse(createdAt);

      String deadline = job.deadlineDate;
      DateFormat deadlineFormat =
          DateFormat('EEE, dd MMM yyyy HH:mm:ss \'GMT\'');
      DateTime jobDeadline = deadlineFormat.parse(deadline);

      setState(() {
        title = job.title;
        category = job.category;
        description = job.description;
        recruitment = job.recruitment;
        postedDate = jobPostedDate;
        deadlineDate = jobDeadline;
        comments = job.comments;
        location = job.location;
        emailUploader = job.uploader['email'];
        nameUploader = job.uploader['name'];
        applicants = job.applicants;
        isDeadlineAvailable = jobDeadline.isAfter(DateTime.now());
      });
    }).catchError((err) {
      throw Exception(err.toString());
    });
    ApiManager.getUploadedCV().then((data) async {
      setState(() {
        byte = data;
      });
      if (byte != '') {
        file = await _createFileFromString(byte);
      }
      setState(() {
        isLoading = false;
      });
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<Directory?> getDownloadDirectory() async {
    if (Platform.isAndroid) {
      return await getExternalStorageDirectory();
    }
    return await getApplicationDocumentsDirectory();
  }

  void listenForPermission() async {
    final status = await Permission.storage.status;
    setState(() {
      permissionStatus = status;
    });
    switch (status) {
      case PermissionStatus.denied:
        requestForPermission();
        break;
      case PermissionStatus.granted:
        break;
      case PermissionStatus.restricted:
        // TODO: Handle this case.
        break;
      case PermissionStatus.limited:
        // TODO: Handle this case.
        break;
      case PermissionStatus.permanentlyDenied:
        // TODO: Handle this case.
        break;
      case PermissionStatus.provisional:
      // TODO: Handle this case.
    }
  }

  String savePath = '';
  Permission? permission;
  PermissionStatus permissionStatus = PermissionStatus.denied;

  Future requestForPermission() async {
    final status = await Permission.storage.request();
    setState(() {
      permissionStatus = status;
    });
  }

  Future<File> _createFileFromString(String data) async {
    requestForPermission();
    final dir = await getDownloadDirectory();
    savePath = path.join(dir!.path, "$uid.pdf");
    setState(() {});
    var bytes = base64Decode(data.replaceAll("", ''));

    final file = File(savePath);
    File file12 = await file.writeAsBytes(bytes.buffer.asUint8List());

    return file12;
  }

  @override
  void initState() {
    super.initState();
    Persistent persistent = Persistent();
    persistent.getMyData();
    getJobData();
  }

  Widget dividerWidget() {
    return const Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Divider(
          thickness: 1,
          color: Colors.grey,
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  void sendEmailWithAttachment() async {
    // Path to your PDF file
    if (await File(file.path).exists()) {
      final _mailSenderPlugin = MailSender();
      _mailSenderPlugin.sendMail(
        recipient: [emailUploader],
        subject: "Applying for $title",
        body: "Hello My resume is attached",
        attachment: file.path,
      );
    } else {
      print('File not found');
    }
  }

  void applyForJob() {
    final Uri params = Uri(
      scheme: 'mailto',
      path: emailUploader,
      query:
          'subject=Applying for $title&body=Hello, please attach Resume CV file',
    );
    final url = params.toString();
    launchUrlString(url);
    addNewApplicant();
  }

  void addNewApplicant() {
    ApiManager.updateJob(widget.jobID, {
      'applicants': applicants + 1,
    });
    // Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          flexibleSpace: Container(
              // decoration: BoxDecoration(
              //   gradient: LinearGradient(
              //     colors: [Colors.deepOrange.shade300, Colors.blueAccent],
              //     begin: Alignment.centerLeft,
              //     end: Alignment.centerRight,
              //     stops: const [0.2, 0.9],
              //   ),
              // ),
              ),
          title: Text(
            'Job Detail',
            style: TextStyle(fontSize: 20),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              size: 25,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.green,
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Card(
                        color: Colors.black45,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Text(
                                  title,
                                  maxLines: 3,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 60,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 3,
                                        color: Colors.grey,
                                      ),
                                      shape: BoxShape.rectangle,
                                      image: const DecorationImage(
                                        image: NetworkImage(
                                          'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png',
                                        ),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          nameUploader,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          location ?? "",
                                          style: const TextStyle(
                                              color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              dividerWidget(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    applicants.toString(),
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  const Text(
                                    'Applicants',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Icon(
                                    Icons.how_to_reg_sharp,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                              uid != widget.uploadedBy
                                  ? Container()
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        dividerWidget(),
                                        const Text(
                                          'Recruitment',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                if (uid == widget.uploadedBy) {
                                                  try {
                                                    ApiManager.updateJob(
                                                        widget.jobID,
                                                        {'recruitment': true});
                                                  } catch (error) {
                                                    GlobalMethod
                                                        .showErrorDialog(
                                                      error:
                                                          'Action cannot be performed',
                                                      ctx: context,
                                                    );
                                                  }
                                                } else {
                                                  GlobalMethod.showErrorDialog(
                                                    error:
                                                        'You cannot perform this action',
                                                    ctx: context,
                                                  );
                                                }
                                                getJobData();
                                              },
                                              child: const Text(
                                                'ON',
                                                style: TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                            Opacity(
                                              opacity:
                                                  recruitment == true ? 1 : 0,
                                              child: const Icon(
                                                Icons.check_box,
                                                color: Colors.green,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 40,
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                if (uid == widget.uploadedBy) {
                                                  try {
                                                    ApiManager.updateJob(
                                                        widget.jobID,
                                                        {'recruitment': false});
                                                  } catch (error) {
                                                    GlobalMethod
                                                        .showErrorDialog(
                                                      error:
                                                          'Action cannot be performed',
                                                      ctx: context,
                                                    );
                                                  }
                                                } else {
                                                  GlobalMethod.showErrorDialog(
                                                    error:
                                                        'You cannot perform this action',
                                                    ctx: context,
                                                  );
                                                }
                                                getJobData();
                                              },
                                              child: const Text(
                                                'OFF',
                                                style: TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                            Opacity(
                                              opacity:
                                                  recruitment == false ? 1 : 0,
                                              child: const Icon(
                                                Icons.check_box,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                              dividerWidget(),
                              const Text(
                                'Job Description',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                description,
                                textAlign: TextAlign.justify,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              dividerWidget(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Card(
                        color: Colors.black45,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              uid == widget.uploadedBy
                                  ? Container()
                                  : Column(
                                      children: [
                                        Center(
                                          child: Text(
                                            isDeadlineAvailable
                                                ? 'Actively Recruiting, Send CV/Resume:'
                                                : 'Deadline Passed away.',
                                            style: TextStyle(
                                              color: isDeadlineAvailable
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 6,
                                        ),
                                        isDeadlineAvailable
                                            ? Center(
                                                child: MaterialButton(
                                                  onPressed: () {
                                                    showBottomSheet(context);
                                                  },
                                                  color: Colors.blueAccent,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            13),
                                                  ),
                                                  child: const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 14),
                                                    child: Text(
                                                      'Easy Apply Now',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : SizedBox(),
                                      ],
                                    ),
                              dividerWidget(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Uploaded on:',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "${postedDate?.day}-${postedDate?.month}-${postedDate?.year}",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Deadline date:',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "${deadlineDate?.day}-${deadlineDate?.month}-${deadlineDate?.year}",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  )
                                ],
                              ),
                              dividerWidget(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Card(
                        color: Colors.black45,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isCommenting = !_isCommenting;
                                      });
                                    },
                                    icon: Icon(
                                      _isCommenting
                                          ? Icons.close
                                          : Icons.add_circle_outline,
                                      color: Colors.green,
                                      size: 40,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        showComment = !showComment;
                                      });
                                    },
                                    icon: Icon(
                                      showComment
                                          ? Icons.arrow_drop_down_rounded
                                          : Icons.arrow_drop_up_rounded,
                                      color: Colors.green,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                              AnimatedSwitcher(
                                  duration: const Duration(
                                    milliseconds: 500,
                                  ),
                                  child: _isCommenting
                                      ? Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              flex: 3,
                                              child: TextField(
                                                controller: _commentController,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                ),
                                                maxLength: 200,
                                                keyboardType:
                                                    TextInputType.text,
                                                maxLines: 6,
                                                decoration: InputDecoration(
                                                  filled: true,

                                                  fillColor: Colors.white,
                                                  enabledBorder:
                                                      const UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.white),
                                                  ),
                                                  focusedBorder:
                                                      const OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.green),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Flexible(
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8),
                                                    child: MaterialButton(
                                                      onPressed: () async {
                                                        if (_commentController
                                                                .text.length <
                                                            7) {
                                                          GlobalMethod
                                                              .showErrorDialog(
                                                            error:
                                                                'Comment cannot be less than 7 characters',
                                                            ctx: context,
                                                          );
                                                        } else {
                                                          final generatedId =
                                                              const Uuid().v4();
                                                          Object comment = {
                                                            "id": generatedId,
                                                            "body":
                                                                _commentController
                                                                    .text,
                                                            "userId": uid,
                                                            "time":
                                                                DateTime.now()
                                                                    .toString()
                                                          };
                                                          comments.add(comment);
                                                          ApiManager.updateJob(
                                                              widget.jobID, {
                                                            'comments': comments
                                                          }).then((res) {
                                                            Fluttertoast
                                                                .showToast(
                                                              msg:
                                                                  'Your comment has been added',
                                                              toastLength: Toast
                                                                  .LENGTH_LONG,
                                                              backgroundColor:
                                                                  Colors.grey,
                                                              fontSize: 18.0,
                                                            );
                                                          }).catchError((err) {
                                                            Fluttertoast
                                                                .showToast(
                                                              msg: err
                                                                  .toString(),
                                                              toastLength: Toast
                                                                  .LENGTH_LONG,
                                                              backgroundColor:
                                                                  Colors.red,
                                                              fontSize: 18.0,
                                                            );
                                                          });
                                                          _commentController
                                                              .clear();

                                                          Navigator
                                                              .pushReplacement(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          JobDetailsScreen(
                                                                            uploadedBy:
                                                                                widget.uploadedBy,
                                                                            jobID:
                                                                                widget.jobID,
                                                                          )));
                                                        }
                                                        setState(() {
                                                          showComment = true;
                                                        });
                                                      },
                                                      color: Colors.blueAccent,
                                                      elevation: 0,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: const Text(
                                                        'Post',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _isCommenting =
                                                            !_isCommenting;
                                                        showComment = false;
                                                      });
                                                    },
                                                    child: const Text('Cancel',style: TextStyle(color: Colors.white),),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      : SizedBox()),
                              showComment == false
                                  ? Container()
                                  : Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: ListView.separated(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            if (comments.isEmpty) {
                                              return const Center(
                                                child: Text(
                                                    'No Comment for this job'),
                                              );
                                            } else {
                                              return CommentWidget(
                                                commentId: comments[index]
                                                    ['id'],
                                                commentBody: comments[index]
                                                    ['body'],
                                                userId: comments[index]
                                                    ['userId'],
                                                userName: comments[index]
                                                    ['username'],
                                                userImageUrl: comments[index]
                                                    ['userImageUrl'],
                                              );
                                            }
                                          },
                                          separatorBuilder: (context, index) {
                                            return const Divider(
                                              thickness: 1,
                                              color: Colors.grey,
                                            );
                                          },
                                          itemCount: comments.length),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ));
  }

  showBottomSheet(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.email),
                title: Text('Send via Email'),
                onTap: () async {
                  Navigator.pop(context);
                  applyForJob();
                },
              ),
              (byte == '' || byte.toLowerCase().contains('no file found'))
                  ? SizedBox()
                  : ListTile(
                      leading: Icon(Icons.file_copy_rounded),
                      title: Text('Send Email attached default CV'),
                      onTap: () async {
                        Navigator.pop(context);
                        sendEmailWithAttachment();
                      },
                    ),
              ListTile(
                leading: Icon(Icons.create),
                title: Text('Generate Resume'),
                onTap: () async {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => CVInputUserScreen()));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
