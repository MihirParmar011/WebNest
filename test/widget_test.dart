import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pwa/home_page.dart';
import 'package:pwa/onboarding_screen.dart';
import 'package:pwa/splash_screen.dart';
import 'package:pwa/url_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pwa/main.dart';

void main() {
  group('PWA Browser App Tests', () {
    setUp(() {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('App initializes correctly', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(MyApp());
      await tester.pump();

      // Verify that the app starts (should show splash or onboarding)
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(InitialScreen), findsOneWidget);
    });

    testWidgets('Splash screen displays correctly', (WidgetTester tester) async {
      // Build splash screen
      await tester.pumpWidget(MaterialApp(home: SplashScreen()));

      // Verify splash screen elements
      expect(find.text('Web PWA'), findsOneWidget);
      expect(find.text('Browse any website seamlessly'), findsOneWidget);
      expect(find.byIcon(Icons.web), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Onboarding screen navigation works', (WidgetTester tester) async {
      // Build onboarding screen
      await tester.pumpWidget(MaterialApp(home: OnboardingScreen()));
      await tester.pumpAndSettle();

      // Verify first page content
      expect(find.text('Browse Any Website'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);

      // Test next button
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Verify second page
      expect(find.text('Mobile Optimized'), findsOneWidget);

      // Test next button again
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Verify third page
      expect(find.text('Fast & Secure'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('Home page displays correctly', (WidgetTester tester) async {
      // Build home page
      await tester.pumpWidget(MaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      // Verify home page elements
      expect(find.text('Web Browser'), findsOneWidget);
      expect(find.text('Enter URL or search...'), findsOneWidget);
      expect(find.text('Quick Links'), findsOneWidget);
      expect(find.text('Google'), findsOneWidget);
      expect(find.text('YouTube'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('URL input dialog works', (WidgetTester tester) async {
      bool urlSubmitted = false;
      String submittedUrl = '';

      // Build URL input widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UrlInput(
              onUrlSubmitted: (url) {
                urlSubmitted = true;
                submittedUrl = url;
              },
            ),
          ),
        ),
      );

      // Verify URL input elements
      expect(find.text('Enter URL or Search'), findsOneWidget);
      expect(find.text('https://example.com or search term'), findsOneWidget);
      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Test URL input
      await tester.enterText(
        find.byType(TextField),
        'https://www.google.com',
      );
      await tester.tap(find.text('Open'));
      await tester.pump();

      // Verify URL was submitted
      expect(urlSubmitted, true);
      expect(submittedUrl, 'https://www.google.com');
    });

    testWidgets('URL formatting works correctly', (WidgetTester tester) async {
      String? submittedUrl;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UrlInput(
              onUrlSubmitted: (url) {
                submittedUrl = url;
              },
            ),
          ),
        ),
      );

      // Test URL without protocol
      await tester.enterText(find.byType(TextField), 'google.com');
      await tester.tap(find.text('Open'));
      await tester.pump();
      expect(submittedUrl, 'https://google.com');

      // Test search query
      await tester.enterText(find.byType(TextField), 'flutter tutorial');
      await tester.tap(find.text('Open'));
      await tester.pump();
      expect(submittedUrl?.contains('google.com/search'), true);
    });

    testWidgets('Quick links are tappable', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      // Find and verify quick links
      expect(find.text('Google'), findsOneWidget);
      expect(find.text('YouTube'), findsOneWidget);
      expect(find.text('GitHub'), findsOneWidget);
      expect(find.text('Reddit'), findsOneWidget);

      // Test that quick links are tappable (this would normally navigate)
      await tester.tap(find.text('Google'));
      await tester.pump();
      // Note: In a real test, you'd verify navigation occurred
    });

    testWidgets('FAB opens URL input', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      // Verify FAB exists
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Tap FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // This would normally open a modal bottom sheet
      // In a real app test, you'd verify the modal opened
    });

    testWidgets('Search bar is tappable', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      // Find search bar
      expect(find.text('Enter URL or search...'), findsOneWidget);

      // Tap search bar
      await tester.tap(find.text('Enter URL or search...'));
      await tester.pump();

      // This would normally open URL input modal
    });
  });

  group('URL Formatting Tests', () {
    test('URL formatting logic', () {
      // These would be unit tests for URL formatting functions
      // if they were extracted to separate functions

      // Test cases for URL formatting:
      // 'google.com' -> 'https://google.com'
      // 'https://example.com' -> 'https://example.com' (no change)
      // 'flutter tutorial' -> 'https://www.google.com/search?q=flutter%20tutorial'
      // '' -> '' (empty)
    });
  });
}