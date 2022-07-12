import 'package:flutter/material.dart';
import 'package:pointdraw/components/main_button.dart';
import 'package:pointdraw/responsive.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants.dart';

class AdvantageSection extends StatelessWidget {
  const AdvantageSection({
    Key? key,
  }) : super(key: key);

  Widget advantageItem(
      String image, String subTitle, String message, double width) {
    return SizedBox(
        width: width,
        child: Column(
          children: [
            Image.asset(image),
            Text(
              subTitle,
              style: const TextStyle(fontSize: 24, color: kTextColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              message,
              style: const TextStyle(fontSize: 16, color: kTextColor),
              textAlign: TextAlign.center,
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin:
            EdgeInsets.symmetric(vertical: 20, horizontal: isDesktop(context) ? horizontalMargin : mobileHorizontalMargin),
        child: Column(
          children: [
            Text(
              "Built for striking results",
              style: GoogleFonts.courgette(
                  fontSize: isDesktop(context) ? 48 : 32,
                  fontWeight: FontWeight.w800,
                  color: kPrimaryColor)),
            const SizedBox(
              height: 20,
            ),
            isMobile(context)
                ? Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      advantageItem(
                          "assets/images/advantage_1.png",
                          "Made by designers like you",
                          "A thoughtfully designed SVG creator tailored to your professional needs. Discover the most efficient and intuitive interface that will maximise your design potential.",
                          250),
                      const SizedBox(
                        height: 40,
                      ),
                      advantageItem(
                          "assets/images/advantage_2.png",
                          "Easy and flexible shape creation",
                          "Create perfect straight lines and proportional rectangles, circles, polygons or stars with ease. Edit compound shapes and custom paths effortlessly.",
                          250),
                      const SizedBox(
                        height: 40,
                      ),
                      advantageItem(
                          "assets/images/advantage_3.png",
                          "Fast editing options, less clicks",
                          "Get started with the Pen tool and work without any interruption. You can always select and move node points or adjust bezier curves on the go.",
                          250),
                    ],
                  ))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      advantageItem(
                          "assets/images/advantage_1.png",
                          "Made by designers like you",
                          "A thoughtfully designed SVG creator tailored to your professional needs. Discover the most efficient and intuitive interface that will maximise your design potential.",
                          isDesktop(context) ? 250 : 180),
                      advantageItem(
                          "assets/images/advantage_2.png",
                          "Easy and flexible shape creation",
                          "Create perfect straight lines and proportional rectangles, circles, polygons or stars with ease. Edit compound shapes and custom paths effortlessly.",
                          isDesktop(context) ? 250 : 180),
                      advantageItem(
                          "assets/images/advantage_3.png",
                          "Fast editing options, less clicks",
                          "Get started with the Pen tool and work without any interruption. You can always select and move node points or adjust bezier curves on the go.",
                          isDesktop(context) ? 250 : 180),
                    ],
                  ),
            const SizedBox(height: 80,)
          ],
        ));
  }
}
