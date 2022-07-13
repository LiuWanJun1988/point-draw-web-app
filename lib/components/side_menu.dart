import 'package:flutter/material.dart';
import '../constants.dart';
import 'menu_item.dart';
import 'package:pointdraw/screens/home/gallery.dart';
import 'package:pointdraw/screens/home/home.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      color: Colors.indigo.shade500,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(50),
          child: Column(
            children: [
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

              SizedBox(height: sideMenuSpace),

              NavItem(
                title: 'TUTORIALS',
                tapEvent: () {},
              ),

              SizedBox(height: sideMenuSpace),
              
              NavItem(
                title: 'PRICING',
                tapEvent: () {},
              ),

              SizedBox(height: sideMenuSpace),
              
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

              SizedBox(height: sideMenuSpace),
              
              NavItem(
                title: 'LOGIN',
                tapEvent: () {},
              ),
              SizedBox(height: sideMenuSpace),
              NavItem(
                title: 'SIGNUP',
                tapEvent: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}