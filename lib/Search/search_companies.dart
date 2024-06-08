import 'dart:async';
import 'package:career_quest/LoginPage/login_screen.dart';
import 'package:career_quest/Models/user_model.dart';
import 'package:career_quest/Services/api.dart';
import 'package:career_quest/Widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

import '../Widgets/all_companies_widget.dart';

class AllWorkersScreen extends StatefulWidget {
  @override
  State<AllWorkersScreen> createState() => _AllWorkersScreenState();
}

class _AllWorkersScreenState extends State<AllWorkersScreen> {
  final TextEditingController _searchQueryController = TextEditingController();
  String searchQuery = 'Search query';
  Future<List<UserModel>>? _users;

  @override
  void initState() {
    super.initState();
    _users = ApiManager.getUserByName(null);
    print(_users);
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autocorrect: true,
      decoration: const InputDecoration(
        hintText: 'Search for companies....',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.black),
      ),
      style: const TextStyle(color: Colors.black, fontSize: 16.0),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  bool isSearchClick = false;

  List<Widget> _buildActions() {
    return <Widget>[
      !isSearchClick
          ? IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  isSearchClick = !isSearchClick;
                });
              },
            )
          : SizedBox(),
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          _clearSearchQuery();
        },
      ),
    ];
  }

  void _clearSearchQuery() {
    setState(() {
      isSearchClick = false;
      _searchQueryController.clear();
      updateSearchQuery('');
    });
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
      print(searchQuery);

      _users = ApiManager.getUserByName(searchQuery);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //   gradient: LinearGradient(
      //     colors: [Colors.deepOrange.shade300, Colors.blueAccent],
      //     begin: Alignment.centerLeft,
      //     end: Alignment.centerRight,
      //     stops: const [0.2, 0.9],
      //   ),
      // ),
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBarForApp(
          indexNum: 1,
        ),
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
          automaticallyImplyLeading: false,
          title: isSearchClick
              ? _buildSearchField()
              : Text(
                  'Companies Search',
                  style: TextStyle(fontSize: 18),
                ),
          actions: _buildActions(),
        ),
        body: FutureBuilder(
            future: _users,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final objects = snapshot.data!;
                return ListView.builder(
                    itemCount: objects.length,
                    itemBuilder: (context, index) {
                      final object = objects[index];
                      return AllWorkersWidget(
                          userID: object.id,
                          userName: object.name,
                          userEmail: object.email,
                          phoneNumber: object.phoneNumber,
                          userImageUrl: object.pic);
                    });
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
                child: CircularProgressIndicator(color: Colors.green,),
              );
            }),
      ),
    );
  }
}
