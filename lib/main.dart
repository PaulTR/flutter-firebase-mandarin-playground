import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mandarin/models/section.dart';
import 'package:mandarin/screens/flashcardsscreen.dart';

void main() async {
  await WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
      routes: <String, WidgetBuilder> {
        '/home': (context) => MyHomePage(),
        FlashcardsScreen.routeName: (BuildContext context) => FlashcardsScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  List<Section> appSections = <Section> [
    Section('Flash Cards', SectionType.flashcards, Colors.red[700], Icons.input),
    Section('Dictionary', SectionType.dictionary, Colors.yellow[200], Icons.import_contacts),
    Section('Item Matching', SectionType.matching, Colors.green[300], Icons.border_all)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: IndexedStack(
          index: _currentIndex,
          children: appSections.map<Widget>((Section section) {
            return SectionView(section: section);
          }).toList(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: appSections[_currentIndex].color,
        selectedItemColor: Colors.black,
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: appSections.map((Section section) {
          return BottomNavigationBarItem(
              icon: Icon(section.icon),
              backgroundColor: section.color,
              title: Text(section.title)
          );
        }).toList(),
      ),
    );
  }
}

class SectionView extends StatefulWidget {
  const SectionView({ Key key, this.section }) : super(key: key);

  final Section section;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SectionViewState();
  }
}

class _SectionViewState extends State<SectionView> {
  final Firestore firestore = Firestore(app: FirebaseApp.instance);
  CollectionReference get flashcards => firestore.collection('flashcards');

  @override
  void initState() {
    super.initState();
    switch( widget.section.type ) {
      case SectionType.flashcards: {
        break;
      }
      case SectionType.dictionary: {
        break;
      }
      case SectionType.matching: {
        break;
      }
      default: {
        //Add for any new section types
      }

    }
  }

  List<Widget> getFlashcardSectionListItems(AsyncSnapshot<QuerySnapshot> snapshot, Section section) {
    List<Widget> flashcardSectionListItems = new List<Widget>();
    for( DocumentSnapshot document in snapshot.data.documents ) {
      flashcardSectionListItems.add(
        new SizedBox(
          height: 100.0,
            child: Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, FlashcardsScreen.routeName, arguments: document.data['items']);
              },
              splashColor: section.color,
              child: Center(child: Text(document.documentID, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold))),
            ),
          )
        )
      );
    }
    return flashcardSectionListItems;
  }

  Widget getSectionUi(Section section) {
    switch( section.type ) {
      case SectionType.flashcards: {
        return FutureBuilder<QuerySnapshot>(
          future: flashcards.getDocuments(),
          builder:(context, snapshot) {
            if( snapshot.hasData ) {
              return ListView(
                children: getFlashcardSectionListItems(snapshot, section),
              );
            }
            return CircularProgressIndicator();
          },

        );
      }
      case SectionType.dictionary: {
        return Image.network('https://fireflicks-io.firebaseapp.com/dist/Popcorn_Sparky.png?fff0508ec5db8e88e811030bc93a44a8');
      }
      case SectionType.matching: {
        return Image.network('https://firebase.google.com/images/homepage/sparky_couchgamer_1x.png');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.section.title),
        backgroundColor: widget.section.color,
      ),
      backgroundColor: widget.section.color,
      body: Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: getSectionUi(widget.section),
      )
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}