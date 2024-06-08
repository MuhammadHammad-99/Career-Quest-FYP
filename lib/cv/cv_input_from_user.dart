import 'dart:io';
import 'dart:typed_data';

import 'package:career_quest/Services/global_methods.dart';
import 'package:career_quest/Services/global_variables.dart';
import 'package:career_quest/cv/generate_cv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class CVInputUserScreen extends StatefulWidget {
  const CVInputUserScreen({Key? key}) : super(key: key);

  @override
  State<CVInputUserScreen> createState() => _CVInputUserScreenState();
}

class _CVInputUserScreenState extends State<CVInputUserScreen> {
  File image = File('');
  ImagePickerService imagePickerService = ImagePickerService();
  TextEditingController nameController = TextEditingController();
  TextEditingController occupationController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController contactController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
    occupationController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    emailController.dispose();
    contactController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    getData();
    super.initState();
  }

  getData() async {
    nameController.text = await TokenManager.getCVName() ?? '';

    occupationController.text = await TokenManager.getCVOccupation() ?? '';
    locationController.text = await TokenManager.getCVLocation() ?? '';
    descriptionController.text = await TokenManager.getCVDescription() ?? '';
    emailController.text = await TokenManager.getCVEmail() ?? '';
    contactController.text = await TokenManager.getCVContact() ?? '';

    skillsList = await TokenManager.getSkills();
    experienceList = await TokenManager.getExp();
    educationList = await TokenManager.getEdu();
    socialList = await TokenManager.getSocial();
    String? file = await TokenManager.getCVDp() ?? '';
    if (file != '') {
      image = File(file);
    } else {
      image = File('');
    }
    setState(() {});
  }

  List<String> platforms = [
    'Facebook',
    'Instagram',
    'Skype',
    'LinkedIn',
    'Others'
  ];
  List<String> selectedPlatforms = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildHeader(),
            _buildNameTextField(),
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(color: Colors.grey.shade200),
              child: TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: 'Description about yourself',
                ),
                maxLines: 20,
                minLines: 1,
                maxLength: 250,
              ),
            ),
            _buildTitle("Skills", true),
            _buildSkillsInput(),
            const SizedBox(height: 30.0),
            _buildTitle("Experience", true),
            _buildExperienceInput(),
            const SizedBox(height: 20.0),
            _buildTitle("Education", true),
            _buildEducationInput(),
            const SizedBox(height: 20.0),
            _buildTitle("Contact", false),
            const SizedBox(height: 5.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 1.5,
                  child: TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                        hintText: 'Email',
                        prefixIcon: Icon(Icons.alternate_email)),
                    keyboardType: TextInputType.emailAddress,
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 1.5,
                  child: TextFormField(
                    controller: contactController,
                    decoration: InputDecoration(
                        hintText: 'Contact', prefixIcon: Icon(Icons.phone)),
                    keyboardType: TextInputType.phone,
                    maxLength: 11,
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            _buildContactInput(),
            const SizedBox(height: 5.0),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Social".toUpperCase(),
                          style: const TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Note: Tap to each icon to Add/Edit URL",
                          style: const TextStyle(
                              fontSize: 12.0, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            _buildSocialsRow(),
            const SizedBox(height: 20.0),
            Center(
                child: SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: ElevatedButton(
                  onPressed: () {
                    saveDataAndPreview(context);
                  },
                  child: Text(
                    "Save and preview",
                    style: TextStyle(color: Colors.blue),
                  )),
            ))
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsInput() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (ctx, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                    skillsList[index].name ?? "",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Flexible(
                  child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  skillsList[index].value.toString() ?? "0",
                  style: TextStyle(fontSize: 16),
                ),
              )),
              Flexible(
                  child: IconButton(
                      onPressed: () async {
                        await addSkills(
                            context,
                            true,
                            skillsList[index].name ?? "",
                            skillsList[index].value ?? 0.0,
                            index);
                        setState(() {});
                      },
                      icon: Icon(
                        Icons.edit,
                        color: Colors.blue,
                      ))),
              Flexible(
                  child: IconButton(
                      onPressed: () {
                        removeSkills(ctx, index);
                      },
                      icon: Icon(
                        Icons.remove_circle,
                        color: Colors.red,
                      )))
            ],
          ),
        );
      },
      itemCount: skillsList.length,
    );
  }

  Widget _buildExperienceInput() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (ctx, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                    experienceList[index].company ?? "",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Flexible(
                  child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  experienceList[index].position ?? "",
                  style: TextStyle(fontSize: 16),
                ),
              )),
              Flexible(
                  child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  experienceList[index].duration ?? "",
                  style: TextStyle(fontSize: 16),
                ),
              )),
              Flexible(
                  child: IconButton(
                      onPressed: () async {
                        await addExperience(
                            context,
                            true,
                            experienceList[index].company ?? "",
                            experienceList[index].position ?? "",
                            experienceList[index].duration!.split("-")[0] ?? "",
                            experienceList[index].duration!.split("-")[1] ?? "",
                            index);
                        setState(() {});
                      },
                      icon: Icon(
                        Icons.edit,
                        color: Colors.blue,
                      ))),
              Flexible(
                  child: IconButton(
                      onPressed: () {
                        removeExperience(ctx, index);
                      },
                      icon: Icon(
                        Icons.remove_circle,
                        color: Colors.red,
                      )))
            ],
          ),
        );
      },
      itemCount: experienceList.length,
    );
  }

  Widget _buildEducationInput() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (ctx, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                    educationList[index].uniName ?? "",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Flexible(
                  child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  educationList[index].degreeName ?? "",
                  style: TextStyle(fontSize: 16),
                ),
              )),
              Flexible(
                  child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  educationList[index].cityName ?? "",
                  style: TextStyle(fontSize: 16),
                ),
              )),
              Flexible(
                  child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  educationList[index].duration ?? "",
                  style: TextStyle(fontSize: 16),
                ),
              )),
              Flexible(
                  child: IconButton(
                      onPressed: () async {
                        await addEducation(
                            context,
                            true,
                            educationList[index].uniName ?? "",
                            educationList[index].cityName ?? "",
                            educationList[index].degreeName ?? "",
                            educationList[index].duration!.split("-")[0] ?? "",
                            educationList[index].duration!.split("-")[1] ?? "",
                            index);
                        setState(() {});
                      },
                      icon: Icon(
                        Icons.edit,
                        color: Colors.blue,
                      ))),
              Flexible(
                  child: IconButton(
                      onPressed: () {
                        removeEducation(ctx, index);
                      },
                      icon: Icon(
                        Icons.remove_circle,
                        color: Colors.red,
                      )))
            ],
          ),
        );
      },
      itemCount: educationList.length,
    );
  }

  Widget _buildContactInput() {
    return Column(
      children: [
        // Add text fields here for inputting contact details
        // Example:
        // TextFormField(
        //   decoration: InputDecoration(labelText: 'Email'),
        // ),
        // TextFormField(
        //   decoration: InputDecoration(labelText: 'Phone'),
        // ),
        // Add more text fields as needed for additional contact details
      ],
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
            final data = socialList
                .where((element) => element.name!.toLowerCase() == "facebook")
                .firstOrNull;

            if (data == null) {
              addSocial(context, false, "Facebook", '', -1);
            } else {
              addSocial(context, true, "Facebook", data.URL!,
                  socialList.indexOf(data));
            }
          },
        ),
        const SizedBox(width: 5.0),
        IconButton(
          color: Colors.indigo,
          icon: const Icon(FontAwesomeIcons.github),
          onPressed: () {
            final data = socialList
                .where((element) => element.name!.toLowerCase() == "github")
                .firstOrNull;

            if (data == null) {
              addSocial(context, false, "Github", '', -1);
            } else {
              addSocial(
                  context, true, "Github", data.URL!, socialList.indexOf(data));
            }
          },
        ),
        const SizedBox(width: 5.0),
        IconButton(
          color: Colors.blue,
          icon: const Icon(FontAwesomeIcons.linkedin),
          onPressed: () {
            final data = socialList
                .where((element) => element.name!.toLowerCase() == "linkedin")
                .firstOrNull;

            if (data == null) {
              addSocial(context, false, "Linkedin", '', -1);
            } else {
              addSocial(context, true, "Linkedin", data.URL!,
                  socialList.indexOf(data));
            }
          },
        ),
        IconButton(
          color: Colors.blue,
          icon: const Icon(FontAwesomeIcons.skype),
          onPressed: () {
            final data = socialList
                .where((element) => element.name!.toLowerCase() == "skype")
                .firstOrNull;

            if (data == null) {
              addSocial(context, false, "Skype", '', -1);
            } else {
              addSocial(
                  context, true, "Skype", data.URL!, socialList.indexOf(data));
            }
          },
        ),
        IconButton(
          color: Colors.red,
          icon: const Icon(FontAwesomeIcons.instagram),
          onPressed: () {
            final data = socialList
                .where((element) => element.name!.toLowerCase() == "instagram")
                .firstOrNull;

            if (data == null) {
              addSocial(context, false, "Instagram", '', -1);
            } else {
              addSocial(context, true, "Instagram", data.URL!,
                  socialList.indexOf(data));
            }
          },
        ),
        const SizedBox(width: 10.0),
      ],
    );
  }

  Widget _buildTitle(String title, bool showAddButton) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              showAddButton
                  ? IconButton(
                      onPressed: () async {
                        if (title.toLowerCase().contains("skills")) {
                          await addSkills(
                              context, false, skillName, proficiency, -1);
                        } else if (title.toLowerCase().contains("experience")) {
                          await addExperience(
                              context, false, "", "", "", "", -1);
                        } else if (title.toLowerCase().contains("education")) {
                          await addEducation(
                              context, false, "", "", "", "", "", -1);
                        }
                        setState(() {});
                      },
                      icon: Icon(
                        Icons.add_circle,
                        color: Colors.green,
                      ))
                  : SizedBox(),
            ],
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
                // Replace the image URL below with the user's picture
                child: InkWell(
                  onTap: () async {
                    image =
                        (await imagePickerService.chooseImageFile(context))!;

                    TokenManager.saveCVDP(image);
                    image == null
                        ? GlobalMethod.showErrorDialog(
                            error: 'Image is null', ctx: context)
                        : setState(() {});
                  },
                  child: CircleAvatar(
                    radius: 35.0,
                    backgroundImage: (image != '' && image.path != '')
                        ? Image.file(image).image
                        : AssetImage(
                            'assets/images/add_image.png',
                          ),
                  ),
                ))),
        const SizedBox(width: 20.0),
      ],
    );
  }

  Column _buildNameTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 30,
            child: TextFormField(
              controller: nameController,
              decoration: InputDecoration(hintText: 'Name Here'),
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 10.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 30,
            child: TextFormField(
              controller: occupationController,
              decoration: InputDecoration(hintText: 'Occupation'),
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 10.0),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 30,
              child: TextFormField(
                controller: locationController,
                decoration:
                    InputDecoration(hintText: 'Location e:g City,Country'),
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            )),
      ],
    );
  }

  List<SkillsModel> skillsList = [];
  String skillName = '';
  double proficiency = 0.0;

  addSkills(BuildContext context, bool isUpdate, String name, double value,
      int index) {
    print('object ${skillsList.length}');
    return showDialog(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(builder: (ctx, setState) {
            return AlertDialog(
              title: Text('Enter Skill Proficiency'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    initialValue: name,
                    decoration: InputDecoration(labelText: 'Skill Name'),
                    onChanged: (value) {
                      setState(() {
                        name = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text('Proficiency Level:'),
                      ),
                      Expanded(
                        flex: 2,
                        child: Slider(
                          value: value,
                          min: 0,
                          max: 100,
                          divisions: 100,
                          onChanged: (val) {
                            setState(() {
                              value = val;
                            });
                          },
                        ),
                      ),
                      Text('${value.toInt()}%'),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Here you can use skillName and proficiency however you need
                    if (isUpdate) {
                      if (name.isEmpty) {
                        GlobalMethod.showErrorDialog(
                            error: 'Please enter name', ctx: ctx);
                      } else {
                        skillsList[index].name = name;
                        skillsList[index].value = value;

                        Navigator.of(context).pop();
                      }
                    } else {
                      if (name.isEmpty) {
                        GlobalMethod.showErrorDialog(
                            error: 'Please enter name ', ctx: ctx);
                      } else if (skillsList
                          .contains(SkillsModel(name: name, value: value))) {
                        GlobalMethod.showErrorDialog(
                            error: 'Skills is already added', ctx: ctx);
                      } else {
                        skillName = '';
                        proficiency = 0.0;
                        skillsList.add(SkillsModel(name: name, value: value));

                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            );
          });
        });
  }

  List<SocialModel> socialList = [];
  List<EducationModel> educationList = [];

  addSocial(BuildContext context, bool isUpdate, String name, String url,
      int index) async {
    return showDialog(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(builder: (ctx, setState) {
            return SingleChildScrollView(
              child: AlertDialog(
                title: Text('Enter Social'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      name,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      initialValue: url,
                      decoration: InputDecoration(labelText: name + ' URL'),
                      onChanged: (value) {
                        setState(() {
                          url = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                  ],
                ),
                actions: <Widget>[
                  isUpdate
                      ? ElevatedButton(
                          onPressed: () {
                            removeSocial(index, context);
                            Navigator.of(context).pop();
                          },
                          child: Text('Remove'),
                        )
                      : SizedBox(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Here you can use skillName and proficiency however you need
                      if (isUpdate) {
                        if (url.isEmpty) {
                          GlobalMethod.showErrorDialog(
                              error: 'Please enter URL for ' + name, ctx: ctx);
                        } else {
                          socialList[index].URL = url;
                          Navigator.of(context).pop();
                        }
                      } else {
                        if (url.isEmpty) {
                          GlobalMethod.showErrorDialog(
                              error: 'Please enter URL for ' + name, ctx: ctx);
                        } else {
                          addSocialToList(context, name, url);
                        }
                      }
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
            );
          });
        });
  }

  addEducation(
      BuildContext context,
      bool isUpdate,
      String uniName,
      String cityName,
      String degreeName,
      String startDate,
      String endDate,
      int index) {
    print('object ${experienceList.length}');
    return showDialog(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(builder: (ctx, setState) {
            return SingleChildScrollView(
              child: AlertDialog(
                title: Text('Enter Education'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      initialValue: uniName,
                      decoration: InputDecoration(labelText: 'University Name'),
                      onChanged: (value) {
                        setState(() {
                          uniName = value;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      initialValue: degreeName,
                      decoration: InputDecoration(labelText: 'Your Degreee'),
                      onChanged: (value) {
                        setState(() {
                          degreeName = value;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      initialValue: cityName,
                      decoration: InputDecoration(labelText: 'Your City'),
                      onChanged: (value) {
                        setState(() {
                          cityName = value;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              initialValue: startDate,
                              decoration: InputDecoration(
                                  labelText: 'Start Date', hintText: '19XX'),
                              onChanged: (value) {
                                setState(() {
                                  startDate = value;
                                });
                              },
                            ),
                          ),
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              initialValue: endDate,
                              decoration: InputDecoration(
                                  labelText: 'End Date', hintText: '20XX'),
                              onChanged: (value) {
                                setState(() {
                                  endDate = value;
                                });
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Here you can use skillName and proficiency however you need
                      if (isUpdate) {
                        if (uniName.isEmpty) {
                          GlobalMethod.showErrorDialog(
                              error: 'Please enter university name', ctx: ctx);
                        } else if (cityName.isEmpty) {
                          GlobalMethod.showErrorDialog(
                              error: 'Please enter city name', ctx: ctx);
                        } else if (degreeName.isEmpty) {
                          GlobalMethod.showErrorDialog(
                              error: 'Please enter degree name', ctx: ctx);
                        } else if (startDate.isEmpty) {
                          GlobalMethod.showErrorDialog(
                              error: 'Please enter start date', ctx: ctx);
                        } else if (endDate.isEmpty) {
                          GlobalMethod.showErrorDialog(
                              error: 'Please enter end date', ctx: ctx);
                        } else {
                          educationList[index].uniName = uniName;
                          educationList[index].degreeName = degreeName;
                          educationList[index].cityName = cityName;
                          educationList[index].duration =
                              "$startDate - $endDate";
                          Navigator.of(context).pop();
                        }
                      } else {
                        if (uniName.isEmpty) {
                          GlobalMethod.showErrorDialog(
                              error: 'Please enter university name', ctx: ctx);
                        } else if (cityName.isEmpty) {
                          GlobalMethod.showErrorDialog(
                              error: 'Please enter city name', ctx: ctx);
                        } else if (degreeName.isEmpty) {
                          GlobalMethod.showErrorDialog(
                              error: 'Please enter degree name', ctx: ctx);
                        } else if (startDate.isEmpty) {
                          GlobalMethod.showErrorDialog(
                              error: 'Please enter start date', ctx: ctx);
                        } else if (endDate.isEmpty) {
                          GlobalMethod.showErrorDialog(
                              error: 'Please enter end date', ctx: ctx);
                        } else {
                          educationList.add(EducationModel(
                              uniName: uniName,
                              degreeName: degreeName,
                              cityName: cityName,
                              duration: "$startDate - $endDate"));
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
            );
          });
        });
  }

  List<ExperienceModel> experienceList = [];

  addExperience(BuildContext context, bool isUpdate, String company,
      String position, String startDate, String endDate, int index) {
    print('object ${experienceList.length}');
    return showDialog(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(builder: (ctx, setState) {
            return SingleChildScrollView(
              child: AlertDialog(
                title: Text('Enter Experience'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      initialValue: company,
                      decoration: InputDecoration(labelText: 'Company Name'),
                      onChanged: (value) {
                        setState(() {
                          company = value;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      initialValue: position,
                      decoration: InputDecoration(labelText: 'Your Position'),
                      onChanged: (value) {
                        setState(() {
                          position = value;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              initialValue: startDate,
                              decoration: InputDecoration(
                                  labelText: 'Start Date', hintText: '19XX'),
                              onChanged: (value) {
                                setState(() {
                                  startDate = value;
                                });
                              },
                            ),
                          ),
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              initialValue: endDate,
                              decoration: InputDecoration(
                                  labelText: 'End Date', hintText: '20XX'),
                              onChanged: (value) {
                                setState(() {
                                  endDate = value;
                                });
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Here you can use skillName and proficiency however you need
                      if (isUpdate) {
                        if (company.isEmpty) {
                          GlobalMethod.showErrorDialog(
                              error: 'Please enter company name', ctx: ctx);
                        } else if (position.isEmpty) {
                          GlobalMethod.showErrorDialog(
                              error: 'Please enter position name', ctx: ctx);
                        } else if (startDate.isEmpty) {
                          GlobalMethod.showErrorDialog(
                              error: 'Please enter start date', ctx: ctx);
                        } else if (endDate.isEmpty) {
                          GlobalMethod.showErrorDialog(
                              error: 'Please enter end date', ctx: ctx);
                        } else {
                          experienceList[index].company = company;
                          experienceList[index].position = position;
                          experienceList[index].duration =
                              "$startDate - $endDate";
                          Navigator.of(context).pop();
                        }
                      } else {
                        if (company.isEmpty) {
                          GlobalMethod.showErrorDialog(
                              error: 'Please enter company name', ctx: ctx);
                        } else if (position.isEmpty) {
                          GlobalMethod.showErrorDialog(
                              error: 'Please enter position name', ctx: ctx);
                        } else if (startDate.isEmpty) {
                          GlobalMethod.showErrorDialog(
                              error: 'Please enter start date', ctx: ctx);
                        } else if (endDate.isEmpty) {
                          GlobalMethod.showErrorDialog(
                              error: 'Please enter end date', ctx: ctx);
                        } else {
                          experienceList.add(ExperienceModel(
                              company: company,
                              position: position,
                              duration: "$startDate - $endDate"));
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
            );
          });
        });
  }

  void removeSkills(BuildContext ctx, int index) {
    skillsList.removeAt(index);
    setState(() {});
  }

  void removeExperience(BuildContext ctx, int index) {
    experienceList.removeAt(index);
    setState(() {});
  }

  void removeEducation(BuildContext ctx, int index) {
    educationList.removeAt(index);
    setState(() {});
  }

  void saveDataAndPreview(BuildContext context) {
    if (nameController.text.isEmpty) {
      GlobalMethod.showErrorDialog(error: 'Enter Name', ctx: context);
    } else if (occupationController.text.isEmpty) {
      GlobalMethod.showErrorDialog(error: 'Enter Occupation', ctx: context);
    } else if (locationController.text.isEmpty) {
      GlobalMethod.showErrorDialog(error: 'Enter Location', ctx: context);
    } else if (descriptionController.text.isEmpty) {
      GlobalMethod.showErrorDialog(error: 'Enter Description', ctx: context);
    } else {
      TokenManager.saveCVName(nameController.text);
      TokenManager.saveCVOccupation(occupationController.text);
      TokenManager.saveCVLocation(locationController.text);
      TokenManager.saveCVDescription(descriptionController.text);
      TokenManager.saveContact(contactController.text);
      TokenManager.saveCVEmail(emailController.text);
      if (skillsList.isNotEmpty) {
        TokenManager.saveSkills(skillsList);
      }
      if (experienceList.isNotEmpty) {
        TokenManager.saveExp(experienceList);
      }
      if (educationList.isNotEmpty) {
        TokenManager.saveEdu(educationList);
      }
      if (socialList.isNotEmpty) {
        TokenManager.saveSocial(socialList);
      }

      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => ProfileFourPage()));
    }
  }

  addSocialToList(BuildContext context, String name, String url) async {
    socialList.add(SocialModel(name: name, URL: url));
    Navigator.of(context).pop();
  }

  void removeSocial(int index, BuildContext context) {
    socialList.removeAt(index);
    setState(() {});
  }
}

class EducationModel {
  String? uniName, cityName, degreeName, duration;

  EducationModel({this.uniName, this.cityName, this.degreeName, this.duration});

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    return EducationModel(
      uniName: json["uniName"] ?? "",
      cityName: json["cityName"] ?? "",
      degreeName: json["degreeName"] ?? "",
      duration: json["duration"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "uniName": uniName,
      "cityName": cityName,
      "degreeName": degreeName,
      "duration": duration,
    };
  }
//
}

class ExperienceModel {
  String? company, position, duration;

  ExperienceModel({this.company, this.position, this.duration});

  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      company: json["company"] ?? "",
      position: json["position"] ?? "",
      duration: json["duration"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "company": company,
      "position": position,
      "duration": duration,
    };
  }
//
}

class SocialModel {
  String? name;

  //Uint8List? icon;
  String? URL;

  SocialModel({this.name, this.URL});

  factory SocialModel.fromJson(Map<String, dynamic> json) {
    return SocialModel(
      name: json["name"],
      //icon: json["icon"],
      URL: json["URL"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      //"icon": icon,
      "URL": URL,
    };
  }
//
}

class SkillsModel {
  String? name;
  double? value;

  SkillsModel({this.name, this.value});

  factory SkillsModel.fromJson(Map<String, dynamic> json) {
    return SkillsModel(
      name: json["name"] ?? '',
      value: json["value"] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "value": value,
    };
  }
//
}

class GetPermissions {
  static Future<bool> getCameraPermission(BuildContext ctx) async {
    PermissionStatus permissionStatus = await Permission.camera.status;
    if (permissionStatus.isGranted) {
      return true;
    } else if (permissionStatus.isDenied) {
      PermissionStatus status = await Permission.camera.request();
      if (status.isGranted) {
        return true;
      } else {
        GlobalMethod.showErrorDialog(
            error: 'Camera Permission is required', ctx: ctx);
        return false;
      }
    }
    return false;
  }

  static Future<bool> getGalleryPermission(BuildContext ctx) async {
    PermissionStatus permissionStatus = await Permission.mediaLibrary.status;
    if (permissionStatus.isGranted) {
      return true;
    } else if (permissionStatus.isDenied) {
      PermissionStatus status = await Permission.mediaLibrary.request();
      if (status.isGranted) {
        return true;
      } else {
        GlobalMethod.showErrorDialog(
            error: 'Storage Permission is required', ctx: ctx);
        return false;
      }
    }
    return false;
  }
}

class ImagePickerService {
  Future<PickedFile> pickImage({required ImageSource source}) async {
    final xFileSource = await ImagePicker().pickImage(source: source);
    return PickedFile(xFileSource!.path);
  }

  Future<File?> chooseImageFile(BuildContext context) async {
    try {
      return await showModalBottomSheet(
          context: context, builder: (builder) => bottomSheet(context));
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  Widget bottomSheet(BuildContext context) {
    Future<void> openSource(ImageSource source) async {
      final file = await pickImage(source: source);
      final selected = File(file.path);
      if (await selected.exists()) {
        Navigator.pop(context, selected);
      } else {
        Navigator.pop(context, '');
      }
    }

    var styleF = TextStyle(
        fontSize: 12, letterSpacing: 0.02, fontWeight: FontWeight.w600);

    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Text(
            'Choose Image File',
            style: styleF,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () async {
                  final bool cameraStatus =
                      await GetPermissions.getCameraPermission(context);
                  if (cameraStatus) {
                    openSource(ImageSource.camera);
                  }
                },
                child: Column(
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 22,
                    ),
                    Text(
                      'Camera',
                      style: styleF,
                    )
                  ],
                ),
              ),
              SizedBox(
                width: 1,
              ),
              InkWell(
                onTap: () async {
                  final bool galleryStatus =
                      await GetPermissions.getGalleryPermission(context);
                  if (galleryStatus) {
                    openSource(ImageSource.gallery);
                  }
                },
                child: Column(
                  children: [
                    Icon(
                      Icons.image,
                      size: 22,
                    ),
                    Text(
                      'Gallery',
                      style: styleF,
                    )
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
