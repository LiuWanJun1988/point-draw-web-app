import 'package:flutter/material.dart';
import 'package:pointdraw/components/main_button.dart';
import 'package:pointdraw/responsive.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants.dart';

class Feature1Section extends StatelessWidget {
  const Feature1Section({
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
            Text(
              "A free SVG creator right at your fingertips",
              style: GoogleFonts.courgette(
                  fontSize: isDesktop(context) ? 48 : 32,
                  fontWeight: FontWeight.w800,
                  color: kPrimaryColor),
              textAlign: TextAlign.center,
            ),
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
                        "Whether you are a graphic or web designer, PointDraw will always get your job done. Use this powerful SVG maker to turn basic shapes and lines into complex works of art.",
                        textAlign: isMobile(context)
                            ? TextAlign.center
                            : TextAlign.start,
                        style: TextStyle(
                            fontSize: isDesktop(context) ? 16 : 16,
                            fontWeight: FontWeight.w300,
                            color: kTextColor),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "The best part in PointDraw is that you can create and export an endless number of static svg files free of charge! No need for download, you can start to create SVG online whenever you want.",
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
