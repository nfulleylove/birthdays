extension ForenamePossessive on String {
  /// Returns the possessive form of a forename:
  /// - "James"  → "James'"
  /// - "Alice"  → "Alice's"
  /// - ""       → ""
  String toPossessive() {
    if (isEmpty) return this;

    final lower = toLowerCase();

    // Append '
    if (lower.endsWith('s')) return '$this\'';

    // Else append 's
    return '$this\'s';
  }
}
