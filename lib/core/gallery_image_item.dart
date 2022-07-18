import 'package:flutter/material.dart';

class Author {
  String? email, username;

  Author.fromJson(dynamic data) {
    email = data["email"];
    username = data["username"];
  }
  Map<String, Object?> toJson() {
    return {
      'email': email,
      'username': username
    };
  }
}

class GalleryImageItem {
  String? url, title, description, category;
  List<dynamic>? tags;
  Author? author;

  GalleryImageItem.fromJson(dynamic data) {
    url = data["url"];
    title = data["title"];
    description = data["description"];
    category = data["category"];
    tags = data["tags"];
    author = Author.fromJson(data["author"]);
  }

  Map<String, Object?> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'tags': tags,
      'author': author?.toJson(),
      'url': url,
    };
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
