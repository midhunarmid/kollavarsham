// Browser features for the web app, called from Dart (lib/web/browser_web.dart)
// as window.calendarBrowser:
//
// - get/set: the database document in IndexedDB, which holds more than
//   localStorage and is less likely to be cleared;
// - persisted/persist: navigator.storage persistence;
// - canInstall/install/standalone/ios: the install prompt;
// - updateReady/reload: a newer version found by app_sw.js;
// - listen: a callback for changes to canInstall and updateReady.
(function () {
  'use strict';
  var DB = 'malayalam-calendar';
  var STORE = 'documents';
  var opening = null;

  function open() {
    if (!opening) {
      opening = new Promise(function (resolve, reject) {
        var request = indexedDB.open(DB, 1);
        request.onupgradeneeded = function () { request.result.createObjectStore(STORE); };
        request.onsuccess = function () { resolve(request.result); };
        request.onerror = function () { reject(request.error); };
        request.onblocked = function () { reject(new Error('IndexedDB blocked')); };
      });
      opening.catch(function () { opening = null; });
    }
    return opening;
  }

  function transaction(mode, work) {
    return open().then(function (db) {
      return new Promise(function (resolve, reject) {
        var tx = db.transaction(STORE, mode);
        var request = work(tx.objectStore(STORE));
        tx.oncomplete = function () { resolve(request.result); };
        tx.onerror = function () { reject(tx.error); };
        tx.onabort = function () { reject(tx.error || new Error('aborted')); };
      });
    });
  }

  var installEvent = null;
  var updateReady = false;
  var listeners = [];
  function changed() { listeners.forEach(function (f) { try { f(); } catch (e) { console.warn(e); } }); }

  window.addEventListener('beforeinstallprompt', function (e) {
    e.preventDefault();
    installEvent = e;
    changed();
  });
  window.addEventListener('appinstalled', function () {
    installEvent = null;
    changed();
  });
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.addEventListener('message', function (e) {
      if (e.data && e.data.type === 'update-ready' && !updateReady) {
        updateReady = true;
        changed();
      }
    });
  }

  var storage = navigator.storage;
  window.calendarBrowser = {
    get: function (key) {
      return transaction('readonly', function (s) { return s.get(key); })
        .then(function (v) { return typeof v === 'string' ? v : null; });
    },
    set: function (key, value) {
      return transaction('readwrite', function (s) { return s.put(value, key); })
        .then(function () { return null; });
    },
    persisted: function () {
      return storage && storage.persisted ? storage.persisted() : Promise.resolve(null);
    },
    persist: function () {
      return storage && storage.persist ? storage.persist() : Promise.resolve(null);
    },
    canInstall: function () { return installEvent !== null; },
    install: function () {
      if (!installEvent) return Promise.resolve(false);
      var e = installEvent;
      installEvent = null;
      changed();
      e.prompt();
      return e.userChoice.then(function (choice) { return choice.outcome === 'accepted'; });
    },
    standalone: function () {
      return window.matchMedia('(display-mode: standalone)').matches || navigator.standalone === true;
    },
    ios: function () {
      return /iPad|iPhone|iPod/.test(navigator.userAgent) ||
        (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1);
    },
    updateReady: function () { return updateReady; },
    reload: function () { window.location.reload(); },
    listen: function (callback) { listeners.push(callback); },
  };
})();
