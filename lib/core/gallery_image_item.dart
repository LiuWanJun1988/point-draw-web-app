import 'package:flutter/material.dart';

class Author {
  String? email, username;
}

class GalleryImageItem {
  GalleryImageItem() {
    author = Author();
    tags = [];
  }

  String? url, title, description, category;
  List<dynamic>? tags;
  Author? author;

  static GalleryImageItem fromJson(dynamic data) {
    GalleryImageItem imageItem = GalleryImageItem();
    imageItem.url = data["url"];
    imageItem.title = data["title"];
    imageItem.description = data["description"];
    imageItem.category = data["category"];
    imageItem.tags = data["tags"];
    imageItem.author?.email = data["author"]["email"];
    imageItem.author?.username = data["author"]["username"];
    return imageItem;
  }

  bool search(String? data) {
    if (data == null || data.isEmpty) return true;

    String searchString = data.toLowerCase();
    bool res = title!.toLowerCase().contains(searchString) ||
        description!.toLowerCase().contains(searchString) ||
        category!.toLowerCase().contains(searchString) ||
    tags!.contains(searchString) ||
    author!.email!.toLowerCase().contains(searchString)  ||
    author!.username!.toLowerCase().contains(searchString);
    return res;
  }
}
