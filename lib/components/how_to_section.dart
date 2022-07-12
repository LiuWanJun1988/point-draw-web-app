import 'package:flutter/material.dart';
import 'package:pointdraw/components/main_button.dart';
import 'package:pointdraw/responsive.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants.dart';

class HowToSection extends StatelessWidget {
  const HowToSection({
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
              "How to make SVG files",
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
                          "Step 1",
                          "Draw SVG with the editing tools or jumpstart your project with custom shapes. Use anything from the assets library or upload your own elements.",
                          250),
                      const SizedBox(
                        height: 40,
                      ),
                      advantageItem(
                          "assets/images/advantage_2.png",
                          "Step 2",
                          "Play with colors, gradients and filters, add masks, text or anything you want. You’ll have full creative freedom to bring your ideas to life!",
                          250),
                      const SizedBox(
                        height: 40,
                      ),
                      advantageItem(
                          "assets/images/advantage_3.png",
                          "Step 3",
                          "Export and show off your amazing illustrations! Your projects are always easily accessible, anywhere you are.",
                          250),
                    ],
                  ))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      advantageItem(
                          "assets/images/advantage_1.png",
                          "Step 1",
                          "Draw SVG with the editing tools or jumpstart your project with custom shapes. Use anything from the assets library or upload your own elements.",
                          isDesktop(context) ? 250 : 180),
                      advantageItem(
                          "assets/images/advantage_2.png",
                          "Step 2",
                          "Play with colors, gradients and filters, add masks, text or anything you want. You’ll have full creative freedom to bring your ideas to life!",
                          isDesktop(context) ? 250 : 180),
                      advantageItem(
                          "assets/images/advantage_3.png",
                          "Step 3",
                          "Export and show off your amazing illustrations! Your projects are always easily accessible, anywhere you are.",
                          isDesktop(context) ? 250 : 180),
                    ],
                  ),
            const SizedBox(height: 80,)
          ],
        ));
  }
}
