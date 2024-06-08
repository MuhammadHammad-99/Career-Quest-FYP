import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:career_quest/LoginPage/login_screen.dart';
import 'package:career_quest/Services/api.dart';
import 'package:career_quest/Services/global_methods.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../Services/global_variables.dart';

class SignUp extends StatefulWidget {
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with TickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;

  final TextEditingController _fullNameController =
      TextEditingController(text: '');
  final TextEditingController _emailTextController =
      TextEditingController(text: '');
  final TextEditingController _passTextController =
      TextEditingController(text: '');
  final TextEditingController _phoneNumberTextController =
      TextEditingController(text: '');
  final TextEditingController _locationController =
      TextEditingController(text: '');

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passFocusNode = FocusNode();
  final FocusNode _phoneNumberFocusNode = FocusNode();
  final FocusNode _positionCPFocusNode = FocusNode();

  final _signUpFormKey = GlobalKey<FormState>();
  bool _obscureText = true;
  File? imageFile;
  final bool _isLoading = false;
  String? imageUrl;

  @override
  void dispose() {
    _animationController.dispose();
    _fullNameController.dispose();
    _emailTextController.dispose();
    _passTextController.dispose();
    _phoneNumberTextController.dispose();
    _emailFocusNode.dispose();
    _passFocusNode.dispose();
    _positionCPFocusNode.dispose();
    _phoneNumberFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 20));
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.linear)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((animationstatus) {
            if (animationstatus == AnimationStatus.completed) {
              _animationController.reset();
              _animationController.forward();
            }
          });
    _animationController.forward();

    super.initState();
  }

  void _showImageDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Please choose an option'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    _getFromCamera();
                  },
                  child: const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.camera,
                          color: Colors.purple,
                        ),
                      ),
                      Text(
                        'Camera',
                        style: TextStyle(color: Colors.purple),
                      )
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    _getFromGallery();
                  },
                  child: const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.image,
                          color: Colors.purple,
                        ),
                      ),
                      Text(
                        'Gallery',
                        style: TextStyle(color: Colors.purple),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  void _getFromCamera() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _getFromGallery() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _cropImage(filePath) async {
    CroppedFile? croppedImage = await ImageCropper()
        .cropImage(sourcePath: filePath, maxHeight: 1080, maxWidth: 1080);
    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  int activeStep = 0;

  header() {
    return EasyStepper(
      activeStep: activeStep,
      activeStepBackgroundColor: const Color.fromRGBO(243, 250, 240, 0.7),
      activeStepBorderType: BorderType.normal,

      //lineLength: 50,
      lineStyle: const LineStyle(
          lineType: LineType.normal, defaultLineColor: Colors.green),
      enableStepTapping: false,
      stepShape: StepShape.circle,

      stepBorderRadius: 15,
      borderThickness: 2,

      padding: const EdgeInsets.all(15),
      stepRadius: 28,
      finishedStepBorderColor: Colors.green,
      activeStepBorderColor: Colors.black,
      finishedStepBackgroundColor: const Color.fromRGBO(243, 250, 240, 0.7),
      finishedStepBorderType: BorderType.normal,
      showLoadingAnimation: false,
      steps: [
        EasyStep(
          customStep: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Opacity(
              opacity: activeStep >= 0 ? 1 : 0.3,
              child: const Text(
                "1",
                style: TextStyle(
                    fontFamily: 'HEL', color: Colors.green, fontSize: 25),
              ),
            ),
          ),
          customTitle: const Text(
            'Email',
            textAlign: TextAlign.center,
          ),
        ),
        EasyStep(
          customStep: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Opacity(
              opacity: activeStep >= 1 ? 1 : 0.3,
              child: const Text(
                "2",
                style: TextStyle(
                    fontFamily: 'HEL', color: Colors.green, fontSize: 25),
              ),
            ),
          ),
          customTitle: const Text(
            'Basic Details',
            textAlign: TextAlign.center,
          ),
        ),
        EasyStep(
          customStep: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Opacity(
              opacity: activeStep >= 2 ? 1 : 0.3,
              child: const Text(
                "3",
                style: TextStyle(
                    fontFamily: 'HEL', color: Colors.green, fontSize: 25),
              ),
            ),
          ),
          customTitle: const Text(
            'Password',
            textAlign: TextAlign.center,
          ),
        ),
      ],
      onStepReached: (index) => setState(() => activeStep = index),
    );
  }

  Widget _buildNextBtn(int step) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      width: double.infinity,
      child: MaterialButton(
        elevation: 5.0,
        onPressed: () {
          if (activeStep == 0) {
            if (_emailTextController.text.isEmpty) {
              GlobalMethod.showErrorDialog(
                  error: 'Please Enter Email', ctx: context);
            } else {
              setState(() {
                activeStep = step;
              });
            }
          } else if (activeStep == 1) {
            if (_fullNameController.text.isEmpty) {
              GlobalMethod.showErrorDialog(
                  error: 'Please Enter Name', ctx: context);
            } else if (_phoneNumberTextController.text.isEmpty) {
              GlobalMethod.showErrorDialog(
                  error: 'Please Enter phone', ctx: context);
            } else if (_locationController.text.isEmpty) {
              GlobalMethod.showErrorDialog(
                  error: 'Please Enter Location', ctx: context);
            } else {
              setState(() {
                activeStep = step;
              });
            }
          }
        },
        padding: const EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.green,
        child: Text(
          "Next",
          style: const TextStyle(
            color: Colors.white,
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'HEL',
          ),
        ),
      ),
    );
  }

  Widget _buildBackBtn(int step) {
    return Container(
      margin: const EdgeInsets.only(top: 5, bottom: 20),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              setState(() {
                activeStep = step;
              });
            },
          text: "Go Back",
          style: TextStyle(color: Colors.green, fontSize: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          // CachedNetworkImage(
          //   imageUrl: signUpUrlImage,
          //   placeholder: (context, url) => Image.asset(
          //     'assets/images/wallpaper.jpg',
          //     fit: BoxFit.fill,
          //   ),
          //   errorWidget: (context, url, error) => const Icon(Icons.error),
          //   width: double.infinity,
          //   height: double.infinity,
          //   fit: BoxFit.cover,
          //   alignment: FractionalOffset(_animation.value, 0),
          // ),
          PopScope(
            canPop: false,
            onPopInvoked: (bool didPop) {
              // print('sdsa ${didPop}/${items[selectedTab].navKey.currentState !.canPop()}');
              if (activeStep == 0) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => login()),
                    (route) => false);
              } else if (activeStep == 2) {
                setState(() {
                  activeStep = 1;
                });
              } else if (activeStep == 1) {
                setState(() {
                  activeStep = 0;
                });
              }
            },
            child: Container(
              color: Colors.white,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                child: ListView(
                  children: [
                    Form(
                      key: _signUpFormKey,
                      child: Column(
                        children: [
                          Image.asset(
                            "assets/images/login.png",
                            width: MediaQuery.of(context).size.width,
                            height: 200,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Sign Up',
                                style: TextStyle(
                                    fontFamily: 'HEL',
                                    fontSize: 24,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          header(),
                          if (activeStep == 0)
                            Column(
                              children: [
                                TextFormField(
                                  textInputAction: TextInputAction.next,
                                  onEditingComplete: () =>
                                      FocusScope.of(context)
                                          .requestFocus(_passFocusNode),
                                  keyboardType: TextInputType.emailAddress,
                                  controller: _emailTextController,
                                  validator: (value) {
                                    if (value!.isEmpty ||
                                        !value.contains('@')) {
                                      return 'Please enter a valid Email address';
                                    } else {
                                      return null;
                                    }
                                  },
                                  style: const TextStyle(color: Colors.black),
                                  decoration: const InputDecoration(
                                    hintText: 'Email',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30.0)),
                                        borderSide:
                                            BorderSide(color: Colors.green)),
                                    border: InputBorder.none,
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30.0)),
                                        borderSide:
                                            BorderSide(color: Colors.green)),
                                    errorBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                    ),
                                  ),
                                ),
                                _buildNextBtn(1)
                              ],
                            ),
                          if (activeStep == 1)
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _showImageDialog();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: size.width * 0.24,
                                      height: size.width * 0.24,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 1,
                                          color: Colors.cyanAccent,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: imageFile == null
                                            ? const Icon(
                                                Icons.camera_enhance_sharp,
                                                color: Colors.cyan,
                                                size: 30,
                                              )
                                            : Image.file(
                                                imageFile!,
                                                fit: BoxFit.fill,
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  textInputAction: TextInputAction.next,
                                  onEditingComplete: () =>
                                      FocusScope.of(context)
                                          .requestFocus(_emailFocusNode),
                                  keyboardType: TextInputType.name,
                                  controller: _fullNameController,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'This Field is missing';
                                    } else {
                                      return null;
                                    }
                                  },
                                  style: const TextStyle(color: Colors.black),
                                  decoration: const InputDecoration(
                                    hintText: 'Full Name / Company Name',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30.0)),
                                        borderSide:
                                            BorderSide(color: Colors.green)),
                                    border: InputBorder.none,
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30.0)),
                                        borderSide:
                                            BorderSide(color: Colors.green)),
                                    errorBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  textInputAction: TextInputAction.next,
                                  onEditingComplete: () =>
                                      FocusScope.of(context)
                                          .requestFocus(_positionCPFocusNode),
                                  keyboardType: TextInputType.phone,
                                  maxLength: 11,
                                  controller: _phoneNumberTextController,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'This Field is missing';
                                    } else {
                                      return null;
                                    }
                                  },
                                  style: const TextStyle(color: Colors.black),
                                  decoration: const InputDecoration(
                                    hintText: 'Phone Number',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30.0)),
                                        borderSide:
                                            BorderSide(color: Colors.green)),
                                    border: InputBorder.none,
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30.0)),
                                        borderSide:
                                            BorderSide(color: Colors.green)),
                                    errorBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  textInputAction: TextInputAction.next,
                                  onEditingComplete: () =>
                                      FocusScope.of(context)
                                          .requestFocus(_positionCPFocusNode),
                                  keyboardType: TextInputType.text,
                                  controller: _locationController,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'This Field is missing';
                                    } else {
                                      return null;
                                    }
                                  },
                                  style: const TextStyle(color: Colors.black),
                                  decoration: const InputDecoration(
                                    hintText: 'Company Address ',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30.0)),
                                        borderSide:
                                            BorderSide(color: Colors.green)),
                                    border: InputBorder.none,
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30.0)),
                                        borderSide:
                                            BorderSide(color: Colors.green)),
                                    errorBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                    ),
                                  ),
                                ),
                                _buildNextBtn(2),
                                _buildBackBtn(0),
                              ],
                            ),
                          if (activeStep == 2)
                            Column(
                              children: [
                                TextFormField(
                                  textInputAction: TextInputAction.next,
                                  onEditingComplete: () =>
                                      FocusScope.of(context)
                                          .requestFocus(_phoneNumberFocusNode),
                                  keyboardType: TextInputType.visiblePassword,
                                  controller: _passTextController,
                                  obscureText: !_obscureText,
                                  validator: (value) {
                                    if (value!.isEmpty || value.length < 7) {
                                      return 'Please enter a valid Password';
                                    } else {
                                      return null;
                                    }
                                  },
                                  style: const TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                      child: Icon(
                                        _obscureText
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.white,
                                      ),
                                    ),
                                    hintText: 'Password',
                                    hintStyle:
                                        const TextStyle(color: Colors.grey),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30.0)),
                                        borderSide:
                                            BorderSide(color: Colors.green)),
                                    border: InputBorder.none,
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30.0)),
                                        borderSide:
                                            BorderSide(color: Colors.green)),
                                    errorBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                isUploading
                                    ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : MaterialButton(
                                        onPressed: () {
                                          var data = {
                                            'name': _fullNameController.text,
                                            'email': _emailTextController.text
                                                .trim()
                                                .toLowerCase(),
                                            'password':
                                                _passTextController.text,
                                            'location':
                                                _locationController.text,
                                            "phoneNumber":
                                                _phoneNumberTextController.text,
                                          };
                                          if (_passTextController.text.length >=
                                              8) {
                                            upload(context,data);
                                          } else {
                                            GlobalMethod.showErrorDialog(
                                                error:
                                                    'Password length must be greater than and equal to 8',
                                                ctx: context);
                                          }
                                        },
                                        color: Colors.green,
                                        elevation: 8,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(13),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 14),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'SignUp',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                SizedBox(
                                  height: 10,
                                ),
                                _buildBackBtn(1),
                                // _buildTerms(),
                              ],
                            ),
                          const SizedBox(
                            height: 15,
                          ),
                          Center(
                            child: RichText(
                              text: TextSpan(children: [
                                const TextSpan(
                                    text: 'Already have an account ?',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    )),
                                const TextSpan(text: '  '),
                                TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => Navigator.canPop(context)
                                          ? Navigator.pop(context)
                                          : null,
                                    text: 'Login',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    )),
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  bool isUploading = false;
   upload(BuildContext context, Map<String, String> data) async {
    setState(() {
      isUploading = true;
    });
    final result = await ApiManager.signup(data);
    if(result!=null){
      if(result['user']!=null){
        Fluttertoast.showToast(
          msg: 'User added successfully',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.grey,
          fontSize: 18.0,
        );
        setState(() {
          isUploading = false;
        });
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>login()), (route) => false);
      }
      if(result['error']!=null){
        setState(() {
          isUploading = false;
        });
        GlobalMethod.showErrorDialog(error: result['error'], ctx: context);
      }
    }
  }
}
