// Conditional export untuk image target menabung.
// Web: tidak pakai dart:io (pakai NetworkImage/blob atau placeholder).
// IO (Android/desktop): pakai FileImage.
export 'goal_image_widget_stub.dart'
    if (dart.library.io) 'goal_image_widget_io.dart'
    if (dart.library.js_interop) 'goal_image_widget_web.dart';
