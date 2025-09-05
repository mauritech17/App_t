import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import '../state/extract_store.dart';
import '../state/models.dart';
import '../widgets/fab.dart';
import '../services/js_injector.dart';

class WebViewScreen extends ConsumerStatefulWidget {
  final String initialUrl;
  final String title;

  const WebViewScreen({
    super.key,
    required this.initialUrl,
    required this.title,
  });

  @override
  ConsumerState<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends ConsumerState<WebViewScreen> {
  late final WebViewController controller;
  bool isLoading = true;
  String currentUrl = '';
  String? debugMessage;

  @override
  void initState() {
    super.initState();
    currentUrl = widget.initialUrl;
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
              currentUrl = url;
              debugMessage = 'Loading: ${Uri.parse(url).host}';
            });
            ref.read(extractProvider.notifier).setDebugMessage(debugMessage);
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
              currentUrl = url;
              debugMessage = 'Ready: ${Uri.parse(url).host}';
            });
            ref.read(extractProvider.notifier).setDebugMessage(debugMessage);
            _injectJavaScript(url);
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              debugMessage = 'Error: ${error.description}';
            });
            ref.read(extractProvider.notifier).setError(error.description);
          },
        ),
      )
      ..addJavaScriptChannel(
        'TalaBridge',
        onMessageReceived: _handleJavaScriptMessage,
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  void _injectJavaScript(String url) async {
    try {
      final host = Uri.parse(url).host;
      final fullInjection = await JsInjector.buildFullInjection(host);
      
      await controller.runJavaScript(fullInjection);
      
      setState(() {
        debugMessage = 'Injection complete for $host';
      });
      
      // Detect page type
      await controller.runJavaScript('''
        setTimeout(() => {
          if (window.__talabiyah && window.__talabiyah.detectPage) {
            const pageInfo = window.__talabiyah.detectPage();
            window.__talabiyah.post({
              kind: 'talabiyah/page_detected',
              payload: pageInfo
            });
          }
        }, 1000);
      ''');
      
      print('Talabiyah: JavaScript injection completed for $host');
      
    } catch (e) {
      setState(() {
        debugMessage = 'Injection failed: $e';
      });
      ref.read(extractProvider.notifier).setError('JavaScript injection failed: $e');
      print('Talabiyah: JavaScript injection error: $e');
    }
  }

  void _handleJavaScriptMessage(JavaScriptMessage message) {
    try {
      final data = jsonDecode(message.message) as Map<String, dynamic>;
      final kind = data['kind'] as String?;
      final payload = data['payload'] as Map<String, dynamic>?;
      
      print('Talabiyah: Received message - Kind: $kind');
      
      if (kind == 'talabiyah/snapshot' && payload != null) {
        final snapshot = Snapshot.fromJson(payload);
        ref.read(extractProvider.notifier).addSnapshot(snapshot);
        
        Fluttertoast.showToast(
          msg: '✓ Extracted ${snapshot.items.length} item(s) from ${snapshot.origin}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
        );
        
        setState(() {
          debugMessage = 'Extracted ${snapshot.items.length} items (${snapshot.type})';
        });
        
      } else if (kind == 'talabiyah/error' && payload != null) {
        final errorMessage = payload['message'] as String? ?? 'Unknown error';
        
        Fluttertoast.showToast(
          msg: '⚠️ Error: $errorMessage',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
        );
        
        ref.read(extractProvider.notifier).setError(errorMessage);
        setState(() {
          debugMessage = 'Error: $errorMessage';
        });
        
      } else if (kind == 'talabiyah/page_detected' && payload != null) {
        final pageKind = payload['kind'] as String? ?? 'unknown';
        final origin = payload['origin'] as String? ?? 'unknown';
        
        setState(() {
          debugMessage = 'Detected: $pageKind page on $origin';
        });
      }
      
    } catch (e) {
      print('Talabiyah: Error processing JavaScript message: $e');
      Fluttertoast.showToast(
        msg: '⚠️ Message processing error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
      );
    }
  }

  void _collectProduct() async {
    try {
      ref.read(extractProvider.notifier).setExtracting(true);
      
      await controller.runJavaScript('''
        if (window.__talabiyah && window.__talabiyah.collectProduct) {
          window.__talabiyah.collectProduct();
        } else {
          window.__talabiyah.post({
            kind: 'talabiyah/error',
            payload: {
              message: 'Talabiyah not initialized or collectProduct not available',
              timestamp: new Date().toISOString()
            }
          });
        }
      ''');
      
      setState(() {
        debugMessage = 'Collecting product data...';
      });
      
    } catch (e) {
      ref.read(extractProvider.notifier).setError('Failed to collect product: $e');
      print('Talabiyah: Product collection error: $e');
    } finally {
      ref.read(extractProvider.notifier).setExtracting(false);
    }
  }

  void _collectCart() async {
    try {
      ref.read(extractProvider.notifier).setExtracting(true);
      
      await controller.runJavaScript('''
        if (window.__talabiyah && window.__talabiyah.collectCart) {
          window.__talabiyah.collectCart();
        } else {
          window.__talabiyah.post({
            kind: 'talabiyah/error',
            payload: {
              message: 'Talabiyah not initialized or collectCart not available',
              timestamp: new Date().toISOString()
            }
          });
        }
      ''');
      
      setState(() {
        debugMessage = 'Collecting cart data...';
      });
      
    } catch (e) {
      ref.read(extractProvider.notifier).setError('Failed to collect cart: $e');
      print('Talabiyah: Cart collection error: $e');
    } finally {
      ref.read(extractProvider.notifier).setExtracting(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final extractState = ref.watch(extractProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              Uri.parse(currentUrl).host,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (extractState.items.isNotEmpty)
            Chip(
              label: Text('${extractState.items.length}'),
              backgroundColor: Colors.green,
            ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          
          if (isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading and injecting scripts...'),
                  ],
                ),
              ),
            ),
          
          if (extractState.isExtracting)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.blue.shade100,
                padding: const EdgeInsets.all(8),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Extracting data...'),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: TalabiyahFAB(
        onCollectProduct: _collectProduct,
        onCollectCart: _collectCart,
        debugMessage: debugMessage,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}