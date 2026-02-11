import 'dart:math';

class PasswordFactory {
  static const String _uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _lowercaseChars = 'abcdefghijklmnopqrstuvwxyz';
  static const String _digitChars = '0123456789';
  static const String _punctuationChars = '!@#\$%^&*()_+\-=[]{}|;:\'",.<>?/';

  /// Removes excluded chars from each category, returning a map.
  /// If everything is excluded, the "allChars" string ends up empty as well.
  static Map<String, String> _getChars({List<String>? excludeChars}) {
    final exclude = excludeChars?.join() ?? '';
    // Helper
    String removeExcluded(String chars) {
      // e.g. '[$exclude]' means “any of these chars is removed”
      return chars.replaceAll(RegExp('[$exclude]'), '');
    }

    final uppercase = removeExcluded(_uppercaseChars);
    final lowercase = removeExcluded(_lowercaseChars);
    final digits = removeExcluded(_digitChars);
    final punctuation = removeExcluded(_punctuationChars);

    return {
      'uppercaseChars': uppercase,
      'lowercaseChars': lowercase,
      'digitChars': digits,
      'punctuationChars': punctuation,
      'allChars': uppercase + lowercase + digits + punctuation,
    };
  }

  /// Distributes lengths among non-empty sets, ensuring each set gets at least 1 char.
  /// Throws if all sets are empty or if maxLength < numberOfNonEmptyCategories.
  static Map<String, int> _getRandomCharLengths({
    required int minLength,
    required int maxLength,
    required Map<String, String> chars,
  }) {
    final random = Random.secure();

    // Guarantee minLength >= 4
    minLength = max(4, minLength);
    maxLength = max(minLength, maxLength);

    // Identify which categories are non-empty
    final availableCategories = <String>[];
    if (chars['uppercaseChars']!.isNotEmpty) availableCategories.add('uppercase');
    if (chars['lowercaseChars']!.isNotEmpty) availableCategories.add('lowercase');
    if (chars['digitChars']!.isNotEmpty) availableCategories.add('digits');
    if (chars['punctuationChars']!.isNotEmpty) availableCategories.add('punctuation');

    // If user excluded all sets => all are empty
    if (availableCategories.isEmpty) {
      throw StateError('No character sets available after exclusions!');
    }

    // If we have 4 sets but maxLength=3 => can't place 1 char from each
    if (availableCategories.length > maxLength) {
      throw StateError(
        'maxLength too small for one char each from ${availableCategories.length} non-empty sets.',
      );
    }

    // Give each non-empty category 1 char
    final lengthMap = <String, int>{
      'uppercase': 0,
      'lowercase': 0,
      'digits': 0,
      'punctuation': 0,
    };
    for (final cat in availableCategories) {
      lengthMap[cat] = 1;
    }

    // Distribute remaining among those sets
    var remaining = maxLength - availableCategories.length;
    while (remaining > 0) {
      final cat = availableCategories[random.nextInt(availableCategories.length)];
      lengthMap[cat] = lengthMap[cat]! + 1;
      remaining--;
    }

    return {
      'lengthUppercase': lengthMap['uppercase']!,
      'lengthLowercase': lengthMap['lowercase']!,
      'lengthDigits': lengthMap['digits']!,
      'lengthPunctuation': lengthMap['punctuation']!,
      'maxLength': maxLength,
    };
  }

  /// Validates the [excludeChars] argument, accepting a string or List<String>.
  static List<String> validateExcludeChars(dynamic excludeChars) {
    if (excludeChars is String) {
      return excludeChars.split('').toSet().toList();
    } else if (excludeChars is List<String>) {
      return excludeChars.toSet().toList();
    } else {
      throw ArgumentError(
          'Exclude chars must be a String or List<String>. Received ${excludeChars.runtimeType}');
    }
  }

  /// Generates a password, ensuring at least one char from each non-empty set.
  /// If user excludes everything => throws [StateError].
  /// If maxLength < # of non-empty categories => also throws [StateError].
  static String generatePassword({
    int minLength = 4,
    int maxLength = 20,
    dynamic excludeChars,
  }) {
    // Normalize exclusions
    List<String>? exclusions;
    if (excludeChars != null) {
      exclusions = validateExcludeChars(excludeChars);
    }

    // Build character sets
    final chars = _getChars(excludeChars: exclusions);

    // Decide how many chars each set gets
    final charLengths = _getRandomCharLengths(
      minLength: minLength,
      maxLength: maxLength,
      chars: chars,
    );

    final random = Random.secure();

    // Helper
    String generateChars(String source, int count) {
      if (count <= 0 || source.isEmpty) return '';
      return List.generate(
        count,
        (_) => source[random.nextInt(source.length)],
      ).join('');
    }

    final uppercase = generateChars(chars['uppercaseChars']!, charLengths['lengthUppercase']!);
    final lowercase = generateChars(chars['lowercaseChars']!, charLengths['lengthLowercase']!);
    final digits = generateChars(chars['digitChars']!, charLengths['lengthDigits']!);
    final punctuation = generateChars(chars['punctuationChars']!, charLengths['lengthPunctuation']!);

    var password = uppercase + lowercase + digits + punctuation;

    // Fill leftover (if any) from the combined set
    final totalAssigned = password.length;
    final needed = charLengths['maxLength']! - totalAssigned;
    if (needed > 0 && chars['allChars']!.isNotEmpty) {
      password += generateChars(chars['allChars']!, needed);
    }

    // Shuffle
    final passwordChars = password.split('');
    passwordChars.shuffle(random);
    return passwordChars.join('');
  }
}

