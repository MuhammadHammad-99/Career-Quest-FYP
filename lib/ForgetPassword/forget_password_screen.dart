import 'package:career_quest/Services/global_methods.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ForgetPasswordScreen extends StatefulWidget {
  @override
  _ForgetPasswordScreen createState() => _ForgetPasswordScreen();
}

class _ForgetPasswordScreen extends State<ForgetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool isLoading = false;
  int success = -1;
  String message = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 50.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Center(child: Image.asset("assets/images/fogetpassheader.png")),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 20.0, bottom: 10, top: 10),
                      child: Text(
                        "Forget Password",
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'HEL',
                        ),
                      ),
                    ),
                  ],
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Text(
                          "Don’t worry! It occurs. Please enter the email address linked with your account",
                          style: TextStyle(
                            fontSize: 14.0,
                            fontFamily: 'HEL',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // ListTile(
                //   title: Text(
                //     l10n!.email_for_forget_pass_txt,
                //     textAlign: TextAlign.center,
                //     style: const TextStyle(
                //       fontSize: 18.0,
                //       fontFamily: 'HEL',
                //     ),
                //   ),
                //   subtitle: Center(
                //     child: Text(
                //       l10n!.send_code_for_email_txt,
                //       style: const TextStyle(
                //         fontSize: 15.0,
                //         fontFamily: 'HEL',
                //       ),
                //     ),
                //   ),
                // ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    height: 50,
                    child: TextFormField(
                      controller: _emailController,
                      cursorColor: Colors.black,
                      style: const TextStyle(
                        color: Colors.black54,
                        decorationColor: Colors.black,
                      ),
                      decoration: InputDecoration(
                          hintText: 'Enter Your Register Email',
                          hintStyle: TextStyle(color: Colors.grey),
                          enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                          labelStyle: const TextStyle(
                            color: Colors.black,
                          ),
                          focusColor: Colors.black,
                          hoverColor: Colors.black),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onSaved: (String? val) {
                        _emailController.text = val!;
                      },
                    ),
                  ),
                ),
                success == 0
                    ? Text(
                        message,
                        style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16.0,
                            fontFamily: 'HEL'),
                      )
                    : const SizedBox(
                        width: 1,
                      ),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Container(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        width: MediaQuery.of(context).size.width / 1.2,
                        child: MaterialButton(
                          elevation: 5.0,
                          onPressed: () {
                            gotoNextScreen();
                            // Navigator.push(context, Material.MaterialPageRoute(builder: (_)=>VerificationScreen()));
                          },
                          padding: const EdgeInsets.all(15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          color: Colors.green,
                          child: isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  "Send Code",
                                  style: TextStyle(
                                    color: Theme.of(context).cardColor,
                                    letterSpacing: 1.5,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'HEL',
                                  ),
                                ),
                        ),
                      ),
                // SizedBox(
                //
                //   child: MaterialButton(
                //           onPressed: () => {gotoNextScreen()},
                //           color: mTextColor,
                //           shape: RoundedRectangleBorder(
                //             side: const BorderSide(
                //                 color: Colors.white70, width: 1),
                //             borderRadius: BorderRadius.circular(30),
                //           ),
                //           padding: const EdgeInsets.all(10.0),
                //           child: Row(
                //             // Replace with a Row for horizontal icon + text
                //             children: <Widget>[
                //               const SizedBox(
                //                 width: 10,
                //               ),
                //               const Icon(
                //                 Icons.send,
                //                 color: Colors.white,
                //               ),
                //               const SizedBox(
                //                 width: 20,
                //               ),
                //               Text(
                //                 l10n!.get_code_btn_txt,
                //                 style: kBoldStyle,
                //               ),
                //             ],
                //           ),
                //         ),
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }

  gotoNextScreen() async {
    // Route route =
    //     MaterialPageRoute(builder: (context) => ChangePasswordScreen());
    // Navigator.pushReplacement(context, route);
    if (_emailController.text.isEmpty) {
      GlobalMethod.showErrorDialog(error: 'Please Enter Email', ctx: context);
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }
}
