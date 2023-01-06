import 'package:flutter/material.dart';
import 'package:repo/screens/repo_list.dart';
import 'package:repo/screens/repo_details.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Repo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: Colors.lightGreen,
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.lightGreen)
              .copyWith(secondary: Colors.lightGreenAccent)),
      home: RepoList(),
    );
  }
}
