class JobDetailModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final int applicants;
  final String category;
  final List<dynamic> comments;
  final String createdAt;
  final String deadlineDate;
  final bool recruitment;
  final String uploadedBy;
  final dynamic uploader;

  JobDetailModel(
      {required this.id,
      required this.title,
      required this.description,
      required this.location,
      required this.applicants,
      required this.category,
      required this.comments,
      required this.createdAt,
      required this.deadlineDate,
      required this.recruitment,
      required this.uploadedBy,
      required this.uploader});

  factory JobDetailModel.fromJson(Map<String, dynamic> json) {
    return JobDetailModel(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        location: json['location'],
        applicants: json['applicants'],
        category: json['category'],
        comments: json['comments'],
        createdAt: json['createdAt'],
        deadlineDate: json['deadlineDate'],
        recruitment: json['recruitment'],
        uploadedBy: json['uploadedBy'],
        uploader: json['uploader']);
  }
}
