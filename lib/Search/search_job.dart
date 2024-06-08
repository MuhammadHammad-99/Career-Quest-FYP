import 'dart:async';
import 'package:career_quest/Services/api.dart';
import 'package:flutter/material.dart';
import 'package:career_quest/Widgets/job_widget.dart';

import '../Jobs/job_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchQueryController = TextEditingController();
  String? searchQuery = 'Search query';
  Future<List<JobWidget>>? _jobs;

  @override
  void initState() {
    super.initState();
    _jobs = ApiManager.getListJobs(null, null);
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autocorrect: true,
      decoration: const InputDecoration(
        hintText: 'Search for jobs....',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  List<Widget> _buildActions() {
    return <Widget>[
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
      _searchQueryController.clear();
      updateSearchQuery(null);
    });
  }

  void updateSearchQuery(String? newQuery) {
    setState(() {
      searchQuery = newQuery;
      _jobs = ApiManager.getListJobs(searchQuery, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepOrange.shade300, Colors.blueAccent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.2, 0.9],
        ),
      ),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepOrange.shade300, Colors.blueAccent],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: const [0.2, 0.9],
                ),
              ),
            ),
            leading: IconButton(
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => JobScreen()));
              },
              icon: const Icon(Icons.arrow_back),
            ),
            title: _buildSearchField(),
            actions: _buildActions(),
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
                      return JobWidget(
                        id: object.id,
                        title: object.title,
                        description: object.description,
                        uploadedBy: object.uploadedBy,
                        recruitment: object.recruitment,
                        location: object.location,
                        category: object.category,
                      );
                    },
                  );
                }
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          )),
    );
  }
}
