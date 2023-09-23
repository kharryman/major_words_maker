//import 'dart:collection';
//import 'dart:js_interop';

import 'dart:io';
import 'dart:math';

//kIsWeb : SIMILIAR TO NOT isApp() FUNCTION====>
import 'package:flutter/foundation.dart';

//import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
//import 'package:list_major_english_words/list_major_english_words.dart';
import 'major_english_words.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
//import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:device_info/device_info.dart';

const String testDevice = '974550CBC7D4EA4718A67165E2E3B868';
const String myIpad = '00008020-0014301102D1002E';
const int maxFailedLoadAttempts = 3;
InterstitialAd? interstitialAd;
int numInterstitialLoadAttempts = 0;

///----

///------

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
      testDevices = [myIpad];
    }
    MobileAds.instance
      ..initialize()
      ..updateRequestConfiguration(RequestConfiguration(
        testDeviceIds: testDevices,
      ));
  } else {
    print("main NOT SHOWING AD");
  }
  String deviceId = await getDeviceId();
  print('Device ID: $deviceId');
  runApp(MyApp());
}

Future<String> getDeviceId() async {
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  String deviceId = '';

  if (defaultTargetPlatform == TargetPlatform.iOS) {
    try {
      // ignore: unnecessary_nullable_for_final_variable_declarations
      final info = await deviceInfoPlugin.iosInfo;
      deviceId = info.identifierForVendor; // This is the iOS device ID
    } catch (e) {
      print('Error obtaining device ID: $e');
    }
  }

  return deviceId;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Major Words Maker App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Color.fromRGBO(200, 255, 200, 1.0)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  bool isLoading = false;
  void showProgress(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevents the user from dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(), // Loading indicator
        );
      },
    );
    Future.delayed(Duration(seconds: 1)).then(
        (value) => {hideProgress(context)}); // Simulate 3 seconds of loading
  }

  void hideProgress(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
    isLoading = false;
  }

  List<List<String>> words = [];
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

  String lastNumber = "";
  void makeMajorWords(context) {
    if (numberController.text.trim() == '') {
      return;
    }
    isLoading = true;
    showProgress(context);
    print("list_english_words length = ${dicWords.length}");
    print("makeMajorWords called ");
    print(numberController.text);
    lastNumber = numberController.text;
    //var num = "";
    words = [];
    String key = "";
    var formattedWord = "";
    Map<String, List<String>> dicObj;
    for (var i = 0; i < dicWords.length; i++) {
      for (var j = 0; j < dicWords[i].length; j++) {
        dicObj = dicWords[i][j];
        key = dicObj.keys.toList().first;
        //print("key: $key, value: $value");
        //num = getMajorSystemNumber(dicWord, 0, null);
        //print("FOR WORD, $dicWord,  GOT NUM $num");
        if (dicObj[key]?[0].toString() == numberController.text.toString()) {
          formattedWord = formatWord(key);
          words.add([key, formattedWord, dicObj[key]!.elementAt(1)]);
        }
      }
    }
    //print("WORDS FOUND= $words");
    //hideProgress(context);
    //isLoading = false;
    if (kIsWeb == false) {
      Random random = Random();
      var isShowAd = random.nextInt(1000) >= 500; //EXACTLY HALF.
      if (isShowAd) {
        print("makeMajor showInterstitialAd CALLING...");
        _MyHomePageState().showInterstitialAd();
      }
    } else {
      print("NOT SHOWING AD");
    }
    notifyListeners();
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

  String getMajorSystemNumber(inputWord, start, number) {
    //console.log("getMajorSystemNumber called. word=" + input_word);
    var defspl = inputWord.toLowerCase().split("");
    var wl = defspl.length;
    var z = 0;
    var num = "";
    var numberSplit = [];
    if (number != null) {
      number = number.toString();
      numberSplit = number.split("");
    }
    for (var i = start; i < wl; i++) {
      z = i + 1;
      if (defspl[i] == "s") {
        if (z < wl) {
          if (defspl[z] != "h") {
            num += "0";
          }
        } else if (z >= wl) {
          num += "0";
        }
      }
      if (defspl[i] == "z") {
        num += "0";
      }
      if (defspl[i] == "d" || defspl[i] == "t") {
        num += "1";
      }
      if (defspl[i] == "n") {
        num += "2";
      }
      if (defspl[i] == "m") {
        num += "3";
      }
      if (defspl[i] == "r") {
        num += "4";
      }
      if (defspl[i] == "l") {
        num += "5";
      }
      if (defspl[i] == "j") {
        num += "6";
      }
      if (defspl[i] == "c" && z < wl) {
        if (defspl[z] == "h") {
          num += "6";
        }
      }
      if (defspl[i] == "s" && z < wl) {
        if (defspl[z] == "h") {
          num += "6";
        }
      }
      if (defspl[i] == "g") {
        //console.log("TESTING G?? z = " + z + ", wl = " + wl);
        if (z < wl) {
          //console.log("TESTING G??");
          if (defspl[z] != "g" && defspl[z] != "h") {
            //console.log("TESTING G??");
            if (number != null && numberSplit[num.length] == "6") {
              num += "6";
            } else if (number != null && numberSplit[num.length] == "7") {
              num += "7";
            } else if (number != null) {
              num += "";
            } else {
              num += "6";
            }
          } else if (defspl[z] == "h") {
            //console.log("TESTING G??");
            //console.log("numberSplit[num.length] = " + numberSplit[num.length]);
            if (number != null && numberSplit[num.length] == "7") {
              num += "7";
            } else if (number != null && numberSplit[num.length] == "8") {
              num += "8";
            } else if (number != null) {
              num += "";
            } else {
              num += "7";
            }
            i++;
          } else if (defspl[z] == "g") {
            num += "7";
          }
        } else if (z == wl) {
          num += "7";
        }
      }
      if (defspl[i] == "c") {
        if (z < wl) {
          if (defspl[z] != "h") {
            num += "7";
          }
        } else if (z >= wl) {
          num += "7";
        }
      }
      if (defspl[i] == "k" || defspl[i] == "q") {
        num += "7";
      }
      if (defspl[i] == "f" || defspl[i] == "v") {
        num += "8";
      }
      if (defspl[i] == "p" && z < wl) {
        if (defspl[z] == "h") {
          num += "8";
        }
      }
      if (defspl[i] == "b") {
        num += "9";
      }
      if (defspl[i] == "p") {
        if (z < wl) {
          if (defspl[z] != "h") {
            num += "9";
          }
        } else if (z >= wl) {
          num += "9";
        }
      }
    }
    //console.log("getMajorSystemNumber num = " + num);
    return num;
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0; // ← Add this property.
  //bool isMakeMajor = false;
  bool isMakeMajor = true;

  @override
  void initState() {
    super.initState();
    if (kIsWeb == false) {
      createInterstitialAd();
    }
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
    var appId = (Platform.isAndroid || (Platform.isIOS && kDebugMode == false))
        ? 'ca-app-pub-8514966468184377/6907461840'
        : 'ca-app-pub-3940256099942544/4411468910';
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

  void showInterstitialAd() {
    print("showInterstitialAd called");
    if (interstitialAd == null) {
      print('Warning: attempt to show interstitialAd before loaded.');
      return;
    }
    print(
        "showInterstitialAd called, CALLING interstitialAd!.fullScreenContentCallback!!!");
    interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('interstitialAd onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad interstitialAd onAdDismissedFullScreenContent.');
        ad.dispose();
        print(
            'interstitialAd onAdDismissedFullScreenContent Calling createInterstitialAd again');
        createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad interstitialAd onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        print(
            'interstitialAd onAdFailedToShowFullScreenContent Calling createInterstitialAd again');
        createInterstitialAd();
      },
    );
    interstitialAd!.show();
    print("SETTING interstitialAd = null!!");
    interstitialAd = null;
  }

  @override
  void dispose() {
    super.dispose();
    if (kIsWeb == false) {
      print("DISPOSING interstitialAd !!!");
      interstitialAd?.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = Placeholder();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            /*
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600, // ← Here.
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex, // ← Change to this.
                onDestinationSelected: (value) {
                  // ↓ Replace print with this.
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            */
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page, // ← Here.
              ),
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

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    const appTitle = 'Major Words Maker';
    final theme = Theme.of(context); // ← Add this.
    String tmpText =
        '<strong style="font-style:italic;">The Major Sytem is a digit to consonant memory tool.<br />Each digit is represented by a set of similar sounding consonants.<br />It was designed by Stanislaus Mink von Wennsshein of 17th Century.<br />Here is the Major System:</strong><br />';
    final helpText = tmpText;

    FocusNode focusNode = FocusNode();
    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(appTitle),
          actions: <Widget>[
            // Add your menu items here
            PopupMenuButton<String>(
              constraints: BoxConstraints(
                minWidth: 2.0 * 56.0,
                maxWidth: MediaQuery.of(context).size.width,
              ),
              icon: Icon(Icons.menu),
              onSelected: (value) {
                focusNode.unfocus();
                if (kIsWeb == false) {
                  Random random = Random();
                  var isShowAd = random.nextInt(1000) >= 500; //EXACTLY HALF.
                  if (isShowAd) {
                    print("makeMajor showInterstitialAd CALLING...");
                    _MyHomePageState().showInterstitialAd();
                  }
                } else {
                  print("NOT SHOWING AD");
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: 'Help',
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Html(data: helpText),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text('0',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child:
                                        Text('s,z', textAlign: TextAlign.left),
                                  ),
                                  Expanded(
                                    flex: 11,
                                    child: Text('z starts with "zero"',
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
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text('d,t,th',
                                        textAlign: TextAlign.left),
                                  ),
                                  Expanded(
                                    flex: 11,
                                    child: Text(
                                        't is for "ten" th is for "THe one"',
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
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text('n', textAlign: TextAlign.left),
                                  ),
                                  Expanded(
                                    flex: 11,
                                    child: Text('"n" has two lines going down',
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
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text('m', textAlign: TextAlign.left),
                                  ),
                                  Expanded(
                                    flex: 11,
                                    child: Text(
                                        '"m" has three lines going down',
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
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text('r', textAlign: TextAlign.left),
                                  ),
                                  Expanded(
                                    flex: 11,
                                    child: Text('r is last letter of "four"',
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
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text('l', textAlign: TextAlign.left),
                                  ),
                                  Expanded(
                                    flex: 11,
                                    child: Text(
                                        'l is half or 50% of a box(2 Ls put together)',
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
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text('ch,j,g,sh',
                                        textAlign: TextAlign.left),
                                  ),
                                  Expanded(
                                    flex: 11,
                                    child: Text('g looks like an upside-down 6',
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
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text('c,gg,k,q',
                                        textAlign: TextAlign.left),
                                  ),
                                  Expanded(
                                    flex: 11,
                                    child: Text('k looks like 2 7s',
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
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text('f,ph,v',
                                        textAlign: TextAlign.left),
                                  ),
                                  Expanded(
                                    flex: 11,
                                    child: Text(
                                        'f is for "forever" or infinity "∞"',
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
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child:
                                        Text('b,p', textAlign: TextAlign.left),
                                  ),
                                  Expanded(
                                    flex: 11,
                                    child: Text(
                                        'b or p looks like a 9 when spinned or flipped',
                                        textAlign: TextAlign.left),
                                  ),
                                ],
                              ),
                            ]),
                      ),
                    ),
                  )
                ];
                /*
                return [
                  PopupMenuItem<String>(
                    value: 'Help',
                    //width: MediaQuery.of(context).size.width,
                    child: Container(width: 200, child: Html(data: helpText)),
                  )
                ];
                */
              },
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextField(
                  controller: appState.numberController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter numbers',
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
                    appState.makeMajorWords(context);
                  }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
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
                  appState.makeMajorWords(context);
                  //});
                },
                child: Text('Make Major Words'),
              ),
            ),
            Visibility(
              visible: appState.lastNumber.trim() != '',
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                    "Found ${appState.words.length} major words for number '${appState.lastNumber}':"),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  print("BODY UNFOCUSSING");
                  focusNode.unfocus();
                },
                child: SizedBox(
                  width: double.infinity,
                  child: ListView(children: <Widget>[
                    for (var i = 0; i < appState.words.length; i++)
                      Flex(
                        direction: Axis.horizontal,
                        children: [
                          Flexible(
                            flex: 1,
                            child: Card(
                              color:
                                  theme.colorScheme.surface, // ← And also this.
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * .06,
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
                                      focusNode.unfocus();
                                      print(
                                          "Copy word, '${appState.words[i][0]}' clicked!");
                                      Clipboard.setData(ClipboardData(
                                          text: appState.words[i][0]));
                                    },
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          .15,
                                      child: Text(appState.words[i][0],
                                          softWrap: true,
                                          style: TextStyle(fontSize: 12.0)),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      // Handle the click action here
                                      // For example, you can navigate to a new screen or perform some other action.
                                      print("BODY UNFOCUSSING");
                                      focusNode.unfocus();
                                      print(
                                          "Copy formatted word, '${appState.words[i][1]}' clicked!");
                                      Clipboard.setData(ClipboardData(
                                          text: appState.words[i][1]));
                                    },
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          .15,
                                      child: Text(
                                        "( ${appState.words[i][1]} )",
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
                                      focusNode.unfocus();
                                      print(
                                          "Definition for '${appState.words[i][0]}', copy '${appState.words[i][2]}'' clicked!");
                                      Clipboard.setData(ClipboardData(
                                          text: appState.words[i][2]));
                                    },
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          .56,
                                      child: Text(
                                        appState.words[i][2],
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
          ],
        ),
      ),
    );
  }
}
