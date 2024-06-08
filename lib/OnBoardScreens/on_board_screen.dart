import 'package:career_quest/LoginPage/login_screen.dart';
import 'package:career_quest/Services/global_methods.dart';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  final List<Widget> _pages = [
    OnboardingPage(
        'Welcome to Career Quest',
        "Career Quest is your gateway to endless career opportunities. Whether you're a seasoned professional or just starting your journey, we're here to help you find the perfect job match. Let's embark on this quest together and shape your future career!",
        "assets/images/welcome_icon_1.png"),
    OnboardingPage(
        'Explore Exciting Opportunities',
        "With Career Quest, explore a vast array of job listings tailored to your skills, interests, and experience. From entry-level positions to executive roles, we've got you covered. Swipe, search, and filter through opportunities from top companies worldwide. Your dream job awaits!",
        "assets/images/welcome_icon_1.png"),
    OnboardingPage(
        'Connect, Apply, Succeed',
        "Unlock the power of networking with Career Quest. Connect with industry professionals, recruiters, and mentors to expand your professional network. Apply to jobs seamlessly and track your applications with ease. Let Career Quest be your companion on the journey to career success!",
        "assets/images/welcome_icon_1.png"),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 50,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              children: _pages,
            ),
          ),
          Row(
            children: [
              Visibility(
                visible: _currentPage == _pages.length - 1,
                child: Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: GestureDetector(
                      onTap: () async {
                        TokenManager.setOnboardingStatus("true");
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => login(),
                          ),
                        );
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        child: Center(
                          child: Text(
                            "Get Started",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Visibility(
                  visible: _currentPage > 0,
                  child: IconButton(
                    icon: Icon(
                      CupertinoIcons.back,
                      color: Colors.green,
                    ),
                    onPressed: _previousPage,
                  ),
                ),
                Visibility(
                  visible: _currentPage == 0,
                  child: IconButton(
                    icon: const Icon(
                      CupertinoIcons.back,
                      color: Colors.transparent,
                    ),
                    onPressed: () {},
                  ),
                ),
                Expanded(
                  child: Center(
                    child: DotsIndicator(
                      dotsCount: _pages.length,
                      position: int.parse(_currentPage.toString()),
                      decorator: DotsDecorator(
                        color: Colors.grey,
                        // Color for future dots
                        activeColor: Colors.green,
                        // Color for current dot

                        activeSize: Size(18.0, 9.0),
                        // Size of the current dot
                        activeShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        // Shape of the current dot
                        spacing: EdgeInsets.symmetric(
                            horizontal: 6.0), // Spacing between dots
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: _currentPage < _pages.length - 1,
                  child: IconButton(
                    icon: Icon(
                      CupertinoIcons.forward,
                      color: Colors.green,
                    ),
                    onPressed: _nextPage,
                  ),
                ),
                Visibility(
                  visible: _currentPage == _pages.length - 1,
                  child: IconButton(
                    icon: const Icon(
                      CupertinoIcons.back,
                      color: Colors.transparent,
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.0),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String image;

  OnboardingPage(this.title, this.description, this.image);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 500),
      opacity: 1.0,
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(30))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  image,
                ),
                // SizedBox(height: 0.01.sh,)
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(10)),
              color: Colors.transparent,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.1, vertical: 30.0),
              child: Column(children: [
                Text(
                  this.title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    this.description,
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
