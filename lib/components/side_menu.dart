import 'package:flutter/material.dart';
import '../constants.dart';
import 'menu_item.dart';

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
                tapEvent: () {},
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
                tapEvent: () {},
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