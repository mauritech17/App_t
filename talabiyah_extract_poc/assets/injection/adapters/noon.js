// Noon-specific adapter for Talabiyah
(function() {
  'use strict';
  
  if (!window.__talabiyah) {
    console.error('Talabiyah: Bootstrap not loaded');
    return;
  }
  
  // Initialize adapters namespace
  window.__talabiyah.adapters = window.__talabiyah.adapters || {};
  
  window.__talabiyah.adapters.noon = {
    collectProductDOM() {
      try {
        const utils = window.__talabiyah.utils;
        
        // Noon product title selectors
        const titleSelectors = [
          '[data-qa="pdp-product-name"]',
          'h1[data-qa="product-title"]',
          '.product-title h1',
          'h1[class*="product"]',
          '.pdp-product-name'
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
          console.debug('Noon: No product title found');
          return null;
        }
        
        // Noon price selectors
        const priceSelectors = [
          '[data-qa="pdp-price"]',
          '[data-qa="price-current"]',
          '.price-current',
          '[class*="price"][class*="now"]',
          '.price.now'
        ];
        
        let price = null;
        for (const selector of priceSelectors) {
          const element = utils.q(selector);
          if (element) {
            price = utils.extractPrice(utils.extractText(element));
            if (price) break;
          }
        }
        
        // Noon image selectors
        const imageSelectors = [
          '[data-qa="pdp-product-image"] img',
          '.product-gallery img',
          '.gallery-main img',
          '.product-image img'
        ];
        
        let image = null;
        for (const selector of imageSelectors) {
          const img = utils.q(selector);
          if (img && img.src && !img.src.includes('placeholder')) {
            image = utils.absUrl(img.src);
            break;
          }
        }
        
        // SKU from product data
        let sku = null;
        const skuElement = utils.q('[data-qa="product-sku"], .product-sku');
        if (skuElement) {
          sku = skuElement.textContent.trim();
        }
        
        // Extract variant options
        const options = {};
        const variantElements = utils.qa('[data-qa*="variant"]');
        variantElements.forEach(element => {
          const label = element.querySelector('.variant-label, .option-label');
          const value = element.querySelector('.variant-value, .selected');
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
        console.error('Noon: Error in collectProductDOM', error);
        return null;
      }
    },
    
    collectCartDOM() {
      try {
        const utils = window.__talabiyah.utils;
        
        // Noon cart item selectors
        const cartItemSelectors = [
          '[data-qa="cart-item"]',
          '.cart-item',
          '.bag-item',
          '[class*="checkout-item"]'
        ];
        
        let cartItems = [];
        for (const selector of cartItemSelectors) {
          cartItems = utils.qa(selector);
          if (cartItems.length > 0) break;
        }
        
        if (cartItems.length === 0) {
          console.debug('Noon: No cart items found');
          return null;
        }
        
        const items = [];
        
        for (const itemElement of cartItems) {
          const nameSelectors = [
            '[data-qa="cart-item-name"]',
            '.item-name',
            '.product-name',
            'a[data-qa*="product"]'
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
            '[data-qa="cart-item-price"]',
            '.item-price',
            '[class*="price"]'
          ];
          
          let itemPrice = null;
          for (const selector of priceSelectors) {
            const priceElement = itemElement.querySelector(selector);
            if (priceElement) {
              itemPrice = utils.extractPrice(utils.extractText(priceElement));
              if (itemPrice) break;
            }
          }
          
          const imgElement = itemElement.querySelector('[data-qa="cart-item-image"] img, .item-image img, img');
          const itemImage = imgElement && imgElement.src ? utils.absUrl(imgElement.src) : null;
          
          const qtySelectors = [
            '[data-qa="quantity"] input',
            'input[type="number"]',
            '.quantity input',
            '[class*="qty"] input'
          ];
          
          let qty = 1;
          for (const selector of qtySelectors) {
            const qtyElement = itemElement.querySelector(selector);
            if (qtyElement && qtyElement.value) {
              qty = parseInt(qtyElement.value) || 1;
              break;
            }
          }
          
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
          '[data-qa="cart-summary-subtotal"]',
          '[data-qa="checkout-total"]',
          '.cart-total .price',
          '.subtotal',
          '[class*="total"] [class*="price"]'
        ];
        
        let subtotal = null;
        let currency = 'AED'; // Noon default currency
        
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
        console.error('Noon: Error in collectCartDOM', error);
        return null;
      }
    }
  };
  
  console.debug('Talabiyah: Noon adapter loaded');
})();