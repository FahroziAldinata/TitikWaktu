import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:titik_waktu/widgets/floating_bottom_nav_bar.dart';

void main() {
  group('FloatingBottomNavBar Widget Tests', () {
    testWidgets('Renders 3 tabs with proper order: Kategori (0), Home (1), Pengaturan (2)', (tester) async {
      int selectedIndex = 1; // Default to Home (index 1)

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const SizedBox(),
            bottomNavigationBar: StatefulBuilder(
              builder: (context, setState) {
                return FloatingBottomNavBar(
                  currentIndex: selectedIndex,
                  onTap: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Home should be active (displays text 'Home')
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Kategori'), findsNothing);
      expect(find.text('Pengaturan'), findsNothing);

      // Check all 3 tabs exist
      expect(find.byKey(const ValueKey('nav_item_0')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_item_1')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_item_2')), findsOneWidget);

      // Tap on tab 0 (Kategori)
      await tester.tap(find.byKey(const ValueKey('nav_item_0')));
      await tester.pumpAndSettle();

      expect(selectedIndex, 0);
      expect(find.text('Home'), findsNothing);
      expect(find.text('Kategori'), findsOneWidget);
      expect(find.text('Pengaturan'), findsNothing);

      // Tap on tab 2 (Pengaturan)
      await tester.tap(find.byKey(const ValueKey('nav_item_2')));
      await tester.pumpAndSettle();

      expect(selectedIndex, 2);
      expect(find.text('Home'), findsNothing);
      expect(find.text('Kategori'), findsNothing);
      expect(find.text('Pengaturan'), findsOneWidget);

      // Tap on tab 1 (Home)
      await tester.tap(find.byKey(const ValueKey('nav_item_1')));
      await tester.pumpAndSettle();

      expect(selectedIndex, 1);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('Rapid tab switches across all combinations do not throw errors or break animation state', (tester) async {
      int selectedIndex = 1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: StatefulBuilder(
              builder: (context, setState) {
                return FloatingBottomNavBar(
                  currentIndex: selectedIndex,
                  onTap: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Rapid clicks testing combinations: 1->0, 0->2, 2->1, 1->2, 2->0
      await tester.tap(find.byKey(const ValueKey('nav_item_0')));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byKey(const ValueKey('nav_item_2')));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byKey(const ValueKey('nav_item_1')));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byKey(const ValueKey('nav_item_2')));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byKey(const ValueKey('nav_item_0')));
      await tester.pumpAndSettle();

      expect(selectedIndex, 0);
      expect(find.text('Kategori'), findsOneWidget);
    });
  });
}
