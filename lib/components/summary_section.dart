import 'package:flutter/material.dart';
import 'package:pointdraw/components/main_button.dart';
import 'package:pointdraw/responsive.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants.dart';

class SummarySection extends StatelessWidget {
  const SummarySection({
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
                      'assets/images/2.png',
                      height: size.height * 0.3,
                    ),
                  RichText(
                      textAlign: !isMobile(context)
                          ? TextAlign.start
                          : TextAlign.center,
                      text: TextSpan(children: [
                        TextSpan(
                            text: 'Welcome To\n',
                            style: GoogleFonts.courgette(
                                fontSize: isDesktop(context) ? 36 : 20,
                                fontWeight: FontWeight.w800,
                                color: kTextColor)),
                        TextSpan(
                            text: appTitle,
                            style: GoogleFonts.courgette(
                                fontSize: isDesktop(context) ? 48 : 32,
                                fontWeight: FontWeight.w800,
                                color: kPrimaryColor)),
                      ])),
                  const SizedBox(height: 10),
                  Text(
                    summary,
                    textAlign:
                        isMobile(context) ? TextAlign.center : TextAlign.start,
                    style: TextStyle(
                        fontSize: isDesktop(context) ? 16 : 16,
                        fontWeight: FontWeight.w300, color: kTextColor),
                  ),
                  const SizedBox(height: 32),
                  Wrap(
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: <Widget>[
                      MainButton(
                        title: 'GET STARTED',
                        color: kButtonColor,
                        tapEvent: () {},
                      ),
                      const SizedBox(width: 20),
                      MainButton(
                        title: 'Sign Up',
                        color: kButtonColor,
                        tapEvent: () {},
                      )
                    ],
                  )
                ],
              ),
            )),
            if (isDesktop(context) || isTab(context))
              Expanded(
                  child: Image.asset(
                'assets/images/2.png',
                height: size.height * 0.7,
              ))
          ],
        ));
  }
}
