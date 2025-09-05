// Amazon.ae-specific adapter for Talabiyah
(function() {
  'use strict';
  
  if (!window.__talabiyah) {
    console.error('Talabiyah: Bootstrap not loaded');
    return;
  }
  
  // Initialize adapters namespace
  window.__talabiyah.adapters = window.__talabiyah.adapters || {};
  
  window.__talabiyah.adapters['amazon-ae'] = {
    collectProductDOM() {
      try {
        const utils = window.__talabiyah.utils;
        
        // Amazon product title selectors
        const titleSelectors = [
          '#productTitle',
          '.product-title',
          'h1.a-size-large',
          '[data-automation-id="product-title"]'
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
          console.debug('Amazon: No product title found');
          return null;
        }
        
        // Amazon price selectors
        const priceSelectors = [
          '#corePrice_feature_div .a-offscreen',
          '.a-price .a-offscreen',
          '#price_inside_buybox',
          '.a-price-current .a-offscreen',
          '[data-automation-id="product-price"] .a-offscreen'
        ];
        
        let price = null;
        for (const selector of priceSelectors) {
          const element = utils.q(selector);
          if (element) {
            price = utils.extractPrice(utils.extractText(element));
            if (price) break;
          }
        }
        
        // Amazon image selectors
        const imageSelectors = [
          '#landingImage',
          '#imgTagWrapperId img',
          '.a-dynamic-image',
          '[data-automation-id="product-image"] img'
        ];
        
        let image = null;
        for (const selector of imageSelectors) {
          const img = utils.q(selector);
          if (img && img.src && !img.src.includes('transparent-pixel')) {
            image = utils.absUrl(img.src);
            break;
          }
        }
        
        // ASIN from URL or meta
        let sku = null;
        const asinMatch = window.location.href.match(/\/dp\/([A-Z0-9]{10})/);
        if (asinMatch) {
          sku = asinMatch[1];
        } else {
          const asinMeta = utils.q('meta[name="keywords"]');
          if (asinMeta && asinMeta.content.includes('ASIN:')) {
            const asinFromMeta = asinMeta.content.match(/ASIN:([A-Z0-9]{10})/);
            if (asinFromMeta) {
              sku = asinFromMeta[1];
            }
          }
        }
        
        // Extract variant options (size, color, etc.)
        const options = {};
        const variantElements = utils.qa('#variation_size_name .selection, #variation_color_name .selection');
        variantElements.forEach(element => {
          const parentId = element.closest('[id*="variation"]')?.id;
          if (parentId && element.textContent.trim()) {
            const optionType = parentId.includes('size') ? 'Size' : 
                              parentId.includes('color') ? 'Color' : 'Option';
            options[optionType] = element.textContent.trim();
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
        console.error('Amazon: Error in collectProductDOM', error);
        return null;
      }
    },
    
    collectCartDOM() {
      try {
        const utils = window.__talabiyah.utils;
        
        // Amazon cart item selectors
        const cartItemSelectors = [
          '[data-name="Active Items"] .sc-list-item',
          '.sc-list-item[data-item-index]',
          '.cart-item',
          '#sc-active-cart .sc-list-item'
        ];
        
        let cartItems = [];
        for (const selector of cartItemSelectors) {
          cartItems = utils.qa(selector);
          if (cartItems.length > 0) break;
        }
        
        if (cartItems.length === 0) {
          console.debug('Amazon: No cart items found');
          return null;
        }
        
        const items = [];
        
        for (const itemElement of cartItems) {
          const nameSelectors = [
            '[data-testid="item-product-name"]',
            '.sc-product-title',
            '.item-name',
            'a[data-testid*="product"]'
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
            '.sc-price .a-offscreen',
            '.item-price .a-offscreen',
            '.a-color-price .a-offscreen'
          ];
          
          let itemPrice = null;
          for (const selector of priceSelectors) {
            const priceElement = itemElement.querySelector(selector);
            if (priceElement) {
              itemPrice = utils.extractPrice(utils.extractText(priceElement));
              if (itemPrice) break;
            }
          }
          
          const imgElement = itemElement.querySelector('.sc-product-image img, .item-image img, img');
          const itemImage = imgElement && imgElement.src ? utils.absUrl(imgElement.src) : null;
          
          const qtySelectors = [
            '.a-dropdown-prompt',
            'select[name*="quantity"] option[selected]',
            'input[name*="quantity"]'
          ];
          
          let qty = 1;
          for (const selector of qtySelectors) {
            const qtyElement = itemElement.querySelector(selector);
            if (qtyElement) {
              const qtyText = qtyElement.textContent || qtyElement.value;
              if (qtyText && !isNaN(qtyText)) {
                qty = parseInt(qtyText) || 1;
                break;
              }
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
          '#sc-subtotal-amount-activecart .a-offscreen',
          '.sc-subtotal .a-offscreen',
          '[data-testid="cart-subtotal"] .a-offscreen',
          '.cart-total .a-offscreen'
        ];
        
        let subtotal = null;
        let currency = 'AED'; // Amazon.ae default currency
        
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
        console.error('Amazon: Error in collectCartDOM', error);
        return null;
      }
    }
  };
  
  console.debug('Talabiyah: Amazon.ae adapter loaded');
})();