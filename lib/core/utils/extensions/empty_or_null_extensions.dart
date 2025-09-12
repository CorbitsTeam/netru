//! Empty or Null Extensions

// for String
extension NullableStringExtension on String? {
  bool isEmptyOrNull() => this == null || this!.isEmpty;
}

// extension NullableListExtension<T> on List<T>? {
//   bool isEmptyOrNull() => this == null || this!.isEmpty;
// }

// extension NullableSetExtension<T> on Set<T>? {
//   bool isEmptyOrNull() => this == null || this!.isEmpty;
// }


// for Map 
extension NullableMapExtension<K, V> on Map<K, V>? {
  bool isEmptyOrNull() => this == null || this!.isEmpty;
}
// for List and Set
extension NullableCollectionExtension<T> on Iterable<T>? {
  bool isEmptyOrNull() => this == null || this!.isEmpty;
}
