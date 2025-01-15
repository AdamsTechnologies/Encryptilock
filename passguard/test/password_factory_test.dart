import 'package:flutter_test/flutter_test.dart';
import 'package:passguard/backend/helpers/password_generator.dart';

void main() {
  group('PasswordFactory Tests', () {
    test('Generates a password of minimum length', () {
      final password = PasswordFactory.generatePassword(minLength: 8, maxLength: 8);
      expect(password.length, equals(8));
    });

    test('Generates a password of maximum length', () {
      final password = PasswordFactory.generatePassword(minLength: 12, maxLength: 20);
      expect(password.length, greaterThanOrEqualTo(12));
      expect(password.length, lessThanOrEqualTo(20));
    });

    test('Generates a password with at least one character from each category', () {
      final password = PasswordFactory.generatePassword(minLength: 8, maxLength: 12);
      final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
      final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
      final hasDigit = RegExp(r'\d').hasMatch(password);
      final hasPunctuation = RegExp(r"[!@#$%^&*()_+\-=\[\]{}|;:\',<>./?]").hasMatch(password);


      expect(hasUppercase, isTrue, reason: 'Password should contain at least one uppercase letter.');
      expect(hasLowercase, isTrue, reason: 'Password should contain at least one lowercase letter.');
      expect(hasDigit, isTrue, reason: 'Password should contain at least one digit.');
      expect(hasPunctuation, isTrue, reason: 'Password should contain at least one punctuation character.');
    });

    test('Excludes specified characters', () {
      final excludeChars = '!@#\$';
      final password = PasswordFactory.generatePassword(
        minLength: 10,
        maxLength: 20,
        excludeChars: excludeChars,
      );

      for (final char in excludeChars.split('')) {
        expect(password.contains(char), isFalse, reason: 'Password should not contain "$char".');
      }
    });

    test('Handles excluding all characters of a specific type gracefully', () {
      final password = PasswordFactory.generatePassword(
        minLength: 8,
        maxLength: 12,
        excludeChars: 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789',
      );

      // Only punctuation characters should remain
      final hasPunctuation = RegExp(r"[!@#$%^&*()_+\-=\[\]{}|;:\',<>./?]").hasMatch(password);

      expect(hasPunctuation, isTrue, reason: 'Password should still generate with only punctuation characters.');
    });
    test('Generates password when only digits remain', () {
      const String uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      const String lowercaseChars = 'abcdefghijklmnopqrstuvwxyz';
      const String punctuationChars = '!@#\$%^&*()_+-=[]{}|;:\'",.<>?/';
      final exclude = uppercaseChars + lowercaseChars + punctuationChars;
      final password = PasswordFactory.generatePassword(minLength: 8, maxLength: 12, excludeChars: exclude);

      final hasDigit = RegExp(r'\d').hasMatch(password);
      expect(hasDigit, isTrue);
      expect(password.length, greaterThanOrEqualTo(8));
    });
    test('Ensures random distribution across multiple generations', () {
      final passwords = List.generate(
        100,
        (_) => PasswordFactory.generatePassword(minLength: 8, maxLength: 12),
      );

      final uniquePasswords = passwords.toSet();
      expect(uniquePasswords.length, equals(passwords.length), reason: 'All passwords should be unique.');
    });
    test('Generates a password when minLength == maxLength == 10', () {
      final password = PasswordFactory.generatePassword(minLength: 10, maxLength: 10);
      expect(password.length, 10);
    });

    test('Throws an error for invalid excludeChars type', () {
      expect(
        () => PasswordFactory.generatePassword(minLength: 8, maxLength: 12, excludeChars: 123),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Handles empty excludeChars gracefully', () {
      final password = PasswordFactory.generatePassword(minLength: 8, maxLength: 12, excludeChars: '');
      expect(password.length, greaterThanOrEqualTo(8));
    });

    test('Handles very short minLength gracefully', () {
      final password = PasswordFactory.generatePassword(minLength: 1, maxLength: 4);
      expect(password.length, equals(4), reason: 'Minimum length should be at least 4.');
    });

    test('Handles very large maxLength (e.g., 200) without error', () {
      final password = PasswordFactory.generatePassword(minLength: 8, maxLength: 200);
      expect(password.length, greaterThanOrEqualTo(8));
      expect(password.length, lessThanOrEqualTo(200));

      // Also ensure at least 1 from each category (if none excluded)
      final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
      final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
      final hasDigit = RegExp(r'\d').hasMatch(password);
      final hasPunctuation = RegExp(r"[!@#$%^&*()_+\-=\[\]{}|;:\',<>./?]").hasMatch(password);

      expect(hasUppercase, isTrue);
      expect(hasLowercase, isTrue);
      expect(hasDigit, isTrue);
      expect(hasPunctuation, isTrue);
    });
  });
}
