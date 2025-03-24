// results.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:major_words_maker/menu.dart';
import 'main.dart';

// ignore: must_be_immutable
class WordsPageNew extends StatefulWidget {
  final String lastNumber;
  final Map<String, List<dynamic>> words;
  final int countWords;
  final int countTotal;

  WordsPageNew(
      {required this.lastNumber,
      required this.words,
      required this.countWords,
      required this.countTotal});
  @override
  // ignore: library_private_types_in_public_api
  State<WordsPageNew> createState() => WordsPageNewState();
}

class WordsPageNewState extends State<WordsPageNew> {
  GlobalKey appBarKey = GlobalKey();

  copyToClipboard(context, myText) {
    Clipboard.setData(ClipboardData(text: myText));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          "'${myText.toString()}' ${FlutterI18n.translate(context, "COPIED")}"),
    ));
  }

  updateSelf() {
    print("WordsPageNewState updateSelf called");
    setState(() {});
  }

  String getLanguage(BuildContext context, String LID) {
    dynamic myLanguage =
        MyHomeState().languages.where((lang) => lang["LID"] == LID).toList()[0];
    return "${myLanguage["name1"]}(${FlutterI18n.translate(context, myLanguage["name2"])})";
  }

  @override
  Widget build(BuildContext context) {
    MyHomeState().setSavedLanguage(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double titleFontSize =
        (screenWidth * 0.020 + 6) < 16 ? 16 : (screenWidth * 0.020 + 6);
    double wordsFontSize =
        (screenWidth * 0.016 + 4) < 14 ? 14 : (screenWidth * 0.016 + 4);
    double defsFontSize =
        (screenWidth * 0.014 + 4) < 12 ? 12 : (screenWidth * 0.014 + 4);
    double big1FontSize =
        (screenWidth * 0.018 + 4) < 15 ? 15 : (screenWidth * 0.018 + 4);
    double big2FontSize =
        (screenWidth * 0.016 + 4) < 11 ? 11 : (screenWidth * 0.016 + 4);
    //final appBarHeight = (appBarKey.currentContext!.findRenderObject() as RenderBox).size.height;
    final PreferredSizeWidget appBar = AppBar(
      key: appBarKey,
      backgroundColor: Colors.grey,
      title: Text(
        FlutterI18n.translate(context, "PROMPT_MAJOR_WORDS"),
        style: TextStyle(fontSize: titleFontSize),
      ),
      actions: <Widget>[
        Menu(context: context, page: 'main', updateParent: updateSelf)
      ],
    );
    double appBarHeight = appBar.preferredSize.height;
    double appBarBottomHeight = MediaQuery.of(context).padding.bottom;
    if (kIsWeb == false) {
      appBarBottomHeight = 60;
    }
    double appBarsHeight = appBarHeight + appBarBottomHeight;
    double promptFoundHeight = 50;
    double promptLanguageHeight = 45;
    List<String> wordKeys = List<String>.from(widget.words.keys);
    Map<int, TableColumnWidth> myColumnWidths = {};
    List<Widget> widgetLanguageHeaderList = [];
    List<Widget> widgetMajorList = [];
    List<TableRow> widgetTableRowList = [];
    double computedcolumnWidth = (screenWidth / wordKeys.length);
    double columnWidth = computedcolumnWidth > 275 ? computedcolumnWidth : 275;
    double numColumnWidth = (columnWidth * 0.10) > 50 ? 50 : columnWidth * 0.10;
    for (int i = 0; i < wordKeys.length; i++) {
      myColumnWidths[i] = FixedColumnWidth(columnWidth);
      widgetLanguageHeaderList.add(TableCell(
          child: Container(
              width: columnWidth,
              height: promptLanguageHeight,
              padding: EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black), color: Colors.white),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                    "${getLanguage(context, wordKeys[i])}(${widget.words[wordKeys[i]]!.length})",
                    style: TextStyle(
                        fontSize: big2FontSize, fontWeight: FontWeight.bold)),
              ))));

      widgetMajorList.add(TableCell(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
            Container(
              height: screenHeight -
                  appBarsHeight -
                  promptFoundHeight -
                  promptLanguageHeight,
              child: ListView.builder(
                  itemCount: widget.words[wordKeys[i]]!.length,
                  itemBuilder: (context, j) {
                    return Container(
                      padding: EdgeInsets.zero,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey), // Add border
                        ),
                      ),
                      width: columnWidth,
                      child: GestureDetector(
                        onTap: () {
                          print("BODY UNFOCUSSING");
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              SizedBox(
                                width: numColumnWidth,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                    child: Text("${j + 1})",
                                        softWrap: true,
                                        style: TextStyle(fontSize: 12.0)),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: columnWidth - numColumnWidth - 10,
                                child: Wrap(
                                    alignment: WrapAlignment.start,
                                    direction: Axis.horizontal,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          // Handle the click action here
                                          // For example, you can navigate to a new screen or perform some other action.
                                          print("BODY UNFOCUSSING");
                                          print(
                                              "Copy word, '${widget.words[wordKeys[i]]![j]["Word"]}' clicked!");
                                          copyToClipboard(
                                              context,
                                              widget.words[wordKeys[i]]![j]
                                                  ["Word"]);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 0, 0, 0),
                                          child: Text(
                                              widget.words[wordKeys[i]]![j]
                                                  ["Word"],
                                              softWrap: true,
                                              style: TextStyle(
                                                fontSize: wordsFontSize,
                                                color: const Color.fromARGB(
                                                    255, 17, 59, 93),
                                              )),
                                        ),
                                      ),
                                      InkWell(
                                          onTap: () {
                                            // Handle the click action here
                                            // For example, you can navigate to a new screen or perform some other action.
                                            print("BODY UNFOCUSSING");
                                            print(
                                                "Copy formatted word, '${widget.words[wordKeys[i]]![j]["formattedWord"]}' clicked!");
                                            copyToClipboard(
                                                context,
                                                widget.words[wordKeys[i]]![j]
                                                    ["formattedWord"]);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 0, 0, 0),
                                            child: Text(
                                              "( ${widget.words[wordKeys[i]]![j]["formattedWord"]} )",
                                              softWrap: true,
                                              style: TextStyle(
                                                  color: const Color.fromARGB(
                                                      255, 17, 59, 93),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: wordsFontSize),
                                            ),
                                          ))
                                    ]),
                              )
                            ]),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                InkWell(
                                  onTap: () {
                                    // Handle the click action here
                                    // For example, you can navigate to a new screen or perform some other action.
                                    print("BODY UNFOCUSSING");
                                    print(
                                        "Definition for '${widget.words[wordKeys[i]]![j]["Word"]}', copy '${widget.words[wordKeys[i]]![j]["Def"]}'' clicked!");
                                    copyToClipboard(context,
                                        widget.words[wordKeys[i]]![j]["Def"]);
                                  },
                                  child: SizedBox(
                                    width: columnWidth - 10,
                                    child: Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            (numColumnWidth + 10), 5, 10, 0),
                                        child: Text(
                                          widget.words[wordKeys[i]]![j]["Def"],
                                          softWrap: true,
                                          style:
                                              TextStyle(fontSize: defsFontSize),
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            )
          ])));
    }
    if (widgetLanguageHeaderList.length == wordKeys.length) {
      widgetTableRowList.add(TableRow(children: widgetLanguageHeaderList));
    }
    if (widgetMajorList.length == wordKeys.length) {
      widgetTableRowList.add(TableRow(children: widgetMajorList));
    }

    return WillPopScope(
        onWillPop: () async {
          print("HOME PAGE GOING BACK TO MY APP!");
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => MyApp()));
          return true; // Return false to prevent popping the route
        },
        child: Scaffold(
            appBar: appBar,
            body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Visibility(
                    visible: widget.lastNumber.trim() != '',
                    child: SizedBox(
                      height: promptFoundHeight,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                          child: Text(
                              FlutterI18n.translate(
                                  context, 'PROMPT_FOUND_WORDS',
                                  translationParams: {
                                    'fcwrds':
                                        '${(widget.countWords).toString()}/${widget.countTotal}',
                                    'fnmbr': widget.lastNumber
                                  }),
                              style: TextStyle(
                                  fontSize: big1FontSize,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Table(
                                columnWidths: myColumnWidths,
                                children: widgetTableRowList),
                          ]),
                    ),
                  )
                ])));
  }
}
