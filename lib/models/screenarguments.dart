import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class ScreenArguments {
  const ScreenArguments(this.key, this.color);
  final String key;
  final Color color;
}