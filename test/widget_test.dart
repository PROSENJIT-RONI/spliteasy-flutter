import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spliteasy/app/config/supabase_config.dart';
import 'package:spliteasy/main.dart';

void main() {
  testWidgets('App loads splash screen', (WidgetTester tester) async {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
    } catch (_) {}

    await tester.pumpWidget(const SplitEasyApp());
    expect(find.text('SplitEasy'), findsOneWidget);
  });
}
