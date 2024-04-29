// ignore_for_file: use_build_context_synchronously, must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import 'main.dart';

class Menu extends StatefulWidget {
  final BuildContext context;
  final String page;
  final Function updateParent;
  Menu({required this.context, required this.page, required this.updateParent});

  @override
  // ignore: library_private_types_in_public_api
  MenuState createState() => MenuState();
}

class MenuState extends State<Menu> {
  late BuildContext mainContext;
  String helpText =
      '<strong style="font-style:italic;">Welcome to my Joints.<br />After loggin in, you can choose 3 options:<br /></strong><u>1) \'See Joints Map\'</u>:<br />`&nbsp;&nbsp;&nbsp;`Click this to see a filtered map of the places you have visited.The maker titles show the comment entered.<br /><u>2) \'See Joints List\'</u>:<br />`&nbsp;&nbsp;&nbsp;`Click this to see a filtered list of the history and comments of each place visited.<br /><u>3) \'Add Joint\'</u>:<br /><p style="text-indent: 20px;"></p>First, select a joint type. Second, drag the marker to your exact position. Third, click to "+" icon. Fourth, enter a name and a comment for your new joint. Finally, click "Add Joint".<br />';
  @override
  void initState() {
    mainContext = widget.context;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MyHomePageState().setSavedLanguage(context);
    return PopupMenuButton<dynamic>(
        padding: EdgeInsets.all(0),
        color: Colors.white,
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),
        icon: Icon(Icons.menu),
        onSelected: (value) {
          print("menu selected value = $value");
          //focusNode.unfocus();
          FocusScope.of(context).unfocus();
          //MyHomePageState().showInterstitialAd((){});
        },
        onOpened: () {
          print("menu opened.");
          setState(() {
            context.read<AppData>().setMenuOpen(true);
          });
          widget.updateParent();
        },
        onCanceled: () {
          setState(() {
            context.read<AppData>().setMenuOpen(false);
          });
          widget.updateParent();
        },
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem<dynamic>(
                value: 'MY POPUP',
                child: MenuList(
                    context: context,
                    page: widget.page,
                    updateParent: widget.updateParent)),
          ];
        });
  }
}

class MenuList extends StatefulWidget {
  BuildContext context;
  String page;
  Function updateParent;
  MenuList(
      {required this.context, required this.page, required this.updateParent});

  @override
  // ignore: library_private_types_in_public_api
  MenuListState createState() => MenuListState();
}

class MenuListState extends State<MenuList> {
  List<dynamic> languages = [];
  @override
  void initState() {
    super.initState();
    languages = MyHomePageState().languages;
  }

  Future<void> changeLanguage(String languageCode) async {
    print("changeLanguage called, languageCode = $languageCode");

    FlutterI18n.refresh(widget.context, Locale(languageCode));
    await Future.delayed(Duration(milliseconds: 400));
    setState(() {
      //Future.delayed(Duration(milliseconds: 3000), () {
      dynamic myLanguage = (languages.where(
          (dynamic language) => language["value"] == languageCode)).toList()[0];
      context.read<AppData>().setLanguage(myLanguage!);
      print("SELECTED LANGUAGE = $myLanguage");
    });
    widget.updateParent();
  }

  @override
  Widget build(BuildContext context) {
    MyHomePageState().setSavedLanguage(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double promptFontSize =
        (screenWidth * 0.05 - 3) > 15 ? 15 : (screenWidth * 0.05 - 3);

    var help1 = FlutterI18n.translate(context, "HELP1");
    var help2 = FlutterI18n.translate(context, "HELP2");
    var help3 = FlutterI18n.translate(context, "HELP3");
    var help4 = FlutterI18n.translate(context, "HELP4");
    String helpText =
        '<strong style="font-style:italic;">$help1<br />$help2<br />$help3<br />$help4</strong><br />';
    List<DropdownMenuItem<String>> languageItems =
        languages.map<DropdownMenuItem<String>>((dynamic lang) {
      return DropdownMenuItem<String>(
        value: lang["value"],
        child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.40,
            child: Text(
                "${lang["name1"]}(${FlutterI18n.translate(context, lang["name2"])})",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: promptFontSize))),
      );
    }).toList();
    return languages.isEmpty
        ? Center(child: CircularProgressIndicator())
        : Container(
            width: screenWidth,
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              children: [
                Container(
                  width: screenWidth,
                  height: 50,
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(color: Colors.white),
                        width: screenWidth * 0.25,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                          child: Text(
                              '${FlutterI18n.translate(context, "PROMPT_LANGUAGE")}:',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: promptFontSize)),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(color: Colors.white),
                        width: (screenWidth * 0.75) - 60,
                        child: DropdownButton<String>(
                          alignment: Alignment.centerRight,
                          isExpanded: true,
                          //{"name1": "Afrikaans", "name2": "LANGUAGE_AFRIKAANS", "value": "af"},
                          value: Provider.of<AppData>(context)
                              .selectedLanguage["value"],
                          onChanged: (newLanguage) {
                            changeLanguage(newLanguage!);
                          },
                          items: languageItems,
                        ),
                      ),
                    ],
                  ),
                ),
                Html(data: helpText),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text('0',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('s,z', textAlign: TextAlign.left),
                    ),
                    Expanded(
                      flex: 11,
                      child: Text(
                          FlutterI18n.translate(context, "PROMPT_SOUND_SZ"),
                          textAlign: TextAlign.left),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text('1',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('d,t,th', textAlign: TextAlign.left),
                    ),
                    Expanded(
                      flex: 11,
                      child: Text(
                          FlutterI18n.translate(context, "PROMPT_SOUND_DTTH"),
                          textAlign: TextAlign.left),
                    )
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text('2',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('n', textAlign: TextAlign.left),
                    ),
                    Expanded(
                      flex: 11,
                      child: Text(
                          FlutterI18n.translate(context, "PROMPT_SOUND_N"),
                          textAlign: TextAlign.left),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text('3',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('m', textAlign: TextAlign.left),
                    ),
                    Expanded(
                      flex: 11,
                      child: Text(
                          FlutterI18n.translate(context, "PROMPT_SOUND_M"),
                          textAlign: TextAlign.left),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text('4',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('r', textAlign: TextAlign.left),
                    ),
                    Expanded(
                      flex: 11,
                      child: Text(
                          FlutterI18n.translate(context, "PROMPT_SOUND_R"),
                          textAlign: TextAlign.left),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text('5',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('l', textAlign: TextAlign.left),
                    ),
                    Expanded(
                      flex: 11,
                      child: Text(
                          FlutterI18n.translate(context, "PROMPT_SOUND_L"),
                          textAlign: TextAlign.left),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text('6',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('ch,j,g,sh', textAlign: TextAlign.left),
                    ),
                    Expanded(
                      flex: 11,
                      child: Text(
                          FlutterI18n.translate(context, "PROMPT_SOUND_G"),
                          textAlign: TextAlign.left),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text('7',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('c,gg,k,q', textAlign: TextAlign.left),
                    ),
                    Expanded(
                      flex: 11,
                      child: Text(
                          FlutterI18n.translate(context, "PROMPT_SOUND_K"),
                          textAlign: TextAlign.left),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text('8',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('f,ph,v', textAlign: TextAlign.left),
                    ),
                    Expanded(
                      flex: 11,
                      child: Text(
                          FlutterI18n.translate(context, "PROMPT_SOUND_FPHV"),
                          textAlign: TextAlign.left),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text('9',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('b,p', textAlign: TextAlign.left),
                    ),
                    Expanded(
                      flex: 11,
                      child: Text(
                          FlutterI18n.translate(context, "PROMPT_SOUND_BP"),
                          textAlign: TextAlign.left),
                    ),
                  ],
                ),
              ],
            ),
          );
  }
}
