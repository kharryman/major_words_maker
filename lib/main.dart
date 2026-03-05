//import 'dart:collection';
//import 'dart:js_interop';

// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'dart:async';
import 'dart:convert';
import 'dart:io';

//kIsWeb : SIMILIAR TO NOT isApp() FUNCTION====>
import 'package:flutter/foundation.dart';

//import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/loaders/decoders/base_decode_strategy.dart';
import 'package:flutter_i18n/loaders/decoders/json_decode_strategy.dart';
import 'package:http/http.dart';
import 'package:major_words_maker/dict_big.dart';
import 'package:major_words_maker/globals.dart';
import 'package:major_words_maker/menu.dart';
import 'package:major_words_maker/services/ads.dart';
import 'package:major_words_maker/services/helpers.dart';
import 'package:major_words_maker/words_new.dart';
//import 'package:list_major_english_words/list_major_english_words.dart';
//import 'major_english_words.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:multiselect/multiselect.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:advanced_in_app_review/advanced_in_app_review.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

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
List<dynamic> savedAvailLanguages = [];
List<dynamic> availLanguages = [];
List<String> myList = ["English(English)"];
List<String> myFilteredLanguages = [];
dynamic defaultLanguage = {
  "LID": "8",
  "name1": "English",
  "name2": "LANGUAGE_ENGLISH",
  "value": "en"
};
String priceNoAds = "\$1";
String removeAdsProductId = "remove_ads";
bool isOnline = true;

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
      removeAdsProductId = "remove_ads";
    } else if (Platform.isIOS) {
      testDevices = [myIpad, myIphone11];
      removeAdsProductId = "remove_ads_major_words_maker";
    }
    MobileAds.instance
      ..initialize()
      ..updateRequestConfiguration(RequestConfiguration(
        testDeviceIds: testDevices,
      ));
    InAppPurchase.instance.isAvailable().then((available) {
      if (!available) {
        print("In-app purchases not available on this device.");
      }
    });
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
    MyHomeState().setSavedLanguage(context);
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
      theme:
          ThemeData(useMaterial3: true, scaffoldBackgroundColor: Colors.white),
      home: MyHome(),
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
    await HelpersService.setData("LANGUAGE", selectedLanguage["value"]);
  }

  void setIsAds(bool myIsAds) {
    print("AppData setIsAds called myIsAds = $myIsAds");
    Globals.isAds = myIsAds;
  }

  bool menuOpen = false;
  void setMenuOpen(bool isOpen) {
    menuOpen = isOpen;
  }
}

class MyHome extends StatefulWidget {
  @override
  State<MyHome> createState() => MyHomeState();
}

class MyHomeState extends State<MyHome> with WidgetsBindingObserver {
  BannerAd? bannerAd;

  final MultiSelectController controllerMultiselect = MultiSelectController();
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
    {
      "LID": "22",
      "name1": "Lëtzebuergesch",
      "name2": "LANGUAGE_LUXEMBOURGISH",
      "value": "lb"
    },
    {"LID": "23", "name1": "Melayu", "name2": "LANGUAGE_MALAY", "value": "ms"},
    {"LID": "24", "name1": "Malti", "name2": "LANGUAGE_MALTESE", "value": "mt"},
    {"LID": "25", "name1": "Maori", "name2": "LANGUAGE_MAORI", "value": "mi"},
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
    {"LID": "39", "name1": "Cymraeg", "name2": "LANGUAGE_WELSH", "value": "cy"}
  ];

  bool isLanguagesLoading = false;
  bool isAllLanguages = false;

  int lastSelectedLanguagesLength = 0;
  StreamSubscription<List<PurchaseDetails>>? purchaseSubscription;
  late final StreamSubscription<List<ConnectivityResult>>
      connectivitySubscription;

  @override
  void initState() {
    super.initState();
    if (kIsWeb == false) {
      initializeInAppPurchase();
      AdvancedInAppReview()
          .setMinDaysBeforeRemind(7)
          .setMinDaysAfterInstall(2)
          .setMinLaunchTimes(2)
          .setMinSecondsBeforeShowDialog(4)
          .monitor();
    }
    isLanguagesLoading = true;
    //DEFAULT TO ENGLISH:
    selectedMajorLanguage = languages[6];
    setSavedLanguage(null);

    final Connectivity connectivity = Connectivity();
    connectivitySubscription = connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final ConnectivityResult result =
          results.isNotEmpty ? results.first : ConnectivityResult.none;
      isOnline = result != ConnectivityResult.none;
      doNetworkChange();
    });

    connectivity.checkConnectivity().then((List<ConnectivityResult> results) {
      final ConnectivityResult result =
          results.isNotEmpty ? results.first : ConnectivityResult.none;
      isOnline = result != ConnectivityResult.none;
      print(
          "Main initState Connectivity resolved: result = $result, isOnline = $isOnline");
      doNetworkChange();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (kIsWeb == false && Globals.isAds == true) {
        AdService.loadInterstitial();
        bannerAd = await AdService.createBanner(
          onLoaded: () => setState(() {}),
        );
      }
    });
  }

  doNetworkChange() async {
    if (isOnline == false) {
      setState(() {
        print("OFFLINE...");
        selectedMajorLanguage = defaultLanguage;
        isLanguagesLoading = false;
        myList = ["English(English)"];
        myFilteredLanguages = ["English(English)"];
        availLanguages = [languages[6]]; //ENGLISH ONLY
      });
    } else {
      print("ONLINE...");
      availLanguages = savedAvailLanguages;
      setAvailLanguages();
      if (kIsWeb == false) {
        await initializeInAppPurchase();
        if (Globals.isAds == true) {
          AdService.checkAds();
        }
      }
    }
  }

  @override
  didChangeAppLifecycleState(AppLifecycleState state) {
    print("didChangeAppLifecycleState called");
    if (state == AppLifecycleState.resumed) {
      if (kIsWeb == false) {
        //initializeInAppPurchase();
        if (Globals.isAds == true) {
          AdService.checkAds();
        }
        AdService.loadInterstitial();
      }
    }
  }

  Future<void> initializeInAppPurchase() async {
    final InAppPurchase iap = InAppPurchase.instance;
    final bool isAvailable = await iap.isAvailable();

    if (isAvailable) {
      if (purchaseSubscription != null) {
        await purchaseSubscription!.cancel();
      }

      purchaseSubscription =
          iap.purchaseStream.listen((List<PurchaseDetails> purchases) async {
        PurchaseDetails? purchaseRemoveAds = purchases.isNotEmpty
            ? purchases.firstWhere(
                (purchase) => purchase.productID == removeAdsProductId)
            : null;

        if (purchaseRemoveAds != null) {
          if (purchaseRemoveAds.status == PurchaseStatus.purchased ||
              purchaseRemoveAds.status == PurchaseStatus.restored) {
            print(
                "main initializeInAppPurchase $removeAdsProductId ${purchaseRemoveAds.status == PurchaseStatus.purchased ? "PURCHASED" : "RESTORED"}! Setting isAds=FALSE!");

            print("main initializeInAppPurchase COMPLETING PURCHASE!");
            if (Globals.isForceAds == false) {
              setState(() {
                bannerAd?.dispose();
                AdService.disposeAll();
                Globals.isAds = false;
              });
            }

            if (purchaseRemoveAds.pendingCompletePurchase) {
              await MenuState().showSuccessThanksBuy();
              print("Completing purchase...");
              await InAppPurchase.instance.completePurchase(purchaseRemoveAds);
            }
          } else if (purchaseRemoveAds.status == PurchaseStatus.pending) {
            print(
                "IAP.listen purchaseRemoveAds.status == PurchaseStatus.pending ...");
            //await InAppPurchase.instance.completePurchase(purchaseRemoveAds);
            await MenuState().showSuccessThanksBuy();
          } else if (purchaseRemoveAds.status == PurchaseStatus.error) {
            // Handle failed purchase
            print(
                "main initializeInAppPurchase '$removeAdsProductId' Purchase error: ${purchaseRemoveAds.error}.");
            //if (mounted) {
            //  WidgetsBinding.instance.addPostFrameCallback((_) {
            await HelpersService.showPopup(context,
                message:
                    "${FlutterI18n.translate(context, "PROMPT_PURCHASING_ERROR")}: ${purchaseRemoveAds.error}");
            // });
            //}
          }
        }
      }, onError: (error) {
        print("Purchase Error: $error");
      }, onDone: () {
        purchaseSubscription?.cancel(); // Clean up after use
      }, cancelOnError: true);
      await restorePurchases();
    }
  }

  Future<void> restorePurchases() async {
    print("restorePurchases called");
    if (kIsWeb == true) {
      //MyHomeState().showPopup(context, "CAN'T RESTORE ADS ON WEB!");
      print("Cant restore purchases on web-app.");
    } else {
      //setState(() {
      //  isRestoring = true;
      //});
      final InAppPurchase iapInstance = InAppPurchase.instance;
      bool isAvailable = await iapInstance.isAvailable();
      if (isAvailable) {
        // Fetch past purchases
        try {
          await iapInstance.restorePurchases();
        } catch (e) {
          print("Failed to restore purchases");
          //ScaffoldMessenger.of(context).showSnackBar(
          //  SnackBar(content: Text("Failed to restore purchases")),
          //);
          //setState(() {
          //  isRestoring = false;
          //});
          return;
        }
      }
    }
  }

  getTransLangValue(dynamic value) {
    return "${value["name1"]}(${FlutterI18n.translate(context, value["name2"])})";
  }

  resetMyList() {
    print("resetMyList called");

    myList = [];

    myList.addAll(List<String>.from(availLanguages.map((dynamic value) {
      return getTransLangValue(value);
    }).toList()));
    Set<String> uniqueMyList = myList.toSet();
    myList = uniqueMyList.toList();
    if (myList.isEmpty) {
      myList = ["English(English)"];
    }

    dynamic myLanguage = List<dynamic>.from(languages
        .where(
            (dynamic lang) => lang["value"] == selectedMajorLanguage["value"])
        .toList())[0];
    List<String> foundMyListEles = List<String>.from(
        myList.where((myEle) => myEle.contains(myLanguage["name1"])).toList());
    if (foundMyListEles.isNotEmpty) {
      dynamic myListElement = foundMyListEles[0];
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
    try {
      final response = await http.get(Uri.parse(
          'https://www.learnfactsquick.com/lfq_app_php/get_dict_langs.php'));
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
        HelpersService.showPopup(context,
            message: FlutterI18n.translate(context, "NETWORK_ERROR"));
      }
      setState(() {
        isLanguagesLoading = false;
        availLanguages = [];
        savedAvailLanguages = [];
        if (isSuccess == true) {
          dynamic availLang;
          for (int i = 0; i < gotLanguages.length; i++) {
            availLang = (MyHomeState().languages.where((dynamic language) =>
                language["value"] == gotLanguages[i]["Code"])).toList()[0];
            availLanguages.add(availLang);
            savedAvailLanguages.add(availLang);
          }
          resetMyList();
        }
      });
    } catch (e) {
      setState(() {
        isLanguagesLoading = false;
        print("setAvailLanguages OFFLINE...");
        myList = ["English(English)"];
        myFilteredLanguages = ["English(English)"];
      });
    }
  }

  List<dynamic> oldWords = [];
  Map<String, List<dynamic>> newWords = {};
  List<Map<String, List<String>>> dicWords = [
    dicA1,
    dicA2,
    dicB1,
    dicB2,
    dicC1,
    dicC2,
    dicC3,
    dicD1,
    dicD2,
    dicE1,
    dicF1,
    dicG1,
    dicH1,
    dicI1,
    dicJ1,
    dicK1,
    dicL1,
    dicM1,
    dicM2,
    dicN1,
    dicO1,
    dicP1,
    dicP2,
    dicQ1,
    dicR1,
    dicR2,
    dicS1,
    dicS2,
    dicS3,
    dicT1,
    dicT2,
    dicU1,
    dicV1,
    dicW1,
    dicX1,
    dicY1,
    dicZ1
  ];
  final TextEditingController numberController = TextEditingController();

  void doMakeMajorWords(context, targetLanguage) {
    print("doMakeMajorWords called, targetLanguage = $targetLanguage");
    if (numberController.text.trim() == '') {
      HelpersService.showPopup(context,
          message: FlutterI18n.translate(context, "PROMPT_NO_NUMBERS"));
      return;
    } else if (myFilteredLanguages.isEmpty) {
      HelpersService.showPopup(context,
          message: FlutterI18n.translate(context, "PROMPT_NO_LANGUAGES"));
      return;
    }
    print(
        "doMakeMajorWords myFilteredLanguages.length = ${myFilteredLanguages.length}, myFilteredLanguages[0] = ${myFilteredLanguages[0]}");

    if (Globals.isAds == false &&
        ((targetLanguage == "en" &&
                myFilteredLanguages.length == 1 &&
                myFilteredLanguages[0] == "English(English)") ||
            isOnline == false)) {
      makeMajorWordsOld(context);
    } else {
      makeMajorWordsNew(context, targetLanguage);
    }
  }

  String lastNumber = "";
  Future<void> makeMajorWordsOld(context) async {
    HelpersService.showProgress(
        context, FlutterI18n.translate(context, "PROGRESS_MAKE_MAJOR"));
    await Future.delayed(Duration(milliseconds: 200));
    print("list_english_words length = ${dicWords.length}");
    print("makeMajorWordsOld called");
    print(numberController.text);
    lastNumber = numberController.text.toString();
    //var num = "";
    oldWords = [];
    List<dynamic> filteredWords = [];
    String key = "";
    List<String> words = [];
    var formattedWord = "";
    Map<String, List<String>> dicObj;
    String dictNum = "";
    for (var i = 0; i < dicWords.length; i++) {
      dicObj = dicWords[i];
      words = dicObj.keys.toList();
      for (var j = 0; j < words.length; j++) {
        //print("key: $key, value: $value");
        //print("FOR WORD, $dicWord,  GOT NUM $num");
        dictNum = "";
        dictNum = dicObj[words[j]]![0].toString();
        if (dictNum.length >= lastNumber.length) {
          if (dictNum.substring(0, lastNumber.length) == lastNumber) {
            formattedWord = formatWord(words[j]);
            print("formattedWOrd = $formattedWord");
            filteredWords
                .add([words[j], formattedWord, dicObj[words[j]]!.elementAt(1)]);
          }
        }
      }
    }
    int countTotal = filteredWords.length;
    filteredWords.shuffle();
    if (filteredWords.length > 500) {
      oldWords = filteredWords.sublist(0, 500);
    } else {
      oldWords = filteredWords;
    }
    //print("oldWords = ${json.encode(oldWords)}");
    oldWords.sort((a, b) => a[0].toString().compareTo(b[0].toString()));
    print("oldWords.length = ${oldWords.length}");
    //print("WORDS FOUND= $words");
    //hideProgress(context);
    //isLoading = false;

    Map<String, List<dynamic>> newWords = {"8": []};
    for (int i = 0; i < oldWords.length; i++) {
      newWords["8"]!.add({
        "Word": oldWords[i][0],
        "formattedWord": oldWords[i][1],
        "Def": oldWords[i][2],
      });
    }
    HelpersService.hideProgress(context);
    AdService.showInterstitialAd(() {
      print("NOT SHOWING AD");
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WordsPageNew(
                    lastNumber: lastNumber,
                    words: newWords,
                    countTotal: countTotal,
                    countWords: oldWords.length,
                  )));

      setState(() {});
    });
  }

  makeMajorWordsNew(BuildContext context, String targetLanguage) async {
    print("makeMajorWordsNew called targetLanguage = $targetLanguage");
    if (isOnline == false) {
      HelpersService.showPopup(context,
          message: FlutterI18n.translate(context, "NOT_ONLINE"));
    } else {
      if (numberController.text.trim() == '') {
        return;
      }
      HelpersService.showProgress(
          context, FlutterI18n.translate(context, "PROGRESS_MAKE_MAJOR"));
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
      bool isRequestSuccess = true;
      Response response = http.Response("", 200);
      try {
        response = await http.post(
            Uri.parse(
                'https://www.learnfactsquick.com/major_words_maker/make_major.php'),
            body: json.encode(body));
      } catch (e) {
        isRequestSuccess = false;
      }
      if (isRequestSuccess == false) {
        HelpersService.hideProgress(context);
        HelpersService.showPopup(context,
            message: FlutterI18n.translate(context, "NETWORK_ERROR"));
      } else {
        //hideProgress(context);
        if (response.statusCode == 200) {
          data = Map<String, dynamic>.from(json.decode(response.body));
          print("GET MAJOR WORDS data = ${json.encode(data)}");
          if (data["SUCCESS"] == true) {
            countWords = data["COUNT_WORDS"];
            int countTotal = data["COUNT_TOTAL"];
            if (countWords > 0) {
              gotMajorWords = Map<String, List<dynamic>>.from(data["WORDS"]);
              List<String> LIDs = gotMajorWords.keys.toList();
              for (int i = 0; i < LIDs.length; i++) {
                for (int j = 0; j < gotMajorWords[LIDs[i]]!.length; j++) {
                  gotMajorWords[LIDs[i]]![j]["formattedWord"] =
                      formatWord(gotMajorWords[LIDs[i]]![j]["Word"]);
                }
              }
            } else {
              gotMajorWords = {};
            }
            print("GOT MAJOR WORDS NEW = ${json.encode(gotMajorWords)}");
            HelpersService.hideProgress(context);
            AdService.showInterstitialAd(() {
              print("NOT SHOWING AD");
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WordsPageNew(
                          lastNumber: lastNumber,
                          words: gotMajorWords,
                          countWords: countWords,
                          countTotal: countTotal)));
              setState(() {});
            });
          } else {
            print("GET MAJOR WORDS ERROR: ${data["ERROR"]}");
            HelpersService.hideProgress(context);
            HelpersService.showPopup(context, message: data["ERROR"]);
          }
        } else {
          HelpersService.hideProgress(context);
          HelpersService.showPopup(context,
              message: FlutterI18n.translate(context, "NETWORK_ERROR"));
        }
      }
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
    String savedLanguage = (await HelpersService.getData("LANGUAGE")) ?? "";
    print("savedLanguage = ${json.encode(savedLanguage)}");
    if (savedLanguage != "") {
      selectedMajorLanguage = List<dynamic>.from(languages
          .where((dynamic lang) => lang["value"] == savedLanguage)
          .toList())[0];
      print("selectedMajorLanguage = ${json.encode(selectedMajorLanguage)}");
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
    //setState((){});
  }

  @override
  void dispose() {
    super.dispose();
    if (kIsWeb == false) {
      print("DISPOSING interstitialAd !!!");
      interstitialAd?.dispose();
    }
    connectivitySubscription.cancel();
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
    Future.delayed(Duration(microseconds: 10), () {
      setState(() {
        myFilteredLanguages = newList;
      });
    });
  }

  selectAllNoLanguages() {
    setState(() {
      isAllLanguages = !isAllLanguages;
      if (isAllLanguages == true) {
        myFilteredLanguages = List<String>.from(
            availLanguages.map((lang) => getTransLangValue(lang)).toList());
        Set<String> uniqueMyFilteredLanguages = myFilteredLanguages.toSet();
        myFilteredLanguages = uniqueMyFilteredLanguages.toList();
      } else {
        myFilteredLanguages = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //if (myList.isEmpty) {
    //}
    final TextStyle commonTextStyle = TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.normal,
      fontFamily: 'Arial', // Specify the font family
    );
    print("Menu build myList = $myList");
    print("Menu build myFilteredLanguages = $myFilteredLanguages");
    MyHomeState().setSavedLanguage(context);
    //const appTitle = 'Major Words Maker';
    double screenWidth = MediaQuery.of(context).size.width;
    double tabFontSize =
        (screenWidth * 0.020 + 4) < 15 ? 15 : (screenWidth * 0.020 + 4);
    double promptFontSize =
        (screenWidth * 0.016 + 4) < 11 ? 11 : (screenWidth * 0.016 + 4);
    //double promptFontSize = (screenWidth * 0.016 + 4) < 11 ? 11 : (screenWidth * 0.016 + 4);
    var appTitle = FlutterI18n.translate(context, "APP_TITLE");
    //final theme = Theme.of(context); // ← Add this.

    FocusNode focusNode = FocusNode();
    //String promptAll = FlutterI18n.translate(context, "PROMPT_ALL");
    //String myHint = myFilteredLanguages.isEmpty
    //    ? FlutterI18n.translate(context, "SELECT_LANGUAGES")
    //    : myFilteredLanguages
    //        .where((mfl) => !mfl.contains("ALL"))
    //        .toList()
    //        .join(", ");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(appTitle, style: TextStyle(fontSize: tabFontSize)),
        centerTitle: true,
        actions: <Widget>[
          Menu(context: context, page: 'main', updateParent: updateSelf)
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextField(
                  controller: numberController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: FlutterI18n.translate(context, "ENTER_NUMBERS"),
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
                    doMakeMajorWords(context, selectedMajorLanguage["value"]);
                  }),
            ),
            //Text(json.encode(myFilteredLanguages)),
            Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: ElevatedButton(
                  onPressed: () async {
                    selectAllNoLanguages();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: isAllLanguages == false
                        ? Colors.purple[200]
                        : Colors.grey[700],
                    minimumSize: Size(75, 25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text(FlutterI18n.translate(
                      context,
                      (isAllLanguages == false
                          ? FlutterI18n.translate(
                              context, "SELECT_ALL_LANGUAGES")
                          : FlutterI18n.translate(
                              context, "SELECT_NO_LANGUAGES")))),
                )),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: Container(
                  decoration: BoxDecoration(color: Colors.white),
                  width: screenWidth - 40,
                  child: DropDownMultiSelect<String>(
                    separator: ", ",
                    decoration: InputDecoration(
                      labelText: "",
                      labelStyle: commonTextStyle,
                    ),
                    isDense: true,
                    onChanged: (List<String> newList) {
                      setState(() {
                        setLanguages(context, newList);
                      });
                    },
                    options: myList,
                    selectedValues: myFilteredLanguages,
                    whenEmpty:
                        FlutterI18n.translate(context, "SELECT_LANGUAGES"),
                  ),
                )),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: HelpersService.customButton(
                    context,
                    0.90,
                    promptFontSize,
                    FlutterI18n.translate(context, "MAKE_MAJOR_WORDS"),
                    Icon(Icons.construction),
                    Colors.green,
                    Colors.black,
                    5, () async {
                  focusNode.unfocus();
                  FocusScope.of(context).unfocus();
                  print("Delayed action executed!");
                  doMakeMajorWords(context, selectedMajorLanguage["value"]);
                }),
              ),
            ),

            SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      textAlign: TextAlign.left,
                      FlutterI18n.translate(
                        context,
                        "SEE_LFQ_WEBSITE_OTHER_APPS",
                      ),
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: promptFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    HelpersService.customButton(
                      context,
                      0.85,
                      promptFontSize,
                      FlutterI18n.translate(
                        context,
                        "PROMPT_TOOLS_WEBSITE",
                      ),
                      Image.asset(
                        'assets/images/lfq_icon.png',
                        width: 20,
                        height: 20,
                      ),
                      Color.fromARGB(255, 204, 159, 252),
                      Colors.white,
                      15,
                      () => launch('https://learnfactsquick.com'),
                    ),
                    if (HelpersService.isLinkPlayStore())
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: HelpersService.customButton(
                          context,
                          0.85,
                          promptFontSize,
                          FlutterI18n.translate(
                            context,
                            "PROMPT_APPS_PLAY_STORE",
                          ),
                          Icon(Icons.play_circle_fill),
                          Colors.green,
                          Colors.white,
                          15,
                          () => launch(
                            'https://play.google.com/store/apps/dev?id=5263177578338103821',
                          ),
                        ),
                      ),
                    if (HelpersService.isLinkAppStore())
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: HelpersService.customButton(
                          context,
                          0.85,
                          promptFontSize,
                          FlutterI18n.translate(
                            context,
                            "PROMPT_APPS_APP_STORE",
                          ),
                          Icon(Icons.download_sharp),
                          Colors.blue,
                          Colors.white,
                          15,
                          () => launch(
                            'https://apps.apple.com/us/developer/keith-harryman/id1693739510',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
      bottomNavigationBar:
          Globals.isAds ? AdService.bottomBanner(bannerAd: bannerAd) : null,
    );
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
