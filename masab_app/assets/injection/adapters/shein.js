// Shein-specific selectors and extraction logic
(function() {
  'use strict';
  
  if (!window.__masab) {
    console.error('Masab bootstrap not loaded');
    return;
  }
  
  // Shein-specific product selectors
  window.__masab.adapters = window.__masab.adapters || {};
  window.__masab.adapters.shein = {
    product: {
      name: '.product-intro__head-name, h1[class*="product"]',
      price: '.product-intro__head-price, [class*="price"][class*="current"]',
      image: '.product-intro__head-gallery img, .product-gallery img',
      description: '.product-intro__description, [class*="description"]'
    },
    cart: {
      items: '.shopping-cart-item, [class*="cart-item"]',
      itemName: '.item-name, [class*="item"][class*="name"]',
      itemPrice: '.item-price, [class*="item"][class*="price"]',
      itemImage: '.item-image img, [class*="item"][class*="image"] img'
    }
  };
  
  console.log('Masab Shein adapter loaded');
})();