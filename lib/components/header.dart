import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:pointdraw/responsive.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pointdraw/screens/home/gallery.dart';
import 'package:pointdraw/screens/home/home.dart';
import 'package:pointdraw/point_draw_models/svg/point_draw_render_screen.dart';

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
            'assets/images/point-draw-logo.png',
            width: 120,
          ),
          const Spacer(),
          if (!isMobile(context))
            Row(
              children: [
                if(!kReleaseMode)
                  NavItem(
                    title: 'Point draw renderer',
                    tapEvent: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder: (context, _, __) => PointDrawRenderScreen(),
                        ),
                      );
                    },
                  ),
                NavItem(
                  title: 'HOME',
                  tapEvent: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                          settings: const RouteSettings(name: '/home')),
                    );
                  },
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
                  tapEvent: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const GalleryScreen(),
                          settings: const RouteSettings(name: '/gallery')),
                    );
                  },
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
                icon: const Icon(
                  Icons.menu,
                  color: kTextColor,
                ),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                })
        ],
      ),
    );
  }
}
