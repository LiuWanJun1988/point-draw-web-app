import 'package:flutter/material.dart';
import 'package:pointdraw/responsive.dart';

import '../constants.dart';

class Footer extends StatelessWidget {
  const Footer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (!isMobile(context)) ? const DesktopFooter() : const MobileFooter();
  }
}

class DesktopFooter extends StatelessWidget {
  const DesktopFooter({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Row(
        children: <Widget>[
          const Expanded(
              flex: 1,
              child: Text(
                'All Right Reserved',
                style: TextStyle(fontSize: 10, color: kTextColor),
              )),
          Expanded(
              flex: 2,
              child: Row(
                children: <Widget>[
                  NavItem(
                    title: 'Twitter',
                    tapEvent: () {},
                  ),
                  NavItem(
                    title: 'Facebook',
                    tapEvent: () {},
                  ),
                  NavItem(
                    title: 'Linkedin',
                    tapEvent: () {},
                  ),
                  NavItem(
                    title: 'Instagram',
                    tapEvent: () {},
                  ),
                ],
              )),
        ],
      ),
    );
  }
}

class MobileFooter extends StatelessWidget {
  const MobileFooter({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      child: Column(
        children: <Widget>[
          const Text(
            'All Right Reserved',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: kTextColor),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              NavItem(
                title: 'Twitter',
                tapEvent: () {},
              ),
              NavItem(
                title: 'Facebook',
                tapEvent: () {},
              ),
              NavItem(
                title: 'Linkedin',
                tapEvent: () {},
              ),
              NavItem(
                title: 'Instagram',
                tapEvent: () {},
              ),
            ],
          )
        ],
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  const NavItem({Key? key, required this.title, required this.tapEvent})
      : super(key: key);

  final String title;
  final GestureTapCallback tapEvent;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: tapEvent,
      hoverColor: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          title,
          style: TextStyle(color: kPrimaryColor, fontSize: 12),
        ),
      ),
    );
  }
}
