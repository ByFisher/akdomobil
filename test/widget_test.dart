// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:akdomobil/main.dart';
import 'package:akdomobil/presentation/theme/app_theme.dart';

void main() {
  testWidgets('Start screen offers customer and administrator sign-in', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AkdoApp());
    expect(find.text('MARAŞ LEZZETLERİ'), findsNothing);
    expect(find.text('Profil menüsü'), findsNothing);
    expect(find.text('MÜŞTERİ OLARAK GİRİŞ YAP'), findsOneWidget);
    expect(find.text('YÖNETİCİ OLARAK GİRİŞ YAP'), findsOneWidget);
    expect(find.text('AKDOŞEF GİRİŞİ'), findsOneWidget);
    expect(find.text('AKDOGARSON GİRİŞİ'), findsOneWidget);
    expect(find.text('Sürüm $appVersion'), findsOneWidget);
    expect(find.text('LunaSoft ürünüdür.'), findsOneWidget);
  });

  testWidgets('Chef and waiter entry points open their matching login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AkdoApp());

    await tester.tap(find.text('AKDOŞEF GİRİŞİ'));
    await tester.pumpAndSettle();
    expect(find.text('AkdoŞef personel girişi'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('AKDOGARSON GİRİŞİ'));
    await tester.pumpAndSettle();
    expect(find.text('AkdoGarson personel girişi'), findsOneWidget);
  });

  testWidgets('Customer sign-in offers registration', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AkdoApp());
    await tester.tap(find.text('MÜŞTERİ OLARAK GİRİŞ YAP'));
    await tester.pumpAndSettle();

    expect(find.text('Üye girişi'), findsOneWidget);
    expect(find.text('Üye ol'), findsOneWidget);
    await tester.tap(find.text('Üye ol'));
    await tester.pumpAndSettle();
    expect(find.text('Ad'), findsOneWidget);
    expect(find.text('Soyad'), findsOneWidget);
    expect(find.text('Kullanıcı adı'), findsOneWidget);
    expect(find.textContaining('en az 3 karakter'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('ÜYELİK OLUŞTUR'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('ÜYELİK OLUŞTUR'));
    await tester.pump();
    expect(
      find.text('Kullanıcı adı en az 3 karakter olmalıdır.'),
      findsOneWidget,
    );
  });

  testWidgets('Customer login requests a username instead of member number', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AkdoApp());
    await tester.tap(find.text('MÜŞTERİ OLARAK GİRİŞ YAP'));
    await tester.pumpAndSettle();

    expect(find.text('Kullanıcı adı'), findsOneWidget);
    expect(find.text('8 haneli üye numarası'), findsNothing);
  });

  testWidgets('Registration requires acknowledgement of the privacy notice', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AkdoApp());
    await tester.tap(find.text('MÜŞTERİ OLARAK GİRİŞ YAP'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Üye ol'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('member-first-name')), 'Ayşe');
    await tester.enterText(find.byKey(const Key('member-last-name')), 'Yılmaz');
    await tester.enterText(find.byKey(const Key('member-username')), 'ayse');

    await tester.scrollUntilVisible(
      find.text('ÜYELİK OLUŞTUR'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('ÜYELİK OLUŞTUR'));
    await tester.pump();
    expect(
      find.text('KVKK bilgilendirmesini okuyup onaylayın.'),
      findsOneWidget,
    );
  });

  testWidgets('Registration provides a privacy notice summary', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AkdoApp());
    await tester.tap(find.text('MÜŞTERİ OLARAK GİRİŞ YAP'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Üye ol'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('KVKK bilgilendirmesini görüntüle'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('KVKK bilgilendirmesini görüntüle'));
    await tester.pumpAndSettle();
    expect(find.text('KVKK bilgilendirmesi'), findsOneWidget);
    expect(find.text('Bu onay açık rıza yerine geçmez.'), findsOneWidget);
  });

  testWidgets('Administrator sign-in opens the admin login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AkdoApp());
    await tester.tap(find.text('YÖNETİCİ OLARAK GİRİŞ YAP'));
    await tester.pumpAndSettle();

    expect(find.text('Yönetim Merkezi'), findsOneWidget);
    expect(find.text('Kullanıcı adı'), findsOneWidget);
  });

  test('Monochrome theme exposes presentation tokens', () {
    final theme = AkdoAppTheme.light;
    final tokens = theme.extension<AkdoThemeTokens>();

    expect(theme.colorScheme.primary, AkdoAppTheme.accent);
    expect(theme.scaffoldBackgroundColor, AkdoAppTheme.groupedBackground);
    expect(tokens?.cornerRadius, 10);
    expect(tokens?.separator, AkdoAppTheme.separator);
  });

  test('mobile API configuration does not fall back to a local network host', () {
    expect(() => ApiClient.baseUrl, throwsStateError);
  });
}
