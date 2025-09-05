// Product and cart collection functions
(function() {
  'use strict';
  
  if (!window.__masab) {
    console.error('Masab bootstrap not loaded');
    return;
  }
  
  const utils = window.__masab.utils;
  
  // Generic product collection
  window.__masab.collectProduct = function() {
    try {
      console.log('Masab: Collecting product data...');
      
      const item = {
        id: Date.now().toString(),
        name: document.title || 'Product from ' + window.location.hostname,
        description: 'Extracted from ' + window.location.href,
        url: window.location.href,
        imageUrl: getFirstImage(),
        price: extractPriceFromPage(),
        metadata: {
          domain: window.location.hostname,
          timestamp: new Date().toISOString()
        }
      };
      
      const snapshot = {
        type: 'product',
        domain: window.location.hostname,
        url: window.location.href,
        items: [item],
        timestamp: new Date().toISOString(),
        metadata: {
          userAgent: navigator.userAgent,
          pageTitle: document.title
        }
      };
      
      window.__masab.post(snapshot);
      console.log('Masab: Product collected successfully', item);
      
    } catch (error) {
      console.error('Masab: Error collecting product', error);
    }
  };
  
  // Generic cart collection
  window.__masab.collectCart = function() {
    try {
      console.log('Masab: Collecting cart data...');
      
      const items = [];
      
      // Try to find cart items (generic selectors)
      const cartSelectors = [
        '[data-testid*="cart"] [data-testid*="item"]',
        '.cart-item',
        '.shopping-cart-item',
        '[class*="cart"][class*="item"]'
      ];
      
      let cartItems = [];
      for (const selector of cartSelectors) {
        cartItems = utils.qa(selector);
        if (cartItems.length > 0) break;
      }
      
      if (cartItems.length === 0) {
        // If no specific cart items found, create a generic cart entry
        items.push({
          id: Date.now().toString(),
          name: 'Cart items from ' + window.location.hostname,
          description: 'Cart extracted from ' + window.location.href,
          url: window.location.href,
          imageUrl: getFirstImage(),
          metadata: {
            domain: window.location.hostname,
            timestamp: new Date().toISOString()
          }
        });
      } else {
        // Process found cart items
        cartItems.forEach((element, index) => {
          items.push({
            id: Date.now().toString() + '_' + index,
            name: utils.extractText(element) || 'Cart Item ' + (index + 1),
            description: 'Cart item from ' + window.location.hostname,
            url: window.location.href,
            imageUrl: getImageFromElement(element),
            price: extractPriceFromElement(element),
            metadata: {
              domain: window.location.hostname,
              timestamp: new Date().toISOString(),
              elementIndex: index
            }
          });
        });
      }
      
      const snapshot = {
        type: 'cart',
        domain: window.location.hostname,
        url: window.location.href,
        items: items,
        timestamp: new Date().toISOString(),
        metadata: {
          userAgent: navigator.userAgent,
          pageTitle: document.title,
          itemCount: items.length
        }
      };
      
      window.__masab.post(snapshot);
      console.log('Masab: Cart collected successfully', items);
      
    } catch (error) {
      console.error('Masab: Error collecting cart', error);
    }
  };
  
  // Helper functions
  function getFirstImage() {
    const img = utils.q('img[src*="product"], img[src*="item"], .product-image img, img');
    return img ? utils.absUrl(img.src) : 'https://via.placeholder.com/150';
  }
  
  function getImageFromElement(element) {
    const img = element.querySelector('img');
    return img ? utils.absUrl(img.src) : 'https://via.placeholder.com/150';
  }
  
  function extractPriceFromPage() {
    const priceSelectors = [
      '[class*="price"]',
      '[data-testid*="price"]',
      '.currency',
      '.amount'
    ];
    
    for (const selector of priceSelectors) {
      const element = utils.q(selector);
      if (element) {
        const price = utils.extractPrice(utils.extractText(element));
        if (price) return price;
      }
    }
    
    return null;
  }
  
  function extractPriceFromElement(element) {
    const priceElement = element.querySelector('[class*="price"], .currency, .amount');
    if (priceElement) {
      return utils.extractPrice(utils.extractText(priceElement));
    }
    return null;
  }
  
  console.log('Masab collectors loaded successfully');
})();