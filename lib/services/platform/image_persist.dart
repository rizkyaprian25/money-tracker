// Conditional export untuk persist image target menabung.
// IO: copy ke documents/goal_images agar survive restart.
// Web: kembalikan path asli (blob URL), tanpa filesystem.
export 'image_persist_stub.dart'
    if (dart.library.io) 'image_persist_io.dart'
    if (dart.library.js_interop) 'image_persist_web.dart';
