import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:mandarin/models/flashcardsarguments.dart';

class FlashcardsScreen extends StatefulWidget {
  static const String routeName = '/flashcard_items';
  const FlashcardsScreen({Key key} ) : super(key: key);

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
  PageController _pageController;
  Color color;

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
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
                  child: Card( child: GestureDetector(
                    onTap: () {
                      if (_animationStatus == AnimationStatus.dismissed) {
                        _animationController.forward();
                      } else {
                        _animationController.reverse();
                      }
                    },
                    child: _animation.value <= 0.5 ?
                    Container(
                      child: Center( child: Text(key, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 64))),
                      color: color,
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
                                return Padding(padding: EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children:
                                        [
                                          Text("English: " + answer.data['english'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white)),
                                          Text("Pinyin: " + answer.data['pinyin'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white )),
                                        ]
                                    ));
                              }
                              return Container();
                            })),
                      color: color,
                    )
                  ))
                )
            )
          );
        }
      return flashcardWidgets;
    }

  @override
  Widget build(BuildContext context) {
    FlashcardArguments arguments = ModalRoute.of(context).settings.arguments;
    final DocumentReference ref = arguments.documentReference;
    color = arguments.color;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('中文课'),
        backgroundColor: color,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: ref.get(),
        builder:(context, snapshot) {
          if( snapshot.hasData ) {
            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              Flexible(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                  child: FractionallySizedBox(
                  heightFactor: 0.5,
                  child: PageView(
                    controller: _pageController,
                    children: getFlashcards(snapshot.data),
                      pageSnapping: true,
                      //physics:new NeverScrollableScrollPhysics(),
                      onPageChanged: (value) {
                        //TODO make this better.
                        //Read this https://medium.com/flutter-community/synchronising-widget-animations-with-the-scroll-of-a-pageview-in-flutter-2f3475fcffa3
                        _animationController.duration = Duration(seconds: 0);
                        _animationController.reverse();
                        _animationController.duration = Duration(seconds: 1);
                      },
                    )
                  )
                )),
              ),
              ]
            );
          }
          return Center(
              child: CircularProgressIndicator());
        },
      ),
    );
  }

}