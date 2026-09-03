// Conditional export for platform file operations.
// Usage: import 'platform/file_helper.dart' as file_helper;
export 'file_helper_stub.dart'
    if (dart.library.io) 'file_helper_io.dart'
    if (dart.library.js_interop) 'file_helper_web.dart';
