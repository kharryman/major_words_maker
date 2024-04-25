// results.dart

import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:major_words_maker/menu.dart';
import 'main.dart';

// ignore: must_be_immutable
class WordsPageOld extends StatefulWidget {
  final String lastNumber;
  final List<dynamic> words;

  WordsPageOld({required this.lastNumber, required this.words});
  @override
  // ignore: library_private_types_in_public_api
  State<WordsPageOld> createState() => WordsPageOldState();
}

class WordsPageOldState extends State<WordsPageOld> {
  copyToClipboard(context, myText) {
    Clipboard.setData(ClipboardData(text: myText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(("Text, '").toString() +
              myText.toString() +
              ("' copied to clipboard").toString())),
    );
  }

  updateSelf() {
    print("LoginPageState updateSelf called");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    MyHomePageState().setSavedLanguage(context);
    final theme = Theme.of(context); // ← Add this.
    return WillPopScope(
        onWillPop: () async {
          print("HOME PAGE GOING BACK TO MY APP!");
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => MyApp()));
          return true; // Return false to prevent popping the route
        },
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.grey,
              title: Text(FlutterI18n.translate(context, "PROMPT_MAJOR_WORDS")),
              actions: <Widget>[
                Menu(context: context, page: 'main', updateParent: updateSelf)
              ],
            ),
            body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Visibility(
                    visible: widget.lastNumber.trim() != '',
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(FlutterI18n.translate(
                          context, 'PROMPT_FOUND_WORDS', translationParams: {
                        'fcwrds': (widget.words.length).toString(),
                        'fnmbr': widget.lastNumber
                      })),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        print("BODY UNFOCUSSING");
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: ListView(children: <Widget>[
                          for (var i = 0; i < widget.words.length; i++)
                            Flex(
                              direction: Axis.horizontal,
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: Card(
                                    color: theme.colorScheme
                                        .surface, // ← And also this.
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .06,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 0, 5, 0),
                                              child: Text("${i + 1})",
                                                  softWrap: true,
                                                  style: TextStyle(
                                                      fontSize: 12.0)),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            // Handle the click action here
                                            // For example, you can navigate to a new screen or perform some other action.
                                            print("BODY UNFOCUSSING");
                                            print(
                                                "Copy word, '${widget.words[i][0]}' clicked!");
                                            copyToClipboard(
                                                context, widget.words[i][0]);
                                          },
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .15,
                                            child: Text(widget.words[i][0],
                                                softWrap: true,
                                                style:
                                                    TextStyle(fontSize: 12.0)),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            // Handle the click action here
                                            // For example, you can navigate to a new screen or perform some other action.
                                            print("BODY UNFOCUSSING");
                                            print(
                                                "Copy formatted word, '${widget.words[i][1]}' clicked!");
                                            copyToClipboard(
                                                context, widget.words[i][1]);
                                          },
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .15,
                                            child: Text(
                                              "( ${widget.words[i][1]} )",
                                              softWrap: true,
                                              style: TextStyle(fontSize: 10.0),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            // Handle the click action here
                                            // For example, you can navigate to a new screen or perform some other action.
                                            print("BODY UNFOCUSSING");
                                            print(
                                                "Definition for '${widget.words[i][0]}', copy '${widget.words[i][2]}'' clicked!");
                                            copyToClipboard(
                                                context, widget.words[i][2]);
                                          },
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .56,
                                            child: Text(
                                              widget.words[i][2],
                                              softWrap: true,
                                              style: TextStyle(fontSize: 12.0),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                        ]),
                      ),
                    ),
                  )
                ])));
  }
}
