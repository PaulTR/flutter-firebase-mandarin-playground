import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Section {
  const Section(this.title, this.type, this.color, this.icon);
  final String title;
  final SectionType type;
  final Color color;
  final IconData icon;
}

enum SectionType {
  flashcards,
  dictionary,
  matching
}