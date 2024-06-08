import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:career_quest/cv/cv_input_from_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:career_quest/Persistent/persistent.dart';
import 'package:career_quest/Services/api.dart';
import 'package:career_quest/Services/global_methods.dart';
import 'package:career_quest/Services/global_variables.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../Widgets/bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  final String userID;

  const ProfileScreen({super.key, required this.userID});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? name;
  String email = '';
  String phoneNumber = '';
  String? pic;
  String location = "";
  bool isLoading = false;
  bool _isSameUser = false;
  List<int>? pdfBytes;

  FilePickerResult _pdfFileResult = const FilePickerResult([]);

  Future<void> _pickPDFFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _pdfFileResult = result;
        });
      }
    } catch (e) {
      GlobalMethod.showErrorDialog(
          error: "Error picking PDF file: $e", ctx: context);
    }
  }

  String byte = '';
  File file = File('');

  void getUserData() async {
    try {
      requestForPermission();

      ApiManager.getUserDetail(widget.userID).then((user) {
        setState(() {
          name = user.name;
          email = user.email;
          phoneNumber = user.phoneNumber;
          pic = user.pic;
          // Timestamp joinedAtTimeStamp = user.get('createdAt');
          // var joinedDate = joinedAtTimeStamp.toDate();
          // joinedAt = '${joinedDate.year} - ${joinedDate.month} - ${joinedDate.day}';
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

      setState(() {
        _isSameUser = uid == widget.userID;
      });
    } catch (error) {
      throw Exception(error.toString());
    }
  }

  Decoration decoration1 = const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(20)), color: Colors.white);

  @override
  void initState() {
    super.initState();
    Persistent persistent = Persistent();
    persistent.getMyData();
    setState(() {
      isLoading = true;
    });
    print(' ds ${isLoading}');
    getUserData();
  }

  Widget userInfo({required IconData icon, required String content}) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.green,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            content,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }

  Widget _contactBy(
      {required Color color, required Function fct, required IconData icon}) {
    return CircleAvatar(
      backgroundColor: color,
      radius: 25,
      child: CircleAvatar(
        radius: 23,
        backgroundColor: Colors.white,
        child: IconButton(
          icon: Icon(
            icon,
            color: color,
          ),
          onPressed: () {
            fct();
          },
        ),
      ),
    );
  }

  void _openWhatsAppChat() async {
    var url = 'https://wa.me/$phoneNumber?text=HelloWorld';
    launchUrlString(url);
  }

  void _mailTo() async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: email,
      query:
          'subject=Write subject here, Please&body=Hello, please write details here',
    );
    final url = params.toString();
    launchUrlString(url);
  }

  void _callPhoneNumber() async {
    var url = 'tel://$phoneNumber';
    launchUrlString(url);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: BottomNavigationBarForApp(
        indexNum: 3,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: isLoading == true
            ? const Center(
                child: CircularProgressIndicator(color: Colors.green,),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Stack(
                    children: [
                      Card(
                        color: Colors.white10,
                        margin: const EdgeInsets.all(30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 60),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  name == null ? 'Name here' : name!,
                                  style: const TextStyle(
                                      color: Colors.blue, fontSize: 24.0),
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Divider(
                                thickness: 1,
                                color: Colors.white,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Account Information :',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child:
                                    userInfo(icon: Icons.email, content: email),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: userInfo(
                                    icon: Icons.phone, content: phoneNumber),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              _isSameUser
                                  ? Container()
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        _contactBy(
                                          color: Colors.green,
                                          fct: () {
                                            _openWhatsAppChat();
                                          },
                                          icon: FontAwesome.whatsapp,
                                        ),
                                        _contactBy(
                                          color: Colors.red,
                                          fct: () {
                                            _mailTo();
                                          },
                                          icon: Icons.mail_outline,
                                        ),
                                        _contactBy(
                                          color: Colors.purple,
                                          fct: () {
                                            _callPhoneNumber();
                                          },
                                          icon: Icons.call,
                                        ),
                                      ],
                                    ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Divider(
                                thickness: 1,
                                color: Colors.white,
                              ),
                              !_isSameUser
                                  ? Container()
                                  : Column(
                                      children: [
                                        isLoading
                                            ? CircularProgressIndicator()
                                            : (byte == '' ||
                                                    byte.toLowerCase().contains(
                                                        'no file found'))
                                                ? Column(
                                                    children: [
                                                      SizedBox(
                                                        // height: 0.45.sh,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      15,
                                                                  vertical: 15),
                                                          child: Container(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      20.0),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(
                                                                        "Resume/CV",
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .white,
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w700),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 8,
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Expanded(
                                                                        child: Container(
                                                                            decoration: decoration1,
                                                                            child: _pdfFileResult.files.isEmpty
                                                                                ? boxContent(context, "Select PDF File", "1", "assets/images/cnic_icon.png")
                                                                                : Stack(
                                                                                    children: [
                                                                                      SizedBox(
                                                                                          height: 50,
                                                                                          child: Center(
                                                                                              child: Text(
                                                                                            _pdfFileResult.files.single.name,
                                                                                            textAlign: TextAlign.center,
                                                                                          ))),
                                                                                      // Image.file(
                                                                                      //   File(cnic_file!
                                                                                      //       .path),
                                                                                      //   fit: BoxFit
                                                                                      //       .cover,
                                                                                      // ),
                                                                                      Positioned(
                                                                                        top: 8.0,
                                                                                        right: 8.0,
                                                                                        child: GestureDetector(
                                                                                          onTap: () {
                                                                                            // Handle delete action

                                                                                            setState(() {
                                                                                              _pdfFileResult = const FilePickerResult([]);
                                                                                              _isPDFReadable = true;
                                                                                            });
                                                                                          },
                                                                                          child: Container(
                                                                                            padding: const EdgeInsets.all(4.0),
                                                                                            decoration: const BoxDecoration(
                                                                                              shape: BoxShape.circle,
                                                                                              color: Colors.red,
                                                                                            ),
                                                                                            child: const Icon(
                                                                                              Icons.delete,
                                                                                              color: Colors.white,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  )),
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            20,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  _pdfFileResult
                                                                          .files
                                                                          .isEmpty
                                                                      ? SizedBox()
                                                                      : _isPDFReadable
                                                                          ? Padding(
                                                                              padding: const EdgeInsets.all(15.0),
                                                                              child: Column(
                                                                                children: [
                                                                                  Row(
                                                                                    children: [
                                                                                      Text(
                                                                                        "Preview",
                                                                                        style: TextStyle(color: Colors.white, fontSize: 15),
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 250,
                                                                                    child: PDFView(
                                                                                      filePath: _pdfFileResult.files.single.path!,
                                                                                      onPageChanged: (int? page, int? total) {
                                                                                        setState(() {
                                                                                          _pages = total!;
                                                                                          _isPDFReadable = true;
                                                                                        });
                                                                                      },
                                                                                      onError: (error) {
                                                                                        setState(() {
                                                                                          _isPDFReadable = false;
                                                                                        });
                                                                                      },
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            )
                                                                          : Center(
                                                                              child: Text('PDF file is not readable.'),
                                                                            ),
                                                                  SizedBox(
                                                                    height: 15,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 0.01,
                                                      ),
                                                      isUploading?Center(child: CircularProgressIndicator(),):GestureDetector(
                                                        onTap: () {
                                                          uploadFile(context);
                                                        },
                                                        child: Container(
                                                          height: 40,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.85,
                                                          alignment:
                                                              AlignmentDirectional
                                                                  .center,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0),
                                                          ),
                                                          child: Text("Upload",
                                                              style: TextStyle(
                                                                fontSize: 12.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Colors
                                                                    .black,
                                                              )),
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                : Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'Your Uploaded CV/Resume',
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        color: Colors.green,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  5.0),
                                                          child: Column(
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Flexible(
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () {
                                                                        OpenFile.open(
                                                                            savePath);
                                                                      },
                                                                      child:
                                                                          Text(
                                                                        '${username!.replaceAll(" ", "_")}.pdf',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                18,
                                                                            decoration:
                                                                                TextDecoration.underline,
                                                                            color: Colors.white,
                                                                            fontWeight: FontWeight.w500),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              // Center(
                                                              //     child: FittedBox(
                                                              //         fit: BoxFit
                                                              //             .scaleDown,
                                                              //         child:
                                                              //             GestureDetector(
                                                              //           onTap: () {
                                                              //             OpenFile.open(
                                                              //                 savePath);
                                                              //           },
                                                              //           child: Text(
                                                              //             'VIEW FILE ',
                                                              //             style: TextStyle(
                                                              //                 fontWeight:
                                                              //                     FontWeight
                                                              //                         .bold,
                                                              //                 decoration:
                                                              //                     TextDecoration
                                                              //                         .underline,
                                                              //                 decorationColor:
                                                              //                     Colors
                                                              //                         .white,
                                                              //                 color: Colors
                                                              //                     .white),
                                                              //           ),
                                                              //         ))),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                        const Divider(
                                          thickness: 1,
                                          color: Colors.white,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'CV Generator',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              color: Colors.blue,
                                              child: Padding(
                                                padding: EdgeInsets.all(5.0),
                                                child: Column(
                                                  children: [
                                                    Center(
                                                        child: FittedBox(
                                                            fit: BoxFit
                                                                .scaleDown,
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (_) =>
                                                                                CVInputUserScreen()));
                                                              },
                                                              child: Text(
                                                                'Add/Update Data',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        18,
                                                                    decoration:
                                                                        TextDecoration
                                                                            .underline,
                                                                    decorationColor:
                                                                        Colors
                                                                            .white,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ))),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: size.width * 0.26,
                            height: size.width * 0.26,
                            decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 8,
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    pic ??
                                        'https://cdn.icon-icons.com/icons2/2643/PNG/512/male_boy_person_people_avatar_icon_159358.png',
                                  ),
                                  fit: BoxFit.fill,
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  String msg = '';

  bool isUploading = false;
  uploadFile(BuildContext context) async {
    if (_pdfFileResult.files.isEmpty) {
      GlobalMethod.showErrorDialog(error: "Please Select PDF", ctx: context);
    } else if (_isPDFReadable != true) {
      GlobalMethod.showErrorDialog(
          error: "PDF File is corrupted", ctx: context);
    } else {
      setState(() {
        isUploading = true;
      });
      File file = File(_pdfFileResult.files.single.path!);
      if (file.existsSync()) {
        //Uint8List image = await file.readAsBytes();
        //String pdfBase64 = base64Encode(image);
        ApiManager.uploadCV(_pdfFileResult.files.single.path!).then((user) {
          msg = user;
          if (msg.toLowerCase().contains('file uploaded successfully!')) {
            setState(() {
              ApiManager.getUploadedCV().then((data) async {
                setState(() {
                  byte = data;
                });
                if (byte != '') {
                  file = await _createFileFromString(byte);
                  isUploading =false;
                }
              }).catchError((err) {
                print('object1213 $err');
              });
            });
          } else {
            setState(() {
              isUploading = false;
            });
            GlobalMethod.showErrorDialog(error: msg, ctx: context);
          }
        }).catchError((err) {
          msg = err;
          setState(() {
            isUploading = false;
          });
          GlobalMethod.showErrorDialog(error: err, ctx: context);
        });
      }
    }
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

  Permission? permission;
  PermissionStatus permissionStatus = PermissionStatus.denied;

  Future requestForPermission() async {
    final status = await Permission.storage.request();
    setState(() {
      permissionStatus = status;
    });
  }

  String savePath = '';

  Future<File> _createFileFromString(String data) async {
    requestForPermission();
    final dir = await getDownloadDirectory();
    savePath = path.join(dir!.path, "$uid.pdf");
    setState(() {});
    var bytes = base64Decode(data.replaceAll("", ''));

    final file = File(savePath);
    File file12 = await file.writeAsBytes(bytes.buffer.asUint8List());
    print('object122121212 $file12');
    return file12;
  }

  Widget boxContent(
      BuildContext context, String name, String no, String image) {
    return GestureDetector(
      onTap: () {
        _pickPDFFile();
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2), // Shadow color
                        spreadRadius: 2, // Spread radius
                        blurRadius: 5, // Blur radius
                        offset:
                            const Offset(2, 4), // Offset (vertical, horizontal)
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      image,
                      height: 0.04,
                      width: 0.04,
                    ),
                  )),
              SizedBox(height: 15),
              Text(
                name,
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 2.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Expanded(
                        child: Container(
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Colors.white),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          "SELECT",
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  late int _pages;
  bool _isPDFReadable = true;
}
