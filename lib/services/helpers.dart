import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelpersService {
  static bool isLoading = false;

  static isLinkPlayStore() {
    return (kIsWeb || Platform.isAndroid);
  }

  static isLinkAppStore() {
    return (kIsWeb || Platform.isIOS);
  }

  static Future<void> showPopup(
    BuildContext context, {
    String? title,
    required String message,
  }) async {
    debugPrint("showPopup called");
    String myTitle = title ?? FlutterI18n.translate(context, "PROMPT_ALERT");
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing by tapping outside the popup
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(textAlign: TextAlign.center, myTitle),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.70,
            child: SingleChildScrollView(child: Html(data: message)),
          ),
          actions: <Widget>[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(FlutterI18n.translate(context, "OK")),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<bool> showConfirm(
    BuildContext context,
    String title,
    String message,
    String cancelText,
    String okText,
  ) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  /// Message
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SingleChildScrollView(child: Html(data: message)),
                  ),

                  const SizedBox(height: 10),

                  IntrinsicHeight(
                    child: Row(
                      children: [
                        /// Cancel Button (Secondary)
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  249,
                                  208,
                                  208,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: Text(
                                cancelText,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),

                        /// Confirm Button (Primary)
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  192,
                                  253,
                                  163,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                              child: Text(
                                okText,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((value) => value ?? false);
  }

  static Widget customButton(
    BuildContext context,
    double widthFactor,
    double promptFontSize,
    String labelKey,
    Widget icon,
    Color color,
    Color textColor,
    double roundness,
    VoidCallback? onPressed,
  ) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(roundness),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                softWrap: true,
                labelKey,
                textAlign: TextAlign.center,
                style: TextStyle(color: textColor, fontSize: promptFontSize),
              ),
            ),
            const SizedBox(width: 12),
            icon,
          ],
        ),
      ),
    );
  }

  static void showProgress(BuildContext context, message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                  style: TextStyle(color: Colors.black, fontSize: 18.0),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void hideProgress(BuildContext context) {
    print("hideProgress called");
    Navigator.of(context, rootNavigator: true).pop();
    isLoading = false;
  }

  // To save data
  static Future<void> setData(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  // To read data
  static Future<String?> getData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static copyToClipboard(context, myText) {
    Clipboard.setData(ClipboardData(text: myText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ("Text, '").toString() +
              myText.toString() +
              ("' copied to clipboard").toString(),
        ),
      ),
    );
  }
}
