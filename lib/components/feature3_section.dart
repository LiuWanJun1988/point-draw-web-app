import 'package:flutter/material.dart';
import 'package:pointdraw/components/main_button.dart';
import 'package:pointdraw/responsive.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants.dart';

class Feature3Section extends StatelessWidget {
  const Feature3Section({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
        margin: EdgeInsets.symmetric(
            vertical: 20,
            horizontal:
            isDesktop(context) ? horizontalMargin : mobileHorizontalMargin),
        child: Column(
          children: [
            Row(
              children: <Widget>[
                if (isDesktop(context) || isTab(context))
                  Expanded(
                      child: Image.asset(
                        'assets/images/feature1.png',
                        height: size.height * 0.7,
                      )),
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
                              'assets/images/feature1.png',
                              height: size.height * 0.3,
                            ),
                          Text(
                            "More than a simple SVG maker",
                            style: GoogleFonts.courgette(
                                fontSize: isDesktop(context) ? 48 : 32,
                                fontWeight: FontWeight.w800,
                                color: kPrimaryColor),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          Text(
                            "Create SVG online easier than ever and benefit from the ever-growing assets library or upload your own custom elements. Get quick access to the clipping path and rest assured that the origin point of your object will stay where you put it.",
                            textAlign: isMobile(context)
                                ? TextAlign.center
                                : TextAlign.start,
                            style: TextStyle(
                                fontSize: isDesktop(context) ? 16 : 16,
                                fontWeight: FontWeight.w300,
                                color: kTextColor),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Try a pencil tool second to none that creates a significantly lower number of node points than other editors. Your exported file will be as light as a feather and also responsive by default, so It will perfectly fit into your website design right away.",
                            textAlign: isMobile(context)
                                ? TextAlign.center
                                : TextAlign.start,
                            style: TextStyle(
                                fontSize: isDesktop(context) ? 16 : 16,
                                fontWeight: FontWeight.w300,
                                color: kTextColor),
                          ),
                        ],
                      ),
                    )),
              ],
            )
          ],
        ));
  }
}
