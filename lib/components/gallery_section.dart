import 'package:flutter/material.dart';
import 'package:pointdraw/responsive.dart';

import '../constants.dart';

class GallerySection extends StatelessWidget {
  const GallerySection({
    Key? key,
  }) : super(key: key);

  Widget imageCard(String imageUrl, BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.image_sharp, color: backgroundColor),
            title: Text(
              'Gallery Image',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: backgroundColor),
            ),
            subtitle: Text(
              'Secondary Text',
              style: TextStyle(color: Colors.black.withOpacity(0.6)),
            ),
          ),
          Image.network(
            imageUrl,
            loadingBuilder: _loader,
            errorBuilder: _error,
            fit: BoxFit.fitWidth,
          ),
          ButtonBar(
            alignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  // Perform some action
                },
                child: Text('View', style: TextStyle(color: backgroundColor)),
              ),
              TextButton(
                onPressed: () {
                  // Perform some action
                },
                child:
                    Text('Download', style: TextStyle(color: backgroundColor)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
        width: size.width,
        height: size.height,
        margin: EdgeInsets.symmetric(
            vertical: 20,
            horizontal: isDesktop(context)
                ? horizontalMargin
                : mobileHorizontalMargin / 2),
        child: GridView.builder(
            itemCount: 250,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    isMobile(context) ? 1 : (isTab(context) ? 4 : 5),
                childAspectRatio: 0.9),
            itemBuilder: (BuildContext context, int index) => imageCard(
                'https://loremflickr.com/200/200/music?lock=$index', context)));
  }

  Widget _loader(
      BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
    if (loadingProgress == null) return child;
    return Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
            : null,
      ),
    );
  }

  Widget _error(BuildContext context, Object obj, StackTrace? error) {
    return const Center(child: Icon(Icons.error));
  }
}
