import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
          fontFamily: 'DejaVuSans'),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  var menu = ["Overview", "Symptoms", "Protection"];
  var entry = [
    "Coronavirus disease is an infectious disease caused by a newly discovoured coronavirous.",
    "People may be sick with the virus for 1 to 14 days before developing any symptoms.",
    "There's currently no vaccine to prevent this disease. You can protect yourself and help prevent spreading the virus if"
  ];

  var symtoms = {
    "Fever": false,
    "Runny Nose": true,
    "Dry Cough": false,
    "Sore Throat": false,
    "Headache": true,
    "Cough": true,
    "Fatigue": false,
    "Dyspnoea": false
  };

  PageController _controller = PageController(
    initialPage: 0,
  );
  final formatter = new NumberFormat("#,###");
  final _keys = [GlobalKey(), GlobalKey(), GlobalKey()];
  final _position = [Offset.zero, Offset.zero, Offset.zero];
  final _size = [Size.zero, Size.zero, Size.zero];
  var _page = 0;
  var _totalConfirmed = 0;
  var _totalDeath = 0;
  var _totalRecovered = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _keys.asMap().forEach((pos, element) {
        RenderBox _box = element.currentContext.findRenderObject();
        _position[pos] = _box.localToGlobal(Offset.zero);
        _size[pos] = _box.size;
        print(_size);
      });
      setState(() {});
    });

    http
        .get("https://api.covid19api.com/world/total")
        .then((value) => setState(() {
              var resp = jsonDecode(value.body);
              _totalConfirmed = resp["TotalConfirmed"];
              _totalDeath = resp["TotalDeaths"];
              _totalRecovered = resp["TotalRecovered"];
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Row(
          children: <Widget>[
            //menu
            Stack(
              children: <Widget>[
                _buildDotsMenu(),
                _buildMenu(),
              ],
            ),
            //content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 15),
                child: PageView.builder(
                  controller: _controller,
                  scrollDirection: Axis.vertical,
                  physics: ClampingScrollPhysics(),
                  itemCount: menu.length,
                  onPageChanged: (page) => setState(() {
                    this._page = page;
                  }),
                  itemBuilder: (ctx, k) => _buildPager(k),
                ),
              ),
            )
          ],
        ));
  }

  _buildPagerContent(page) {
    if (page == 0) {
      return _buildOverview();
    } else if (page == 1) {
      return _buildSymptoms();
    } else {
      return _buildProtection();
    }
  }

  _buildSideMenuWidget(int pos) {
    return Center(
      child: RotatedBox(
        quarterTurns: 3,
        child: AnimatedContainer(
          duration: Duration(seconds: 10),
          child: Text(
            menu[pos],
            key: _keys[pos],
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color(0xffed6672),
                fontSize: pos == _page ? 34 : 28,
                fontWeight: pos == _page ? FontWeight.bold : FontWeight.normal),
          ),
        ),
      ),
    );
  }

  _buildPager(k) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 110),
        Text(menu[k],
            style: TextStyle(
              fontSize: 74,
              fontWeight: FontWeight.bold,
            )),
        Text("Covid-19 Disease",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xffed6672),
            )),
        SizedBox(height: 25),
        Padding(
          padding: const EdgeInsets.only(right: 55),
          child: Text(entry[k],
              style: TextStyle(
                fontSize: 23,
                letterSpacing: 1.2,
                wordSpacing: 1.5,
                color: Color(0xff9d1e1e),
              )),
        ),
        _buildPagerContent(k)
      ],
    );
  }

  _buildOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Center(
            child: Lottie.asset("lottie/virus.json", height: 300, width: 300)),
        Text("Covid-19 Cases",
            style: TextStyle(
              fontSize: 23,
              color: Color(0xff9d1e1e),
            )),
        SizedBox(
          height: 10,
        ),
        Text(
          formatter.format(_totalConfirmed),
          style: TextStyle(
            fontSize: 54,
            fontWeight: FontWeight.bold,
            color: Color(0xffed6672),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                  Text(
                    "Deaths",
                    style: TextStyle(fontSize: 23, color: Color(0xff9d1e1e)),
                  ),
                  SizedBox(height: 5),
                  Text(
                    formatter.format(_totalDeath),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 39),
                  )
                ])),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                  Text(
                    "Recovered",
                    style: TextStyle(fontSize: 23, color: Color(0xff9d1e1e)),
                  ),
                  SizedBox(height: 5),
                  Text(
                    formatter.format(_totalRecovered),
                    style: TextStyle(
                        color: Color(0xff73d7b0),
                        fontWeight: FontWeight.bold,
                        fontSize: 39),
                  ),
                ])),
          ],
        ),
        SizedBox(height: 25),
        Container(
          width: 300,
          child: Card(
            color: Color(0xffee6672),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: <Widget>[
                  Text(
                    "Please, stay at home\nif you are sick!",
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  SizedBox(
                    width: 25,
                  ),
                  Icon(
                    Icons.info_outline,
                    color: Colors.white,
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  _buildSymptoms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Center(
          child: Lottie.asset(
            "lottie/stayhome.json",
            height: 300,
            onLoaded: (composition) {},
          ),
        ),
        Text(
          "What symptoms do you experience?",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
        ),
        SizedBox(
          height: 40,
        ),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: symtoms
              .map((k, e) => MapEntry(
                  k,
                  Material(
                    elevation: 1,
                    color: e ? Color(0xffed6671) : Color(0xfffff3f4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      child: Text(
                        k,
                        style: TextStyle(
                            fontSize: 21,
                            color: e ? Colors.white : Color(0xff9d1e1e)),
                      ),
                    ),
                  )))
              .values
              .toList(),
        )
      ],
    );
  }

  _buildProtection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 15,
        ),
        Lottie.asset("lottie/wearmask.json", width: 150),
        SizedBox(
          height: 15,
        ),
        Text(
          "Cover your cough",
          style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 8,
        ),
        Text("Cover your nose and mouth \nwith a disposable tissue.",
            style: TextStyle(
              color: Color(0xff9d1e1e),
              fontSize: 24,
              wordSpacing: 1.2,
              letterSpacing: 1.1,
            )),
        SizedBox(
          height: 15,
        ),
        Lottie.asset("lottie/washhands.json", width: 150),
        SizedBox(
          height: 35,
        ),
        Text("Wash your hands",
            style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold)),
        SizedBox(
          height: 8,
        ),
        Text("With soap & water or alcohol-based hand rub.",
            style: TextStyle(
              color: Color(0xff9d1e1e),
              fontSize: 24,
              wordSpacing: 1.2,
              letterSpacing: 1.1,
            )),
      ],
    );
  }

  _buildDotsMenu() {
    return Container(
      width: 85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          SizedBox(height: 192),
          Expanded(
            child: Stack(
              children: menu
                  .asMap()
                  .keys
                  .map((e) => Positioned(
                        left: _position[0].dx + 55,
                        top: _position[e].dy - 312,
                        height: _size[e].width,
                        width: _size[e].height,
                        child: e != _page
                            ? SizedBox.shrink()
                            : Container(
                                child: Text(
                                  ".",
                                  style: TextStyle(
                                      color: Color(0xffed6672),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 74),
                                ),
                              ),
                      ))
                  .toList(),
            ),
          ),
          SizedBox(height: 156),
        ],
      ),
    );
  }

  _buildMenu() {
    return Container(
      width: 65,
      color: Color(0xfff0e0e1),
      child: Column(
        children: <Widget>[
          SizedBox(height: 60),
          Icon(Icons.apps, size: 36, color: Color(0xffed6672)),
          SizedBox(height: 30),
          Icon(Icons.search, size: 36, color: Color(0xffed6672)),
          SizedBox(height: 30),
          Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: menu
                    .asMap()
                    .keys
                    .map((pos) => _buildSideMenuWidget(pos))
                    .toList()),
          ),
          SizedBox(
            height: 100,
          ),
          Icon(Icons.person, size: 36),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
