{{flutter_js}}
{{flutter_build_config}}

// Loads the app without Flutter's own service worker: that one is a stub
// that unregisters itself, and at the same /app/ scope it would replace
// app_sw.js, which index.html registers for offline use.
_flutter.loader.load();
