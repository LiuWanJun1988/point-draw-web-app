import 'package:flutter/material.dart';
import 'package:pointdraw/components/main_button.dart';
import 'package:pointdraw/responsive.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants.dart';

class Feature2Section extends StatelessWidget {
  const Feature2Section({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
        margin: EdgeInsets.symmetric(vertical: 20, horizontal: isDesktop(context) ? horizontalMargin : mobileHorizontalMargin),
        child: Row(
          children: <Widget>[
            Expanded(
                child: Padding(
              padding: EdgeInsets.only(right: !isMobile(context) ? 40 : 0),
              child: Column(
                mainAxisAlignment: !isMobile(context)
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                crossAxisAlignment: !isMobile(context)
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: <Widget>[
                  if (isMobile(context))
                    Image.asset(
                      'assets/images/feature2.png',
                      height: size.height * 0.3,
                    ),
                  RichText(
                      textAlign: !isMobile(context)
                          ? TextAlign.start
                          : TextAlign.center,
                      text: TextSpan(children: [
                        TextSpan(
                            text: "Fast and professional",
                            style: GoogleFonts.courgette(
                                fontSize: isDesktop(context) ? 64 : 32,
                                fontWeight: FontWeight.w800,
                                color: kPrimaryColor)),
                      ])),
                  const SizedBox(height: 10),
                  Text(
                    "Enjoy a familiar interface with a fresh look that works exactly the way you expect it. Invented, tested, and improved by graphic designers, PointDraw provides the ultimate editor experience: faster node workflow, comprehensive graphic tools, professional grid system, smart guides, and snapping options - all integrated into an interface that allows more control over your workspace.",
                    textAlign:
                        isMobile(context) ? TextAlign.center : TextAlign.start,
                    style: TextStyle(
                        fontSize: isDesktop(context) ? 16 : 16,
                        fontWeight: FontWeight.w300, color: kTextColor),
                  ),
                ],
              ),
            )),
            if (isDesktop(context) || isTab(context))
              Expanded(
                  child: Image.asset(
                'assets/images/feature2.png',
                height: size.height,
              ))
          ],
        ));
  }
}
