import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:animated_check/animated_check.dart';

import 'add_item_bottom_sheet.dart';
import 'item.dart';
import 'item_view.dart';

String daySuffix(int day) {
  if (!(day >= 1 && day <= 31)) {
    throw Exception('Invalid day of month');
  }

  if (day >= 11 && day <= 13) {
    return 'th';
  }

  switch (day % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}

String formattedDate() {
  final date = DateTime.now();
  return DateFormat("MMM d'${daySuffix(date.day)}'").format(date);
}

void main() => runApp(Elegant());

class Elegant extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Elegant',
        theme: ThemeData(
          primarySwatch: Colors.grey,
          primaryColor: Colors.black,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          checkboxTheme: CheckboxThemeData(
            checkColor: MaterialStateProperty.all(Colors.white),
            fillColor: MaterialStateProperty.all(Colors.black),
          ),
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.grey,
          primaryColor: Colors.white,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          checkboxTheme: CheckboxThemeData(
            checkColor: MaterialStateProperty.all(Colors.black),
            fillColor: MaterialStateProperty.all(Colors.white),
          ),
        ),
        home: Today(),
      );
}

class Today extends StatefulWidget {
  Today({Key? key}) : super(key: key);

  @override
  _TodayState createState() => _TodayState();
}

class _TodayState extends State<Today> with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController animationController;

  bool showCheck = true;

  List<Item> items = [];

  List<Item> get today => items.where((o) => o.repeat.contains(DateTime.now().weekday)).toList();
  int get checked => today.where((o) => o.checked).length;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: Duration(seconds: 1))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => showCheck = false);
        }
      });

    animation = new Tween<double>(begin: 0, end: 1).animate(new CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOutCubic,
    ));
    getApplicationDocumentsDirectory()
        .then((directory) => File('${directory.path}/items.json').readAsString())
        .then((json) => super.setState(
              () => items = jsonDecode(json).map<Item>((json) => Item.fromJson(json)).toList(),
            ));
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    getApplicationDocumentsDirectory()
        .then((directory) => File('${directory.path}/items.json').writeAsString(jsonEncode(items)));
  }

  void setStatusBar(BuildContext context) => SystemChrome.setSystemUIOverlayStyle(
        MediaQuery.of(context).platformBrightness == Brightness.light
            ? const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarBrightness: Brightness.light,
                statusBarIconBrightness: Brightness.dark,
              )
            : const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarBrightness: Brightness.dark,
                statusBarIconBrightness: Brightness.light,
              ),
      );

  @override
  Widget build(BuildContext context) {
    setStatusBar(context);
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
            child: items.isEmpty
                ? Center(child: Text('Swipe up to add an item.'))
                : Stack(children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                            child: Text(formattedDate(), style: TextStyle(fontSize: 60.0, fontWeight: FontWeight.w300)),
                          ),
                          for (var item in today)
                            ItemView(
                              item,
                              onChanged: (val) => setState(() {
                                item.checked = val!;
                                if (today.length != checked) return;
                                setState(() => showCheck = true);
                                animationController.forward(from: 0.0);
                              }),
                              onLongPress: () async {
                                final value = await showModalBottomSheet<Item>(
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (context) => AddItemBottomSheet(item: item),
                                );
                                if (value != null) setState(() => item.update(value));
                              },
                            ),
                          const Spacer(),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            width: MediaQuery.of(context).size.width / today.length * checked,
                            height: 2.0,
                            color: Colors.grey[500],
                          )
                        ],
                      ),
                    ),
                    if (showCheck)
                      Center(
                        child: AnimatedCheck(
                          progress: animation,
                          size: 200,
                        ),
                      ),
                  ])),
        onPanUpdate: (details) async {
          if (details.delta.dy >= 0) return;

          final value = await showModalBottomSheet<Item>(
            isScrollControlled: true,
            context: context,
            builder: (context) => AddItemBottomSheet(),
          );
          if (value != null) setState(() => items.add(value));
        },
      ),
    );
  }
}
