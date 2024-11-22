import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class PageThree extends StatefulWidget {
  final String sid;

  const PageThree({Key? key, required this.sid}) : super(key: key);

  @override
  State<PageThree> createState() => _PageThreeState();
}

class _PageThreeState extends State<PageThree> {
  InAppWebViewController? _webViewController;

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "My Incident List",
            style: TextStyle(
              color: const Color.fromARGB(255, 255, 255, 255),
              fontSize: 16,
              fontFamily: 'Arial',
            ),
          ),
          backgroundColor: Colors.lightBlue,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: Uri.parse(
                      "http://124.43.128.239/ApiOrchid/WebPages/mylist.php?sno=${widget.sid}",
                    ),
                  ),
                  onWebViewCreated: (controller) {
                    _webViewController = controller;
                    _webViewController?.clearCache();
                  },
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                      javaScriptEnabled: true,
                      useShouldOverrideUrlLoading: true,
                    ),
                  ),
                  onLoadStop: (controller, url) {
                    // Perform actions on page load complete, if needed.
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    var url = navigationAction.request.url.toString();
                    if (url.contains('pdf')) {
                      // Handle PDF download or prevent navigation
                      return NavigationActionPolicy.CANCEL;
                    }
                    return NavigationActionPolicy.ALLOW;
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
