import 'package:flutter/services.dart';
import 'domain_detector.dart';

class JsInjector {
  static Future<String> loadBootstrap() async {
    return await rootBundle.loadString('assets/injection/bootstrap.js');
  }

  static Future<String> loadCollectors() async {
    return await rootBundle.loadString('assets/injection/collectors.js');
  }

  static Future<String?> loadAdapterFor(String host) async {
    final adapterType = mapHostToAdapter(host);
    
    if (adapterType == 'unknown') {
      return null;
    }
    
    try {
      return await rootBundle.loadString('assets/injection/adapters/$adapterType.js');
    } catch (e) {
      print('Failed to load adapter for $adapterType: $e');
      return null;
    }
  }

  static Future<String> buildFullInjection(String host) async {
    final bootstrap = await loadBootstrap();
    final collectors = await loadCollectors();
    final adapter = await loadAdapterFor(host);
    
    final parts = [bootstrap, collectors];
    
    if (adapter != null) {
      parts.add(adapter);
    }
    
    // Add adapter initialization
    final adapterType = mapHostToAdapter(host);
    if (adapterType != 'unknown') {
      parts.add('''
        // Initialize adapter
        if (window.__talabiyah && window.__talabiyah.adapters && window.__talabiyah.adapters.$adapterType) {
          window.__talabiyah.adapters.current = window.__talabiyah.adapters.$adapterType;
          console.debug('Talabiyah: Initialized $adapterType adapter');
        }
      ''');
    }
    
    return parts.join('\n\n');
  }
}