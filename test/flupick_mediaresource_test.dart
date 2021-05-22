import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flupick_mediaresource/flupick_mediaresource.dart';

void main() {
  const MethodChannel channel = MethodChannel('flupick_mediaresource');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
