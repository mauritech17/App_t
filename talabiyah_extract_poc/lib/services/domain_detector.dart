String mapHostToAdapter(String host) {
  final lowerHost = host.toLowerCase();
  
  if (lowerHost.contains('shein')) {
    return 'shein';
  } else if (lowerHost.contains('noon')) {
    return 'noon';
  } else if (lowerHost.contains('amazon.ae')) {
    return 'amazon-ae';
  }
  
  return 'unknown';
}