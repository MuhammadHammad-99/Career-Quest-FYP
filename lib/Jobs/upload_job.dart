import 'package:career_quest/LoginPage/login_screen.dart';
import 'package:career_quest/Services/api.dart';
import 'package:career_quest/Services/global_methods.dart';
import 'package:career_quest/Services/global_variables.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Persistent/persistent.dart';
import '../Widgets/bottom_nav_bar.dart';

class UploadJobNow extends StatefulWidget {
  const UploadJobNow({super.key});

  @override
  State<UploadJobNow> createState() => _UploadJobNowState();
}

class _UploadJobNowState extends State<UploadJobNow> {
  final TextEditingController _jobCategoryController =
      TextEditingController(text: 'Select Job Category');
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _jobDescriptionController =
      TextEditingController();
  final TextEditingController _deadlineDateController =
      TextEditingController(text: 'Job Deadline Date');

  final _formKey = GlobalKey<FormState>();
  DateTime? picked;
  // Timestamp? deadlineDateTimeStamp;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Persistent persistent = Persistent();
    persistent.getMyData();
  }

  @override
  void dispose() {
    super.dispose();
    _jobCategoryController.dispose();
    _jobTitleController.dispose();
    _jobDescriptionController.dispose();
    _deadlineDateController.dispose();
  }

  Widget _textTitles({required String label}) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _textFormFields({
    required String valueKey,
    required TextEditingController controller,
    required bool enabled,
    required Function fct,
    required int maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        onTap: () {
          fct();
        },
        child: TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return 'Value is missing';
            }
            return null;
          },
          controller: controller,
          enabled: enabled,
          key: ValueKey(valueKey),
          style: const TextStyle(
            color: Colors.white,
          ),
          maxLines: valueKey == 'JobDescription' ? 3 : 1,
          maxLength: maxLength,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.black54,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }

  _showtaskCategoriesDialog({required Size size}) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              'Job Category',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.green),
            ),
            content: Container(
              width: size.width * 0.9,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: Persistent.jobCategoryList.length,
                itemBuilder: (ctxx, index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _jobCategoryController.text =
                            Persistent.jobCategoryList[index];
                      });
                      Navigator.pop(context);
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.arrow_right_alt_outlined,
                          color: Colors.blue,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            Persistent.jobCategoryList[index],
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        });
  }

  void _pickDateDialog() async {
    picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(
        const Duration(days: 0),
      ),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _deadlineDateController.text =
            '${picked!.year}-${picked!.month}-${picked!.day}';
        // deadlineDateTimeStamp = Timestamp.fromMicrosecondsSinceEpoch(
        //     picked!.microsecondsSinceEpoch);
      });
    }
  }

  void _uploadTask() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      if (_deadlineDateController.text == 'Choose job Deadline date' ||
          _jobCategoryController.text == 'Choose job category') {
        GlobalMethod.showErrorDialog(
            error: 'Please fill all fields!', ctx: context);
        return;
      }
      setState(() {
        _isLoading = true;
      });
      try {
        var job = {
          'title': _jobTitleController.text,
          'description': _jobDescriptionController.text,
          'category': _jobCategoryController.text,
          'email': userEmail,
          'uploadedBy': uid,
          'deadlineDate': _deadlineDateController.text,
          'comments': [],
          'recruitment': true,
          'createdAt': DateTime.now().toString(),
          'location': userLocation,
          'applicants': 0,
        };

        ApiManager.addJob(job).then((value) {
          Fluttertoast.showToast(
            msg: value,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.grey,
            fontSize: 18.0,
          );
        }).catchError((e) {
          if (e.toString().contains("Token has expired")) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => login()));
          } else {
            Fluttertoast.showToast(
              msg: e.toString(),
              toastLength: Toast.LENGTH_LONG,
              backgroundColor: Colors.red,
              fontSize: 18.0,
            );
          }
        });
        _jobTitleController.clear();
        _jobDescriptionController.clear();
        setState(() {
          _jobCategoryController.text = 'Choose job category';
          _deadlineDateController.text = 'Choose job Deadline date';
        });
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        // ignore: use_build_context_synchronously
        GlobalMethod.showErrorDialog(error: error.toString(), ctx: context);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print('Its not valid');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: BottomNavigationBarForApp(indexNum: 2),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(7.0),
          child: Card(
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Please fill all fields',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Signatra',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(
                    thickness: 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _textTitles(label: 'Job Category :'),
                          _textFormFields(
                            valueKey: 'JobCategory',
                            controller: _jobCategoryController,
                            enabled: false,
                            fct: () {
                              _showtaskCategoriesDialog(size: size);
                            },
                            maxLength: 100,
                          ),
                          _textTitles(label: 'Job Title :'),
                          _textFormFields(
                            valueKey: 'JobTitle',
                            controller: _jobTitleController,
                            enabled: true,
                            fct: () {},
                            maxLength: 100,
                          ),
                          _textTitles(label: 'Job Description :'),
                          _textFormFields(
                            valueKey: 'JobDescription',
                            controller: _jobDescriptionController,
                            enabled: true,
                            fct: () {},
                            maxLength: 100,
                          ),
                          _textTitles(label: 'Job Deadline Date :'),
                          _textFormFields(
                            valueKey: 'Deadline',
                            controller: _deadlineDateController,
                            enabled: false,
                            fct: () {
                              _pickDateDialog();
                            },
                            maxLength: 100,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : MaterialButton(
                              onPressed: () {
                                _uploadTask();
                              },
                              color: Colors.black,
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Post Now',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25,
                                        fontFamily: 'Signatra',
                                      ),
                                    ),
                                    SizedBox(
                                      width: 9,
                                    ),
                                    Icon(
                                      Icons.upload_file,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
