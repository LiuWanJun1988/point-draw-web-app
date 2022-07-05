import 'package:flutter/material.dart';
import 'package:pointdraw/responsive.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants.dart';
import 'menu_item.dart';

class Header extends StatelessWidget {
  const Header({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Row(
        children: <Widget>[
          Image.asset(
            'assets/images/point-draw-icon.png',
            width: 50,
          ),
          const SizedBox(width: 10),
          Text(
            appTitle,
            style: GoogleFonts.indieFlower(fontSize: 18, color: kTextColor),
          ),
          const Spacer(),
          if (!isMobile(context))
            Row(
              children: [
                NavItem(
                  title: 'HOME',
                  tapEvent: () {},
                ),
                NavItem(
                  title: 'TUTORIALS ',
                  tapEvent: () {},
                ),
                NavItem(
                  title: 'PRICING',
                  tapEvent: () {},
                ),
                NavItem(
                  title: 'GALLERY',
                  tapEvent: () {},
                ),
                NavItem(
                  title: 'LOGIN',
                  tapEvent: () {},
                ),
                NavItem(
                  title: 'SIGNUP',
                  tapEvent: () {},
                ),
              ],
            ),
          if (isMobile(context))
            IconButton(
                icon: const Icon(Icons.menu, color: kTextColor,),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                })
        ],
      ),
    );
  }
}
