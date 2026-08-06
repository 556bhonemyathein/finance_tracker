import 'package:isar_community/isar.dart';

import '../../../shared/models/app_user.dart';

part 'user_entity.g.dart';

/// Isar row for an account.
///
/// [passwordHash] exists only for the local backend simulator used in dev
/// builds; against a real API the field stays empty because credentials never
/// touch the device.
@collection
class UserEntity {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uid;

  late String name;

  @Index(unique: true, replace: true, caseSensitive: false)
  late String email;

  String? avatarUrl;

  late String currencyCode;

  late String languageCode;

  late double monthlyBudget;

  late DateTime createdAt;

  /// SHA-256(password + salt). Never the password itself.
  String passwordHash = '';

  String passwordSalt = '';

  /// Marks the row whose session is currently active — survives app restarts
  /// and is what makes auto-login possible without hitting the network.
  @Index()
  bool isCurrent = false;

  AppUser toDomain() => AppUser(
    id: uid,
    name: name,
    email: email,
    avatarUrl: avatarUrl,
    currencyCode: currencyCode,
    languageCode: languageCode,
    monthlyBudget: monthlyBudget,
    createdAt: createdAt,
  );
}

extension UserEntityX on AppUser {
  UserEntity toEntity({
    int? isarId,
    String passwordHash = '',
    String passwordSalt = '',
    bool isCurrent = true,
  }) {
    return UserEntity()
      ..isarId = isarId ?? Isar.autoIncrement
      ..uid = id
      ..name = name
      ..email = email
      ..avatarUrl = avatarUrl
      ..currencyCode = currencyCode
      ..languageCode = languageCode
      ..monthlyBudget = monthlyBudget
      ..createdAt = createdAt ?? DateTime.now()
      ..passwordHash = passwordHash
      ..passwordSalt = passwordSalt
      ..isCurrent = isCurrent;
  }
}
