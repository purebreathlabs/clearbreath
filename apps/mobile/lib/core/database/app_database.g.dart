// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PreferencesTable extends Preferences
    with TableInfo<$PreferencesTable, Preference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _onboardingCompleteMeta =
      const VerificationMeta('onboardingComplete');
  @override
  late final GeneratedColumn<bool> onboardingComplete = GeneratedColumn<bool>(
    'onboarding_complete',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_complete" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _experienceLevelMeta = const VerificationMeta(
    'experienceLevel',
  );
  @override
  late final GeneratedColumn<String> experienceLevel = GeneratedColumn<String>(
    'experience_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('beginner'),
  );
  static const VerificationMeta _primaryGoalMeta = const VerificationMeta(
    'primaryGoal',
  );
  @override
  late final GeneratedColumn<String> primaryGoal = GeneratedColumn<String>(
    'primary_goal',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('calm'),
  );
  static const VerificationMeta _primaryGoalsJsonMeta = const VerificationMeta(
    'primaryGoalsJson',
  );
  @override
  late final GeneratedColumn<String> primaryGoalsJson = GeneratedColumn<String>(
    'primary_goals_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('["calm"]'),
  );
  static const VerificationMeta _practiceWindowMeta = const VerificationMeta(
    'practiceWindow',
  );
  @override
  late final GeneratedColumn<String> practiceWindow = GeneratedColumn<String>(
    'practice_window',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('morning'),
  );
  static const VerificationMeta _practiceWindowsJsonMeta =
      const VerificationMeta('practiceWindowsJson');
  @override
  late final GeneratedColumn<String> practiceWindowsJson =
      GeneratedColumn<String>(
        'practice_windows_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('["varies"]'),
      );
  static const VerificationMeta _sessionLengthMinutesMeta =
      const VerificationMeta('sessionLengthMinutes');
  @override
  late final GeneratedColumn<int> sessionLengthMinutes = GeneratedColumn<int>(
    'session_length_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _hapticsEnabledMeta = const VerificationMeta(
    'hapticsEnabled',
  );
  @override
  late final GeneratedColumn<bool> hapticsEnabled = GeneratedColumn<bool>(
    'haptics_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("haptics_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _keepScreenAwakeMeta = const VerificationMeta(
    'keepScreenAwake',
  );
  @override
  late final GeneratedColumn<bool> keepScreenAwake = GeneratedColumn<bool>(
    'keep_screen_awake',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("keep_screen_awake" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _reminderTimeMinutesMeta =
      const VerificationMeta('reminderTimeMinutes');
  @override
  late final GeneratedColumn<int> reminderTimeMinutes = GeneratedColumn<int>(
    'reminder_time_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(22 * 60),
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    onboardingComplete,
    experienceLevel,
    primaryGoal,
    primaryGoalsJson,
    practiceWindow,
    practiceWindowsJson,
    sessionLengthMinutes,
    hapticsEnabled,
    keepScreenAwake,
    reminderTimeMinutes,
    displayName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<Preference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('onboarding_complete')) {
      context.handle(
        _onboardingCompleteMeta,
        onboardingComplete.isAcceptableOrUnknown(
          data['onboarding_complete']!,
          _onboardingCompleteMeta,
        ),
      );
    }
    if (data.containsKey('experience_level')) {
      context.handle(
        _experienceLevelMeta,
        experienceLevel.isAcceptableOrUnknown(
          data['experience_level']!,
          _experienceLevelMeta,
        ),
      );
    }
    if (data.containsKey('primary_goal')) {
      context.handle(
        _primaryGoalMeta,
        primaryGoal.isAcceptableOrUnknown(
          data['primary_goal']!,
          _primaryGoalMeta,
        ),
      );
    }
    if (data.containsKey('primary_goals_json')) {
      context.handle(
        _primaryGoalsJsonMeta,
        primaryGoalsJson.isAcceptableOrUnknown(
          data['primary_goals_json']!,
          _primaryGoalsJsonMeta,
        ),
      );
    }
    if (data.containsKey('practice_window')) {
      context.handle(
        _practiceWindowMeta,
        practiceWindow.isAcceptableOrUnknown(
          data['practice_window']!,
          _practiceWindowMeta,
        ),
      );
    }
    if (data.containsKey('practice_windows_json')) {
      context.handle(
        _practiceWindowsJsonMeta,
        practiceWindowsJson.isAcceptableOrUnknown(
          data['practice_windows_json']!,
          _practiceWindowsJsonMeta,
        ),
      );
    }
    if (data.containsKey('session_length_minutes')) {
      context.handle(
        _sessionLengthMinutesMeta,
        sessionLengthMinutes.isAcceptableOrUnknown(
          data['session_length_minutes']!,
          _sessionLengthMinutesMeta,
        ),
      );
    }
    if (data.containsKey('haptics_enabled')) {
      context.handle(
        _hapticsEnabledMeta,
        hapticsEnabled.isAcceptableOrUnknown(
          data['haptics_enabled']!,
          _hapticsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('keep_screen_awake')) {
      context.handle(
        _keepScreenAwakeMeta,
        keepScreenAwake.isAcceptableOrUnknown(
          data['keep_screen_awake']!,
          _keepScreenAwakeMeta,
        ),
      );
    }
    if (data.containsKey('reminder_time_minutes')) {
      context.handle(
        _reminderTimeMinutesMeta,
        reminderTimeMinutes.isAcceptableOrUnknown(
          data['reminder_time_minutes']!,
          _reminderTimeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Preference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Preference(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      onboardingComplete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_complete'],
      )!,
      experienceLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}experience_level'],
      )!,
      primaryGoal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_goal'],
      )!,
      primaryGoalsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_goals_json'],
      )!,
      practiceWindow: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}practice_window'],
      )!,
      practiceWindowsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}practice_windows_json'],
      )!,
      sessionLengthMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_length_minutes'],
      )!,
      hapticsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}haptics_enabled'],
      )!,
      keepScreenAwake: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}keep_screen_awake'],
      )!,
      reminderTimeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_time_minutes'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
    );
  }

  @override
  $PreferencesTable createAlias(String alias) {
    return $PreferencesTable(attachedDatabase, alias);
  }
}

class Preference extends DataClass implements Insertable<Preference> {
  final int id;
  final bool onboardingComplete;
  final String experienceLevel;
  final String primaryGoal;
  final String primaryGoalsJson;
  final String practiceWindow;
  final String practiceWindowsJson;
  final int sessionLengthMinutes;
  final bool hapticsEnabled;
  final bool keepScreenAwake;
  final int reminderTimeMinutes;
  final String displayName;
  const Preference({
    required this.id,
    required this.onboardingComplete,
    required this.experienceLevel,
    required this.primaryGoal,
    required this.primaryGoalsJson,
    required this.practiceWindow,
    required this.practiceWindowsJson,
    required this.sessionLengthMinutes,
    required this.hapticsEnabled,
    required this.keepScreenAwake,
    required this.reminderTimeMinutes,
    required this.displayName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['onboarding_complete'] = Variable<bool>(onboardingComplete);
    map['experience_level'] = Variable<String>(experienceLevel);
    map['primary_goal'] = Variable<String>(primaryGoal);
    map['primary_goals_json'] = Variable<String>(primaryGoalsJson);
    map['practice_window'] = Variable<String>(practiceWindow);
    map['practice_windows_json'] = Variable<String>(practiceWindowsJson);
    map['session_length_minutes'] = Variable<int>(sessionLengthMinutes);
    map['haptics_enabled'] = Variable<bool>(hapticsEnabled);
    map['keep_screen_awake'] = Variable<bool>(keepScreenAwake);
    map['reminder_time_minutes'] = Variable<int>(reminderTimeMinutes);
    map['display_name'] = Variable<String>(displayName);
    return map;
  }

  PreferencesCompanion toCompanion(bool nullToAbsent) {
    return PreferencesCompanion(
      id: Value(id),
      onboardingComplete: Value(onboardingComplete),
      experienceLevel: Value(experienceLevel),
      primaryGoal: Value(primaryGoal),
      primaryGoalsJson: Value(primaryGoalsJson),
      practiceWindow: Value(practiceWindow),
      practiceWindowsJson: Value(practiceWindowsJson),
      sessionLengthMinutes: Value(sessionLengthMinutes),
      hapticsEnabled: Value(hapticsEnabled),
      keepScreenAwake: Value(keepScreenAwake),
      reminderTimeMinutes: Value(reminderTimeMinutes),
      displayName: Value(displayName),
    );
  }

  factory Preference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Preference(
      id: serializer.fromJson<int>(json['id']),
      onboardingComplete: serializer.fromJson<bool>(json['onboardingComplete']),
      experienceLevel: serializer.fromJson<String>(json['experienceLevel']),
      primaryGoal: serializer.fromJson<String>(json['primaryGoal']),
      primaryGoalsJson: serializer.fromJson<String>(json['primaryGoalsJson']),
      practiceWindow: serializer.fromJson<String>(json['practiceWindow']),
      practiceWindowsJson: serializer.fromJson<String>(
        json['practiceWindowsJson'],
      ),
      sessionLengthMinutes: serializer.fromJson<int>(
        json['sessionLengthMinutes'],
      ),
      hapticsEnabled: serializer.fromJson<bool>(json['hapticsEnabled']),
      keepScreenAwake: serializer.fromJson<bool>(json['keepScreenAwake']),
      reminderTimeMinutes: serializer.fromJson<int>(
        json['reminderTimeMinutes'],
      ),
      displayName: serializer.fromJson<String>(json['displayName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'onboardingComplete': serializer.toJson<bool>(onboardingComplete),
      'experienceLevel': serializer.toJson<String>(experienceLevel),
      'primaryGoal': serializer.toJson<String>(primaryGoal),
      'primaryGoalsJson': serializer.toJson<String>(primaryGoalsJson),
      'practiceWindow': serializer.toJson<String>(practiceWindow),
      'practiceWindowsJson': serializer.toJson<String>(practiceWindowsJson),
      'sessionLengthMinutes': serializer.toJson<int>(sessionLengthMinutes),
      'hapticsEnabled': serializer.toJson<bool>(hapticsEnabled),
      'keepScreenAwake': serializer.toJson<bool>(keepScreenAwake),
      'reminderTimeMinutes': serializer.toJson<int>(reminderTimeMinutes),
      'displayName': serializer.toJson<String>(displayName),
    };
  }

  Preference copyWith({
    int? id,
    bool? onboardingComplete,
    String? experienceLevel,
    String? primaryGoal,
    String? primaryGoalsJson,
    String? practiceWindow,
    String? practiceWindowsJson,
    int? sessionLengthMinutes,
    bool? hapticsEnabled,
    bool? keepScreenAwake,
    int? reminderTimeMinutes,
    String? displayName,
  }) => Preference(
    id: id ?? this.id,
    onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    experienceLevel: experienceLevel ?? this.experienceLevel,
    primaryGoal: primaryGoal ?? this.primaryGoal,
    primaryGoalsJson: primaryGoalsJson ?? this.primaryGoalsJson,
    practiceWindow: practiceWindow ?? this.practiceWindow,
    practiceWindowsJson: practiceWindowsJson ?? this.practiceWindowsJson,
    sessionLengthMinutes: sessionLengthMinutes ?? this.sessionLengthMinutes,
    hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
    reminderTimeMinutes: reminderTimeMinutes ?? this.reminderTimeMinutes,
    displayName: displayName ?? this.displayName,
  );
  Preference copyWithCompanion(PreferencesCompanion data) {
    return Preference(
      id: data.id.present ? data.id.value : this.id,
      onboardingComplete: data.onboardingComplete.present
          ? data.onboardingComplete.value
          : this.onboardingComplete,
      experienceLevel: data.experienceLevel.present
          ? data.experienceLevel.value
          : this.experienceLevel,
      primaryGoal: data.primaryGoal.present
          ? data.primaryGoal.value
          : this.primaryGoal,
      primaryGoalsJson: data.primaryGoalsJson.present
          ? data.primaryGoalsJson.value
          : this.primaryGoalsJson,
      practiceWindow: data.practiceWindow.present
          ? data.practiceWindow.value
          : this.practiceWindow,
      practiceWindowsJson: data.practiceWindowsJson.present
          ? data.practiceWindowsJson.value
          : this.practiceWindowsJson,
      sessionLengthMinutes: data.sessionLengthMinutes.present
          ? data.sessionLengthMinutes.value
          : this.sessionLengthMinutes,
      hapticsEnabled: data.hapticsEnabled.present
          ? data.hapticsEnabled.value
          : this.hapticsEnabled,
      keepScreenAwake: data.keepScreenAwake.present
          ? data.keepScreenAwake.value
          : this.keepScreenAwake,
      reminderTimeMinutes: data.reminderTimeMinutes.present
          ? data.reminderTimeMinutes.value
          : this.reminderTimeMinutes,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Preference(')
          ..write('id: $id, ')
          ..write('onboardingComplete: $onboardingComplete, ')
          ..write('experienceLevel: $experienceLevel, ')
          ..write('primaryGoal: $primaryGoal, ')
          ..write('primaryGoalsJson: $primaryGoalsJson, ')
          ..write('practiceWindow: $practiceWindow, ')
          ..write('practiceWindowsJson: $practiceWindowsJson, ')
          ..write('sessionLengthMinutes: $sessionLengthMinutes, ')
          ..write('hapticsEnabled: $hapticsEnabled, ')
          ..write('keepScreenAwake: $keepScreenAwake, ')
          ..write('reminderTimeMinutes: $reminderTimeMinutes, ')
          ..write('displayName: $displayName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    onboardingComplete,
    experienceLevel,
    primaryGoal,
    primaryGoalsJson,
    practiceWindow,
    practiceWindowsJson,
    sessionLengthMinutes,
    hapticsEnabled,
    keepScreenAwake,
    reminderTimeMinutes,
    displayName,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Preference &&
          other.id == this.id &&
          other.onboardingComplete == this.onboardingComplete &&
          other.experienceLevel == this.experienceLevel &&
          other.primaryGoal == this.primaryGoal &&
          other.primaryGoalsJson == this.primaryGoalsJson &&
          other.practiceWindow == this.practiceWindow &&
          other.practiceWindowsJson == this.practiceWindowsJson &&
          other.sessionLengthMinutes == this.sessionLengthMinutes &&
          other.hapticsEnabled == this.hapticsEnabled &&
          other.keepScreenAwake == this.keepScreenAwake &&
          other.reminderTimeMinutes == this.reminderTimeMinutes &&
          other.displayName == this.displayName);
}

class PreferencesCompanion extends UpdateCompanion<Preference> {
  final Value<int> id;
  final Value<bool> onboardingComplete;
  final Value<String> experienceLevel;
  final Value<String> primaryGoal;
  final Value<String> primaryGoalsJson;
  final Value<String> practiceWindow;
  final Value<String> practiceWindowsJson;
  final Value<int> sessionLengthMinutes;
  final Value<bool> hapticsEnabled;
  final Value<bool> keepScreenAwake;
  final Value<int> reminderTimeMinutes;
  final Value<String> displayName;
  const PreferencesCompanion({
    this.id = const Value.absent(),
    this.onboardingComplete = const Value.absent(),
    this.experienceLevel = const Value.absent(),
    this.primaryGoal = const Value.absent(),
    this.primaryGoalsJson = const Value.absent(),
    this.practiceWindow = const Value.absent(),
    this.practiceWindowsJson = const Value.absent(),
    this.sessionLengthMinutes = const Value.absent(),
    this.hapticsEnabled = const Value.absent(),
    this.keepScreenAwake = const Value.absent(),
    this.reminderTimeMinutes = const Value.absent(),
    this.displayName = const Value.absent(),
  });
  PreferencesCompanion.insert({
    this.id = const Value.absent(),
    this.onboardingComplete = const Value.absent(),
    this.experienceLevel = const Value.absent(),
    this.primaryGoal = const Value.absent(),
    this.primaryGoalsJson = const Value.absent(),
    this.practiceWindow = const Value.absent(),
    this.practiceWindowsJson = const Value.absent(),
    this.sessionLengthMinutes = const Value.absent(),
    this.hapticsEnabled = const Value.absent(),
    this.keepScreenAwake = const Value.absent(),
    this.reminderTimeMinutes = const Value.absent(),
    this.displayName = const Value.absent(),
  });
  static Insertable<Preference> custom({
    Expression<int>? id,
    Expression<bool>? onboardingComplete,
    Expression<String>? experienceLevel,
    Expression<String>? primaryGoal,
    Expression<String>? primaryGoalsJson,
    Expression<String>? practiceWindow,
    Expression<String>? practiceWindowsJson,
    Expression<int>? sessionLengthMinutes,
    Expression<bool>? hapticsEnabled,
    Expression<bool>? keepScreenAwake,
    Expression<int>? reminderTimeMinutes,
    Expression<String>? displayName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (onboardingComplete != null) 'onboarding_complete': onboardingComplete,
      if (experienceLevel != null) 'experience_level': experienceLevel,
      if (primaryGoal != null) 'primary_goal': primaryGoal,
      if (primaryGoalsJson != null) 'primary_goals_json': primaryGoalsJson,
      if (practiceWindow != null) 'practice_window': practiceWindow,
      if (practiceWindowsJson != null)
        'practice_windows_json': practiceWindowsJson,
      if (sessionLengthMinutes != null)
        'session_length_minutes': sessionLengthMinutes,
      if (hapticsEnabled != null) 'haptics_enabled': hapticsEnabled,
      if (keepScreenAwake != null) 'keep_screen_awake': keepScreenAwake,
      if (reminderTimeMinutes != null)
        'reminder_time_minutes': reminderTimeMinutes,
      if (displayName != null) 'display_name': displayName,
    });
  }

  PreferencesCompanion copyWith({
    Value<int>? id,
    Value<bool>? onboardingComplete,
    Value<String>? experienceLevel,
    Value<String>? primaryGoal,
    Value<String>? primaryGoalsJson,
    Value<String>? practiceWindow,
    Value<String>? practiceWindowsJson,
    Value<int>? sessionLengthMinutes,
    Value<bool>? hapticsEnabled,
    Value<bool>? keepScreenAwake,
    Value<int>? reminderTimeMinutes,
    Value<String>? displayName,
  }) {
    return PreferencesCompanion(
      id: id ?? this.id,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      primaryGoalsJson: primaryGoalsJson ?? this.primaryGoalsJson,
      practiceWindow: practiceWindow ?? this.practiceWindow,
      practiceWindowsJson: practiceWindowsJson ?? this.practiceWindowsJson,
      sessionLengthMinutes: sessionLengthMinutes ?? this.sessionLengthMinutes,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
      reminderTimeMinutes: reminderTimeMinutes ?? this.reminderTimeMinutes,
      displayName: displayName ?? this.displayName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (onboardingComplete.present) {
      map['onboarding_complete'] = Variable<bool>(onboardingComplete.value);
    }
    if (experienceLevel.present) {
      map['experience_level'] = Variable<String>(experienceLevel.value);
    }
    if (primaryGoal.present) {
      map['primary_goal'] = Variable<String>(primaryGoal.value);
    }
    if (primaryGoalsJson.present) {
      map['primary_goals_json'] = Variable<String>(primaryGoalsJson.value);
    }
    if (practiceWindow.present) {
      map['practice_window'] = Variable<String>(practiceWindow.value);
    }
    if (practiceWindowsJson.present) {
      map['practice_windows_json'] = Variable<String>(
        practiceWindowsJson.value,
      );
    }
    if (sessionLengthMinutes.present) {
      map['session_length_minutes'] = Variable<int>(sessionLengthMinutes.value);
    }
    if (hapticsEnabled.present) {
      map['haptics_enabled'] = Variable<bool>(hapticsEnabled.value);
    }
    if (keepScreenAwake.present) {
      map['keep_screen_awake'] = Variable<bool>(keepScreenAwake.value);
    }
    if (reminderTimeMinutes.present) {
      map['reminder_time_minutes'] = Variable<int>(reminderTimeMinutes.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreferencesCompanion(')
          ..write('id: $id, ')
          ..write('onboardingComplete: $onboardingComplete, ')
          ..write('experienceLevel: $experienceLevel, ')
          ..write('primaryGoal: $primaryGoal, ')
          ..write('primaryGoalsJson: $primaryGoalsJson, ')
          ..write('practiceWindow: $practiceWindow, ')
          ..write('practiceWindowsJson: $practiceWindowsJson, ')
          ..write('sessionLengthMinutes: $sessionLengthMinutes, ')
          ..write('hapticsEnabled: $hapticsEnabled, ')
          ..write('keepScreenAwake: $keepScreenAwake, ')
          ..write('reminderTimeMinutes: $reminderTimeMinutes, ')
          ..write('displayName: $displayName')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PreferencesTable preferences = $PreferencesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [preferences];
}

typedef $$PreferencesTableCreateCompanionBuilder =
    PreferencesCompanion Function({
      Value<int> id,
      Value<bool> onboardingComplete,
      Value<String> experienceLevel,
      Value<String> primaryGoal,
      Value<String> primaryGoalsJson,
      Value<String> practiceWindow,
      Value<String> practiceWindowsJson,
      Value<int> sessionLengthMinutes,
      Value<bool> hapticsEnabled,
      Value<bool> keepScreenAwake,
      Value<int> reminderTimeMinutes,
      Value<String> displayName,
    });
typedef $$PreferencesTableUpdateCompanionBuilder =
    PreferencesCompanion Function({
      Value<int> id,
      Value<bool> onboardingComplete,
      Value<String> experienceLevel,
      Value<String> primaryGoal,
      Value<String> primaryGoalsJson,
      Value<String> practiceWindow,
      Value<String> practiceWindowsJson,
      Value<int> sessionLengthMinutes,
      Value<bool> hapticsEnabled,
      Value<bool> keepScreenAwake,
      Value<int> reminderTimeMinutes,
      Value<String> displayName,
    });

class $$PreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $PreferencesTable> {
  $$PreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboardingComplete => $composableBuilder(
    column: $table.onboardingComplete,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get experienceLevel => $composableBuilder(
    column: $table.experienceLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryGoal => $composableBuilder(
    column: $table.primaryGoal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryGoalsJson => $composableBuilder(
    column: $table.primaryGoalsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get practiceWindow => $composableBuilder(
    column: $table.practiceWindow,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get practiceWindowsJson => $composableBuilder(
    column: $table.practiceWindowsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionLengthMinutes => $composableBuilder(
    column: $table.sessionLengthMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hapticsEnabled => $composableBuilder(
    column: $table.hapticsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get keepScreenAwake => $composableBuilder(
    column: $table.keepScreenAwake,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderTimeMinutes => $composableBuilder(
    column: $table.reminderTimeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $PreferencesTable> {
  $$PreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboardingComplete => $composableBuilder(
    column: $table.onboardingComplete,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get experienceLevel => $composableBuilder(
    column: $table.experienceLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryGoal => $composableBuilder(
    column: $table.primaryGoal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryGoalsJson => $composableBuilder(
    column: $table.primaryGoalsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get practiceWindow => $composableBuilder(
    column: $table.practiceWindow,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get practiceWindowsJson => $composableBuilder(
    column: $table.practiceWindowsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionLengthMinutes => $composableBuilder(
    column: $table.sessionLengthMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hapticsEnabled => $composableBuilder(
    column: $table.hapticsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get keepScreenAwake => $composableBuilder(
    column: $table.keepScreenAwake,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderTimeMinutes => $composableBuilder(
    column: $table.reminderTimeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PreferencesTable> {
  $$PreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get onboardingComplete => $composableBuilder(
    column: $table.onboardingComplete,
    builder: (column) => column,
  );

  GeneratedColumn<String> get experienceLevel => $composableBuilder(
    column: $table.experienceLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get primaryGoal => $composableBuilder(
    column: $table.primaryGoal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get primaryGoalsJson => $composableBuilder(
    column: $table.primaryGoalsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get practiceWindow => $composableBuilder(
    column: $table.practiceWindow,
    builder: (column) => column,
  );

  GeneratedColumn<String> get practiceWindowsJson => $composableBuilder(
    column: $table.practiceWindowsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sessionLengthMinutes => $composableBuilder(
    column: $table.sessionLengthMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hapticsEnabled => $composableBuilder(
    column: $table.hapticsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get keepScreenAwake => $composableBuilder(
    column: $table.keepScreenAwake,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderTimeMinutes => $composableBuilder(
    column: $table.reminderTimeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );
}

class $$PreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PreferencesTable,
          Preference,
          $$PreferencesTableFilterComposer,
          $$PreferencesTableOrderingComposer,
          $$PreferencesTableAnnotationComposer,
          $$PreferencesTableCreateCompanionBuilder,
          $$PreferencesTableUpdateCompanionBuilder,
          (
            Preference,
            BaseReferences<_$AppDatabase, $PreferencesTable, Preference>,
          ),
          Preference,
          PrefetchHooks Function()
        > {
  $$PreferencesTableTableManager(_$AppDatabase db, $PreferencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> onboardingComplete = const Value.absent(),
                Value<String> experienceLevel = const Value.absent(),
                Value<String> primaryGoal = const Value.absent(),
                Value<String> primaryGoalsJson = const Value.absent(),
                Value<String> practiceWindow = const Value.absent(),
                Value<String> practiceWindowsJson = const Value.absent(),
                Value<int> sessionLengthMinutes = const Value.absent(),
                Value<bool> hapticsEnabled = const Value.absent(),
                Value<bool> keepScreenAwake = const Value.absent(),
                Value<int> reminderTimeMinutes = const Value.absent(),
                Value<String> displayName = const Value.absent(),
              }) => PreferencesCompanion(
                id: id,
                onboardingComplete: onboardingComplete,
                experienceLevel: experienceLevel,
                primaryGoal: primaryGoal,
                primaryGoalsJson: primaryGoalsJson,
                practiceWindow: practiceWindow,
                practiceWindowsJson: practiceWindowsJson,
                sessionLengthMinutes: sessionLengthMinutes,
                hapticsEnabled: hapticsEnabled,
                keepScreenAwake: keepScreenAwake,
                reminderTimeMinutes: reminderTimeMinutes,
                displayName: displayName,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> onboardingComplete = const Value.absent(),
                Value<String> experienceLevel = const Value.absent(),
                Value<String> primaryGoal = const Value.absent(),
                Value<String> primaryGoalsJson = const Value.absent(),
                Value<String> practiceWindow = const Value.absent(),
                Value<String> practiceWindowsJson = const Value.absent(),
                Value<int> sessionLengthMinutes = const Value.absent(),
                Value<bool> hapticsEnabled = const Value.absent(),
                Value<bool> keepScreenAwake = const Value.absent(),
                Value<int> reminderTimeMinutes = const Value.absent(),
                Value<String> displayName = const Value.absent(),
              }) => PreferencesCompanion.insert(
                id: id,
                onboardingComplete: onboardingComplete,
                experienceLevel: experienceLevel,
                primaryGoal: primaryGoal,
                primaryGoalsJson: primaryGoalsJson,
                practiceWindow: practiceWindow,
                practiceWindowsJson: practiceWindowsJson,
                sessionLengthMinutes: sessionLengthMinutes,
                hapticsEnabled: hapticsEnabled,
                keepScreenAwake: keepScreenAwake,
                reminderTimeMinutes: reminderTimeMinutes,
                displayName: displayName,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PreferencesTable,
      Preference,
      $$PreferencesTableFilterComposer,
      $$PreferencesTableOrderingComposer,
      $$PreferencesTableAnnotationComposer,
      $$PreferencesTableCreateCompanionBuilder,
      $$PreferencesTableUpdateCompanionBuilder,
      (
        Preference,
        BaseReferences<_$AppDatabase, $PreferencesTable, Preference>,
      ),
      Preference,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PreferencesTableTableManager get preferences =>
      $$PreferencesTableTableManager(_db, _db.preferences);
}
