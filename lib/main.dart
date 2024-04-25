//import 'dart:collection';
//import 'dart:js_interop';

// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

//kIsWeb : SIMILIAR TO NOT isApp() FUNCTION====>
import 'package:flutter/foundation.dart';

//import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/loaders/decoders/base_decode_strategy.dart';
import 'package:flutter_i18n/loaders/decoders/json_decode_strategy.dart';
import 'package:major_words_maker/menu.dart';
import 'package:major_words_maker/words_new.dart';
import 'package:major_words_maker/words_old.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:list_major_english_words/list_major_english_words.dart';
import 'major_english_words.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:multiselect/multiselect.dart';
import 'package:multiselect_dropdown_flutter/multiselect_dropdown_flutter.dart';

//import 'package:flutter_native_splash/flutter_native_splash.dart';
//import 'package:device_info/device_info.dart';

const String testDevice = '974550CBC7D4EA4718A67165E2E3B868';
const String myIpad = '00008020-0014301102D1002E';
const String myIphone11 = 'A8EC231A-DCFC-405C-8A0D-62E9F5BA1918';
const int maxFailedLoadAttempts = 3;
InterstitialAd? interstitialAd;
int numInterstitialLoadAttempts = 0;

///----

///------
dynamic selectedMajorLanguage;

class MajorWord {
  String name;
  String number;
  String definition;
  MajorWord(this.name, this.number, this.definition);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("main RETURNING $kIsWeb");
  if (kIsWeb == false) {
    var testDevices = <String>[];
    if (Platform.isAndroid) {
      testDevices = [testDevice];
    } else if (Platform.isIOS) {
      testDevices = [myIpad, myIphone11];
    }
    MobileAds.instance
      ..initialize()
      ..updateRequestConfiguration(RequestConfiguration(
        testDeviceIds: testDevices,
      ));
  } else {
    print("main NOT SHOWING AD");
  }
  //String deviceId = await getDeviceId();
  //print('Device ID: $deviceId');
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
          create: (context) => AppData(),
          child: MyApp()) // Other providers if needed
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final int ofThousandShowAds = 450;
  List<BaseDecodeStrategy> decodeStrategies = [JsonDecodeStrategy()];
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    MyHomePageState().setSavedLanguage(context);
    return MaterialApp(
      navigatorKey: navigatorKey,
      localizationsDelegates: [
        FlutterI18nDelegate(
          translationLoader: FileTranslationLoader(
              decodeStrategies: decodeStrategies,
              basePath: "assets/i18n",
              fallbackFile: "en",
              useCountryCode: false),
          missingTranslationHandler: (key, locale) {
            print(
                "--- Missing Key: $key, languageCode: ${locale?.languageCode}");
          },
        ),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      title: 'Major Words Maker App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromRGBO(200, 255, 200, 1.0)),
      ),
      home: MyHomePage(),
    );
  }
}

class AppData extends ChangeNotifier {
  dynamic selectedLanguage = {
    "LID": "8",
    "name1": "English",
    "name2": "LANGUAGE_ENGLISH",
    "value": "en"
  };
  Future<void> setLanguage(dynamic myLanguage) async {
    selectedLanguage = myLanguage;
    selectedMajorLanguage = selectedLanguage;
    await MyHomePageState().setData("LANGUAGE", selectedLanguage["value"]);
  }

  bool menuOpen = false;
  void setMenuOpen(bool isOpen) {
    menuOpen = isOpen;
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0; // ← Add this property.
  //bool isMakeMajor = false;
  bool isMakeMajor = true;
  List<dynamic> languages = [
    {
      "LID": "1",
      "name1": "Afrikaans",
      "name2": "LANGUAGE_AFRIKAANS",
      "value": "af"
    },
    {"LID": "2", "name1": "Euskara", "name2": "LANGUAGE_BASQUE", "value": "eu"},
    {
      "LID": "3",
      "name1": "Bosanski",
      "name2": "LANGUAGE_BOSNIAN",
      "value": "bs"
    },
    {
      "LID": "4",
      "name1": "Hrvatski",
      "name2": "LANGUAGE_CROATIAN",
      "value": "hr"
    },
    {"LID": "5", "name1": "čeština", "name2": "LANGUAGE_CZECH", "value": "cs"},
    {"LID": "6", "name1": "Dansk", "name2": "LANGUAGE_DANISH", "value": "da"},
    /*
    {
      "LID": "7",
      "name1": "Nederlands",
      "name2": "LANGUAGE_DUTCH",
      "value": "nl"
    },
    */
    {
      "LID": "8",
      "name1": "English",
      "name2": "LANGUAGE_ENGLISH",
      "value": "en"
    },
    {
      "LID": "9",
      "name1": "Eesti keel",
      "name2": "LANGUAGE_ESTONIAN",
      "value": "et"
    },
    /*
    {
      "LID": "10",
      "name1": "Filipino",
      "name2": "LANGUAGE_FILIPINO",
      "value": "tl"
    },
    */
    {
      "LID": "11",
      "name1": "Suomalainen",
      "name2": "LANGUAGE_FINNISH",
      "value": "fi"
    },
    {
      "LID": "12",
      "name1": "Français",
      "name2": "LANGUAGE_FRENCH",
      "value": "fr"
    },
    {
      "LID": "13",
      "name1": "Deutsch",
      "name2": "LANGUAGE_GERMAN",
      "value": "de"
    },
    {
      "LID": "14",
      "name1": "Kreyòl ayisyen",
      "name2": "LANGUAGE_HAITIAN_CREOLE",
      "value": "ht"
    },
    {
      "LID": "15",
      "name1": "ʻŌlelo Hawaiʻi",
      "name2": "LANGUAGE_HAWAIIAN",
      "value": "haw"
    },
    {"LID": "16", "name1": "Hmoob", "name2": "LANGUAGE_HMONG", "value": "hmn"},
    {
      "LID": "17",
      "name1": "Magyar",
      "name2": "LANGUAGE_HUNGARIAN",
      "value": "hu"
    },
    {
      "LID": "18",
      "name1": "Bahasa Indonesia",
      "name2": "LANGUAGE_INDONESIAN",
      "value": "id"
    },
    {"LID": "19", "name1": "Gaeilge", "name2": "LANGUAGE_IRISH", "value": "ga"},
    {
      "LID": "20",
      "name1": "Italiano",
      "name2": "LANGUAGE_ITALIAN",
      "value": "it"
    },
    /*
    {
      "LID": "21",
      "name1": "Kurdî kurd",
      "name2": "LANGUAGE_KURDISH_KURMANJI",
      "value": "ku"
    },
    */
    {
      "LID": "22",
      "name1": "Lëtzebuergesch",
      "name2": "LANGUAGE_LUXEMBOURGISH",
      "value": "lb"
    },
    {"LID": "23", "name1": "Melayu", "name2": "LANGUAGE_MALAY", "value": "ms"},
    {"LID": "24", "name1": "Malti", "name2": "LANGUAGE_MALTESE", "value": "mt"},
    {"LID": "25", "name1": "Maori", "name2": "LANGUAGE_MAORI", "value": "mi"},
    /*
    {
      "LID": "26",
      "name1": "Norsk",
      "name2": "LANGUAGE_NORWEGIAN",
      "value": "no"
    },
    */
    {"LID": "27", "name1": "Polski", "name2": "LANGUAGE_POLISH", "value": "pl"},
    {
      "LID": "28",
      "name1": "Português",
      "name2": "LANGUAGE_PORTUGUESE",
      "value": "pt"
    },
    {
      "LID": "29",
      "name1": "Română",
      "name2": "LANGUAGE_ROMANIAN",
      "value": "ro"
    },
    {"LID": "30", "name1": "Samoa", "name2": "LANGUAGE_SAMOAN", "value": "sm"},
    {
      "LID": "31",
      "name1": "Slovensko",
      "name2": "LANGUAGE_SLOVAK",
      "value": "sk"
    },
    {
      "LID": "32",
      "name1": "Slovenščina",
      "name2": "LANGUAGE_SLOVENIAN",
      "value": "sl"
    },
    {
      "LID": "33",
      "name1": "Soomaali",
      "name2": "LANGUAGE_SOMALI",
      "value": "so"
    },
    {
      "LID": "34",
      "name1": "Español",
      "name2": "LANGUAGE_SPANISH",
      "value": "es"
    },
    {
      "LID": "35",
      "name1": "Svenska",
      "name2": "LANGUAGE_SWEDISH",
      "value": "sv"
    },
    /*
    {"LID": "37", "name1": "Türk", "name2": "LANGUAGE_TURKISH", "value": "tr"},
    */
    /*
    {
      "LID": "38",
      "name1": "Tiếng Việt",
      "name2": "LANGUAGE_VIETNAMESE",
      "value": "vi"
    },
    */
    {"LID": "39", "name1": "Cymraeg", "name2": "LANGUAGE_WELSH", "value": "cy"}
  ];

  dynamic selectedMajorLanguage;
  List<dynamic> availLanguages = [];
  bool isLanguagesLoading = true;
  List<String> myFilteredLanguages = [];
  bool isAllLanguages = true;
  List<String> myList = ["..."];

  @override
  void initState() {
    super.initState();
    isLanguagesLoading = true;
    selectedMajorLanguage = languages[0];
    if (kIsWeb == false) {
      createInterstitialAd();
    }
    setSavedLanguage(null);
    //setAvailLanguages();
    setAvailLanguages();
  }

  @override
  void didChangeDependencies() {
    print("didChangeDependencies called");
    super.didChangeDependencies();
    doChangeDependencies();
    //FlutterI18n.refresh(context,Locale(Provider.of<AppData>(context).selectedLanguage["value"]));
  }

  doChangeDependencies() {
    //if (context == null)
    //BuildContext? context = scaffoldKey.currentContext;
    //if (context != null) {
    print("MyHomePageState doChangeDependencies called CONTEXT NOT NULL!");
    setState(() {
      resetMyList();
    });
  }

  resetMyList() {
    print("resetMyList called");

    myList = [FlutterI18n.translate(context, "PROMPT_ALL")];
    myList.addAll(availLanguages.map((dynamic value) {
      return "${value["name1"]}(${FlutterI18n.translate(context, value["name2"])})";
    }).toList());
    print(
        "resetMyList called CONTEXT NOT NULL! myList = ${json.encode(myList)}");
    print("selectedMajorLanguage[value] = ${selectedMajorLanguage["value"]}");
    dynamic myLanguage = List<dynamic>.from(languages
        .where(
            (dynamic lang) => lang["value"] == selectedMajorLanguage["value"])
        .toList())[0];
    print("myList = $myList, myLanguage[name1] = ${myLanguage["name1"]}");
    List<String> foundMyListEles = List<String>.from(myList
        .where((String myEle) => myEle.contains(myLanguage["name1"]))
        .toList());
    if (foundMyListEles.isNotEmpty) {
      String myListElement = foundMyListEles[0];
      myFilteredLanguages = [myListElement];
    } else {
      myFilteredLanguages = [];
    }
  }

  setAvailLanguages() async {
    //showProgress(
    //    context, FlutterI18n.translate(context, "PROGRESS_ADD_COMMENT"));
    dynamic data = {"SUCCESS": false};
    bool isSuccess = true;
    List<dynamic> gotLanguages = [];
    final response = await http.get(Uri.parse(
        'https://www.learnfactsquick.com/lfq_app_php/get_languages.php'));
    //hideProgress(context);
    if (response.statusCode == 200) {
      data = Map<String, dynamic>.from(json.decode(response.body));
      print("GET AVAIL LANGUAGES data = ${json.encode(data)}");
      if (data["SUCCESS"] == true) {
        print("GOT LANGUAGES = ${json.encode(data)}");
        gotLanguages = data["LANGUAGES"];
      } else {
        print("GET LANGUAGES ERROR: ${data["ERROR"]}");
        isSuccess = false;
        //showPopup(context, data["ERROR"]);
      }
    } else {
      showPopup(context, FlutterI18n.translate(context, "NETWORK_ERROR"));
    }
    setState(() {
      isLanguagesLoading = false;
      if (isSuccess == true) {
        dynamic availLang;
        for (int i = 0; i < gotLanguages.length; i++) {
          availLang = (MyHomePageState().languages.where((dynamic language) =>
              language["value"] == gotLanguages[i]["Code"])).toList()[0];
          availLanguages.add(availLang);
        }
        resetMyList();
      }
    });
  }

  Future<void> showPopup(BuildContext context, String message) async {
    //context ??= scaffoldKey.currentContext!;
    print("showPopup called");
    return await showDialog<void>(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing by tapping outside the popup
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(FlutterI18n.translate(context, "ALERT")),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the popup
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  bool isLoading = false;
  Future<void> showProgress(BuildContext context, message) async {
    //hideProgress(context);
    Completer<void> completer = Completer<void>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        completer.complete();
        return Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white, // Background color
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
                SizedBox(height: 16.0),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    //isShowProgress = true;
  }

  void hideProgress(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
    isLoading = false;
  }

  List<dynamic> oldWords = [];
  Map<String, List<dynamic>> newWords = {};
  List<List<Map<String, List<String>>>> dicWords = [
    list_major_english_words1,
    list_major_english_words2,
    list_major_english_words3,
    list_major_english_words4,
    list_major_english_words5,
    list_major_english_words6,
    list_major_english_words7,
    list_major_english_words8,
    list_major_english_words9,
    list_major_english_words10,
    list_major_english_words11,
    list_major_english_words12,
    list_major_english_words13,
    list_major_english_words14,
    list_major_english_words15,
    list_major_english_words16,
    list_major_english_words17,
    list_major_english_words18,
    list_major_english_words19,
    list_major_english_words20,
    list_major_english_words21,
    list_major_english_words22
  ];
  final TextEditingController numberController = TextEditingController();

  void doMakeMajorWords(context, targetLanguage) {
    print("doMakeMajorWords called, targetLanguage = $targetLanguage");
    if (numberController.text.trim() == '') {
      showPopup(context, FlutterI18n.translate(context, "PROMPT_NO_NUMBERS"));
      return;
    } else if (myFilteredLanguages.isEmpty) {
      showPopup(context, FlutterI18n.translate(context, "PROMPT_NO_LANGUAGES"));
      return;
    }

    if (targetLanguage == "en" &&
        myFilteredLanguages.length == 1 &&
        myFilteredLanguages[0] == "English(English)") {
      makeMajorWordsOld(context);
    } else {
      makeMajorWords(context, targetLanguage);
    }
  }

  String lastNumber = "";
  void makeMajorWordsOld(context) {
    isLoading = true;
    //showProgress(context);
    print("list_english_words length = ${dicWords.length}");
    print("makeMajorWordsOld called");
    print(numberController.text);
    lastNumber = numberController.text;
    //var num = "";
    oldWords = [];
    String key = "";
    var formattedWord = "";
    Map<String, List<String>> dicObj;
    for (var i = 0; i < dicWords.length; i++) {
      for (var j = 0; j < dicWords[i].length; j++) {
        dicObj = dicWords[i][j];
        key = dicObj.keys.toList().first;
        //print("key: $key, value: $value");
        //print("FOR WORD, $dicWord,  GOT NUM $num");
        if (dicObj[key]?[0].toString() == numberController.text.toString()) {
          formattedWord = formatWord(key);
          oldWords.add([key, formattedWord, dicObj[key]!.elementAt(1)]);
        }
      }
    }
    //print("WORDS FOUND= $words");
    //hideProgress(context);
    //isLoading = false;
    showInterstitialAd(() {
      print("NOT SHOWING AD");
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  WordsPageOld(lastNumber: lastNumber, words: oldWords)));

      setState(() {});
    });
  }

  makeMajorWords(BuildContext context, String targetLanguage) async {
    print("makeMajorWords called targetLanguage = $targetLanguage");
    if (numberController.text.trim() == '') {
      return;
    }
    isLoading = true;
    //showProgress(context, FlutterI18n.translate(context, "PROGRESS_MAKE_MAJOR"));
    print(numberController.text);
    lastNumber = numberController.text;
    Map<String, List<dynamic>> gotMajorWords = {};
    int countWords = 0;
    print('makeMajorWords targetLanguage = $targetLanguage');
    List<String> languageIds = [];
    if (isAllLanguages == false) {
      List<String> langVals = [];
      for (var i = 0; i < myFilteredLanguages.length; i++) {
        langVals
            .add(myFilteredLanguages[i].toString().split("(")[0].toString());
      }
      print("makeMajorWords langVals =$langVals");
      List<dynamic> languages = List<dynamic>.from(availLanguages
          .where((dynamic lang) => langVals.contains(lang["name1"]))
          .toList());
      print("makeMajorWords got languages =${json.encode(languages)}");
      languageIds = List<String>.from(
          languages.map((dynamic lang) => lang["LID"]).toList());
    }
    //DEFAULT TO ENGLISH IF TARGET LANGUAGE(APP LANGUAGE) NOT AVAILABLE:
    String targetLangId = "8";
    List<dynamic> foundTargetLanguages = List<dynamic>.from(availLanguages
        .where((dynamic lang) => lang["value"] == targetLanguage)
        .toList());
    if (foundTargetLanguages.isNotEmpty) {
      targetLangId = foundTargetLanguages[0]["LID"];
    }
    Map<String, dynamic> body = {
      "number": lastNumber,
      "languageIds": languageIds,
      "isAllLangs": isAllLanguages.toString(),
      "targetLangId": targetLangId
    };
    print("ADD JOINT DATA = ${json.encode(body)}");
    dynamic data = {"SUCCESS": false};
    final response = await http.post(
        Uri.parse(
            'https://www.learnfactsquick.com/major_words_maker/make_major_words.php'),
        body: json.encode(body));
    //hideProgress(context);
    if (response.statusCode == 200) {
      data = Map<String, dynamic>.from(json.decode(response.body));
      print("GET MAJOR WORDS data = ${json.encode(data)}");
      if (data["SUCCESS"] == true) {
        gotMajorWords = Map<String, List<dynamic>>.from(data["WORDS"]);
        countWords = data["COUNT_WORDS"];
        print("GOT MAJOR WORDS = ${json.encode(data)}");
        showInterstitialAd(() {
          print("NOT SHOWING AD");
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WordsPageNew(
                      lastNumber: lastNumber,
                      words: gotMajorWords,
                      countWords: countWords)));
          setState(() {});
        });
      } else {
        print("GET MAJOR WORDS ERROR: ${data["ERROR"]}");
        showPopup(context, data["ERROR"]);
      }
    } else {
      showPopup(context, FlutterI18n.translate(context, "NETWORK_ERROR"));
    }
  }

  String formatWord(myWord) {
    var worspl = myWord.toString().toLowerCase().split("").toList();
    var myNumber = numberController.text.toString();
    var markMax = myNumber.length;
    //MAKE ARRAY LOWERCASE:
    var wordLength = worspl.length;
    var marletct = 0;
    var formattedWord = "";
    List<List<String>> letterCombos = [
      ["b", "b"],
      ["c", "h"],
      ["c", "k"],
      ["c", "y"],
      ["c", "z"],
      ["d", "d"],
      ["f", "f"],
      ["g", "h"],
      ["g", "g"],
      ["l", "l"],
      ["m", "m"],
      ["n", "n"],
      ["p", "p"],
      ["p", "h"],
      ["r", "r"],
      ["s", "s"],
      ["s", "h"],
      ["t", "t"],
      ["t", "h"],
      ["z", "z"]
    ];
    //return "YOUP";
    var isLetterCombo = false;
    var numberSplit = myNumber.split("");
    // ignlets=aeiouwxy
    for (var i = 0; i < wordLength; i++) {
      //1) IGNORE LETTERS:
      bool containsSilent = RegExp(r'[aeiouwxy]').hasMatch(worspl[i]);
      if (containsSilent == true) {
        formattedWord += worspl[i].toLowerCase();
      } else {
        //IF NOT IGNORE LETTERS:
        if (marletct < markMax) {
          //if ("aeiouwxyh".match(worspl[i]) == null) {
          //   formattedWord += worspl[i].toUpperCase();
          //   marletct++;
          //}
          //BEGINNING LETTER:
          if (i == 0 && worspl[i] == "h") {
            formattedWord += worspl[i].toLowerCase();
          } else if (i == 0 && worspl[i] != "h") {
            formattedWord += worspl[i].toUpperCase();
            marletct++;
          } else if (i > 0) {
            //NOT BEGINNING LETTER:
            //DOUBLE LETTERS/COMBINATIONS:
            isLetterCombo = false;
            for (var j = 0; j < letterCombos.length; j++) {
              if (worspl[i - 1] == letterCombos[j][0] &&
                  worspl[i] == letterCombos[j][1]) {
                if (letterCombos[j][0] == "g" &&
                    letterCombos[j][1] == "h" &&
                    numberSplit[marletct] != "7" &&
                    numberSplit[marletct] != "8") {
                  formattedWord += worspl[i].toLowerCase();
                } else {
                  formattedWord += worspl[i].toUpperCase();
                }
                isLetterCombo = true;
              }
            }
            if (isLetterCombo == false) {
              if (worspl[i] == "h" ||
                  ((i < (wordLength - 1)) &&
                      worspl[i] == "g" &&
                      worspl[i + 1] == "h" &&
                      (numberSplit[marletct] != "7" &&
                          numberSplit[marletct] != "8"))) {
                formattedWord += worspl[i].toLowerCase();
              } else {
                formattedWord += worspl[i].toUpperCase();
                marletct++;
              }
            }
          }
        } else {
          // end if marletct<numct
          formattedWord += worspl[i].toLowerCase();
        }
      }
    } // end for loop format letters
    return formattedWord;
  }

  setSavedLanguage(BuildContext? context) async {
    String savedLanguage = (await getData("LANGUAGE")) ?? "";
    print("savedLanguage = ${json.encode(savedLanguage)}");
    if (savedLanguage != "") {
      selectedMajorLanguage = List<dynamic>.from(languages
          .where((dynamic lang) => lang["value"] == savedLanguage)
          .toList())[0];
      try {
        if (context != null) {
          FlutterI18n.refresh(context, Locale(savedLanguage));
        }
      } catch (e) {
        print("Error refreshing saved language");
      }
    } else {
      //FlutterI18n.refresh(context, Locale('en'));
    }
  }

  @override
  void didUpdateWidget(covariant MyHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    FlutterI18n.refresh(context,
        Locale(Provider.of<AppData>(context).selectedLanguage["value"]));
  }

  static final AdRequest request = AdRequest(
    keywords: <String>[
      'major system',
      'memorize numbers',
      'improve memory',
      'improve memory of numbers',
      'words'
    ],
    contentUrl: 'https://learnfactsquick.com/#/major_system_generator',
    nonPersonalizedAds: true,
  );

  void createInterstitialAd() {
    print("createInterstitialAd interstitialAd CALLED.");
    //setState(() {
    //  isMakeMajor = false;
    //});
    var appId = Platform.isAndroid
        ? 'ca-app-pub-8514966468184377/6907461840'
        : 'ca-app-pub-8514966468184377/5883541243';
    print("Using appId: $appId kDebugMode = $kDebugMode");
    InterstitialAd.load(
        adUnitId: appId,
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('My InterstitialAd $ad loaded');
            interstitialAd = ad;
            numInterstitialLoadAttempts = 0;
            interstitialAd!.setImmersiveMode(true);
            print("interstitialAd == null ? : ${interstitialAd == null}");
            //setState(() {
            //  isMakeMajor = true;
            //});
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('interstitialAd failed to load: $error.');
            numInterstitialLoadAttempts += 1;
            interstitialAd = null;
            //setState(() {
            //  isMakeMajor = false;
            //});
            if (numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              createInterstitialAd();
            }
          },
        ));
  }

  void showInterstitialAd(Function callback) {
    print("showInterstitialAd called");
    if (kIsWeb == true) {
      print('Web can not show ads.');
      callback();
    } else if (interstitialAd == null) {
      print('Warning: attempt to show interstitialAd before loaded.');
      callback();
    } else {
      Random random = Random();
      var isShowAd = (random.nextInt(1000) < MyApp().ofThousandShowAds);
      if (isShowAd != true) {
        callback();
      } else {
        interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (InterstitialAd ad) =>
              debugPrint('interstitialAd onAdShowedFullScreenContent.'),
          onAdDismissedFullScreenContent: (InterstitialAd ad) {
            ad.dispose();
            createInterstitialAd();
            callback();
          },
          onAdFailedToShowFullScreenContent:
              (InterstitialAd ad, AdError error) {
            ad.dispose();
            createInterstitialAd();
            callback();
          },
        );
        interstitialAd!.show();
        interstitialAd = null;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (kIsWeb == false) {
      print("DISPOSING interstitialAd !!!");
      interstitialAd?.dispose();
    }
  }

  // To save data
  Future<void> setData(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

// To read data
  Future<String?> getData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  isLinkPlayStore() {
    return (kIsWeb || Platform.isAndroid);
  }

  isLinkAppStore() {
    return (kIsWeb || Platform.isIOS);
  }

  updateSelf() {
    print("HomePageState updateSelf called");
    setState(() {
      resetMyList();
    });
  }

  setLanguages(BuildContext context, List<String> newList) {
    print(
        "setLanguages called, newList = ${json.encode(newList)}, myFilteredLanguages = ${json.encode(myFilteredLanguages)}");
    String promptAllTrans = FlutterI18n.translate(context, "PROMPT_ALL");
    setState(() {
      if (newList.contains(promptAllTrans) && isAllLanguages == false) {
        isAllLanguages = true;
        print("SELECTING ALL!!");
        myFilteredLanguages = [promptAllTrans];
        myFilteredLanguages.addAll(availLanguages.map((dynamic value) {
          return "${value["name1"]}(${FlutterI18n.translate(context, value["name2"])})";
        }).toList());
      } else if (isAllLanguages == true &&
          !myFilteredLanguages.contains(promptAllTrans)) {
        isAllLanguages = false;
        myFilteredLanguages = [];
      } else {
        myFilteredLanguages = newList;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //if (myList.isEmpty) {
    //}
    print("Menu build myList = $myList");
    print("Menu build myFilteredLanguages = $myFilteredLanguages");
    MyHomePageState().setSavedLanguage(context);
    //const appTitle = 'Major Words Maker';
    double screenWidth = MediaQuery.of(context).size.width;
    double tabFontSize =
        (screenWidth * 0.020 + 4) < 15 ? 15 : (screenWidth * 0.020 + 4);
    double promptFontSize =
        (screenWidth * 0.016 + 4) < 11 ? 11 : (screenWidth * 0.016 + 4);

    var appTitle = FlutterI18n.translate(context, "APP_TITLE");
    final theme = Theme.of(context); // ← Add this.

    FocusNode focusNode = FocusNode();

    return Consumer<AppData>(builder: (context, appData, child) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: Text(appTitle, style: TextStyle(fontSize: tabFontSize)),
          actions: <Widget>[
            Menu(context: context, page: 'main', updateParent: updateSelf)
          ],
        ),
        body: isLanguagesLoading == true || myList.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextField(
                        controller: numberController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText:
                              FlutterI18n.translate(context, "ENTER_NUMBERS"),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ], // Only numbers can be entered
                        onEditingComplete: () {
                          //if (Platform.isAndroid) {
                          //  focusNode.unfocus();
                          //} else if (Platform.isIOS) {
                          FocusScope.of(context).unfocus();
                          //}
                          doMakeMajorWords(
                              context, selectedMajorLanguage["value"]);
                        }),
                  ),
                  //Text(json.encode(myFilteredLanguages)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Container(
                        decoration: BoxDecoration(color: Colors.white),
                        width: screenWidth - 40,
                        child: DropDownMultiSelect(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                          isDense: true,
                          onChanged: (List<String> newList) {
                            setLanguages(context, List<String>.from(newList));
                          },
                          options: myList,
                          selectedValues: myFilteredLanguages,
                          whenEmpty: FlutterI18n.translate(
                              context, "SELECT_LANGUAGES"),
                        )),
                  ),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: ElevatedButton(
                        onPressed: () async {
                          //if (Platform.isAndroid) {
                          focusNode.unfocus();
                          //} else if (Platform.isIOS) {
                          FocusScope.of(context).unfocus();
                          //}
                          //await Future.delayed(Duration(seconds: 1), () {
                          // Code to be executed after the delay
                          print("Delayed action executed!");
                          doMakeMajorWords(
                              context, selectedMajorLanguage["value"]);
                          //});
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green,
                          minimumSize: Size(100, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Text(
                            FlutterI18n.translate(context, "MAKE_MAJOR_WORDS")),
                      )),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: SizedBox(
                        width: 275,
                        child: ElevatedButton(
                          onPressed: () {
                            // Add your button's functionality here
                            launch('https://learnfactsquick.com');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 204, 159,
                                252), // Change the button's background color
                            foregroundColor:
                                Colors.white, // Change the text color
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            children: <Widget>[
                              Image.asset(
                                'assets/images/lfq_icon.png', // Path to your image asset
                                width: 25, // Set the desired width
                                height: 25, // Set the desired height
                              ),
                              SizedBox(width: 8),
                              Text(
                                  FlutterI18n.translate(
                                      context, "PROMPT_TOOLS_WEBSITE"),
                                  style: TextStyle(fontSize: 10)), // Text
                            ],
                          ),
                        )),
                  ),
                  Visibility(
                    visible: isLinkPlayStore(),
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: SizedBox(
                          width: 275,
                          child: ElevatedButton(
                            onPressed: () {
                              // Add your button's functionality here
                              launch(
                                  'https://play.google.com/store/apps/dev?id=5263177578338103821');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors
                                  .green, // Change the button's background color
                              foregroundColor:
                                  Colors.white, // Change the text color
                            ),
                            child: Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              children: <Widget>[
                                Icon(
                                    Icons.play_circle_fill), // Google Play icon
                                SizedBox(
                                    width:
                                        8), // Add some space between the icon and text
                                Text(
                                    FlutterI18n.translate(
                                        context, "PROMPT_APPS_PLAY_STORE"),
                                    style: TextStyle(fontSize: 10)), // Text
                              ],
                            ),
                          )),
                    ),
                  ),
                  Visibility(
                    visible: isLinkAppStore(),
                    child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: SizedBox(
                            width: 275,
                            child: ElevatedButton(
                              onPressed: () {
                                // Add your button's functionality here
                                launch(
                                    'https://apps.apple.com/us/developer/keith-harryman/id1693739510');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors
                                    .blue, // Change the button's background color
                                foregroundColor:
                                    Colors.white, // Change the text color
                              ),
                              child: Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                children: <Widget>[
                                  Icon(
                                      Icons.download_sharp), // Google Play icon
                                  SizedBox(
                                      width:
                                          8), // Add some space between the icon and text
                                  Text(
                                      FlutterI18n.translate(
                                          context, "PROMPT_APPS_APP_STORE"),
                                      style: TextStyle(fontSize: 10)), // Text
                                ],
                              ),
                            ))),
                  ),
                ],
              ),
      );
    });
  }
}

class CustomPopupMenuItem<T> extends PopupMenuItem<T> {
  final double width;

  CustomPopupMenuItem({
    required T value,
    required Widget child,
    this.width = 200.0, // Set a default width or adjust as needed
  }) : super(value: value, child: child);

  //@override
  //double get width => 100;
}
