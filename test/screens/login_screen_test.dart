import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starter_flutter/screens/login_screen.dart';

void main() {
  Widget buildLoginScreen() {
    return const MaterialApp(home: LoginRegisterScreen());
  }

  testWidgets('shows login form and validates required fields', (tester) async {
    await tester.pumpWidget(buildLoginScreen());

    expect(find.text('Willkommen zurück!'), findsOneWidget);
    expect(find.text('E-Mail'), findsOneWidget);
    expect(find.text('Passwort'), findsOneWidget);
    expect(find.text('Einloggen'), findsOneWidget);

    await tester.tap(find.text('Einloggen'));
    await tester.pumpAndSettle();

    expect(find.text('Bitte gib eine gültige E-Mail ein'), findsOneWidget);
    expect(find.text('Passwort muss mindestens 8 Zeichen lang sein'), findsOneWidget);
  });

  testWidgets('switches to registration and shows the name field', (tester) async {
    await tester.pumpWidget(buildLoginScreen());

    await tester.tap(find.text('Noch keinen Account? Registrieren'));
    await tester.pumpAndSettle();

    expect(find.text('Account erstellen'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Registrieren'), findsOneWidget);
  });
}
