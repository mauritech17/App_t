// Talabiyah Bootstrap - Advanced WebView Product Extractor
(function() {
  'use strict';
  
  // Initialize Talabiyah namespace
  window.__talabiyah = window.__talabiyah || {};
  
  // Communication bridge to Flutter
  window.__talabiyah.post = function(payload) {
    try {
      if (typeof TalaBridge !== 'undefined' && TalaBridge.postMessage) {
        TalaBridge.postMessage(JSON.stringify(payload));
        console.debug('Talabiyah: Sent to Flutter', payload);
      } else {
        console.warn('Talabiyah: TalaBridge not available');
      }
    } catch (e) {
      console.error('Talabiyah: Error sending to Flutter', e);
    }
  };
  
  // Network request interception
  window.__talabiyah.lastCartResponse = null;
  
  // Patch fetch API
  const originalFetch = window.fetch;
  window.fetch = function(url, options) {
    return originalFetch(url, options).then(response => {
      const urlStr = typeof url === 'string' ? url : url.url;
      
      // Check if this is a cart-related request
      if (urlStr && (/\/cart|\/api\/cart|\/checkout\/cart/i.test(urlStr))) {
        response.clone().json().then(data => {
          window.__talabiyah.lastCartResponse = {
            url: urlStr,
            status: response.status,
            bodyJson: data
          };
          console.debug('Talabiyah: Captured cart response', window.__talabiyah.lastCartResponse);
        }).catch(() => {
          // Ignore JSON parse errors for non-JSON responses
        });
      }
      
      return response;
    });
  };
  
  // Patch XMLHttpRequest
  const originalXHROpen = XMLHttpRequest.prototype.open;
  const originalXHRSend = XMLHttpRequest.prototype.send;
  
  XMLHttpRequest.prototype.open = function(method, url) {
    this._talabiyahUrl = url;
    return originalXHROpen.apply(this, arguments);
  };
  
  XMLHttpRequest.prototype.send = function(data) {
    const xhr = this;
    
    xhr.addEventListener('load', function() {
      if (xhr._talabiyahUrl && /\/cart|\/api\/cart|\/checkout\/cart/i.test(xhr._talabiyahUrl)) {
        try {
          const responseData = JSON.parse(xhr.responseText);
          window.__talabiyah.lastCartResponse = {
            url: xhr._talabiyahUrl,
            status: xhr.status,
            bodyJson: responseData
          };
          console.debug('Talabiyah: Captured XHR cart response', window.__talabiyah.lastCartResponse);
        } catch (e) {
          // Ignore JSON parse errors
        }
      }
    });
    
    return originalXHRSend.apply(this, arguments);
  };
  
  // Utility functions
  window.__talabiyah.utils = {
    q: function(selector) {
      return document.querySelector(selector);
    },
    
    qa: function(selector) {
      return document.querySelectorAll(selector);
    },
    
    absUrl: function(url) {
      if (!url) return null;
      if (url.startsWith('http')) return url;
      try {
        return new URL(url, window.location.href).href;
      } catch (e) {
        return url;
      }
    },
    
    extractText: function(element) {
      return element ? element.textContent.trim() : null;
    },
    
    extractPrice: function(text) {
      if (!text) return null;
      
      // Extract currency and amount from text
      const currencyMatch = text.match(/([A-Z]{3})|([£$€¥₹])|(AED|USD|EUR|GBP)/i);
      const priceMatch = text.match(/([\d,]+\.?\d*)/g);
      
      if (priceMatch && priceMatch.length > 0) {
        const amount = parseFloat(priceMatch[priceMatch.length - 1].replace(/,/g, ''));
        const currency = currencyMatch ? currencyMatch[0].toUpperCase() : 'USD';
        
        return {
          amount: amount,
          currency: currency
        };
      }
      
      return null;
    },
    
    readJSONLD: function(type) {
      const scripts = document.querySelectorAll('script[type="application/ld+json"]');
      
      for (const script of scripts) {
        try {
          const data = JSON.parse(script.textContent);
          
          // Handle single object or array
          const items = Array.isArray(data) ? data : [data];
          
          for (const item of items) {
            if (item['@type'] && item['@type'].includes(type)) {
              return item;
            }
          }
        } catch (e) {
          console.warn('Talabiyah: Failed to parse JSON-LD', e);
        }
      }
      
      return null;
    }
  };
  
  // Initialize adapters namespace
  window.__talabiyah.adapters = window.__talabiyah.adapters || {};
  
  console.debug('Talabiyah: Bootstrap initialized successfully');
})();