
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FlashcardsScreen extends StatelessWidget {
  static const String routeName = '/flashcard_items';

  @override
  Widget build(BuildContext context) {
    final DocumentReference ref = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Example'),
      ),
      body: Text(ref.path),
    );
  }
}