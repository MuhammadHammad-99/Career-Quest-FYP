import 'package:career_quest/LoginPage/login_screen.dart';
import 'package:career_quest/Services/api.dart';
import 'package:career_quest/Services/global_methods.dart';
import 'package:flutter/material.dart';
import 'package:career_quest/Search/search_job.dart';
import 'package:career_quest/Widgets/bottom_nav_bar.dart';
import 'package:career_quest/Widgets/job_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Persistent/persistent.dart';

class JobScreen extends StatefulWidget {
  const JobScreen({super.key});

  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {
  String? jobCategoryFilter;
  Future<List<JobWidget>>? _jobs;

  void updateFilter(String? filter) {
    jobCategoryFilter = filter;
    _jobs = ApiManager.getListJobs(null, jobCategoryFilter);
  }

  _showTaskCategoriesDialog({required Size size}) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: Colors.black54,
            title: const Text(
              'Job Category',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            content: SizedBox(
              width: size.width * 0.9,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: Persistent.jobCategoryList.length,
                  itemBuilder: (ctx, index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          updateFilter(Persistent.jobCategoryList[index]);
                        });
                        Navigator.canPop(context)
                            ? Navigator.pop(context)
                            : null;
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.arrow_right_alt_outlined,
                            color: Colors.grey,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              Persistent.jobCategoryList[index],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    updateFilter(null);
                  });
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
                child: const Text(
                  'Cancel Filter',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _jobs = ApiManager.getListJobs(null, null);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      onPopInvoked: (isClick) {
        print('object ${isClick}');
      },
      child: Container(
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     colors: [Colors.deepOrange.shade300, Colors.blueAccent],
        //     begin: Alignment.centerLeft,
        //     end: Alignment.centerRight,
        //     stops: const [0.2, 0.9],
        //   ),
        // ),
        child: Scaffold(
            bottomNavigationBar: BottomNavigationBarForApp(indexNum: 0),
            backgroundColor: Colors.white,
            appBar: AppBar(
              // flexibleSpace: Container(
              //   decoration: BoxDecoration(
              //     gradient: LinearGradient(
              //       colors: [Colors.deepOrange.shade300, Colors.blueAccent],
              //       begin: Alignment.centerLeft,
              //       end: Alignment.centerRight,
              //       stops: const [0.2, 0.9],
              //     ),
              //   ),
              // ),
              centerTitle: true,
              title: Text(
                'All Jobs',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
              backgroundColor: Colors.green,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(
                  Icons.filter_list_rounded,
                  color: Colors.white,
                ),
                onPressed: () {
                  _showTaskCategoriesDialog(size: size);
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.search_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (c) => const SearchScreen()));
                  },
                ),
              ],
            ),
            body: FutureBuilder<List<JobWidget>>(
              future: _jobs,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final objects = snapshot.data!;
                  if (objects.isEmpty) {
                    return const Center(
                      child: Text('No Jobs Found!'),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: objects.length,
                      itemBuilder: (context, index) {
                        final object = objects[index];
                        return Dismissible(
                          key: ObjectKey(object.id),
                          direction: DismissDirection.startToEnd,
                          background: Container(
                            color: Colors.red,
                            padding: const EdgeInsets.only(left: 16),
                            child: const Align(
                                alignment: Alignment.centerLeft,
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                )),
                          ),
                          confirmDismiss: (direction) {
                            final result =
                                _deleteDialog(object.uploadedBy, object.id);
                            if(result!=null){
                              return result;
                            }else{
                              return Future(() => false);
                            }
                          },
                          child: JobWidget(
                            id: object.id,
                            title: object.title,
                            description: object.description,
                            uploadedBy: object.uploadedBy,
                            recruitment: object.recruitment,
                            location: object.location,
                            category: object.category,
                          ),
                        );
                      },
                    );
                  }
                } else if (snapshot.hasError) {
                  if (snapshot.error.toString().contains("Token has expired")) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => login()));
                  } else {
                    return Center(
                      child: Text('${snapshot.error}'),
                    );
                  }
                }

                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.green,
                  ),
                );
              },
            )),
      ),
    );
  }

  _deleteDialog(String userID, String id) {
    String? uid;
    ApiManager.getUser().then((value) {
      uid = value.id;
    });
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            actions: [
              TextButton(
                onPressed: () {
                  if (userID == uid) {
                    Future<dynamic> res = ApiManager.deleteJob(id);
                    res.then((data) {
                      if (data.contains('Job Deleted!')) {

                        Navigator.pop(ctx);
                        Fluttertoast.showToast(
                          msg: 'Job deleted successfully',
                          toastLength: Toast.LENGTH_LONG,
                          backgroundColor: Colors.grey,
                          fontSize: 18.0,
                        );
                        setState(() {
                          _jobs = ApiManager.getListJobs(null, null);
                        });
                      } else {
                        GlobalMethod.showErrorDialog(error: data, ctx: ctx);
                      }
                    }).catchError((err) {
                      GlobalMethod.showErrorDialog(
                          error: err.toString(), ctx: ctx);
                    });
                  } else {
                    Navigator.pop(ctx);
                    GlobalMethod.showErrorDialog(
                        error: 'You cant delete this job', ctx: ctx);
                  }
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }
}
