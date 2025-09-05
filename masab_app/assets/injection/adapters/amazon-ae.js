// Amazon.ae-specific selectors and extraction logic
(function() {
  'use strict';
  
  if (!window.__masab) {
    console.error('Masab bootstrap not loaded');
    return;
  }
  
  // Amazon.ae-specific product selectors
  window.__masab.adapters = window.__masab.adapters || {};
  window.__masab.adapters['amazon-ae'] = {
    product: {
      name: '#productTitle, .product-title',
      price: '.a-price-whole, .a-price .a-offscreen, [class*="price"]',
      image: '#landingImage, .a-dynamic-image, .product-image img',
      description: '#feature-bullets ul, .product-description'
    },
    cart: {
      items: '[data-name="Active Items"] .sc-list-item, .cart-item',
      itemName: '[data-testid="item-product-name"], .item-name',
      itemPrice: '.sc-price, .item-price',
      itemImage: '.sc-product-image img, .item-image img'
    }
  };
  
  console.log('Masab Amazon.ae adapter loaded');
})();