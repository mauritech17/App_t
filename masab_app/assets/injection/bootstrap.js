// Bootstrap script for Masab product extractor
(function() {
  'use strict';
  
  // Initialize Masab namespace
  window.__masab = window.__masab || {};
  
  // Communication function
  window.__masab.post = function(payload) {
    if (typeof TalaBridge !== 'undefined' && TalaBridge.postMessage) {
      try {
        TalaBridge.postMessage(JSON.stringify(payload));
        console.log('Masab: Sent data to Flutter', payload);
      } catch (e) {
        console.error('Masab: Error sending data to Flutter', e);
      }
    } else {
      console.warn('Masab: TalaBridge not available');
    }
  };
  
  // Utility functions
  window.__masab.utils = {
    q: function(selector) {
      return document.querySelector(selector);
    },
    qa: function(selector) {
      return document.querySelectorAll(selector);
    },
    absUrl: function(url) {
      if (!url) return null;
      if (url.startsWith('http')) return url;
      return new URL(url, window.location.href).href;
    },
    extractText: function(element) {
      return element ? element.textContent.trim() : null;
    },
    extractPrice: function(text) {
      if (!text) return null;
      const priceMatch = text.match(/[\d.,]+/);
      if (priceMatch) {
        return {
          amount: parseFloat(priceMatch[0].replace(',', '')),
          currency: 'USD', // Default currency
          originalText: text
        };
      }
      return null;
    }
  };
  
  console.log('Masab bootstrap loaded successfully');
})();