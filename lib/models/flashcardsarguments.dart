import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class FlashcardArguments {
  const FlashcardArguments(this.documentReference, this.color);
  final DocumentReference documentReference;
  final Color color;
}