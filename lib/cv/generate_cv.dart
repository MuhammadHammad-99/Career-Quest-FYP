import 'dart:io';
import 'dart:math';

import 'package:career_quest/Services/global_methods.dart';
import 'package:career_quest/Services/global_variables.dart';
import 'package:career_quest/cv/assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart' as mt;
import 'package:career_quest/cv/cv_input_from_user.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileFourPage extends StatefulWidget {
  const ProfileFourPage({super.key});

  @override
  State<ProfileFourPage> createState() => _ProfileFourPageState();
}

class _ProfileFourPageState extends State<ProfileFourPage> {
  @override
  void initState() {
    // TODO: implement initState
    getData();
    super.initState();
  }

  File cvDp = File('');
  String name = '';
  String occupation = '';
  String location = '';
  String description = '';
  String email = '';
  String contact = '';
  List<SkillsModel> skillsList = [];
  List<ExperienceModel> expList = [];
  List<EducationModel> eduList = [];
  List<SocialModel> socialList = [];

  getData() async {
    String? file = await TokenManager.getCVDp() ?? '';
    name = await TokenManager.getCVName() ?? '';

    occupation = await TokenManager.getCVOccupation() ?? '';
    location = await TokenManager.getCVLocation() ?? '';
    description = await TokenManager.getCVDescription() ?? '';
    email = await TokenManager.getCVEmail() ?? '';
    contact = await TokenManager.getCVContact() ?? '';
    skillsList = await TokenManager.getSkills();
    expList = await TokenManager.getExp();
    eduList = await TokenManager.getEdu();
    socialList = await TokenManager.getSocial();
    print('object ${skillsList.length} ${expList.length} ${eduList.length}');
    if (file != '' || file != null) {
      cvDp = File(file!);
    } else {
      cvDp = File('');
    }
    setState(() {});
  }

  pw.Widget _buildRow(
      int startIndex,
      int endIndex,
      List<SocialModel> socialList,
      pw.MemoryImage facebookIcon,
      pw.MemoryImage instagramIcon,
      pw.MemoryImage gitHubIcon,
      pw.MemoryImage skypeIcon,
      pw.MemoryImage linkedinIcon,
      pw.MemoryImage dotIcon) {
    return pw.Row(
      children: [
        for (int i = startIndex; i < endIndex; i++)
          if (i < socialList.length)
            _buildItem(i, socialList, facebookIcon, instagramIcon, gitHubIcon,
                skypeIcon, linkedinIcon, dotIcon),
      ],
    );
  }

  pw.Widget _buildItem(
    int index,
    List<SocialModel> socialList,
    pw.MemoryImage facebookIcon,
    pw.MemoryImage instagramIcon,
    pw.MemoryImage gitHubIcon,
    pw.MemoryImage skypeIcon,
    pw.MemoryImage linkedinIcon,
    pw.MemoryImage dotIcon,
  ) {
    String name = socialList[index].name ?? "";
    return pw.Container(
      padding: pw.EdgeInsets.only(top: 8.0, left: 8.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.start,
        children: [
          pw.Container(
            padding: pw.EdgeInsets.only(top: 2.0, right: 8.0),
            child: pw.Image(
              name.toLowerCase().contains('facebook')
                  ? facebookIcon
                  : name.toLowerCase().contains('instagram')
                      ? instagramIcon
                      : name.toLowerCase().contains('github')
                          ? gitHubIcon
                          : name.toLowerCase().contains('skype')
                              ? skypeIcon
                              : name.toLowerCase().contains('linkedin')
                                  ? linkedinIcon
                                  : dotIcon,
              height: 10,
              width: 10,
              fit: pw.BoxFit.fill,
            ),
          ),
          pw.Text(
            '${socialList[index].URL}',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              decoration: pw.TextDecoration.underline,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> generateCV(
      File cvDp,
      String name,
      String occupation,
      String location,
      String description,
      List<SkillsModel> skillsList,
      List<ExperienceModel> expList,
      List<EducationModel> eduList,
      List<SocialModel> socialList,
      String email,
      String contact) async {
    final pdf = pw.Document();

    final emailIcon = pw.MemoryImage(
      (await rootBundle.load('assets/images/email.png')).buffer.asUint8List(),
    );
    final locationIcon = pw.MemoryImage(
      (await rootBundle.load('assets/images/location.png'))
          .buffer
          .asUint8List(),
    );
    final occupationIcon = pw.MemoryImage(
      (await rootBundle.load('assets/images/occupation.png'))
          .buffer
          .asUint8List(),
    );
    final phoneIcon = pw.MemoryImage(
      (await rootBundle.load('assets/images/phone.png')).buffer.asUint8List(),
    );
    final dotIcon = pw.MemoryImage(
      (await rootBundle.load('assets/images/dot.png')).buffer.asUint8List(),
    );
    final facebookIcon = pw.MemoryImage(
      (await rootBundle.load('assets/images/facebook.png'))
          .buffer
          .asUint8List(),
    );
    final gitHubIcon = pw.MemoryImage(
      (await rootBundle.load('assets/images/github.png')).buffer.asUint8List(),
    );
    final instagramIcon = pw.MemoryImage(
      (await rootBundle.load('assets/images/instagram.png'))
          .buffer
          .asUint8List(),
    );
    final linkedinIcon = pw.MemoryImage(
      (await rootBundle.load('assets/images/linkd.png')).buffer.asUint8List(),
    );
    final skypeIcon = pw.MemoryImage(
      (await rootBundle.load('assets/images/skype.png')).buffer.asUint8List(),
    );
    final materialIcons = await rootBundle.load("assets/fa.ttf");
    final materialIconsTtf = pw.Font.ttf(materialIcons);
    final imageFile = await cvDp.readAsBytes();

    pdf.addPage(
      pw.Page(
        theme: pw.ThemeData.withFont(icons: materialIconsTtf),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Row(
                children: <pw.Widget>[
                  pw.SizedBox(width: 20.0),
                  pw.SizedBox(
                    width: 80.0,
                    height: 80.0,
                    child: pw.Container(
                      width: 100,
                      height: 100,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        color: PdfColors.grey,
                      ),
                      child: pw.ClipOval(
                        child: imageFile != null
                            ? pw.Image(pw.MemoryImage(imageFile))
                            : pw.Container(), // Placeholder or default image
                      ),
                    ),
                    // CircleAvatar(
                    //     radius: 40,
                    //     backgroundColor: Colors.grey,
                    //     child: CircleAvatar(
                    //       radius: 35.0,
                    //       backgroundImage: (cvDp != null && cvDp.path != '')
                    //           ? Image.file(cvDp).image
                    //           : const AssetImage(
                    //               'assets/images/add_image.png'),
                    //     ))
                  ),
                  pw.SizedBox(width: 10.0),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Text(
                        name,
                        style: pw.TextStyle(
                            fontSize: 18.0, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 10.0),
                      pw.Row(
                        children: <pw.Widget>[
                          pw.Image(occupationIcon,
                              height: 20, width: 20, fit: pw.BoxFit.fill),
                          pw.SizedBox(width: 10.0),
                          pw.Text(
                            occupation,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 10.0),
                      pw.Row(
                        children: <pw.Widget>[
                          pw.Image(locationIcon,
                              height: 20, width: 20, fit: pw.BoxFit.fill),
                          pw.SizedBox(width: 10.0),
                          pw.Text(
                            location,
                            style: pw.TextStyle(color: PdfColors.black),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
              pw.SizedBox(height: 5.0),
              socialList.isNotEmpty
                  ? pw.Container(
                      width: 150,
                      child: socialList.length == 5
                          ? pw.Column(
                              children: [
                                _buildRow(0, 3, socialList,facebookIcon,instagramIcon,gitHubIcon,skypeIcon,linkedinIcon,dotIcon),
                                _buildRow(3, 5, socialList,facebookIcon,instagramIcon,gitHubIcon,skypeIcon,linkedinIcon,dotIcon),
                              ],
                            )
                          : pw.Row(
                              children: [
                                for (int i = 0; i < socialList.length; i++)
                                  _buildItem(i, socialList,facebookIcon,instagramIcon,gitHubIcon,skypeIcon,linkedinIcon,dotIcon),
                              ],
                            ),
                    )
                  : pw.SizedBox(),
              pw.Container(
                margin: const pw.EdgeInsets.all(16.0),
                padding: const pw.EdgeInsets.all(16.0),
                decoration: pw.BoxDecoration(color: PdfColors.grey),
                child: pw.Text(description),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 16.0),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.Text(
                      "SKILLS".toUpperCase(),
                      style: pw.TextStyle(
                          fontSize: 18.0, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Divider(
                      color: PdfColors.black,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 10.0),
              skillsList.isNotEmpty
                  ? pw.ListView.builder(
                      itemBuilder: (context, index) {
                        return pw.Row(
                          children: <pw.Widget>[
                            pw.SizedBox(width: 16.0),
                            pw.Expanded(
                                flex: 2,
                                child: pw.Text(
                                  skillsList[index].name!.toUpperCase(),
                                  textAlign: pw.TextAlign.right,
                                )),
                            pw.SizedBox(width: 10.0),
                            pw.Expanded(
                              flex: 5,
                              child: pw.LinearProgressIndicator(
                                value:
                                    ((skillsList[index].value ?? 0.0) / (100)),
                              ),
                            ),
                            pw.SizedBox(width: 16.0),
                          ],
                        );
                      },
                      itemCount: skillsList.length,
                    )
                  : pw.SizedBox(),
              pw.SizedBox(height: 10.0),
              pw.Padding(
                padding: pw.EdgeInsets.only(left: 16.0),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.Text(
                      "Experience".toUpperCase(),
                      style: pw.TextStyle(
                          fontSize: 18.0, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Divider(
                      color: PdfColors.black,
                    ),
                  ],
                ),
              ),
              expList.isNotEmpty
                  ? pw.ListView.builder(
                      itemBuilder: (context, index) {
                        return pw.Container(
                          padding: pw.EdgeInsets.only(top: 8.0, left: 20.0),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Container(
                                padding:
                                    pw.EdgeInsets.only(top: 2.0, right: 8.0),
                                child: pw.Image(dotIcon,
                                    height: 15, width: 15, fit: pw.BoxFit.fill),
                              ),
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    expList[index].company ?? "",
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold),
                                  ),
                                  pw.Text(
                                      '${expList[index].position ?? ""} (${expList[index].duration ?? ""})'),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      itemCount: expList.length,
                    )
                  : pw.SizedBox(),
              pw.SizedBox(height: 10.0),
              pw.Padding(
                padding: pw.EdgeInsets.only(left: 16.0),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.Text(
                      "Education".toUpperCase(),
                      style: pw.TextStyle(
                          fontSize: 18.0, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Divider(
                      color: PdfColors.black,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 5.0),
              eduList.isNotEmpty
                  ? pw.ListView.builder(
                      itemBuilder: (context, index) {
                        return pw.Container(
                          padding: pw.EdgeInsets.only(top: 8.0, left: 20.0),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Container(
                                padding:
                                    pw.EdgeInsets.only(top: 2.0, right: 8.0),
                                child: pw.Image(dotIcon,
                                    height: 15, width: 15, fit: pw.BoxFit.fill),
                              ),
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    '${eduList[index].uniName}, ${eduList[index].cityName}',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold),
                                  ),
                                  pw.Text(
                                      '${eduList[index].degreeName} (${eduList[index].duration})'),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      itemCount: eduList.length,
                    )
                  : pw.SizedBox(),
              pw.SizedBox(height: 10.0),
              pw.Padding(
                padding: pw.EdgeInsets.only(left: 16.0),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.Text(
                      "Contact".toUpperCase(),
                      style: pw.TextStyle(
                          fontSize: 18.0, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Divider(
                      color: PdfColors.black,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 5.0),
              pw.Row(
                children: <pw.Widget>[
                  pw.SizedBox(width: 30.0),
                  pw.Image(emailIcon,
                      height: 20, width: 20, fit: pw.BoxFit.fill),
                  pw.SizedBox(width: 10.0),
                  pw.Text(
                    email,
                    style: pw.TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
              pw.SizedBox(height: 10.0),
              pw.Row(
                children: <pw.Widget>[
                  pw.SizedBox(width: 30.0),
                  pw.Image(phoneIcon,
                      height: 20, width: 20, fit: pw.BoxFit.fill),
                  pw.SizedBox(width: 10.0),
                  pw.Text(
                    contact,
                    style: pw.TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
              // pw.Padding(
              //   padding: pw.EdgeInsets.only(left: 16.0),
              //   child: pw.Column(
              //     crossAxisAlignment: pw.CrossAxisAlignment.start,
              //     children: <pw.Widget>[
              //       pw.Text(
              //         "Social".toUpperCase(),
              //         style: pw.TextStyle(
              //             fontSize: 18.0, fontWeight: pw.FontWeight.bold),
              //       ),
              //       pw.Divider(
              //         color: PdfColors.black,
              //       ),
              //     ],
              //   ),
              // ),
              //
            ],
          );
        },
      ),
    );
    final String dir = (await getExternalStorageDirectory())!.path;
    final String path = '$dir/user_cv.pdf';
    final File file = File(path!);
    await file.writeAsBytes(await pdf.save());
    OpenFile.open(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                generateCV(cvDp, name, occupation, location, description,
                    skillsList, expList, eduList, socialList, email, contact);
              },
              child: Text(
                'Save as PDF',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline),
              ),
            ),
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildHeader(),
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(color: Colors.grey.shade200),
              child: Text(description),
            ),
            _buildTitle("Skills"),
            const SizedBox(height: 10.0),
            skillsList.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return _buildSkillRow(skillsList[index].name ?? "",
                          skillsList[index].value ?? 0.0);
                    },
                    itemCount: skillsList.length,
                  )
                : const SizedBox(),
            const SizedBox(height: 30.0),
            _buildTitle("Experience"),
            expList.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return _buildExperienceRow(
                          company: expList[index].company ?? "",
                          position: expList[index].position ?? "",
                          duration: expList[index].duration ?? "");
                    },
                    itemCount: expList.length,
                  )
                : const SizedBox(),
            // _buildExperienceRow(
            //     company: "Online Teaching",
            //     position: "Laravel Developer",
            //     duration: "2012 - 2015"),
            // _buildExperienceRow(
            //     company: "Online Teaching",
            //     position: "Web Developer",
            //     duration: "2015 - 2018"),
            // _buildExperienceRow(
            //     company: "Online Teaching",
            //     position: "Flutter Developer",
            //     duration: "2018 - Current"),
            const SizedBox(height: 20.0),
            _buildTitle("Education"),
            const SizedBox(height: 5.0),
            eduList.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return _buildExperienceRow(
                          company:
                              ('${eduList[index].uniName ?? ""}, ${eduList[index].cityName ?? ""}'),
                          position: eduList[index].degreeName ?? "",
                          duration: eduList[index].duration ?? "");
                    },
                    itemCount: eduList.length,
                  )
                : const SizedBox(),
            const SizedBox(height: 20.0),
            _buildTitle("Contact"),
            const SizedBox(height: 5.0),
            Row(
              children: <Widget>[
                const SizedBox(width: 30.0),
                const Icon(
                  Icons.mail,
                  color: Colors.black54,
                ),
                const SizedBox(width: 10.0),
                Text(
                  email,
                  style: const TextStyle(fontSize: 16.0),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              children: <Widget>[
                const SizedBox(width: 30.0),
                const Icon(
                  Icons.phone,
                  color: Colors.black54,
                ),
                const SizedBox(width: 10.0),
                Text(
                  contact,
                  style: const TextStyle(fontSize: 16.0),
                ),
              ],
            ),
            _buildTitle("Social"),
            const SizedBox(height: 5.0),
            socialList.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            socialList[index].name ?? "",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(socialList[index].URL ?? ""),
                        ],
                      );
                    },
                    itemCount: socialList.length,
                  )
                : const SizedBox(),
            //_buildSocialsRow(),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  Row _buildSocialsRow() {
    return Row(
      children: <Widget>[
        const SizedBox(width: 20.0),
        IconButton(
          color: Colors.indigo,
          icon: const Icon(FontAwesomeIcons.facebookF),
          onPressed: () {
            _launchURL("https://facebook.com/");
          },
        ),
        const SizedBox(width: 5.0),
        IconButton(
          color: Colors.indigo,
          icon: const Icon(FontAwesomeIcons.github),
          onPressed: () {
            _launchURL("https://github.com/");
          },
        ),
        const SizedBox(width: 5.0),
        IconButton(
          color: Colors.red,
          icon: const Icon(FontAwesomeIcons.youtube),
          onPressed: () {
            _launchURL("https://youtube.com/");
          },
        ),
        const SizedBox(width: 10.0),
      ],
    );
  }

  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  ListTile _buildExperienceRow(
      {required String company, String? position, String? duration}) {
    return ListTile(
      leading: const Padding(
        padding: EdgeInsets.only(top: 8.0, left: 20.0),
        child: Icon(
          FontAwesomeIcons.solidCircle,
          size: 12.0,
          color: Colors.black54,
        ),
      ),
      title: Text(
        company,
        style:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      subtitle: Text("$position ($duration)"),
    );
  }

  Row _buildSkillRow(String skill, double level) {
    level = level / 100;
    return Row(
      children: <Widget>[
        const SizedBox(width: 16.0),
        Expanded(
            flex: 2,
            child: Text(
              skill.toUpperCase(),
              textAlign: TextAlign.right,
            )),
        const SizedBox(width: 10.0),
        Expanded(
          flex: 5,
          child: LinearProgressIndicator(
            value: level,
          ),
        ),
        const SizedBox(width: 16.0),
      ],
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title.toUpperCase(),
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          const Divider(
            color: Colors.black54,
          ),
        ],
      ),
    );
  }

  Row _buildHeader() {
    return Row(
      children: <Widget>[
        const SizedBox(width: 20.0),
        SizedBox(
            width: 80.0,
            height: 80.0,
            child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey,
                child: CircleAvatar(
                  radius: 35.0,
                  backgroundImage: (cvDp != null && cvDp.path != '')
                      ? Image.file(cvDp).image
                      : const AssetImage('assets/images/add_image.png'),
                ))),
        const SizedBox(width: 20.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              name,
              style:
                  const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            Text(
              occupation,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5.0),
            Row(
              children: <Widget>[
                const Icon(
                  FontAwesomeIcons.map,
                  size: 12.0,
                  color: Colors.black54,
                ),
                const SizedBox(width: 10.0),
                Text(
                  location,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ],
        )
      ],
    );
  }
}
