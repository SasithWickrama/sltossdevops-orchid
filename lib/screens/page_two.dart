import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:orchid_test_app/screens/details_screen.dart';

class PageTwo extends StatefulWidget {
  const PageTwo({super.key});

  @override
  State<PageTwo> createState() => _PageTwoState();
}

class _PageTwoState extends State<PageTwo> {
  late InAppWebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    // Set the preferred orientation to landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    // Reset the orientation to default when the page is disposed
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _moveToFaultScreen(String fltno) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsScreen(ref: fltno),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: Uri.parse(
                        "http://124.43.128.239/ApiOrchid/WebPages/fixlist.php"),
                  ),
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                      javaScriptEnabled: true,
                    ),
                  ),
                  onWebViewCreated: (controller) {
                    _webViewController = controller;

                    // Add JavaScript handler when webview is created
                    _webViewController.addJavaScriptHandler(
                      handlerName: 'moveToFaultScreen',
                      callback: (args) {
                        final fltno = args[0].toString();
                        _moveToFaultScreen(fltno);
                      },
                    );
                  },
                  onLoadStop: (controller, url) {
                    // Evaluate additional JavaScript if needed
                    controller.evaluateJavascript(source: '''
                      window.OK = {
                        moveToFaultScreen: function(fltno) {
                          window.flutter_inappwebview.callHandler('moveToFaultScreen', fltno);
                        }
                      }
                    ''');
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    // Handle console messages if necessary
                  },
                  onLoadError: (controller, url, code, message) {
                    // Handle load errors if necessary
                  },
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
