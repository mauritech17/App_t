import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../state/extract_store.dart';
import '../state/models.dart';
import '../widgets/fab.dart';
import 'dart:convert';

class WebViewScreen extends ConsumerStatefulWidget {
  final String url;
  final String title;

  const WebViewScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  ConsumerState<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends ConsumerState<WebViewScreen> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
            _injectJavaScript();
          },
        ),
      )
      ..addJavaScriptChannel(
        'TalaBridge',
        onMessageReceived: _handleJavaScriptMessage,
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _injectJavaScript() {
    // Basic JavaScript injection - minimal for now
    const jsCode = '''
      window.__masab = window.__masab || {};
      window.__masab.post = function(payload) {
        if (TalaBridge && TalaBridge.postMessage) {
          TalaBridge.postMessage(JSON.stringify(payload));
        }
      };
      
      window.__masab.collectProduct = function() {
        var item = {
          id: Date.now().toString(),
          name: document.title || 'Product from ' + window.location.hostname,
          description: 'Extracted from ' + window.location.href,
          url: window.location.href,
          imageUrl: 'https://via.placeholder.com/150'
        };
        
        var snapshot = {
          type: 'product',
          domain: window.location.hostname,
          url: window.location.href,
          items: [item],
          timestamp: new Date().toISOString()
        };
        
        window.__masab.post(snapshot);
      };
      
      window.__masab.collectCart = function() {
        var item = {
          id: Date.now().toString(),
          name: 'Cart items from ' + window.location.hostname,
          description: 'Cart extracted from ' + window.location.href,
          url: window.location.href,
          imageUrl: 'https://via.placeholder.com/150'
        };
        
        var snapshot = {
          type: 'cart',
          domain: window.location.hostname,
          url: window.location.href,
          items: [item],
          timestamp: new Date().toISOString()
        };
        
        window.__masab.post(snapshot);
      };
      
      console.log('Masab JavaScript injected successfully');
    ''';

    controller.runJavaScript(jsCode);
  }

  void _handleJavaScriptMessage(JavaScriptMessage message) {
    try {
      final data = jsonDecode(message.message);
      final snapshot = Snapshot.fromJson(data);
      
      ref.read(extractProvider.notifier).addSnapshot(snapshot);
      
      Fluttertoast.showToast(
        msg: 'Extracted ${snapshot.items.length} item(s)!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      
      print('Extracted snapshot: ${snapshot.toJson()}');
    } catch (e) {
      print('Error processing JavaScript message: $e');
      Fluttertoast.showToast(
        msg: 'Error processing extraction',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _collectProduct() {
    controller.runJavaScript('window.__masab.collectProduct()');
  }

  void _collectCart() {
    controller.runJavaScript('window.__masab.collectCart()');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: CustomFAB(
        onCollectProduct: _collectProduct,
        onCollectCart: _collectCart,
        onViewResults: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}