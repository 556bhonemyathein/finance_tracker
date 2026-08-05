/// String helpers shared by validators, avatars and search.
extension StringX on String {
  bool get isBlank => trim().isEmpty;

  bool get isNotBlank => trim().isNotEmpty;

  /// `ada lovelace` → `Ada lovelace`
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// `ada lovelace` → `Ada Lovelace`
  String get titleCased => split(' ')
      .where((String w) => w.isNotEmpty)
      .map((String w) => w.capitalized)
      .join(' ');

  /// `Ada Lovelace` → `AL`. Fallback content for the profile avatar.
  String get initials {
    final List<String> parts =
        trim().split(RegExp(r'\s+')).where((String p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters1.toUpperCase();
    return '${parts.first.characters1}${parts.last.characters1}'.toUpperCase();
  }

  String get characters1 => isEmpty ? '' : substring(0, 1);

  bool get isValidEmail => RegExp(
    r'^[\w.!#$%&’*+/=?^`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
    r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$',
  ).hasMatch(trim());

  /// At least 8 chars, one letter and one digit — mirrors the API rule.
  bool get isStrongPassword =>
      length >= 8 && RegExp(r'[A-Za-z]').hasMatch(this) &&
      RegExp(r'\d').hasMatch(this);

  /// Diacritic- and case-insensitive `contains`, used by realtime search.
  bool containsIgnoreCase(String query) =>
      toLowerCase().contains(query.toLowerCase().trim());

  /// Truncates with an ellipsis, never cutting mid-word when avoidable.
  String truncate(int max) {
    if (length <= max) return this;
    final String cut = substring(0, max);
    final int lastSpace = cut.lastIndexOf(' ');
    return '${lastSpace > max * 0.6 ? cut.substring(0, lastSpace) : cut}…';
  }

  /// Parses `#RRGGBB` / `RRGGBB` / `AARRGGBB` into an ARGB int for categories.
  int? get toColorValue {
    final String hex = replaceFirst('#', '').trim();
    if (hex.length != 6 && hex.length != 8) return null;
    return int.tryParse(hex.length == 6 ? 'FF$hex' : hex, radix: 16);
  }
}

extension NullableStringX on String? {
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;

  String orEmpty() => this ?? '';
}
