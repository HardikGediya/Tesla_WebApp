import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../models/models.dart';

class TeslaScreen extends StatefulWidget {
  const TeslaScreen({Key? key}) : super(key: key);

  @override
  State<TeslaScreen> createState() => _TeslaScreenState();
}

class _TeslaScreenState extends State<TeslaScreen> {
  final GlobalKey teslaWebViewKey = GlobalKey();
  final TextEditingController teslaSearchController = TextEditingController();

  double teslaProgress = 0;

  InAppWebViewController? teslaInAppWebViewController;
  late PullToRefreshController teslaPullToRefreshController;

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  wikiInitRefreshController() async {
    teslaPullToRefreshController = PullToRefreshController(
        options: PullToRefreshOptions(color: teslaColor),
        onRefresh: () async {
          if (Platform.isAndroid) {
            teslaInAppWebViewController?.reload();
          } else if (Platform.isIOS) {
            teslaInAppWebViewController?.loadUrl(
                urlRequest: URLRequest(
                    url: await teslaInAppWebViewController?.getUrl()));
          }
        });
  }

  @override
  initState() {
    super.initState();
    wikiInitRefreshController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: teslaColor,
        leading: IconButton(
          icon: Image.asset(
            'assets/images/tesla.png',
            scale: 7,
          ),
          onPressed: () async {
            await teslaInAppWebViewController!.loadUrl(
              urlRequest: URLRequest(
                url: Uri.parse("https://www.tesla.com/"),
              ),
            );
          },
        ),
        title: const Text('Tesla'),
        actions: [
          IconButton(
            icon: const Icon(Icons.book_outlined),
            onPressed: () async {
              Uri? uri = await teslaInAppWebViewController!.getUrl();

              String myURL = "${uri!.scheme}://${uri.host}${uri.path}";

              setState(() {
                bookmarks.add(myURL);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: teslaColor,
                  content: const Text("Successfully Bookmarked..."),
                ),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Center(
                      child: Text('My BookMarks'),
                    ),
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: bookmarks
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: GestureDetector(
                                onTap: () async {
                                  await teslaInAppWebViewController!.loadUrl(
                                    urlRequest: URLRequest(url: Uri.parse(e)),
                                  );
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  e,
                                  style: TextStyle(
                                    color: teslaColor,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Expanded(
              flex: 1,
              child: Container(
                color: Colors.white,
                child: TextField(
                  controller: teslaSearchController,
                  onSubmitted: (val) async {
                    Uri uri = Uri.parse(val);
                    if (uri.scheme.isEmpty) {
                      uri = Uri.parse("https://www.google.co.in/search?q=$val");
                    }
                    await teslaInAppWebViewController!
                        .loadUrl(urlRequest: URLRequest(url: uri));
                  },
                  decoration: InputDecoration(
                    hintText: "Search on web...",
                    prefixIcon: Icon(
                      Icons.search,
                      color: teslaColor,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: teslaColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: teslaColor),
                    ),
                  ),
                ),
              ),
            ),
          ),
          (teslaProgress < 1)
              ? LinearProgressIndicator(
                  value: teslaProgress,
                  color: teslaColor,
                )
              : Container(),
          Expanded(
            flex: 10,
            child: InAppWebView(
              key: teslaWebViewKey,
              pullToRefreshController: teslaPullToRefreshController,
              onWebViewCreated: (controller) {
                teslaInAppWebViewController = controller;
              },
              initialOptions: options,
              initialUrlRequest:
                  URLRequest(url: Uri.parse("https://www.tesla.com/")),
              onLoadStart: (controller, uri) {
                setState(() {
                  teslaSearchController.text =
                      "${uri!.scheme}://${uri.host}${uri.path}";
                });
              },
              onLoadStop: (controller, uri) {
                teslaPullToRefreshController.endRefreshing();
                setState(() {
                  teslaSearchController.text =
                      "${uri!.scheme}://${uri.host}${uri.path}";
                });
              },
              androidOnPermissionRequest:
                  (controller, origin, resources) async {
                return PermissionRequestResponse(
                  resources: resources,
                  action: PermissionRequestResponseAction.GRANT,
                );
              },
              onProgressChanged: (controller, val) {
                if (val == 100) {
                  teslaPullToRefreshController.endRefreshing();
                }
                setState(() {
                  teslaProgress = val / 100;
                });
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: teslaColor,
            child: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () async {
              await teslaInAppWebViewController!.goBack();
            },
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            backgroundColor: teslaColor,
            child: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () async {
              await teslaInAppWebViewController!.goForward();
            },
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            backgroundColor: teslaColor,
            child: const Icon(Icons.refresh),
            onPressed: () async {
              if (Platform.isAndroid) {
                teslaInAppWebViewController?.reload();
              } else if (Platform.isIOS) {
                teslaInAppWebViewController?.loadUrl(
                    urlRequest: URLRequest(
                        url: await teslaInAppWebViewController?.getUrl()));
              }
            },
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            backgroundColor: teslaColor,
            child: const Icon(Icons.close),
            onPressed: () async {
              await teslaInAppWebViewController!.stopLoading();
            },
          ),
        ],
      ),
    );
  }
}
