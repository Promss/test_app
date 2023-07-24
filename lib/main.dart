import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ContentProvider(),
      child: const MaterialApp(
        home: MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Тестовое задание Flutter'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () async {
              ContentProvider contentProvider =
                  Provider.of<ContentProvider>(context, listen: false);
              List<User> users = await fetchUsers();
              contentProvider.updateCurrentContent('Контент 1');
              contentProvider.updateUsers(users);
            },
            child: const Text('Кнопка 1'),
          ),
          ElevatedButton(
            onPressed: () async {
              ContentProvider contentProvider =
                  Provider.of<ContentProvider>(context, listen: false);
              List<Photo> photos = await fetchPhotos();
              contentProvider.updateCurrentContent('Контент 2');
              contentProvider.updatePhotos(photos);
            },
            child: const Text('Кнопка 2'),
          ),
          ElevatedButton(
            onPressed: () async {
              ContentProvider contentProvider =
                  Provider.of<ContentProvider>(context, listen: false);
              contentProvider.updateCurrentContent('Контент 3');
              List<Post> posts = await fetchPosts();
              contentProvider.updatePosts(posts);
            },
            child: const Text('Кнопка 3'),
          ),
          const SizedBox(height: 16),
          const Expanded(
            child: ContentWidget(),
          ),
        ],
      ),
    );
  }
}

class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

class Photo {
  final int id;
  final String title;
  final String url;

  Photo({required this.id, required this.title, required this.url});

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      title: json['title'],
      url: json['url'],
    );
  }
}

class Post {
  final int id;
  final String title;
  final String body;

  Post({required this.id, required this.title, required this.body});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
}

class ContentProvider extends ChangeNotifier {
  List<Post> _posts = [];
  List<User> _users = [];
  List<Photo> _photos = [];
  String _currentContent = 'Контент 1';

  List<Post> get posts => _posts;
  List<User> get users => _users;
  List<Photo> get photos => _photos;
  String get currentContent => _currentContent;

  void updatePosts(List<Post> newPosts) {
    _posts = newPosts;
    notifyListeners();
  }

  void updateUsers(List<User> newUsers) {
    _users = newUsers;
    notifyListeners();
  }

  void updatePhotos(List<Photo> newPhotos) {
    _photos = newPhotos;
    notifyListeners();
  }

  void updateCurrentContent(String newContent) {
    _currentContent = newContent;
    notifyListeners();
  }
}

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    ContentProvider contentProvider = Provider.of<ContentProvider>(context);
    List<Post> posts = contentProvider.posts;
    List<User> users = contentProvider.users;
    List<Photo> photos = contentProvider.photos;

    if (contentProvider.currentContent == 'Контент 1' && users.isNotEmpty) {
      return ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(users[index].name),
            subtitle: Text(users[index].email),
          );
        },
      );
    } else if (contentProvider.currentContent == 'Контент 2' &&
        photos.isNotEmpty) {
      return ListView.builder(
        itemCount: photos.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(photos[index].title),
            subtitle: Image.network(photos[index].url),
          );
        },
      );
    } else if (contentProvider.currentContent == 'Контент 3' &&
        posts.isNotEmpty) {
      return ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(posts[index].title),
            subtitle: Text(posts[index].body),
          );
        },
      );
    } else {
      return const Center(
        child: Text('Нажмите на любую кнопку из трех'),
      );
    }
  }
}

Future<List<User>> fetchUsers() async {
  final response =
      await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));
  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return data.map((item) => User.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load users');
  }
}

Future<List<Photo>> fetchPhotos() async {
  final response = await http
      .get(Uri.parse('https://jsonplaceholder.typicode.com/photos?_limit=50'));
  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return data.map((item) => Photo.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load photos');
  }
}

Future<List<Post>> fetchPosts() async {
  final response = await http
      .get(Uri.parse('https://jsonplaceholder.typicode.com/posts?_limit=50'));
  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return data.map((item) => Post.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load posts');
  }
}
