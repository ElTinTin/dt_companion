import 'package:best_flutter_ui_templates/dt_companion/companion_app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    late WebViewController _controller;

    injectJavascript(WebViewController controller) async {
      controller.runJavaScript("""
        var style = document.createElement('style');
        style.innerHTML = 'body { padding: 16px; }';
        document.head.appendChild(style);
        """
      );
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF111111))
      ..setNavigationDelegate(NavigationDelegate(
          onProgress: (int progress) {
            // TODO Loader
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            injectJavascript(_controller);
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          }))
      ..loadRequest(Uri.parse('https://dice-throne.rulepop.com'));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FAQ',
          style: TextStyle(
            fontFamily: CompanionAppTheme.fontName,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0.2,
            color: CompanionAppTheme.lightText,
          ),
        ),
        backgroundColor: CompanionAppTheme.background,
        iconTheme: IconThemeData(
          color: CompanionAppTheme.lightText,
        ),
      ),
      body: Center(child: WebViewWidget(controller: _controller)),
    );
  }
}
