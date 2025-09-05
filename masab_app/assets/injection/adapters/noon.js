// Noon-specific selectors and extraction logic
(function() {
  'use strict';
  
  if (!window.__masab) {
    console.error('Masab bootstrap not loaded');
    return;
  }
  
  // Noon-specific product selectors
  window.__masab.adapters = window.__masab.adapters || {};
  window.__masab.adapters.noon = {
    product: {
      name: '[data-qa="pdp-product-name"], h1[class*="product"]',
      price: '[data-qa="pdp-price"], [class*="price"][class*="current"]',
      image: '[data-qa="pdp-product-image"] img, .product-gallery img',
      description: '[data-qa="pdp-product-description"], [class*="description"]'
    },
    cart: {
      items: '[data-qa="cart-item"], .cart-item',
      itemName: '[data-qa="cart-item-name"], .item-name',
      itemPrice: '[data-qa="cart-item-price"], .item-price',
      itemImage: '[data-qa="cart-item-image"] img, .item-image img'
    }
  };
  
  console.log('Masab Noon adapter loaded');
})();