enum Casing { none, title, upper, lower, capitalize }

String applyCasing(String text, Casing casing) {
  if (text.isEmpty) {
    return text;
  }
  switch (casing) {
    case Casing.upper:
      return text.toUpperCase();
    case Casing.lower:
      return text.toLowerCase();
    case Casing.title:
      return text
          .split(' ')
          .map((word) => word.isNotEmpty
              ? word[0].toUpperCase() + word.substring(1).toLowerCase()
              : '')
          .join(' ');
    case Casing.capitalize:
      return text[0].toUpperCase() + text.substring(1).toLowerCase();
    case Casing.none:
      return text;
  }
}
