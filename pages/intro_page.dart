import 'package:flutter/material.dart';
import 'package:maps/constants/colors.dart';
import 'package:maps/constants/routes.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  final List<Widget> _pages = const [
    IntroContainer1(),
    IntroContainer2(),
    IntroContainer3(),
    IntroContainer4(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryRedColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryRedColor,
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(loginRoute, (route) => false);
            },
            icon: const Text(
              'LOGIN',
              style: TextStyle(
                fontFamily: 'MavenPro',
              ),
            ),
            label: const Icon(Icons.double_arrow_rounded),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            width: MediaQuery.of(context).size.width,
            child: PageView(
              controller: _pageController,
              children: _pages,
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.linear,
                    );
                  },
                  icon: const Icon(
                    Icons.arrow_circle_left,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.linear,
                    );
                  },
                  icon: const Icon(
                    Icons.arrow_circle_right,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class IntroContainer1 extends StatelessWidget {
  const IntroContainer1({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          Image(
            image: AssetImage('./lib/assets/images/aurak_logo.png'),
            height: 150,
            width: 150,
          ),
          Text(
            'WELCOME\nTO\nAURAK MAPS',
            style: TextStyle(
                fontFamily: 'MavenPro',
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class IntroContainer2 extends StatelessWidget {
  const IntroContainer2({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          Image(
            image: AssetImage('./lib/assets/images/aurak_logo.png'),
            height: 150,
            width: 150,
          ),
          Text(
            'AN APP TO HELP YOU FIND YOUR WAY AROUND CAMPUS',
            style: TextStyle(
                fontFamily: 'MavenPro',
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class IntroContainer3 extends StatelessWidget {
  const IntroContainer3({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          Image(
            image: AssetImage('./lib/assets/images/aurak_logo.png'),
            height: 150,
            width: 150,
          ),
          Text(
            'WITH OUTDOOR NAVIGATION',
            style: TextStyle(
                fontFamily: 'MavenPro',
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class IntroContainer4 extends StatelessWidget {
  const IntroContainer4({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          Image(
            image: AssetImage('./lib/assets/images/aurak_logo.png'),
            height: 150,
            width: 150,
          ),
          Text(
            'AND INDOOR NAVIGATION',
            style: TextStyle(
                fontFamily: 'MavenPro',
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
