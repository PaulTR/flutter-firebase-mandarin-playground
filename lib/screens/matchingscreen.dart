import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:mandarin/models/screenarguments.dart';

class MatchingScreen extends StatefulWidget {
  static const String routeName = '/matching';
  const MatchingScreen({Key key} ) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MatchingScreen();
  }
}

class _MatchingScreen extends State<MatchingScreen> {
  Color color;
  final Firestore firestore = Firestore(app: FirebaseApp.instance);
  final Map<String, bool> score = {};
  int seed = 0;
  Map<String, dynamic> choices = {};

  @override
  Widget build(BuildContext context) {
    ScreenArguments arguments = ModalRoute.of(context).settings.arguments;
    color = arguments.color;
    final String key = arguments.key;

    return Scaffold(
        backgroundColor: Colors.orange,
        appBar: AppBar(
          title: const Text('中文课'),
          backgroundColor: color,
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.refresh),
          onPressed: () {
            setState(() {
              score.clear();
              seed++;
            });
          },
        ),
        body: FutureBuilder<QuerySnapshot>(
          future: firestore.collection('dictionary').where('category', isEqualTo: key).getDocuments(),
          builder:(context, snapshot) {
            if( snapshot.hasData ) {
              //TODO shuffle, then pick x number
              snapshot.data.documents.forEach((element) {
                choices[element.data['zi']] = element.data['pinyin'];
              });

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: choices.keys.map((key) {
                        return Draggable<String>(
                          data: key,
                          child: Container(
                              color:Colors.white,
                              height: 80,
                              width: 80,
                              child: Center( child: Text(score[key] == true ? '✅' : key))),
                          feedback: Text(key),
                          //childWhenDragging: Text('🌱'),
                        );
                      }).toList()),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                    choices.keys.map((key) => _buildDragTarget(key)).toList()
                      ..shuffle(Random(seed)),
                  )
                ],
              );
            }

            return CircularProgressIndicator();
          }
        )
    );
  }

  Widget _buildDragTarget(key) {
    return DragTarget<String>(
      builder: (BuildContext context, List<String> incoming, List rejected) {
        if (score[key] == true) {
          return Container(
            color: Colors.white,
            child: Text('Correct!'),
            alignment: Alignment.center,
            height: 80,
            width: 200,
          );
        } else {
          print( "test: " + choices[key]);
          return Container(color:Colors.white, height: 80, width: 200, child: Center( child: Text(choices[key])));
        }
      },
      onWillAccept: (data) => data == key,
      onAccept: (data) {
        setState(() {
          score[key] = true;
        });
      },
      onLeave: (data) {},
    );
  }
}