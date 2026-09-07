import 'package:flutter/material.dart';

/// The closed set of icons a category can carry.
///
/// Categories persist their icon as a code point (see `Category.iconCodePoint`)
/// so the model stays serialisable. Turning that code point back into an
/// [IconData] must not call the `IconData` constructor at runtime: the icon
/// tree-shaker cannot analyse a non-constant invocation and fails the release
/// build. Instead every offered icon is a compile-time constant here, and
/// [resolve] is a lookup — which keeps `flutter build --release` tree-shaking
/// the MaterialIcons font as normal.
///
/// Adding an icon to [pickerIcons] is all that is needed to offer it; a code
/// point that is not in the catalogue (legacy or synced-in data) falls back to
/// [fallback] rather than rendering a missing glyph.
abstract final class CategoryIcons {
  /// Icons offered by the category icon picker.
  static const List<IconData> pickerIcons = <IconData>[
    Icons.restaurant_rounded,
    Icons.local_cafe_outlined,
    Icons.local_grocery_store_outlined,
    Icons.shopping_bag_outlined,
    Icons.directions_bus_filled_outlined,
    Icons.local_gas_station_outlined,
    Icons.directions_car_outlined,
    Icons.flight_takeoff_rounded,
    Icons.home_outlined,
    Icons.bed_outlined,
    Icons.receipt_long_outlined,
    Icons.bolt_outlined,
    Icons.wifi_rounded,
    Icons.phone_iphone_rounded,
    Icons.favorite_outline_rounded,
    Icons.fitness_center_rounded,
    Icons.medical_services_outlined,
    Icons.school_outlined,
    Icons.menu_book_outlined,
    Icons.movie_outlined,
    Icons.sports_esports_outlined,
    Icons.music_note_outlined,
    Icons.pets_outlined,
    Icons.child_care_outlined,
    Icons.card_giftcard_rounded,
    Icons.payments_outlined,
    Icons.savings_outlined,
    Icons.trending_up_rounded,
    Icons.laptop_mac_outlined,
    Icons.work_outline_rounded,
    Icons.build_outlined,
    Icons.more_horiz_rounded,
  ];

  /// Shown for a category whose stored code point is not in the catalogue.
  static const IconData fallback = Icons.help_outline;

  static final Map<int, IconData> _byCodePoint = <int, IconData>{
    for (final IconData icon in pickerIcons) icon.codePoint: icon,
    fallback.codePoint: fallback,
  };

  /// Resolves a stored code point to its constant [IconData].
  static IconData resolve(int codePoint) =>
      _byCodePoint[codePoint] ?? fallback;
}
