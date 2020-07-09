
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class FlashcardsScreen extends StatefulWidget {
  static const String routeName = '/flashcard_items';
  const FlashcardsScreen({Key key } ) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _FlashcardsScreenState();
  }
}

class _FlashcardsScreenState extends State<FlashcardsScreen> with SingleTickerProviderStateMixin {
  final Firestore firestore = Firestore(app: FirebaseApp.instance);

  AnimationController _animationController;
  Animation _animation;
  AnimationStatus _animationStatus = AnimationStatus.dismissed;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animation = Tween(end: 1.0, begin: 0.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        _animationStatus = status;
      });
  }

  List<Widget> getFlashcards(DocumentSnapshot snapshot) {
    List<Widget> flashcardWidgets = new List<Widget>();
      for( String key in snapshot.data.keys) {
        flashcardWidgets.add(new Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0)
                  ..rotateY(pi * _animation.value.toDouble()),
                alignment: Alignment.center,
                child: SizedBox(
                  height: 300,
                  child: GestureDetector(
                    onTap: () {
                      if (_animationStatus == AnimationStatus.dismissed) {
                        _animationController.forward();
                      } else {
                        _animationController.reverse();
                      }
                    },
                    child: _animation.value <= 0.5 ?
                    Container(
                      child: Center( child: Text(key, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 64))),
                      color: Colors.blueAccent,
                    )
                    : Container(
                      child: Transform(transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.0)
                            ..rotateY(pi * _animation.value.toDouble()),
                            alignment: Alignment.center,
                          child: FutureBuilder<DocumentSnapshot>(
                            future: (snapshot.data[key] as DocumentReference).get(),
                            builder:(context, answer) {
                              if( answer.hasData ) {
                                return Text(answer.data['english']);
                              }
                              return Container();
                            })),
                      color: Colors.redAccent,
                    )
                  )
                )
            )
          );
        }
      return flashcardWidgets;
    }

  @override
  Widget build(BuildContext context) {
    final DocumentReference ref = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Example'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: ref.get(),
        builder:(context, snapshot) {
          if( snapshot.hasData ) {
            return PageView(
              children: getFlashcards(snapshot.data),
            );
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }

}