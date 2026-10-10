import 'package:flutter_test/flutter_test.dart';

import 'package:food_diary/main.dart';

void main() {
  testWidgets('shows missing Supabase configuration', (tester) async {
    await tester.pumpWidget(const MissingConfigApp());

    expect(
      find.textContaining('Supabase configuration is missing'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Add SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY to the local .env file, '
        'then restart the app. Use a publishable key only; never put a '
        'service-role key in Flutter.',
      ),
      findsOneWidget,
    );
  });
}
