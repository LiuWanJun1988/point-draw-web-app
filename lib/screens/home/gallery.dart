import 'package:flutter/material.dart';
import 'package:pointdraw/components/footer.dart';
import 'package:pointdraw/components/header.dart';
import 'package:pointdraw/components/side_menu.dart';
import '../../components/gallery_section.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      endDrawer: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: const SideMenu(),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            width: size.width,
            constraints: BoxConstraints(minHeight: size.height),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const <Widget>[Header(), GallerySection(), Footer()],
            ),
          ),
        ),
      ),
    );
  }
}
