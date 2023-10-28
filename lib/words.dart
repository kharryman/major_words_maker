// results.dart

import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'main.dart';

// ignore: must_be_immutable
class WordsPage extends StatelessWidget {
  final String lastNumber;
  final List<dynamic> words;

  WordsPage({required this.lastNumber, required this.words});
  String helpText =
      '<strong style="font-style:italic;">The Major Sytem is a digit to consonant memory tool.<br />Each digit is represented by a set of similar sounding consonants.<br />It was designed by Stanislaus Mink von Wennsshein of 17th Century.<br />Here is the Major System:</strong><br />';
  copyToClipboard(context, myText) {
    Clipboard.setData(ClipboardData(text: myText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(("Text, '").toString() +
              myText.toString() +
              ("' copied to clipboard").toString())),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // ← Add this.
    return Scaffold(
        appBar: AppBar(
          title: const Text('Major Words'),
          actions: <Widget>[MyPopup()],
        ),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Visibility(
                visible: lastNumber.trim() != '',
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                      "Found ${words.length} major words for number '${lastNumber}':"),
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
                      for (var i = 0; i < words.length; i++)
                        Flex(
                          direction: Axis.horizontal,
                          children: [
                            Flexible(
                              flex: 1,
                              child: Card(
                                color: theme
                                    .colorScheme.surface, // ← And also this.
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          .06,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 5, 0),
                                          child: Text("${i + 1})",
                                              softWrap: true,
                                              style: TextStyle(fontSize: 12.0)),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        // Handle the click action here
                                        // For example, you can navigate to a new screen or perform some other action.
                                        print("BODY UNFOCUSSING");
                                        print(
                                            "Copy word, '${words[i][0]}' clicked!");
                                        copyToClipboard(context, words[i][0]);
                                      },
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .15,
                                        child: Text(words[i][0],
                                            softWrap: true,
                                            style: TextStyle(fontSize: 12.0)),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        // Handle the click action here
                                        // For example, you can navigate to a new screen or perform some other action.
                                        print("BODY UNFOCUSSING");
                                        print(
                                            "Copy formatted word, '${words[i][1]}' clicked!");
                                        copyToClipboard(context, words[i][1]);
                                      },
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .15,
                                        child: Text(
                                          "( ${words[i][1]} )",
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
                                            "Definition for '${words[i][0]}', copy '${words[i][2]}'' clicked!");
                                        copyToClipboard(context, words[i][2]);
                                      },
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .56,
                                        child: Text(
                                          words[i][2],
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
            ]));
  }
}
