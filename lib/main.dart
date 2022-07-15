import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pointdraw/constants.dart';
import 'package:pointdraw/screens/home/home.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    name: "point-draw-web-app",
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const PointDrawApp());
}

class PointDrawApp extends StatelessWidget {
  const PointDrawApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Point Draw',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: backgroundColor,
          primaryColor: kPrimaryColor,
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme.apply(bodyColor: Colors.white,
            displayColor: Colors.white,))),
      home: HomeScreen(),
    );
  }
}
