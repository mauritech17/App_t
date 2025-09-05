// Talabiyah Collectors - Product and Cart Data Extraction
(function() {
  'use strict';
  
  if (!window.__talabiyah) {
    console.error('Talabiyah: Bootstrap not loaded');
    return;
  }
  
  const utils = window.__talabiyah.utils;
  
  // Page detection
  window.__talabiyah.detectPage = function() {
    const url = window.location.href.toLowerCase();
    const title = document.title.toLowerCase();
    
    // Cart page detection
    if (url.includes('/cart') || url.includes('/bag') || url.includes('/checkout') ||
        title.includes('cart') || title.includes('bag') || title.includes('checkout')) {
      return {
        kind: 'cart',
        origin: window.location.host
      };
    }
    
    // Product page detection (more specific patterns)
    if (url.includes('/product') || url.includes('/item') || url.includes('/p/') ||
        document.querySelector('[itemtype*="Product"]') ||
        document.querySelector('meta[property="product:price"]') ||
        utils.readJSONLD('Product')) {
      return {
        kind: 'product',
        origin: window.location.host
      };
    }
    
    return {
      kind: 'unknown',
      origin: window.location.host
    };
  };
  
  // Product collection
  window.__talabiyah.collectProduct = function() {
    try {
      console.debug('Talabiyah: Starting product collection...');
      
      let item = null;
      let sourceMethod = 'UNKNOWN';
      
      // Method 1: JSON-LD (most reliable)
      const jsonLD = utils.readJSONLD('Product');
      if (jsonLD) {
        console.debug('Talabiyah: Found JSON-LD product data', jsonLD);
        
        item = {
          title: jsonLD.name || jsonLD.title || 'Untitled Product',
          url: window.location.href,
          image: extractImageFromJSONLD(jsonLD),
          sku: jsonLD.sku || jsonLD.productID || jsonLD.identifier,
          price: extractPriceFromJSONLD(jsonLD),
          sourceDomain: window.location.host,
          sourceMethod: 'JSONLD'
        };
        
        sourceMethod = 'JSONLD';
      }
      
      // Method 2: DOM via adapter (store-specific)
      if (!item && window.__talabiyah.adapters && window.__talabiyah.adapters.current) {
        console.debug('Talabiyah: Trying adapter-specific DOM extraction');
        
        const adapterResult = window.__talabiyah.adapters.current.collectProductDOM();
        if (adapterResult) {
          item = {
            ...adapterResult,
            url: window.location.href,
            sourceDomain: window.location.host,
            sourceMethod: 'DOM'
          };
          sourceMethod = 'DOM';
        }
      }
      
      // Method 3: Generic DOM fallback
      if (!item) {
        console.debug('Talabiyah: Trying generic DOM extraction');
        
        const title = extractGenericTitle();
        const price = extractGenericPrice();
        const image = extractGenericImage();
        
        if (title) {
          item = {
            title: title,
            url: window.location.href,
            image: image,
            price: price,
            sourceDomain: window.location.host,
            sourceMethod: 'DOM_GENERIC'
          };
          sourceMethod = 'DOM_GENERIC';
        }
      }
      
      // Method 4: META tags fallback
      if (!item) {
        console.debug('Talabiyah: Trying META tags extraction');
        
        const metaTitle = utils.q('meta[property="og:title"]')?.content ||
                         utils.q('meta[name="title"]')?.content ||
                         document.title;
        
        const metaImage = utils.q('meta[property="og:image"]')?.content;
        const metaPrice = utils.q('meta[property="product:price:amount"]')?.content;
        const metaCurrency = utils.q('meta[property="product:price:currency"]')?.content;
        
        if (metaTitle) {
          item = {
            title: metaTitle,
            url: window.location.href,
            image: metaImage ? utils.absUrl(metaImage) : null,
            price: metaPrice ? {
              amount: parseFloat(metaPrice),
              currency: metaCurrency || 'USD'
            } : null,
            sourceDomain: window.location.host,
            sourceMethod: 'META'
          };
          sourceMethod = 'META';
        }
      }
      
      if (!item) {
        console.warn('Talabiyah: Failed to extract product data');
        window.__talabiyah.post({
          kind: 'talabiyah/error',
          payload: {
            message: 'Failed to extract product data',
            url: window.location.href,
            timestamp: new Date().toISOString()
          }
        });
        return;
      }
      
      // Send the snapshot
      const snapshot = {
        type: 'product',
        origin: window.location.host,
        collected_at: new Date().toISOString(),
        items: [item],
        raw: {
          sourceMethod: sourceMethod,
          url: window.location.href,
          title: document.title
        }
      };
      
      window.__talabiyah.post({
        kind: 'talabiyah/snapshot',
        payload: snapshot
      });
      
      console.debug('Talabiyah: Product collected successfully', item);
      
    } catch (error) {
      console.error('Talabiyah: Error in collectProduct', error);
      window.__talabiyah.post({
        kind: 'talabiyah/error',
        payload: {
          message: 'Error in product collection: ' + error.message,
          url: window.location.href,
          timestamp: new Date().toISOString()
        }
      });
    }
  };
  
  // Cart collection
  window.__talabiyah.collectCart = function() {
    try {
      console.debug('Talabiyah: Starting cart collection...');
      
      let items = [];
      let totals = null;
      let sourceMethod = 'UNKNOWN';
      
      // Method 1: Network response (most reliable for SPA)
      if (window.__talabiyah.lastCartResponse) {
        console.debug('Talabiyah: Using captured network response', window.__talabiyah.lastCartResponse);
        
        const cartData = window.__talabiyah.lastCartResponse.bodyJson;
        const extractedData = extractCartFromNetworkResponse(cartData);
        
        if (extractedData && extractedData.items && extractedData.items.length > 0) {
          items = extractedData.items;
          totals = extractedData.totals;
          sourceMethod = 'NETWORK';
        }
      }
      
      // Method 2: DOM via adapter
      if (items.length === 0 && window.__talabiyah.adapters && window.__talabiyah.adapters.current) {
        console.debug('Talabiyah: Trying adapter-specific cart DOM extraction');
        
        const adapterResult = window.__talabiyah.adapters.current.collectCartDOM();
        if (adapterResult && adapterResult.items && adapterResult.items.length > 0) {
          items = adapterResult.items;
          totals = adapterResult.totals;
          sourceMethod = 'DOM';
        }
      }
      
      // Method 3: Generic DOM extraction
      if (items.length === 0) {
        console.debug('Talabiyah: Trying generic cart DOM extraction');
        
        const genericResult = extractGenericCart();
        if (genericResult && genericResult.items && genericResult.items.length > 0) {
          items = genericResult.items;
          totals = genericResult.totals;
          sourceMethod = 'DOM_GENERIC';
        }
      }
      
      // Method 4: JSON-LD ItemList fallback
      if (items.length === 0) {
        console.debug('Talabiyah: Trying JSON-LD ItemList extraction');
        
        const jsonLD = utils.readJSONLD('ItemList');
        if (jsonLD && jsonLD.itemListElement) {
          items = jsonLD.itemListElement.map(element => ({
            title: element.name || 'Cart Item',
            url: utils.absUrl(element.url) || window.location.href,
            image: element.image ? utils.absUrl(element.image) : null,
            sku: element.sku,
            sourceDomain: window.location.host,
            sourceMethod: 'JSONLD'
          }));
          sourceMethod = 'JSONLD';
        }
      }
      
      if (items.length === 0) {
        console.warn('Talabiyah: No cart items found');
        window.__talabiyah.post({
          kind: 'talabiyah/error',
          payload: {
            message: 'No cart items found',
            url: window.location.href,
            timestamp: new Date().toISOString()
          }
        });
        return;
      }
      
      // Build and send snapshot
      const snapshot = {
        type: 'cart_snapshot',
        origin: window.location.host,
        collected_at: new Date().toISOString(),
        items: items,
        subtotal: totals?.subtotal,
        currency: totals?.currency || 'USD',
        raw: {
          sourceMethod: sourceMethod,
          url: window.location.href,
          title: document.title,
          networkResponse: window.__talabiyah.lastCartResponse
        }
      };
      
      window.__talabiyah.post({
        kind: 'talabiyah/snapshot',
        payload: snapshot
      });
      
      console.debug('Talabiyah: Cart collected successfully', { items: items.length, totals });
      
    } catch (error) {
      console.error('Talabiyah: Error in collectCart', error);
      window.__talabiyah.post({
        kind: 'talabiyah/error',
        payload: {
          message: 'Error in cart collection: ' + error.message,
          url: window.location.href,
          timestamp: new Date().toISOString()
        }
      });
    }
  };
  
  // Helper functions
  function extractImageFromJSONLD(jsonLD) {
    if (jsonLD.image) {
      if (typeof jsonLD.image === 'string') {
        return utils.absUrl(jsonLD.image);
      } else if (Array.isArray(jsonLD.image) && jsonLD.image.length > 0) {
        return utils.absUrl(jsonLD.image[0]);
      } else if (jsonLD.image.url) {
        return utils.absUrl(jsonLD.image.url);
      }
    }
    return null;
  }
  
  function extractPriceFromJSONLD(jsonLD) {
    if (jsonLD.offers) {
      const offers = Array.isArray(jsonLD.offers) ? jsonLD.offers[0] : jsonLD.offers;
      if (offers.price && offers.priceCurrency) {
        return {
          amount: parseFloat(offers.price),
          currency: offers.priceCurrency
        };
      }
    }
    return null;
  }
  
  function extractGenericTitle() {
    const selectors = [
      'h1',
      '[data-testid*="title"]',
      '[class*="title"]',
      '[class*="product"][class*="name"]',
      '.product-title',
      '.item-title'
    ];
    
    for (const selector of selectors) {
      const element = utils.q(selector);
      if (element && element.textContent.trim()) {
        return element.textContent.trim();
      }
    }
    
    return null;
  }
  
  function extractGenericPrice() {
    const selectors = [
      '[class*="price"]:not([class*="old"])',
      '[data-testid*="price"]',
      '.currency',
      '.amount',
      '[itemProp="price"]'
    ];
    
    for (const selector of selectors) {
      const element = utils.q(selector);
      if (element) {
        const price = utils.extractPrice(utils.extractText(element));
        if (price) return price;
      }
    }
    
    return null;
  }
  
  function extractGenericImage() {
    const selectors = [
      '.product-image img',
      '.item-image img',
      '[class*="product"][class*="img"] img',
      'img[data-testid*="image"]',
      'img[src*="product"]'
    ];
    
    for (const selector of selectors) {
      const img = utils.q(selector);
      if (img && img.src) {
        return utils.absUrl(img.src);
      }
    }
    
    return null;
  }
  
  function extractCartFromNetworkResponse(cartData) {
    // This is a generic parser - adapters should override for store-specific parsing
    if (!cartData) return null;
    
    try {
      const items = [];
      let subtotal = null;
      let currency = 'USD';
      
      // Try common cart data structures
      if (cartData.items || cartData.products || cartData.cartItems) {
        const itemsArray = cartData.items || cartData.products || cartData.cartItems;
        
        for (const item of itemsArray) {
          items.push({
            title: item.name || item.title || item.product_name || 'Cart Item',
            url: window.location.href,
            image: item.image || item.image_url || item.thumbnail,
            sku: item.sku || item.product_id || item.id,
            qty: item.quantity || item.qty || 1,
            price: {
              amount: parseFloat(item.price || item.unit_price || 0),
              currency: item.currency || currency
            },
            sourceDomain: window.location.host,
            sourceMethod: 'NETWORK'
          });
        }
      }
      
      // Extract totals
      if (cartData.total || cartData.subtotal || cartData.total_price) {
        subtotal = parseFloat(cartData.total || cartData.subtotal || cartData.total_price);
      }
      
      if (cartData.currency) {
        currency = cartData.currency;
      }
      
      return {
        items: items,
        totals: {
          subtotal: subtotal,
          currency: currency
        }
      };
      
    } catch (e) {
      console.warn('Talabiyah: Failed to parse network cart response', e);
      return null;
    }
  }
  
  function extractGenericCart() {
    const itemSelectors = [
      '.cart-item',
      '.bag-item',
      '.checkout-item',
      '[class*="cart"][class*="item"]',
      '[data-testid*="cart"][data-testid*="item"]'
    ];
    
    let cartItems = [];
    
    for (const selector of itemSelectors) {
      cartItems = utils.qa(selector);
      if (cartItems.length > 0) break;
    }
    
    if (cartItems.length === 0) {
      return null;
    }
    
    const items = [];
    
    for (let i = 0; i < cartItems.length; i++) {
      const itemElement = cartItems[i];
      
      const title = extractItemTitle(itemElement) || `Cart Item ${i + 1}`;
      const price = extractItemPrice(itemElement);
      const image = extractItemImage(itemElement);
      const qty = extractItemQuantity(itemElement);
      
      items.push({
        title: title,
        url: window.location.href,
        image: image,
        qty: qty,
        price: price,
        sourceDomain: window.location.host,
        sourceMethod: 'DOM_GENERIC'
      });
    }
    
    // Try to extract totals
    const totalSelectors = [
      '.total',
      '.subtotal',
      '[class*="total"]',
      '[data-testid*="total"]'
    ];
    
    let subtotal = null;
    
    for (const selector of totalSelectors) {
      const totalElement = utils.q(selector);
      if (totalElement) {
        const price = utils.extractPrice(utils.extractText(totalElement));
        if (price) {
          subtotal = price.amount;
          break;
        }
      }
    }
    
    return {
      items: items,
      totals: {
        subtotal: subtotal,
        currency: 'USD'
      }
    };
  }
  
  function extractItemTitle(itemElement) {
    const titleSelectors = [
      '.item-name',
      '.product-name',
      '.title',
      '[class*="name"]',
      '[data-testid*="name"]'
    ];
    
    for (const selector of titleSelectors) {
      const titleElement = itemElement.querySelector(selector);
      if (titleElement && titleElement.textContent.trim()) {
        return titleElement.textContent.trim();
      }
    }
    
    return null;
  }
  
  function extractItemPrice(itemElement) {
    const priceSelectors = [
      '.price',
      '.item-price',
      '[class*="price"]',
      '[data-testid*="price"]'
    ];
    
    for (const selector of priceSelectors) {
      const priceElement = itemElement.querySelector(selector);
      if (priceElement) {
        const price = utils.extractPrice(utils.extractText(priceElement));
        if (price) return price;
      }
    }
    
    return null;
  }
  
  function extractItemImage(itemElement) {
    const img = itemElement.querySelector('img');
    return img && img.src ? utils.absUrl(img.src) : null;
  }
  
  function extractItemQuantity(itemElement) {
    const qtySelectors = [
      'input[type="number"]',
      '.quantity',
      '[class*="qty"]',
      '[data-testid*="quantity"]'
    ];
    
    for (const selector of qtySelectors) {
      const qtyElement = itemElement.querySelector(selector);
      if (qtyElement) {
        const qty = qtyElement.value || qtyElement.textContent;
        if (qty && !isNaN(qty)) {
          return parseInt(qty);
        }
      }
    }
    
    return 1; // default quantity
  }
  
  console.debug('Talabiyah: Collectors loaded successfully');
})();