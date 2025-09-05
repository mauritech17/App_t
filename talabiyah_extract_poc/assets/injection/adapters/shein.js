// Shein-specific adapter for Talabiyah
(function() {
  'use strict';
  
  if (!window.__talabiyah) {
    console.error('Talabiyah: Bootstrap not loaded');
    return;
  }
  
  // Initialize adapters namespace
  window.__talabiyah.adapters = window.__talabiyah.adapters || {};
  
  window.__talabiyah.adapters.shein = {
    collectProductDOM() {
      try {
        const utils = window.__talabiyah.utils;
        
        // Shein product title selectors
        const titleSelectors = [
          'h1.product-intro__head-name',
          'h1[data-testid="product-title"]',
          '.product-title h1',
          '.product-intro__head h1',
          'h1.product-name'
        ];
        
        let title = null;
        for (const selector of titleSelectors) {
          const element = utils.q(selector);
          if (element && element.textContent.trim()) {
            title = element.textContent.trim();
            break;
          }
        }
        
        if (!title) {
          console.debug('Shein: No product title found');
          return null;
        }
        
        // Shein price selectors
        const priceSelectors = [
          '.product-intro__head-price .del-price',
          '.product-intro__head-price [class*="price-current"]',
          '.price-current',
          '[data-testid="current-price"]',
          '.product-price .current'
        ];
        
        let price = null;
        for (const selector of priceSelectors) {
          const element = utils.q(selector);
          if (element) {
            price = utils.extractPrice(utils.extractText(element));
            if (price) break;
          }
        }
        
        // Shein image selectors
        const imageSelectors = [
          '.product-intro__head-gallery img',
          '.product-gallery img',
          '.gallery-image img',
          '[data-testid="product-image"] img'
        ];
        
        let image = null;
        for (const selector of imageSelectors) {
          const img = utils.q(selector);
          if (img && img.src && !img.src.includes('placeholder')) {
            image = utils.absUrl(img.src);
            break;
          }
        }
        
        // SKU from URL or product data
        let sku = null;
        const urlMatch = window.location.href.match(/\/p-([a-zA-Z0-9]+)/);
        if (urlMatch) {
          sku = urlMatch[1];
        }
        
        // Extract options (size, color, etc.)
        const options = {};
        const optionElements = utils.qa('.product-intro__head-attr .attr-item');
        optionElements.forEach(element => {
          const label = element.querySelector('.attr-label');
          const value = element.querySelector('.attr-value, .selected');
          if (label && value) {
            options[label.textContent.trim()] = value.textContent.trim();
          }
        });
        
        return {
          title: title,
          image: image,
          sku: sku,
          options: Object.keys(options).length > 0 ? options : null,
          price: price
        };
        
      } catch (error) {
        console.error('Shein: Error in collectProductDOM', error);
        return null;
      }
    },
    
    collectCartDOM() {
      try {
        const utils = window.__talabiyah.utils;
        
        // Shein cart item selectors
        const cartItemSelectors = [
          '.shopping-cart-item',
          '.bag-item',
          '[class*="cart-item"]',
          '[data-testid="cart-item"]'
        ];
        
        let cartItems = [];
        for (const selector of cartItemSelectors) {
          cartItems = utils.qa(selector);
          if (cartItems.length > 0) break;
        }
        
        if (cartItems.length === 0) {
          console.debug('Shein: No cart items found');
          return null;
        }
        
        const items = [];
        
        for (const itemElement of cartItems) {
          const nameSelectors = [
            '.item-name',
            '.product-name',
            '[class*="name"]',
            'a[href*="/p-"]'
          ];
          
          let itemName = null;
          for (const selector of nameSelectors) {
            const nameElement = itemElement.querySelector(selector);
            if (nameElement && nameElement.textContent.trim()) {
              itemName = nameElement.textContent.trim();
              break;
            }
          }
          
          const priceSelectors = [
            '.item-price',
            '[class*="price"]',
            '.price-current'
          ];
          
          let itemPrice = null;
          for (const selector of priceSelectors) {
            const priceElement = itemElement.querySelector(selector);
            if (priceElement) {
              itemPrice = utils.extractPrice(utils.extractText(priceElement));
              if (itemPrice) break;
            }
          }
          
          const imgElement = itemElement.querySelector('img');
          const itemImage = imgElement && imgElement.src ? utils.absUrl(imgElement.src) : null;
          
          const qtyElement = itemElement.querySelector('input[type="number"], .quantity, [class*="qty"]');
          const qty = qtyElement ? (parseInt(qtyElement.value || qtyElement.textContent) || 1) : 1;
          
          if (itemName) {
            items.push({
              title: itemName,
              image: itemImage,
              qty: qty,
              price: itemPrice
            });
          }
        }
        
        // Extract totals
        const totalSelectors = [
          '.cart-summary-total .price',
          '.total-price',
          '[class*="total"] [class*="price"]',
          '.subtotal'
        ];
        
        let subtotal = null;
        let currency = 'USD';
        
        for (const selector of totalSelectors) {
          const totalElement = utils.q(selector);
          if (totalElement) {
            const totalPrice = utils.extractPrice(utils.extractText(totalElement));
            if (totalPrice) {
              subtotal = totalPrice.amount;
              currency = totalPrice.currency;
              break;
            }
          }
        }
        
        return {
          items: items,
          totals: {
            subtotal: subtotal,
            currency: currency
          }
        };
        
      } catch (error) {
        console.error('Shein: Error in collectCartDOM', error);
        return null;
      }
    }
  };
  
  console.debug('Talabiyah: Shein adapter loaded');
})();