
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pointdraw/core/gallery_image_item.dart';
import 'package:pointdraw/responsive.dart';
import '../constants.dart';

class GallerySection extends StatefulWidget {
  const GallerySection({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GallerySectionWidgetState();
}

class _GallerySectionWidgetState extends State<GallerySection> {
  FirebaseApp secondaryApp = Firebase.app('point-draw-web-app');
  late FirebaseFirestore fireStore;
  late final CollectionReference fireStoreRef;
  List<GalleryImageItem>? allGalleryImages, galleryImages;
  TextEditingController searchController = TextEditingController();
  Size? size;

  @override
  initState() {
    super.initState();

    fireStore = FirebaseFirestore.instanceFor(app: secondaryApp);
    fireStoreRef =
        fireStore.collection('gallery').withConverter<GalleryImageItem>(
              fromFirestore: (snapshots, _) =>
                  GalleryImageItem.fromJson(snapshots.data()!),
              toFirestore: (galleryImageItem, _) => galleryImageItem.toJson(),
            );

    readGalleryData(null);
  }

  void readGalleryData(String? search) {
    galleryImages = [];
    if (search != null && search.isEmpty) search = null;
    fireStoreRef.where('tags', arrayContains: search).get().then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        galleryImages?.add(GalleryImageItem.fromJson(doc));
      }

      if (mounted) {
        setState(() {});
      }
    });
  }

  Widget imageCard(GalleryImageItem imageItem, BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.image_sharp, color: backgroundColor),
            title: Text(
              imageItem.title!,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: backgroundColor),
            ),
            subtitle: Text(
              imageItem.description!,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.black.withOpacity(0.6)),
            ),
          ),
          SizedBox(
            width: 300,
            height: 300,
            child: Image.network(
              imageItem.url!,
              loadingBuilder: _loader,
              errorBuilder: _error,
              fit: BoxFit.cover,
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  showImageDialog(imageItem);
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

  Future<void> showImageDialog(GalleryImageItem imageItem) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return imageDialog(imageItem, context);
      },
    );
  }

  Widget imageDialog(GalleryImageItem imageItem, BuildContext context) {
    return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: SizedBox(
          width: 500,
          height: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      imageItem.title!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close_rounded),
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 400,
                height: 400,
                child: Image.network(
                  imageItem.url!,
                  fit: BoxFit.cover,
                ),
              )
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    double horizontalPadding =
        isDesktop(context) ? horizontalMargin : mobileHorizontalMargin;
    int axisCount = isMobile(context) ? 1 : (isTab(context) ? 4 : 5);
    double cardWidth = ((size?.width)! - horizontalPadding * 2) / axisCount;
    double aspectRatio = cardWidth / (300 + 120);
    return Container(
        width: (size?.width)!,
        height: (size?.height)!,
        margin:
            EdgeInsets.symmetric(vertical: 20, horizontal: horizontalPadding),
        child: galleryImages == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  SizedBox(
                      width: isMobile(context) || isTab(context)
                          ? double.infinity
                          : (size?.width)! * 0.3,
                      child: TextFormField(
                        onEditingComplete: () {
                          setState(() {
                            // galleryImages = [];
                            // for (var element in allGalleryImages!) {
                            //   if (element.search(searchController.text)) {
                            //     galleryImages?.add(element);
                            //   }
                            // }
                            readGalleryData(searchController.text);
                          });
                        },
                        controller: searchController,
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: const TextStyle(color: Colors.grey),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 2.0,
                            ),
                          ),
                        ),
                      )),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                      child: GridView.builder(
                          itemCount: galleryImages?.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: axisCount,
                                  childAspectRatio: aspectRatio),
                          itemBuilder: (BuildContext context, int index) =>
                              imageCard(galleryImages![index], context)))
                ],
              ));
  }

  Widget _loader(
      BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
    if (loadingProgress == null) return child;
    return Center(
      child: CircularProgressIndicator(
        color: Colors.blue,
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
