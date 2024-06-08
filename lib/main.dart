import 'package:career_quest/Jobs/job_screen.dart';
import 'package:career_quest/LoginPage/login_screen.dart';
import 'package:career_quest/OnBoardScreens/on_board_screen.dart';
import 'package:career_quest/Services/global_methods.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Career Quest App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        primarySwatch: Colors.blue,
      ),
      home: Splash()
    );
  }
}

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  @override
  void initState() {
    super.initState();

    // Delay the navigation to a new screen for 3 seconds (adjust as needed)
    Future.delayed(Duration(seconds: 4), () async {
      String? accessToken = await TokenManager.getAccessToken();
      String? onBoard = await TokenManager.getOnboardingStatus()??'false';
      print('object ${accessToken.toString()}');
      (accessToken!=null)?Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => JobScreen(),
        ),
      ):onBoard=='true'?Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => login(),
        ),
      ):Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => OnBoarding(),
        ),
      );
    });
  }

//  @override
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 200.0,
        height: 100.0,
        child: Shimmer.fromColors(
          baseColor: Colors.green,
          highlightColor: Colors.white,
          child: Text(
            'Career Quest',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 50.0,
              fontFamily: 'Signatra',
              fontWeight:
              FontWeight.bold,
              color: Colors.white
            ),
          ),
        ),
      )
    );
  }
}
