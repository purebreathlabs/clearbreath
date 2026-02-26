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
  static const VerificationMeta _introCompleteMeta = const VerificationMeta(
    'introComplete',
  );
  @override
  late final GeneratedColumn<bool> introComplete = GeneratedColumn<bool>(
    'intro_complete',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("intro_complete" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _reminderEnabledMeta = const VerificationMeta(
    'reminderEnabled',
  );
  @override
  late final GeneratedColumn<bool> reminderEnabled = GeneratedColumn<bool>(
    'reminder_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminder_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _streakWarningEnabledMeta =
      const VerificationMeta('streakWarningEnabled');
  @override
  late final GeneratedColumn<bool> streakWarningEnabled = GeneratedColumn<bool>(
    'streak_warning_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("streak_warning_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _firstSessionCompletedMeta =
      const VerificationMeta('firstSessionCompleted');
  @override
  late final GeneratedColumn<bool> firstSessionCompleted =
      GeneratedColumn<bool>(
        'first_session_completed',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("first_session_completed" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _notificationPermissionAskedMeta =
      const VerificationMeta('notificationPermissionAsked');
  @override
  late final GeneratedColumn<bool> notificationPermissionAsked =
      GeneratedColumn<bool>(
        'notification_permission_asked',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("notification_permission_asked" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
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
  static const VerificationMeta _guestUsernameMeta = const VerificationMeta(
    'guestUsername',
  );
  @override
  late final GeneratedColumn<String> guestUsername = GeneratedColumn<String>(
    'guest_username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    introComplete,
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
    reminderEnabled,
    streakWarningEnabled,
    firstSessionCompleted,
    notificationPermissionAsked,
    displayName,
    guestUsername,
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
    if (data.containsKey('intro_complete')) {
      context.handle(
        _introCompleteMeta,
        introComplete.isAcceptableOrUnknown(
          data['intro_complete']!,
          _introCompleteMeta,
        ),
      );
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
    if (data.containsKey('reminder_enabled')) {
      context.handle(
        _reminderEnabledMeta,
        reminderEnabled.isAcceptableOrUnknown(
          data['reminder_enabled']!,
          _reminderEnabledMeta,
        ),
      );
    }
    if (data.containsKey('streak_warning_enabled')) {
      context.handle(
        _streakWarningEnabledMeta,
        streakWarningEnabled.isAcceptableOrUnknown(
          data['streak_warning_enabled']!,
          _streakWarningEnabledMeta,
        ),
      );
    }
    if (data.containsKey('first_session_completed')) {
      context.handle(
        _firstSessionCompletedMeta,
        firstSessionCompleted.isAcceptableOrUnknown(
          data['first_session_completed']!,
          _firstSessionCompletedMeta,
        ),
      );
    }
    if (data.containsKey('notification_permission_asked')) {
      context.handle(
        _notificationPermissionAskedMeta,
        notificationPermissionAsked.isAcceptableOrUnknown(
          data['notification_permission_asked']!,
          _notificationPermissionAskedMeta,
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
    if (data.containsKey('guest_username')) {
      context.handle(
        _guestUsernameMeta,
        guestUsername.isAcceptableOrUnknown(
          data['guest_username']!,
          _guestUsernameMeta,
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
      introComplete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}intro_complete'],
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
      reminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminder_enabled'],
      )!,
      streakWarningEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}streak_warning_enabled'],
      )!,
      firstSessionCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}first_session_completed'],
      )!,
      notificationPermissionAsked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notification_permission_asked'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      guestUsername: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guest_username'],
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
  final bool introComplete;
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
  final bool reminderEnabled;
  final bool streakWarningEnabled;
  final bool firstSessionCompleted;
  final bool notificationPermissionAsked;
  final String displayName;
  final String guestUsername;
  const Preference({
    required this.id,
    required this.introComplete,
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
    required this.reminderEnabled,
    required this.streakWarningEnabled,
    required this.firstSessionCompleted,
    required this.notificationPermissionAsked,
    required this.displayName,
    required this.guestUsername,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['intro_complete'] = Variable<bool>(introComplete);
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
    map['reminder_enabled'] = Variable<bool>(reminderEnabled);
    map['streak_warning_enabled'] = Variable<bool>(streakWarningEnabled);
    map['first_session_completed'] = Variable<bool>(firstSessionCompleted);
    map['notification_permission_asked'] = Variable<bool>(
      notificationPermissionAsked,
    );
    map['display_name'] = Variable<String>(displayName);
    map['guest_username'] = Variable<String>(guestUsername);
    return map;
  }

  PreferencesCompanion toCompanion(bool nullToAbsent) {
    return PreferencesCompanion(
      id: Value(id),
      introComplete: Value(introComplete),
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
      reminderEnabled: Value(reminderEnabled),
      streakWarningEnabled: Value(streakWarningEnabled),
      firstSessionCompleted: Value(firstSessionCompleted),
      notificationPermissionAsked: Value(notificationPermissionAsked),
      displayName: Value(displayName),
      guestUsername: Value(guestUsername),
    );
  }

  factory Preference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Preference(
      id: serializer.fromJson<int>(json['id']),
      introComplete: serializer.fromJson<bool>(json['introComplete']),
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
      reminderEnabled: serializer.fromJson<bool>(json['reminderEnabled']),
      streakWarningEnabled: serializer.fromJson<bool>(
        json['streakWarningEnabled'],
      ),
      firstSessionCompleted: serializer.fromJson<bool>(
        json['firstSessionCompleted'],
      ),
      notificationPermissionAsked: serializer.fromJson<bool>(
        json['notificationPermissionAsked'],
      ),
      displayName: serializer.fromJson<String>(json['displayName']),
      guestUsername: serializer.fromJson<String>(json['guestUsername']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'introComplete': serializer.toJson<bool>(introComplete),
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
      'reminderEnabled': serializer.toJson<bool>(reminderEnabled),
      'streakWarningEnabled': serializer.toJson<bool>(streakWarningEnabled),
      'firstSessionCompleted': serializer.toJson<bool>(firstSessionCompleted),
      'notificationPermissionAsked': serializer.toJson<bool>(
        notificationPermissionAsked,
      ),
      'displayName': serializer.toJson<String>(displayName),
      'guestUsername': serializer.toJson<String>(guestUsername),
    };
  }

  Preference copyWith({
    int? id,
    bool? introComplete,
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
    bool? reminderEnabled,
    bool? streakWarningEnabled,
    bool? firstSessionCompleted,
    bool? notificationPermissionAsked,
    String? displayName,
    String? guestUsername,
  }) => Preference(
    id: id ?? this.id,
    introComplete: introComplete ?? this.introComplete,
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
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    streakWarningEnabled: streakWarningEnabled ?? this.streakWarningEnabled,
    firstSessionCompleted: firstSessionCompleted ?? this.firstSessionCompleted,
    notificationPermissionAsked:
        notificationPermissionAsked ?? this.notificationPermissionAsked,
    displayName: displayName ?? this.displayName,
    guestUsername: guestUsername ?? this.guestUsername,
  );
  Preference copyWithCompanion(PreferencesCompanion data) {
    return Preference(
      id: data.id.present ? data.id.value : this.id,
      introComplete: data.introComplete.present
          ? data.introComplete.value
          : this.introComplete,
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
      reminderEnabled: data.reminderEnabled.present
          ? data.reminderEnabled.value
          : this.reminderEnabled,
      streakWarningEnabled: data.streakWarningEnabled.present
          ? data.streakWarningEnabled.value
          : this.streakWarningEnabled,
      firstSessionCompleted: data.firstSessionCompleted.present
          ? data.firstSessionCompleted.value
          : this.firstSessionCompleted,
      notificationPermissionAsked: data.notificationPermissionAsked.present
          ? data.notificationPermissionAsked.value
          : this.notificationPermissionAsked,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      guestUsername: data.guestUsername.present
          ? data.guestUsername.value
          : this.guestUsername,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Preference(')
          ..write('id: $id, ')
          ..write('introComplete: $introComplete, ')
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
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('streakWarningEnabled: $streakWarningEnabled, ')
          ..write('firstSessionCompleted: $firstSessionCompleted, ')
          ..write('notificationPermissionAsked: $notificationPermissionAsked, ')
          ..write('displayName: $displayName, ')
          ..write('guestUsername: $guestUsername')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    introComplete,
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
    reminderEnabled,
    streakWarningEnabled,
    firstSessionCompleted,
    notificationPermissionAsked,
    displayName,
    guestUsername,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Preference &&
          other.id == this.id &&
          other.introComplete == this.introComplete &&
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
          other.reminderEnabled == this.reminderEnabled &&
          other.streakWarningEnabled == this.streakWarningEnabled &&
          other.firstSessionCompleted == this.firstSessionCompleted &&
          other.notificationPermissionAsked ==
              this.notificationPermissionAsked &&
          other.displayName == this.displayName &&
          other.guestUsername == this.guestUsername);
}

class PreferencesCompanion extends UpdateCompanion<Preference> {
  final Value<int> id;
  final Value<bool> introComplete;
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
  final Value<bool> reminderEnabled;
  final Value<bool> streakWarningEnabled;
  final Value<bool> firstSessionCompleted;
  final Value<bool> notificationPermissionAsked;
  final Value<String> displayName;
  final Value<String> guestUsername;
  const PreferencesCompanion({
    this.id = const Value.absent(),
    this.introComplete = const Value.absent(),
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
    this.reminderEnabled = const Value.absent(),
    this.streakWarningEnabled = const Value.absent(),
    this.firstSessionCompleted = const Value.absent(),
    this.notificationPermissionAsked = const Value.absent(),
    this.displayName = const Value.absent(),
    this.guestUsername = const Value.absent(),
  });
  PreferencesCompanion.insert({
    this.id = const Value.absent(),
    this.introComplete = const Value.absent(),
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
    this.reminderEnabled = const Value.absent(),
    this.streakWarningEnabled = const Value.absent(),
    this.firstSessionCompleted = const Value.absent(),
    this.notificationPermissionAsked = const Value.absent(),
    this.displayName = const Value.absent(),
    this.guestUsername = const Value.absent(),
  });
  static Insertable<Preference> custom({
    Expression<int>? id,
    Expression<bool>? introComplete,
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
    Expression<bool>? reminderEnabled,
    Expression<bool>? streakWarningEnabled,
    Expression<bool>? firstSessionCompleted,
    Expression<bool>? notificationPermissionAsked,
    Expression<String>? displayName,
    Expression<String>? guestUsername,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (introComplete != null) 'intro_complete': introComplete,
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
      if (reminderEnabled != null) 'reminder_enabled': reminderEnabled,
      if (streakWarningEnabled != null)
        'streak_warning_enabled': streakWarningEnabled,
      if (firstSessionCompleted != null)
        'first_session_completed': firstSessionCompleted,
      if (notificationPermissionAsked != null)
        'notification_permission_asked': notificationPermissionAsked,
      if (displayName != null) 'display_name': displayName,
      if (guestUsername != null) 'guest_username': guestUsername,
    });
  }

  PreferencesCompanion copyWith({
    Value<int>? id,
    Value<bool>? introComplete,
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
    Value<bool>? reminderEnabled,
    Value<bool>? streakWarningEnabled,
    Value<bool>? firstSessionCompleted,
    Value<bool>? notificationPermissionAsked,
    Value<String>? displayName,
    Value<String>? guestUsername,
  }) {
    return PreferencesCompanion(
      id: id ?? this.id,
      introComplete: introComplete ?? this.introComplete,
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
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      streakWarningEnabled: streakWarningEnabled ?? this.streakWarningEnabled,
      firstSessionCompleted:
          firstSessionCompleted ?? this.firstSessionCompleted,
      notificationPermissionAsked:
          notificationPermissionAsked ?? this.notificationPermissionAsked,
      displayName: displayName ?? this.displayName,
      guestUsername: guestUsername ?? this.guestUsername,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (introComplete.present) {
      map['intro_complete'] = Variable<bool>(introComplete.value);
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
    if (reminderEnabled.present) {
      map['reminder_enabled'] = Variable<bool>(reminderEnabled.value);
    }
    if (streakWarningEnabled.present) {
      map['streak_warning_enabled'] = Variable<bool>(
        streakWarningEnabled.value,
      );
    }
    if (firstSessionCompleted.present) {
      map['first_session_completed'] = Variable<bool>(
        firstSessionCompleted.value,
      );
    }
    if (notificationPermissionAsked.present) {
      map['notification_permission_asked'] = Variable<bool>(
        notificationPermissionAsked.value,
      );
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (guestUsername.present) {
      map['guest_username'] = Variable<String>(guestUsername.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreferencesCompanion(')
          ..write('id: $id, ')
          ..write('introComplete: $introComplete, ')
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
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('streakWarningEnabled: $streakWarningEnabled, ')
          ..write('firstSessionCompleted: $firstSessionCompleted, ')
          ..write('notificationPermissionAsked: $notificationPermissionAsked, ')
          ..write('displayName: $displayName, ')
          ..write('guestUsername: $guestUsername')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientSessionIdMeta = const VerificationMeta(
    'clientSessionId',
  );
  @override
  late final GeneratedColumn<String> clientSessionId = GeneratedColumn<String>(
    'client_session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _techniqueIdMeta = const VerificationMeta(
    'techniqueId',
  );
  @override
  late final GeneratedColumn<String> techniqueId = GeneratedColumn<String>(
    'technique_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _presetIdMeta = const VerificationMeta(
    'presetId',
  );
  @override
  late final GeneratedColumn<String> presetId = GeneratedColumn<String>(
    'preset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtUtcMeta = const VerificationMeta(
    'startedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> startedAtUtc = GeneratedColumn<DateTime>(
    'started_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtUtcMeta = const VerificationMeta(
    'endedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> endedAtUtc = GeneratedColumn<DateTime>(
    'ended_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timezoneOffsetMinutesMeta =
      const VerificationMeta('timezoneOffsetMinutes');
  @override
  late final GeneratedColumn<int> timezoneOffsetMinutes = GeneratedColumn<int>(
    'timezone_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsActualMeta =
      const VerificationMeta('durationSecondsActual');
  @override
  late final GeneratedColumn<int> durationSecondsActual = GeneratedColumn<int>(
    'duration_seconds_actual',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _breathsCompletedEstimatedMeta =
      const VerificationMeta('breathsCompletedEstimated');
  @override
  late final GeneratedColumn<int> breathsCompletedEstimated =
      GeneratedColumn<int>(
        'breaths_completed_estimated',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _endedEarlyMeta = const VerificationMeta(
    'endedEarly',
  );
  @override
  late final GeneratedColumn<bool> endedEarly = GeneratedColumn<bool>(
    'ended_early',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ended_early" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncedToCloudMeta = const VerificationMeta(
    'syncedToCloud',
  );
  @override
  late final GeneratedColumn<bool> syncedToCloud = GeneratedColumn<bool>(
    'synced_to_cloud',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced_to_cloud" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    clientSessionId,
    techniqueId,
    presetId,
    startedAtUtc,
    endedAtUtc,
    timezoneOffsetMinutes,
    durationSecondsActual,
    breathsCompletedEstimated,
    endedEarly,
    syncedToCloud,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_session_id')) {
      context.handle(
        _clientSessionIdMeta,
        clientSessionId.isAcceptableOrUnknown(
          data['client_session_id']!,
          _clientSessionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientSessionIdMeta);
    }
    if (data.containsKey('technique_id')) {
      context.handle(
        _techniqueIdMeta,
        techniqueId.isAcceptableOrUnknown(
          data['technique_id']!,
          _techniqueIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_techniqueIdMeta);
    }
    if (data.containsKey('preset_id')) {
      context.handle(
        _presetIdMeta,
        presetId.isAcceptableOrUnknown(data['preset_id']!, _presetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_presetIdMeta);
    }
    if (data.containsKey('started_at_utc')) {
      context.handle(
        _startedAtUtcMeta,
        startedAtUtc.isAcceptableOrUnknown(
          data['started_at_utc']!,
          _startedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startedAtUtcMeta);
    }
    if (data.containsKey('ended_at_utc')) {
      context.handle(
        _endedAtUtcMeta,
        endedAtUtc.isAcceptableOrUnknown(
          data['ended_at_utc']!,
          _endedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_endedAtUtcMeta);
    }
    if (data.containsKey('timezone_offset_minutes')) {
      context.handle(
        _timezoneOffsetMinutesMeta,
        timezoneOffsetMinutes.isAcceptableOrUnknown(
          data['timezone_offset_minutes']!,
          _timezoneOffsetMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timezoneOffsetMinutesMeta);
    }
    if (data.containsKey('duration_seconds_actual')) {
      context.handle(
        _durationSecondsActualMeta,
        durationSecondsActual.isAcceptableOrUnknown(
          data['duration_seconds_actual']!,
          _durationSecondsActualMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsActualMeta);
    }
    if (data.containsKey('breaths_completed_estimated')) {
      context.handle(
        _breathsCompletedEstimatedMeta,
        breathsCompletedEstimated.isAcceptableOrUnknown(
          data['breaths_completed_estimated']!,
          _breathsCompletedEstimatedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_breathsCompletedEstimatedMeta);
    }
    if (data.containsKey('ended_early')) {
      context.handle(
        _endedEarlyMeta,
        endedEarly.isAcceptableOrUnknown(data['ended_early']!, _endedEarlyMeta),
      );
    }
    if (data.containsKey('synced_to_cloud')) {
      context.handle(
        _syncedToCloudMeta,
        syncedToCloud.isAcceptableOrUnknown(
          data['synced_to_cloud']!,
          _syncedToCloudMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientSessionId};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      clientSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_session_id'],
      )!,
      techniqueId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}technique_id'],
      )!,
      presetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preset_id'],
      )!,
      startedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at_utc'],
      )!,
      endedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at_utc'],
      )!,
      timezoneOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timezone_offset_minutes'],
      )!,
      durationSecondsActual: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds_actual'],
      )!,
      breathsCompletedEstimated: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}breaths_completed_estimated'],
      )!,
      endedEarly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ended_early'],
      )!,
      syncedToCloud: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced_to_cloud'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final String clientSessionId;
  final String techniqueId;
  final String presetId;
  final DateTime startedAtUtc;
  final DateTime endedAtUtc;
  final int timezoneOffsetMinutes;
  final int durationSecondsActual;
  final int breathsCompletedEstimated;
  final bool endedEarly;
  final bool syncedToCloud;
  final DateTime createdAt;
  const Session({
    required this.clientSessionId,
    required this.techniqueId,
    required this.presetId,
    required this.startedAtUtc,
    required this.endedAtUtc,
    required this.timezoneOffsetMinutes,
    required this.durationSecondsActual,
    required this.breathsCompletedEstimated,
    required this.endedEarly,
    required this.syncedToCloud,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_session_id'] = Variable<String>(clientSessionId);
    map['technique_id'] = Variable<String>(techniqueId);
    map['preset_id'] = Variable<String>(presetId);
    map['started_at_utc'] = Variable<DateTime>(startedAtUtc);
    map['ended_at_utc'] = Variable<DateTime>(endedAtUtc);
    map['timezone_offset_minutes'] = Variable<int>(timezoneOffsetMinutes);
    map['duration_seconds_actual'] = Variable<int>(durationSecondsActual);
    map['breaths_completed_estimated'] = Variable<int>(
      breathsCompletedEstimated,
    );
    map['ended_early'] = Variable<bool>(endedEarly);
    map['synced_to_cloud'] = Variable<bool>(syncedToCloud);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      clientSessionId: Value(clientSessionId),
      techniqueId: Value(techniqueId),
      presetId: Value(presetId),
      startedAtUtc: Value(startedAtUtc),
      endedAtUtc: Value(endedAtUtc),
      timezoneOffsetMinutes: Value(timezoneOffsetMinutes),
      durationSecondsActual: Value(durationSecondsActual),
      breathsCompletedEstimated: Value(breathsCompletedEstimated),
      endedEarly: Value(endedEarly),
      syncedToCloud: Value(syncedToCloud),
      createdAt: Value(createdAt),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      clientSessionId: serializer.fromJson<String>(json['clientSessionId']),
      techniqueId: serializer.fromJson<String>(json['techniqueId']),
      presetId: serializer.fromJson<String>(json['presetId']),
      startedAtUtc: serializer.fromJson<DateTime>(json['startedAtUtc']),
      endedAtUtc: serializer.fromJson<DateTime>(json['endedAtUtc']),
      timezoneOffsetMinutes: serializer.fromJson<int>(
        json['timezoneOffsetMinutes'],
      ),
      durationSecondsActual: serializer.fromJson<int>(
        json['durationSecondsActual'],
      ),
      breathsCompletedEstimated: serializer.fromJson<int>(
        json['breathsCompletedEstimated'],
      ),
      endedEarly: serializer.fromJson<bool>(json['endedEarly']),
      syncedToCloud: serializer.fromJson<bool>(json['syncedToCloud']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientSessionId': serializer.toJson<String>(clientSessionId),
      'techniqueId': serializer.toJson<String>(techniqueId),
      'presetId': serializer.toJson<String>(presetId),
      'startedAtUtc': serializer.toJson<DateTime>(startedAtUtc),
      'endedAtUtc': serializer.toJson<DateTime>(endedAtUtc),
      'timezoneOffsetMinutes': serializer.toJson<int>(timezoneOffsetMinutes),
      'durationSecondsActual': serializer.toJson<int>(durationSecondsActual),
      'breathsCompletedEstimated': serializer.toJson<int>(
        breathsCompletedEstimated,
      ),
      'endedEarly': serializer.toJson<bool>(endedEarly),
      'syncedToCloud': serializer.toJson<bool>(syncedToCloud),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Session copyWith({
    String? clientSessionId,
    String? techniqueId,
    String? presetId,
    DateTime? startedAtUtc,
    DateTime? endedAtUtc,
    int? timezoneOffsetMinutes,
    int? durationSecondsActual,
    int? breathsCompletedEstimated,
    bool? endedEarly,
    bool? syncedToCloud,
    DateTime? createdAt,
  }) => Session(
    clientSessionId: clientSessionId ?? this.clientSessionId,
    techniqueId: techniqueId ?? this.techniqueId,
    presetId: presetId ?? this.presetId,
    startedAtUtc: startedAtUtc ?? this.startedAtUtc,
    endedAtUtc: endedAtUtc ?? this.endedAtUtc,
    timezoneOffsetMinutes: timezoneOffsetMinutes ?? this.timezoneOffsetMinutes,
    durationSecondsActual: durationSecondsActual ?? this.durationSecondsActual,
    breathsCompletedEstimated:
        breathsCompletedEstimated ?? this.breathsCompletedEstimated,
    endedEarly: endedEarly ?? this.endedEarly,
    syncedToCloud: syncedToCloud ?? this.syncedToCloud,
    createdAt: createdAt ?? this.createdAt,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      clientSessionId: data.clientSessionId.present
          ? data.clientSessionId.value
          : this.clientSessionId,
      techniqueId: data.techniqueId.present
          ? data.techniqueId.value
          : this.techniqueId,
      presetId: data.presetId.present ? data.presetId.value : this.presetId,
      startedAtUtc: data.startedAtUtc.present
          ? data.startedAtUtc.value
          : this.startedAtUtc,
      endedAtUtc: data.endedAtUtc.present
          ? data.endedAtUtc.value
          : this.endedAtUtc,
      timezoneOffsetMinutes: data.timezoneOffsetMinutes.present
          ? data.timezoneOffsetMinutes.value
          : this.timezoneOffsetMinutes,
      durationSecondsActual: data.durationSecondsActual.present
          ? data.durationSecondsActual.value
          : this.durationSecondsActual,
      breathsCompletedEstimated: data.breathsCompletedEstimated.present
          ? data.breathsCompletedEstimated.value
          : this.breathsCompletedEstimated,
      endedEarly: data.endedEarly.present
          ? data.endedEarly.value
          : this.endedEarly,
      syncedToCloud: data.syncedToCloud.present
          ? data.syncedToCloud.value
          : this.syncedToCloud,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('clientSessionId: $clientSessionId, ')
          ..write('techniqueId: $techniqueId, ')
          ..write('presetId: $presetId, ')
          ..write('startedAtUtc: $startedAtUtc, ')
          ..write('endedAtUtc: $endedAtUtc, ')
          ..write('timezoneOffsetMinutes: $timezoneOffsetMinutes, ')
          ..write('durationSecondsActual: $durationSecondsActual, ')
          ..write('breathsCompletedEstimated: $breathsCompletedEstimated, ')
          ..write('endedEarly: $endedEarly, ')
          ..write('syncedToCloud: $syncedToCloud, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    clientSessionId,
    techniqueId,
    presetId,
    startedAtUtc,
    endedAtUtc,
    timezoneOffsetMinutes,
    durationSecondsActual,
    breathsCompletedEstimated,
    endedEarly,
    syncedToCloud,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.clientSessionId == this.clientSessionId &&
          other.techniqueId == this.techniqueId &&
          other.presetId == this.presetId &&
          other.startedAtUtc == this.startedAtUtc &&
          other.endedAtUtc == this.endedAtUtc &&
          other.timezoneOffsetMinutes == this.timezoneOffsetMinutes &&
          other.durationSecondsActual == this.durationSecondsActual &&
          other.breathsCompletedEstimated == this.breathsCompletedEstimated &&
          other.endedEarly == this.endedEarly &&
          other.syncedToCloud == this.syncedToCloud &&
          other.createdAt == this.createdAt);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<String> clientSessionId;
  final Value<String> techniqueId;
  final Value<String> presetId;
  final Value<DateTime> startedAtUtc;
  final Value<DateTime> endedAtUtc;
  final Value<int> timezoneOffsetMinutes;
  final Value<int> durationSecondsActual;
  final Value<int> breathsCompletedEstimated;
  final Value<bool> endedEarly;
  final Value<bool> syncedToCloud;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SessionsCompanion({
    this.clientSessionId = const Value.absent(),
    this.techniqueId = const Value.absent(),
    this.presetId = const Value.absent(),
    this.startedAtUtc = const Value.absent(),
    this.endedAtUtc = const Value.absent(),
    this.timezoneOffsetMinutes = const Value.absent(),
    this.durationSecondsActual = const Value.absent(),
    this.breathsCompletedEstimated = const Value.absent(),
    this.endedEarly = const Value.absent(),
    this.syncedToCloud = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String clientSessionId,
    required String techniqueId,
    required String presetId,
    required DateTime startedAtUtc,
    required DateTime endedAtUtc,
    required int timezoneOffsetMinutes,
    required int durationSecondsActual,
    required int breathsCompletedEstimated,
    this.endedEarly = const Value.absent(),
    this.syncedToCloud = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : clientSessionId = Value(clientSessionId),
       techniqueId = Value(techniqueId),
       presetId = Value(presetId),
       startedAtUtc = Value(startedAtUtc),
       endedAtUtc = Value(endedAtUtc),
       timezoneOffsetMinutes = Value(timezoneOffsetMinutes),
       durationSecondsActual = Value(durationSecondsActual),
       breathsCompletedEstimated = Value(breathsCompletedEstimated),
       createdAt = Value(createdAt);
  static Insertable<Session> custom({
    Expression<String>? clientSessionId,
    Expression<String>? techniqueId,
    Expression<String>? presetId,
    Expression<DateTime>? startedAtUtc,
    Expression<DateTime>? endedAtUtc,
    Expression<int>? timezoneOffsetMinutes,
    Expression<int>? durationSecondsActual,
    Expression<int>? breathsCompletedEstimated,
    Expression<bool>? endedEarly,
    Expression<bool>? syncedToCloud,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientSessionId != null) 'client_session_id': clientSessionId,
      if (techniqueId != null) 'technique_id': techniqueId,
      if (presetId != null) 'preset_id': presetId,
      if (startedAtUtc != null) 'started_at_utc': startedAtUtc,
      if (endedAtUtc != null) 'ended_at_utc': endedAtUtc,
      if (timezoneOffsetMinutes != null)
        'timezone_offset_minutes': timezoneOffsetMinutes,
      if (durationSecondsActual != null)
        'duration_seconds_actual': durationSecondsActual,
      if (breathsCompletedEstimated != null)
        'breaths_completed_estimated': breathsCompletedEstimated,
      if (endedEarly != null) 'ended_early': endedEarly,
      if (syncedToCloud != null) 'synced_to_cloud': syncedToCloud,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith({
    Value<String>? clientSessionId,
    Value<String>? techniqueId,
    Value<String>? presetId,
    Value<DateTime>? startedAtUtc,
    Value<DateTime>? endedAtUtc,
    Value<int>? timezoneOffsetMinutes,
    Value<int>? durationSecondsActual,
    Value<int>? breathsCompletedEstimated,
    Value<bool>? endedEarly,
    Value<bool>? syncedToCloud,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SessionsCompanion(
      clientSessionId: clientSessionId ?? this.clientSessionId,
      techniqueId: techniqueId ?? this.techniqueId,
      presetId: presetId ?? this.presetId,
      startedAtUtc: startedAtUtc ?? this.startedAtUtc,
      endedAtUtc: endedAtUtc ?? this.endedAtUtc,
      timezoneOffsetMinutes:
          timezoneOffsetMinutes ?? this.timezoneOffsetMinutes,
      durationSecondsActual:
          durationSecondsActual ?? this.durationSecondsActual,
      breathsCompletedEstimated:
          breathsCompletedEstimated ?? this.breathsCompletedEstimated,
      endedEarly: endedEarly ?? this.endedEarly,
      syncedToCloud: syncedToCloud ?? this.syncedToCloud,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientSessionId.present) {
      map['client_session_id'] = Variable<String>(clientSessionId.value);
    }
    if (techniqueId.present) {
      map['technique_id'] = Variable<String>(techniqueId.value);
    }
    if (presetId.present) {
      map['preset_id'] = Variable<String>(presetId.value);
    }
    if (startedAtUtc.present) {
      map['started_at_utc'] = Variable<DateTime>(startedAtUtc.value);
    }
    if (endedAtUtc.present) {
      map['ended_at_utc'] = Variable<DateTime>(endedAtUtc.value);
    }
    if (timezoneOffsetMinutes.present) {
      map['timezone_offset_minutes'] = Variable<int>(
        timezoneOffsetMinutes.value,
      );
    }
    if (durationSecondsActual.present) {
      map['duration_seconds_actual'] = Variable<int>(
        durationSecondsActual.value,
      );
    }
    if (breathsCompletedEstimated.present) {
      map['breaths_completed_estimated'] = Variable<int>(
        breathsCompletedEstimated.value,
      );
    }
    if (endedEarly.present) {
      map['ended_early'] = Variable<bool>(endedEarly.value);
    }
    if (syncedToCloud.present) {
      map['synced_to_cloud'] = Variable<bool>(syncedToCloud.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('clientSessionId: $clientSessionId, ')
          ..write('techniqueId: $techniqueId, ')
          ..write('presetId: $presetId, ')
          ..write('startedAtUtc: $startedAtUtc, ')
          ..write('endedAtUtc: $endedAtUtc, ')
          ..write('timezoneOffsetMinutes: $timezoneOffsetMinutes, ')
          ..write('durationSecondsActual: $durationSecondsActual, ')
          ..write('breathsCompletedEstimated: $breathsCompletedEstimated, ')
          ..write('endedEarly: $endedEarly, ')
          ..write('syncedToCloud: $syncedToCloud, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoritesTable extends Favorites
    with TableInfo<$FavoritesTable, Favorite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _techniqueIdMeta = const VerificationMeta(
    'techniqueId',
  );
  @override
  late final GeneratedColumn<String> techniqueId = GeneratedColumn<String>(
    'technique_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [techniqueId, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites';
  @override
  VerificationContext validateIntegrity(
    Insertable<Favorite> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('technique_id')) {
      context.handle(
        _techniqueIdMeta,
        techniqueId.isAcceptableOrUnknown(
          data['technique_id']!,
          _techniqueIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_techniqueIdMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {techniqueId};
  @override
  Favorite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Favorite(
      techniqueId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}technique_id'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $FavoritesTable createAlias(String alias) {
    return $FavoritesTable(attachedDatabase, alias);
  }
}

class Favorite extends DataClass implements Insertable<Favorite> {
  final String techniqueId;
  final DateTime addedAt;
  const Favorite({required this.techniqueId, required this.addedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['technique_id'] = Variable<String>(techniqueId);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  FavoritesCompanion toCompanion(bool nullToAbsent) {
    return FavoritesCompanion(
      techniqueId: Value(techniqueId),
      addedAt: Value(addedAt),
    );
  }

  factory Favorite.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Favorite(
      techniqueId: serializer.fromJson<String>(json['techniqueId']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'techniqueId': serializer.toJson<String>(techniqueId),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  Favorite copyWith({String? techniqueId, DateTime? addedAt}) => Favorite(
    techniqueId: techniqueId ?? this.techniqueId,
    addedAt: addedAt ?? this.addedAt,
  );
  Favorite copyWithCompanion(FavoritesCompanion data) {
    return Favorite(
      techniqueId: data.techniqueId.present
          ? data.techniqueId.value
          : this.techniqueId,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Favorite(')
          ..write('techniqueId: $techniqueId, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(techniqueId, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Favorite &&
          other.techniqueId == this.techniqueId &&
          other.addedAt == this.addedAt);
}

class FavoritesCompanion extends UpdateCompanion<Favorite> {
  final Value<String> techniqueId;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const FavoritesCompanion({
    this.techniqueId = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoritesCompanion.insert({
    required String techniqueId,
    required DateTime addedAt,
    this.rowid = const Value.absent(),
  }) : techniqueId = Value(techniqueId),
       addedAt = Value(addedAt);
  static Insertable<Favorite> custom({
    Expression<String>? techniqueId,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (techniqueId != null) 'technique_id': techniqueId,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoritesCompanion copyWith({
    Value<String>? techniqueId,
    Value<DateTime>? addedAt,
    Value<int>? rowid,
  }) {
    return FavoritesCompanion(
      techniqueId: techniqueId ?? this.techniqueId,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (techniqueId.present) {
      map['technique_id'] = Variable<String>(techniqueId.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesCompanion(')
          ..write('techniqueId: $techniqueId, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SafetyAckTable extends SafetyAck
    with TableInfo<$SafetyAckTable, SafetyAckData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SafetyAckTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _techniqueIdMeta = const VerificationMeta(
    'techniqueId',
  );
  @override
  late final GeneratedColumn<String> techniqueId = GeneratedColumn<String>(
    'technique_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _acknowledgedAtMeta = const VerificationMeta(
    'acknowledgedAt',
  );
  @override
  late final GeneratedColumn<DateTime> acknowledgedAt =
      GeneratedColumn<DateTime>(
        'acknowledged_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [techniqueId, acknowledgedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'safety_ack';
  @override
  VerificationContext validateIntegrity(
    Insertable<SafetyAckData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('technique_id')) {
      context.handle(
        _techniqueIdMeta,
        techniqueId.isAcceptableOrUnknown(
          data['technique_id']!,
          _techniqueIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_techniqueIdMeta);
    }
    if (data.containsKey('acknowledged_at')) {
      context.handle(
        _acknowledgedAtMeta,
        acknowledgedAt.isAcceptableOrUnknown(
          data['acknowledged_at']!,
          _acknowledgedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_acknowledgedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {techniqueId};
  @override
  SafetyAckData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SafetyAckData(
      techniqueId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}technique_id'],
      )!,
      acknowledgedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}acknowledged_at'],
      )!,
    );
  }

  @override
  $SafetyAckTable createAlias(String alias) {
    return $SafetyAckTable(attachedDatabase, alias);
  }
}

class SafetyAckData extends DataClass implements Insertable<SafetyAckData> {
  final String techniqueId;
  final DateTime acknowledgedAt;
  const SafetyAckData({
    required this.techniqueId,
    required this.acknowledgedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['technique_id'] = Variable<String>(techniqueId);
    map['acknowledged_at'] = Variable<DateTime>(acknowledgedAt);
    return map;
  }

  SafetyAckCompanion toCompanion(bool nullToAbsent) {
    return SafetyAckCompanion(
      techniqueId: Value(techniqueId),
      acknowledgedAt: Value(acknowledgedAt),
    );
  }

  factory SafetyAckData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SafetyAckData(
      techniqueId: serializer.fromJson<String>(json['techniqueId']),
      acknowledgedAt: serializer.fromJson<DateTime>(json['acknowledgedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'techniqueId': serializer.toJson<String>(techniqueId),
      'acknowledgedAt': serializer.toJson<DateTime>(acknowledgedAt),
    };
  }

  SafetyAckData copyWith({String? techniqueId, DateTime? acknowledgedAt}) =>
      SafetyAckData(
        techniqueId: techniqueId ?? this.techniqueId,
        acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      );
  SafetyAckData copyWithCompanion(SafetyAckCompanion data) {
    return SafetyAckData(
      techniqueId: data.techniqueId.present
          ? data.techniqueId.value
          : this.techniqueId,
      acknowledgedAt: data.acknowledgedAt.present
          ? data.acknowledgedAt.value
          : this.acknowledgedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SafetyAckData(')
          ..write('techniqueId: $techniqueId, ')
          ..write('acknowledgedAt: $acknowledgedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(techniqueId, acknowledgedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SafetyAckData &&
          other.techniqueId == this.techniqueId &&
          other.acknowledgedAt == this.acknowledgedAt);
}

class SafetyAckCompanion extends UpdateCompanion<SafetyAckData> {
  final Value<String> techniqueId;
  final Value<DateTime> acknowledgedAt;
  final Value<int> rowid;
  const SafetyAckCompanion({
    this.techniqueId = const Value.absent(),
    this.acknowledgedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SafetyAckCompanion.insert({
    required String techniqueId,
    required DateTime acknowledgedAt,
    this.rowid = const Value.absent(),
  }) : techniqueId = Value(techniqueId),
       acknowledgedAt = Value(acknowledgedAt);
  static Insertable<SafetyAckData> custom({
    Expression<String>? techniqueId,
    Expression<DateTime>? acknowledgedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (techniqueId != null) 'technique_id': techniqueId,
      if (acknowledgedAt != null) 'acknowledged_at': acknowledgedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SafetyAckCompanion copyWith({
    Value<String>? techniqueId,
    Value<DateTime>? acknowledgedAt,
    Value<int>? rowid,
  }) {
    return SafetyAckCompanion(
      techniqueId: techniqueId ?? this.techniqueId,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (techniqueId.present) {
      map['technique_id'] = Variable<String>(techniqueId.value);
    }
    if (acknowledgedAt.present) {
      map['acknowledged_at'] = Variable<DateTime>(acknowledgedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SafetyAckCompanion(')
          ..write('techniqueId: $techniqueId, ')
          ..write('acknowledgedAt: $acknowledgedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StatsCacheTable extends StatsCache
    with TableInfo<$StatsCacheTable, StatsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StatsCacheTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _currentStreakDaysMeta = const VerificationMeta(
    'currentStreakDays',
  );
  @override
  late final GeneratedColumn<int> currentStreakDays = GeneratedColumn<int>(
    'current_streak_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _longestStreakDaysMeta = const VerificationMeta(
    'longestStreakDays',
  );
  @override
  late final GeneratedColumn<int> longestStreakDays = GeneratedColumn<int>(
    'longest_streak_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _practiceDaysAllTimeMeta =
      const VerificationMeta('practiceDaysAllTime');
  @override
  late final GeneratedColumn<int> practiceDaysAllTime = GeneratedColumn<int>(
    'practice_days_all_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _minutesThisWeekMeta = const VerificationMeta(
    'minutesThisWeek',
  );
  @override
  late final GeneratedColumn<int> minutesThisWeek = GeneratedColumn<int>(
    'minutes_this_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _minutesAllTimeMeta = const VerificationMeta(
    'minutesAllTime',
  );
  @override
  late final GeneratedColumn<int> minutesAllTime = GeneratedColumn<int>(
    'minutes_all_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sessionsAllTimeMeta = const VerificationMeta(
    'sessionsAllTime',
  );
  @override
  late final GeneratedColumn<int> sessionsAllTime = GeneratedColumn<int>(
    'sessions_all_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _minutesByTechniqueJsonMeta =
      const VerificationMeta('minutesByTechniqueJson');
  @override
  late final GeneratedColumn<String> minutesByTechniqueJson =
      GeneratedColumn<String>(
        'minutes_by_technique_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  static const VerificationMeta _longestSessionMinutesMeta =
      const VerificationMeta('longestSessionMinutes');
  @override
  late final GeneratedColumn<int> longestSessionMinutes = GeneratedColumn<int>(
    'longest_session_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _favoriteTechniqueIdMeta =
      const VerificationMeta('favoriteTechniqueId');
  @override
  late final GeneratedColumn<String> favoriteTechniqueId =
      GeneratedColumn<String>(
        'favorite_technique_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _totalBreathsEstimatedMeta =
      const VerificationMeta('totalBreathsEstimated');
  @override
  late final GeneratedColumn<int> totalBreathsEstimated = GeneratedColumn<int>(
    'total_breaths_estimated',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalXpMeta = const VerificationMeta(
    'totalXp',
  );
  @override
  late final GeneratedColumn<int> totalXp = GeneratedColumn<int>(
    'total_xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currentLevelMeta = const VerificationMeta(
    'currentLevel',
  );
  @override
  late final GeneratedColumn<int> currentLevel = GeneratedColumn<int>(
    'current_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    currentStreakDays,
    longestStreakDays,
    practiceDaysAllTime,
    minutesThisWeek,
    minutesAllTime,
    sessionsAllTime,
    minutesByTechniqueJson,
    longestSessionMinutes,
    favoriteTechniqueId,
    totalBreathsEstimated,
    totalXp,
    currentLevel,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stats_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<StatsCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('current_streak_days')) {
      context.handle(
        _currentStreakDaysMeta,
        currentStreakDays.isAcceptableOrUnknown(
          data['current_streak_days']!,
          _currentStreakDaysMeta,
        ),
      );
    }
    if (data.containsKey('longest_streak_days')) {
      context.handle(
        _longestStreakDaysMeta,
        longestStreakDays.isAcceptableOrUnknown(
          data['longest_streak_days']!,
          _longestStreakDaysMeta,
        ),
      );
    }
    if (data.containsKey('practice_days_all_time')) {
      context.handle(
        _practiceDaysAllTimeMeta,
        practiceDaysAllTime.isAcceptableOrUnknown(
          data['practice_days_all_time']!,
          _practiceDaysAllTimeMeta,
        ),
      );
    }
    if (data.containsKey('minutes_this_week')) {
      context.handle(
        _minutesThisWeekMeta,
        minutesThisWeek.isAcceptableOrUnknown(
          data['minutes_this_week']!,
          _minutesThisWeekMeta,
        ),
      );
    }
    if (data.containsKey('minutes_all_time')) {
      context.handle(
        _minutesAllTimeMeta,
        minutesAllTime.isAcceptableOrUnknown(
          data['minutes_all_time']!,
          _minutesAllTimeMeta,
        ),
      );
    }
    if (data.containsKey('sessions_all_time')) {
      context.handle(
        _sessionsAllTimeMeta,
        sessionsAllTime.isAcceptableOrUnknown(
          data['sessions_all_time']!,
          _sessionsAllTimeMeta,
        ),
      );
    }
    if (data.containsKey('minutes_by_technique_json')) {
      context.handle(
        _minutesByTechniqueJsonMeta,
        minutesByTechniqueJson.isAcceptableOrUnknown(
          data['minutes_by_technique_json']!,
          _minutesByTechniqueJsonMeta,
        ),
      );
    }
    if (data.containsKey('longest_session_minutes')) {
      context.handle(
        _longestSessionMinutesMeta,
        longestSessionMinutes.isAcceptableOrUnknown(
          data['longest_session_minutes']!,
          _longestSessionMinutesMeta,
        ),
      );
    }
    if (data.containsKey('favorite_technique_id')) {
      context.handle(
        _favoriteTechniqueIdMeta,
        favoriteTechniqueId.isAcceptableOrUnknown(
          data['favorite_technique_id']!,
          _favoriteTechniqueIdMeta,
        ),
      );
    }
    if (data.containsKey('total_breaths_estimated')) {
      context.handle(
        _totalBreathsEstimatedMeta,
        totalBreathsEstimated.isAcceptableOrUnknown(
          data['total_breaths_estimated']!,
          _totalBreathsEstimatedMeta,
        ),
      );
    }
    if (data.containsKey('total_xp')) {
      context.handle(
        _totalXpMeta,
        totalXp.isAcceptableOrUnknown(data['total_xp']!, _totalXpMeta),
      );
    }
    if (data.containsKey('current_level')) {
      context.handle(
        _currentLevelMeta,
        currentLevel.isAcceptableOrUnknown(
          data['current_level']!,
          _currentLevelMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StatsCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StatsCacheData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      currentStreakDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_streak_days'],
      )!,
      longestStreakDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}longest_streak_days'],
      )!,
      practiceDaysAllTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}practice_days_all_time'],
      )!,
      minutesThisWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minutes_this_week'],
      )!,
      minutesAllTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minutes_all_time'],
      )!,
      sessionsAllTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sessions_all_time'],
      )!,
      minutesByTechniqueJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}minutes_by_technique_json'],
      )!,
      longestSessionMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}longest_session_minutes'],
      )!,
      favoriteTechniqueId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}favorite_technique_id'],
      ),
      totalBreathsEstimated: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_breaths_estimated'],
      )!,
      totalXp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_xp'],
      )!,
      currentLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_level'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $StatsCacheTable createAlias(String alias) {
    return $StatsCacheTable(attachedDatabase, alias);
  }
}

class StatsCacheData extends DataClass implements Insertable<StatsCacheData> {
  final int id;
  final int currentStreakDays;
  final int longestStreakDays;
  final int practiceDaysAllTime;
  final int minutesThisWeek;
  final int minutesAllTime;
  final int sessionsAllTime;
  final String minutesByTechniqueJson;
  final int longestSessionMinutes;
  final String? favoriteTechniqueId;
  final int totalBreathsEstimated;
  final int totalXp;
  final int currentLevel;
  final DateTime updatedAt;
  const StatsCacheData({
    required this.id,
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.practiceDaysAllTime,
    required this.minutesThisWeek,
    required this.minutesAllTime,
    required this.sessionsAllTime,
    required this.minutesByTechniqueJson,
    required this.longestSessionMinutes,
    this.favoriteTechniqueId,
    required this.totalBreathsEstimated,
    required this.totalXp,
    required this.currentLevel,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['current_streak_days'] = Variable<int>(currentStreakDays);
    map['longest_streak_days'] = Variable<int>(longestStreakDays);
    map['practice_days_all_time'] = Variable<int>(practiceDaysAllTime);
    map['minutes_this_week'] = Variable<int>(minutesThisWeek);
    map['minutes_all_time'] = Variable<int>(minutesAllTime);
    map['sessions_all_time'] = Variable<int>(sessionsAllTime);
    map['minutes_by_technique_json'] = Variable<String>(minutesByTechniqueJson);
    map['longest_session_minutes'] = Variable<int>(longestSessionMinutes);
    if (!nullToAbsent || favoriteTechniqueId != null) {
      map['favorite_technique_id'] = Variable<String>(favoriteTechniqueId);
    }
    map['total_breaths_estimated'] = Variable<int>(totalBreathsEstimated);
    map['total_xp'] = Variable<int>(totalXp);
    map['current_level'] = Variable<int>(currentLevel);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  StatsCacheCompanion toCompanion(bool nullToAbsent) {
    return StatsCacheCompanion(
      id: Value(id),
      currentStreakDays: Value(currentStreakDays),
      longestStreakDays: Value(longestStreakDays),
      practiceDaysAllTime: Value(practiceDaysAllTime),
      minutesThisWeek: Value(minutesThisWeek),
      minutesAllTime: Value(minutesAllTime),
      sessionsAllTime: Value(sessionsAllTime),
      minutesByTechniqueJson: Value(minutesByTechniqueJson),
      longestSessionMinutes: Value(longestSessionMinutes),
      favoriteTechniqueId: favoriteTechniqueId == null && nullToAbsent
          ? const Value.absent()
          : Value(favoriteTechniqueId),
      totalBreathsEstimated: Value(totalBreathsEstimated),
      totalXp: Value(totalXp),
      currentLevel: Value(currentLevel),
      updatedAt: Value(updatedAt),
    );
  }

  factory StatsCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StatsCacheData(
      id: serializer.fromJson<int>(json['id']),
      currentStreakDays: serializer.fromJson<int>(json['currentStreakDays']),
      longestStreakDays: serializer.fromJson<int>(json['longestStreakDays']),
      practiceDaysAllTime: serializer.fromJson<int>(
        json['practiceDaysAllTime'],
      ),
      minutesThisWeek: serializer.fromJson<int>(json['minutesThisWeek']),
      minutesAllTime: serializer.fromJson<int>(json['minutesAllTime']),
      sessionsAllTime: serializer.fromJson<int>(json['sessionsAllTime']),
      minutesByTechniqueJson: serializer.fromJson<String>(
        json['minutesByTechniqueJson'],
      ),
      longestSessionMinutes: serializer.fromJson<int>(
        json['longestSessionMinutes'],
      ),
      favoriteTechniqueId: serializer.fromJson<String?>(
        json['favoriteTechniqueId'],
      ),
      totalBreathsEstimated: serializer.fromJson<int>(
        json['totalBreathsEstimated'],
      ),
      totalXp: serializer.fromJson<int>(json['totalXp']),
      currentLevel: serializer.fromJson<int>(json['currentLevel']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'currentStreakDays': serializer.toJson<int>(currentStreakDays),
      'longestStreakDays': serializer.toJson<int>(longestStreakDays),
      'practiceDaysAllTime': serializer.toJson<int>(practiceDaysAllTime),
      'minutesThisWeek': serializer.toJson<int>(minutesThisWeek),
      'minutesAllTime': serializer.toJson<int>(minutesAllTime),
      'sessionsAllTime': serializer.toJson<int>(sessionsAllTime),
      'minutesByTechniqueJson': serializer.toJson<String>(
        minutesByTechniqueJson,
      ),
      'longestSessionMinutes': serializer.toJson<int>(longestSessionMinutes),
      'favoriteTechniqueId': serializer.toJson<String?>(favoriteTechniqueId),
      'totalBreathsEstimated': serializer.toJson<int>(totalBreathsEstimated),
      'totalXp': serializer.toJson<int>(totalXp),
      'currentLevel': serializer.toJson<int>(currentLevel),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  StatsCacheData copyWith({
    int? id,
    int? currentStreakDays,
    int? longestStreakDays,
    int? practiceDaysAllTime,
    int? minutesThisWeek,
    int? minutesAllTime,
    int? sessionsAllTime,
    String? minutesByTechniqueJson,
    int? longestSessionMinutes,
    Value<String?> favoriteTechniqueId = const Value.absent(),
    int? totalBreathsEstimated,
    int? totalXp,
    int? currentLevel,
    DateTime? updatedAt,
  }) => StatsCacheData(
    id: id ?? this.id,
    currentStreakDays: currentStreakDays ?? this.currentStreakDays,
    longestStreakDays: longestStreakDays ?? this.longestStreakDays,
    practiceDaysAllTime: practiceDaysAllTime ?? this.practiceDaysAllTime,
    minutesThisWeek: minutesThisWeek ?? this.minutesThisWeek,
    minutesAllTime: minutesAllTime ?? this.minutesAllTime,
    sessionsAllTime: sessionsAllTime ?? this.sessionsAllTime,
    minutesByTechniqueJson:
        minutesByTechniqueJson ?? this.minutesByTechniqueJson,
    longestSessionMinutes: longestSessionMinutes ?? this.longestSessionMinutes,
    favoriteTechniqueId: favoriteTechniqueId.present
        ? favoriteTechniqueId.value
        : this.favoriteTechniqueId,
    totalBreathsEstimated: totalBreathsEstimated ?? this.totalBreathsEstimated,
    totalXp: totalXp ?? this.totalXp,
    currentLevel: currentLevel ?? this.currentLevel,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  StatsCacheData copyWithCompanion(StatsCacheCompanion data) {
    return StatsCacheData(
      id: data.id.present ? data.id.value : this.id,
      currentStreakDays: data.currentStreakDays.present
          ? data.currentStreakDays.value
          : this.currentStreakDays,
      longestStreakDays: data.longestStreakDays.present
          ? data.longestStreakDays.value
          : this.longestStreakDays,
      practiceDaysAllTime: data.practiceDaysAllTime.present
          ? data.practiceDaysAllTime.value
          : this.practiceDaysAllTime,
      minutesThisWeek: data.minutesThisWeek.present
          ? data.minutesThisWeek.value
          : this.minutesThisWeek,
      minutesAllTime: data.minutesAllTime.present
          ? data.minutesAllTime.value
          : this.minutesAllTime,
      sessionsAllTime: data.sessionsAllTime.present
          ? data.sessionsAllTime.value
          : this.sessionsAllTime,
      minutesByTechniqueJson: data.minutesByTechniqueJson.present
          ? data.minutesByTechniqueJson.value
          : this.minutesByTechniqueJson,
      longestSessionMinutes: data.longestSessionMinutes.present
          ? data.longestSessionMinutes.value
          : this.longestSessionMinutes,
      favoriteTechniqueId: data.favoriteTechniqueId.present
          ? data.favoriteTechniqueId.value
          : this.favoriteTechniqueId,
      totalBreathsEstimated: data.totalBreathsEstimated.present
          ? data.totalBreathsEstimated.value
          : this.totalBreathsEstimated,
      totalXp: data.totalXp.present ? data.totalXp.value : this.totalXp,
      currentLevel: data.currentLevel.present
          ? data.currentLevel.value
          : this.currentLevel,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StatsCacheData(')
          ..write('id: $id, ')
          ..write('currentStreakDays: $currentStreakDays, ')
          ..write('longestStreakDays: $longestStreakDays, ')
          ..write('practiceDaysAllTime: $practiceDaysAllTime, ')
          ..write('minutesThisWeek: $minutesThisWeek, ')
          ..write('minutesAllTime: $minutesAllTime, ')
          ..write('sessionsAllTime: $sessionsAllTime, ')
          ..write('minutesByTechniqueJson: $minutesByTechniqueJson, ')
          ..write('longestSessionMinutes: $longestSessionMinutes, ')
          ..write('favoriteTechniqueId: $favoriteTechniqueId, ')
          ..write('totalBreathsEstimated: $totalBreathsEstimated, ')
          ..write('totalXp: $totalXp, ')
          ..write('currentLevel: $currentLevel, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    currentStreakDays,
    longestStreakDays,
    practiceDaysAllTime,
    minutesThisWeek,
    minutesAllTime,
    sessionsAllTime,
    minutesByTechniqueJson,
    longestSessionMinutes,
    favoriteTechniqueId,
    totalBreathsEstimated,
    totalXp,
    currentLevel,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StatsCacheData &&
          other.id == this.id &&
          other.currentStreakDays == this.currentStreakDays &&
          other.longestStreakDays == this.longestStreakDays &&
          other.practiceDaysAllTime == this.practiceDaysAllTime &&
          other.minutesThisWeek == this.minutesThisWeek &&
          other.minutesAllTime == this.minutesAllTime &&
          other.sessionsAllTime == this.sessionsAllTime &&
          other.minutesByTechniqueJson == this.minutesByTechniqueJson &&
          other.longestSessionMinutes == this.longestSessionMinutes &&
          other.favoriteTechniqueId == this.favoriteTechniqueId &&
          other.totalBreathsEstimated == this.totalBreathsEstimated &&
          other.totalXp == this.totalXp &&
          other.currentLevel == this.currentLevel &&
          other.updatedAt == this.updatedAt);
}

class StatsCacheCompanion extends UpdateCompanion<StatsCacheData> {
  final Value<int> id;
  final Value<int> currentStreakDays;
  final Value<int> longestStreakDays;
  final Value<int> practiceDaysAllTime;
  final Value<int> minutesThisWeek;
  final Value<int> minutesAllTime;
  final Value<int> sessionsAllTime;
  final Value<String> minutesByTechniqueJson;
  final Value<int> longestSessionMinutes;
  final Value<String?> favoriteTechniqueId;
  final Value<int> totalBreathsEstimated;
  final Value<int> totalXp;
  final Value<int> currentLevel;
  final Value<DateTime> updatedAt;
  const StatsCacheCompanion({
    this.id = const Value.absent(),
    this.currentStreakDays = const Value.absent(),
    this.longestStreakDays = const Value.absent(),
    this.practiceDaysAllTime = const Value.absent(),
    this.minutesThisWeek = const Value.absent(),
    this.minutesAllTime = const Value.absent(),
    this.sessionsAllTime = const Value.absent(),
    this.minutesByTechniqueJson = const Value.absent(),
    this.longestSessionMinutes = const Value.absent(),
    this.favoriteTechniqueId = const Value.absent(),
    this.totalBreathsEstimated = const Value.absent(),
    this.totalXp = const Value.absent(),
    this.currentLevel = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  StatsCacheCompanion.insert({
    this.id = const Value.absent(),
    this.currentStreakDays = const Value.absent(),
    this.longestStreakDays = const Value.absent(),
    this.practiceDaysAllTime = const Value.absent(),
    this.minutesThisWeek = const Value.absent(),
    this.minutesAllTime = const Value.absent(),
    this.sessionsAllTime = const Value.absent(),
    this.minutesByTechniqueJson = const Value.absent(),
    this.longestSessionMinutes = const Value.absent(),
    this.favoriteTechniqueId = const Value.absent(),
    this.totalBreathsEstimated = const Value.absent(),
    this.totalXp = const Value.absent(),
    this.currentLevel = const Value.absent(),
    required DateTime updatedAt,
  }) : updatedAt = Value(updatedAt);
  static Insertable<StatsCacheData> custom({
    Expression<int>? id,
    Expression<int>? currentStreakDays,
    Expression<int>? longestStreakDays,
    Expression<int>? practiceDaysAllTime,
    Expression<int>? minutesThisWeek,
    Expression<int>? minutesAllTime,
    Expression<int>? sessionsAllTime,
    Expression<String>? minutesByTechniqueJson,
    Expression<int>? longestSessionMinutes,
    Expression<String>? favoriteTechniqueId,
    Expression<int>? totalBreathsEstimated,
    Expression<int>? totalXp,
    Expression<int>? currentLevel,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (currentStreakDays != null) 'current_streak_days': currentStreakDays,
      if (longestStreakDays != null) 'longest_streak_days': longestStreakDays,
      if (practiceDaysAllTime != null)
        'practice_days_all_time': practiceDaysAllTime,
      if (minutesThisWeek != null) 'minutes_this_week': minutesThisWeek,
      if (minutesAllTime != null) 'minutes_all_time': minutesAllTime,
      if (sessionsAllTime != null) 'sessions_all_time': sessionsAllTime,
      if (minutesByTechniqueJson != null)
        'minutes_by_technique_json': minutesByTechniqueJson,
      if (longestSessionMinutes != null)
        'longest_session_minutes': longestSessionMinutes,
      if (favoriteTechniqueId != null)
        'favorite_technique_id': favoriteTechniqueId,
      if (totalBreathsEstimated != null)
        'total_breaths_estimated': totalBreathsEstimated,
      if (totalXp != null) 'total_xp': totalXp,
      if (currentLevel != null) 'current_level': currentLevel,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  StatsCacheCompanion copyWith({
    Value<int>? id,
    Value<int>? currentStreakDays,
    Value<int>? longestStreakDays,
    Value<int>? practiceDaysAllTime,
    Value<int>? minutesThisWeek,
    Value<int>? minutesAllTime,
    Value<int>? sessionsAllTime,
    Value<String>? minutesByTechniqueJson,
    Value<int>? longestSessionMinutes,
    Value<String?>? favoriteTechniqueId,
    Value<int>? totalBreathsEstimated,
    Value<int>? totalXp,
    Value<int>? currentLevel,
    Value<DateTime>? updatedAt,
  }) {
    return StatsCacheCompanion(
      id: id ?? this.id,
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      longestStreakDays: longestStreakDays ?? this.longestStreakDays,
      practiceDaysAllTime: practiceDaysAllTime ?? this.practiceDaysAllTime,
      minutesThisWeek: minutesThisWeek ?? this.minutesThisWeek,
      minutesAllTime: minutesAllTime ?? this.minutesAllTime,
      sessionsAllTime: sessionsAllTime ?? this.sessionsAllTime,
      minutesByTechniqueJson:
          minutesByTechniqueJson ?? this.minutesByTechniqueJson,
      longestSessionMinutes:
          longestSessionMinutes ?? this.longestSessionMinutes,
      favoriteTechniqueId: favoriteTechniqueId ?? this.favoriteTechniqueId,
      totalBreathsEstimated:
          totalBreathsEstimated ?? this.totalBreathsEstimated,
      totalXp: totalXp ?? this.totalXp,
      currentLevel: currentLevel ?? this.currentLevel,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (currentStreakDays.present) {
      map['current_streak_days'] = Variable<int>(currentStreakDays.value);
    }
    if (longestStreakDays.present) {
      map['longest_streak_days'] = Variable<int>(longestStreakDays.value);
    }
    if (practiceDaysAllTime.present) {
      map['practice_days_all_time'] = Variable<int>(practiceDaysAllTime.value);
    }
    if (minutesThisWeek.present) {
      map['minutes_this_week'] = Variable<int>(minutesThisWeek.value);
    }
    if (minutesAllTime.present) {
      map['minutes_all_time'] = Variable<int>(minutesAllTime.value);
    }
    if (sessionsAllTime.present) {
      map['sessions_all_time'] = Variable<int>(sessionsAllTime.value);
    }
    if (minutesByTechniqueJson.present) {
      map['minutes_by_technique_json'] = Variable<String>(
        minutesByTechniqueJson.value,
      );
    }
    if (longestSessionMinutes.present) {
      map['longest_session_minutes'] = Variable<int>(
        longestSessionMinutes.value,
      );
    }
    if (favoriteTechniqueId.present) {
      map['favorite_technique_id'] = Variable<String>(
        favoriteTechniqueId.value,
      );
    }
    if (totalBreathsEstimated.present) {
      map['total_breaths_estimated'] = Variable<int>(
        totalBreathsEstimated.value,
      );
    }
    if (totalXp.present) {
      map['total_xp'] = Variable<int>(totalXp.value);
    }
    if (currentLevel.present) {
      map['current_level'] = Variable<int>(currentLevel.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StatsCacheCompanion(')
          ..write('id: $id, ')
          ..write('currentStreakDays: $currentStreakDays, ')
          ..write('longestStreakDays: $longestStreakDays, ')
          ..write('practiceDaysAllTime: $practiceDaysAllTime, ')
          ..write('minutesThisWeek: $minutesThisWeek, ')
          ..write('minutesAllTime: $minutesAllTime, ')
          ..write('sessionsAllTime: $sessionsAllTime, ')
          ..write('minutesByTechniqueJson: $minutesByTechniqueJson, ')
          ..write('longestSessionMinutes: $longestSessionMinutes, ')
          ..write('favoriteTechniqueId: $favoriteTechniqueId, ')
          ..write('totalBreathsEstimated: $totalBreathsEstimated, ')
          ..write('totalXp: $totalXp, ')
          ..write('currentLevel: $currentLevel, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $LeaderboardCacheTable extends LeaderboardCache
    with TableInfo<$LeaderboardCacheTable, LeaderboardCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LeaderboardCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rankingMeta = const VerificationMeta(
    'ranking',
  );
  @override
  late final GeneratedColumn<String> ranking = GeneratedColumn<String>(
    'ranking',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowsJsonMeta = const VerificationMeta(
    'rowsJson',
  );
  @override
  late final GeneratedColumn<String> rowsJson = GeneratedColumn<String>(
    'rows_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generatedAtUtcMeta = const VerificationMeta(
    'generatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> generatedAtUtc =
      GeneratedColumn<DateTime>(
        'generated_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ranking,
    rowsJson,
    generatedAtUtc,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'leaderboard_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<LeaderboardCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('ranking')) {
      context.handle(
        _rankingMeta,
        ranking.isAcceptableOrUnknown(data['ranking']!, _rankingMeta),
      );
    } else if (isInserting) {
      context.missing(_rankingMeta);
    }
    if (data.containsKey('rows_json')) {
      context.handle(
        _rowsJsonMeta,
        rowsJson.isAcceptableOrUnknown(data['rows_json']!, _rowsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_rowsJsonMeta);
    }
    if (data.containsKey('generated_at_utc')) {
      context.handle(
        _generatedAtUtcMeta,
        generatedAtUtc.isAcceptableOrUnknown(
          data['generated_at_utc']!,
          _generatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_generatedAtUtcMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ranking};
  @override
  LeaderboardCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LeaderboardCacheData(
      ranking: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ranking'],
      )!,
      rowsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rows_json'],
      )!,
      generatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at_utc'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $LeaderboardCacheTable createAlias(String alias) {
    return $LeaderboardCacheTable(attachedDatabase, alias);
  }
}

class LeaderboardCacheData extends DataClass
    implements Insertable<LeaderboardCacheData> {
  final String ranking;
  final String rowsJson;
  final DateTime generatedAtUtc;
  final DateTime fetchedAt;
  const LeaderboardCacheData({
    required this.ranking,
    required this.rowsJson,
    required this.generatedAtUtc,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['ranking'] = Variable<String>(ranking);
    map['rows_json'] = Variable<String>(rowsJson);
    map['generated_at_utc'] = Variable<DateTime>(generatedAtUtc);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  LeaderboardCacheCompanion toCompanion(bool nullToAbsent) {
    return LeaderboardCacheCompanion(
      ranking: Value(ranking),
      rowsJson: Value(rowsJson),
      generatedAtUtc: Value(generatedAtUtc),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory LeaderboardCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LeaderboardCacheData(
      ranking: serializer.fromJson<String>(json['ranking']),
      rowsJson: serializer.fromJson<String>(json['rowsJson']),
      generatedAtUtc: serializer.fromJson<DateTime>(json['generatedAtUtc']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ranking': serializer.toJson<String>(ranking),
      'rowsJson': serializer.toJson<String>(rowsJson),
      'generatedAtUtc': serializer.toJson<DateTime>(generatedAtUtc),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  LeaderboardCacheData copyWith({
    String? ranking,
    String? rowsJson,
    DateTime? generatedAtUtc,
    DateTime? fetchedAt,
  }) => LeaderboardCacheData(
    ranking: ranking ?? this.ranking,
    rowsJson: rowsJson ?? this.rowsJson,
    generatedAtUtc: generatedAtUtc ?? this.generatedAtUtc,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  LeaderboardCacheData copyWithCompanion(LeaderboardCacheCompanion data) {
    return LeaderboardCacheData(
      ranking: data.ranking.present ? data.ranking.value : this.ranking,
      rowsJson: data.rowsJson.present ? data.rowsJson.value : this.rowsJson,
      generatedAtUtc: data.generatedAtUtc.present
          ? data.generatedAtUtc.value
          : this.generatedAtUtc,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LeaderboardCacheData(')
          ..write('ranking: $ranking, ')
          ..write('rowsJson: $rowsJson, ')
          ..write('generatedAtUtc: $generatedAtUtc, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(ranking, rowsJson, generatedAtUtc, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LeaderboardCacheData &&
          other.ranking == this.ranking &&
          other.rowsJson == this.rowsJson &&
          other.generatedAtUtc == this.generatedAtUtc &&
          other.fetchedAt == this.fetchedAt);
}

class LeaderboardCacheCompanion extends UpdateCompanion<LeaderboardCacheData> {
  final Value<String> ranking;
  final Value<String> rowsJson;
  final Value<DateTime> generatedAtUtc;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const LeaderboardCacheCompanion({
    this.ranking = const Value.absent(),
    this.rowsJson = const Value.absent(),
    this.generatedAtUtc = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LeaderboardCacheCompanion.insert({
    required String ranking,
    required String rowsJson,
    required DateTime generatedAtUtc,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : ranking = Value(ranking),
       rowsJson = Value(rowsJson),
       generatedAtUtc = Value(generatedAtUtc),
       fetchedAt = Value(fetchedAt);
  static Insertable<LeaderboardCacheData> custom({
    Expression<String>? ranking,
    Expression<String>? rowsJson,
    Expression<DateTime>? generatedAtUtc,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ranking != null) 'ranking': ranking,
      if (rowsJson != null) 'rows_json': rowsJson,
      if (generatedAtUtc != null) 'generated_at_utc': generatedAtUtc,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LeaderboardCacheCompanion copyWith({
    Value<String>? ranking,
    Value<String>? rowsJson,
    Value<DateTime>? generatedAtUtc,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return LeaderboardCacheCompanion(
      ranking: ranking ?? this.ranking,
      rowsJson: rowsJson ?? this.rowsJson,
      generatedAtUtc: generatedAtUtc ?? this.generatedAtUtc,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ranking.present) {
      map['ranking'] = Variable<String>(ranking.value);
    }
    if (rowsJson.present) {
      map['rows_json'] = Variable<String>(rowsJson.value);
    }
    if (generatedAtUtc.present) {
      map['generated_at_utc'] = Variable<DateTime>(generatedAtUtc.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LeaderboardCacheCompanion(')
          ..write('ranking: $ranking, ')
          ..write('rowsJson: $rowsJson, ')
          ..write('generatedAtUtc: $generatedAtUtc, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>(
        'last_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    payload,
    status,
    attempts,
    lastAttemptAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final int id;
  final String entityType;
  final String entityId;
  final String payload;
  final String status;
  final int attempts;
  final DateTime? lastAttemptAt;
  final DateTime createdAt;
  const SyncQueueData({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.payload,
    required this.status,
    required this.attempts,
    this.lastAttemptAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['payload'] = Variable<String>(payload);
    map['status'] = Variable<String>(status);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      payload: Value(payload),
      status: Value(status),
      attempts: Value(attempts),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      createdAt: Value(createdAt),
    );
  }

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      payload: serializer.fromJson<String>(json['payload']),
      status: serializer.fromJson<String>(json['status']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'payload': serializer.toJson<String>(payload),
      'status': serializer.toJson<String>(status),
      'attempts': serializer.toJson<int>(attempts),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncQueueData copyWith({
    int? id,
    String? entityType,
    String? entityId,
    String? payload,
    String? status,
    int? attempts,
    Value<DateTime?> lastAttemptAt = const Value.absent(),
    DateTime? createdAt,
  }) => SyncQueueData(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    payload: payload ?? this.payload,
    status: status ?? this.status,
    attempts: attempts ?? this.attempts,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
    createdAt: createdAt ?? this.createdAt,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      payload: data.payload.present ? data.payload.value : this.payload,
      status: data.status.present ? data.status.value : this.status,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    payload,
    status,
    attempts,
    lastAttemptAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.payload == this.payload &&
          other.status == this.status &&
          other.attempts == this.attempts &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.createdAt == this.createdAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> payload;
  final Value<String> status;
  final Value<int> attempts;
  final Value<DateTime?> lastAttemptAt;
  final Value<DateTime> createdAt;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.payload = const Value.absent(),
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required String entityId,
    required String payload,
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    required DateTime createdAt,
  }) : entityType = Value(entityType),
       entityId = Value(entityId),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? payload,
    Expression<String>? status,
    Expression<int>? attempts,
    Expression<DateTime>? lastAttemptAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (payload != null) 'payload': payload,
      if (status != null) 'status': status,
      if (attempts != null) 'attempts': attempts,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? payload,
    Value<String>? status,
    Value<int>? attempts,
    Value<DateTime?>? lastAttemptAt,
    Value<DateTime>? createdAt,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PreferencesTable preferences = $PreferencesTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $FavoritesTable favorites = $FavoritesTable(this);
  late final $SafetyAckTable safetyAck = $SafetyAckTable(this);
  late final $StatsCacheTable statsCache = $StatsCacheTable(this);
  late final $LeaderboardCacheTable leaderboardCache = $LeaderboardCacheTable(
    this,
  );
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    preferences,
    sessions,
    favorites,
    safetyAck,
    statsCache,
    leaderboardCache,
    syncQueue,
  ];
}

typedef $$PreferencesTableCreateCompanionBuilder =
    PreferencesCompanion Function({
      Value<int> id,
      Value<bool> introComplete,
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
      Value<bool> reminderEnabled,
      Value<bool> streakWarningEnabled,
      Value<bool> firstSessionCompleted,
      Value<bool> notificationPermissionAsked,
      Value<String> displayName,
      Value<String> guestUsername,
    });
typedef $$PreferencesTableUpdateCompanionBuilder =
    PreferencesCompanion Function({
      Value<int> id,
      Value<bool> introComplete,
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
      Value<bool> reminderEnabled,
      Value<bool> streakWarningEnabled,
      Value<bool> firstSessionCompleted,
      Value<bool> notificationPermissionAsked,
      Value<String> displayName,
      Value<String> guestUsername,
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

  ColumnFilters<bool> get introComplete => $composableBuilder(
    column: $table.introComplete,
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

  ColumnFilters<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get streakWarningEnabled => $composableBuilder(
    column: $table.streakWarningEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get firstSessionCompleted => $composableBuilder(
    column: $table.firstSessionCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationPermissionAsked => $composableBuilder(
    column: $table.notificationPermissionAsked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guestUsername => $composableBuilder(
    column: $table.guestUsername,
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

  ColumnOrderings<bool> get introComplete => $composableBuilder(
    column: $table.introComplete,
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

  ColumnOrderings<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get streakWarningEnabled => $composableBuilder(
    column: $table.streakWarningEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get firstSessionCompleted => $composableBuilder(
    column: $table.firstSessionCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationPermissionAsked => $composableBuilder(
    column: $table.notificationPermissionAsked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guestUsername => $composableBuilder(
    column: $table.guestUsername,
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

  GeneratedColumn<bool> get introComplete => $composableBuilder(
    column: $table.introComplete,
    builder: (column) => column,
  );

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

  GeneratedColumn<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get streakWarningEnabled => $composableBuilder(
    column: $table.streakWarningEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get firstSessionCompleted => $composableBuilder(
    column: $table.firstSessionCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notificationPermissionAsked => $composableBuilder(
    column: $table.notificationPermissionAsked,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get guestUsername => $composableBuilder(
    column: $table.guestUsername,
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
                Value<bool> introComplete = const Value.absent(),
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
                Value<bool> reminderEnabled = const Value.absent(),
                Value<bool> streakWarningEnabled = const Value.absent(),
                Value<bool> firstSessionCompleted = const Value.absent(),
                Value<bool> notificationPermissionAsked = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> guestUsername = const Value.absent(),
              }) => PreferencesCompanion(
                id: id,
                introComplete: introComplete,
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
                reminderEnabled: reminderEnabled,
                streakWarningEnabled: streakWarningEnabled,
                firstSessionCompleted: firstSessionCompleted,
                notificationPermissionAsked: notificationPermissionAsked,
                displayName: displayName,
                guestUsername: guestUsername,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> introComplete = const Value.absent(),
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
                Value<bool> reminderEnabled = const Value.absent(),
                Value<bool> streakWarningEnabled = const Value.absent(),
                Value<bool> firstSessionCompleted = const Value.absent(),
                Value<bool> notificationPermissionAsked = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> guestUsername = const Value.absent(),
              }) => PreferencesCompanion.insert(
                id: id,
                introComplete: introComplete,
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
                reminderEnabled: reminderEnabled,
                streakWarningEnabled: streakWarningEnabled,
                firstSessionCompleted: firstSessionCompleted,
                notificationPermissionAsked: notificationPermissionAsked,
                displayName: displayName,
                guestUsername: guestUsername,
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
typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      required String clientSessionId,
      required String techniqueId,
      required String presetId,
      required DateTime startedAtUtc,
      required DateTime endedAtUtc,
      required int timezoneOffsetMinutes,
      required int durationSecondsActual,
      required int breathsCompletedEstimated,
      Value<bool> endedEarly,
      Value<bool> syncedToCloud,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<String> clientSessionId,
      Value<String> techniqueId,
      Value<String> presetId,
      Value<DateTime> startedAtUtc,
      Value<DateTime> endedAtUtc,
      Value<int> timezoneOffsetMinutes,
      Value<int> durationSecondsActual,
      Value<int> breathsCompletedEstimated,
      Value<bool> endedEarly,
      Value<bool> syncedToCloud,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientSessionId => $composableBuilder(
    column: $table.clientSessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get techniqueId => $composableBuilder(
    column: $table.techniqueId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get presetId => $composableBuilder(
    column: $table.presetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAtUtc => $composableBuilder(
    column: $table.endedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timezoneOffsetMinutes => $composableBuilder(
    column: $table.timezoneOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSecondsActual => $composableBuilder(
    column: $table.durationSecondsActual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get breathsCompletedEstimated => $composableBuilder(
    column: $table.breathsCompletedEstimated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get endedEarly => $composableBuilder(
    column: $table.endedEarly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get syncedToCloud => $composableBuilder(
    column: $table.syncedToCloud,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientSessionId => $composableBuilder(
    column: $table.clientSessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get techniqueId => $composableBuilder(
    column: $table.techniqueId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get presetId => $composableBuilder(
    column: $table.presetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAtUtc => $composableBuilder(
    column: $table.endedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timezoneOffsetMinutes => $composableBuilder(
    column: $table.timezoneOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSecondsActual => $composableBuilder(
    column: $table.durationSecondsActual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get breathsCompletedEstimated => $composableBuilder(
    column: $table.breathsCompletedEstimated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get endedEarly => $composableBuilder(
    column: $table.endedEarly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get syncedToCloud => $composableBuilder(
    column: $table.syncedToCloud,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientSessionId => $composableBuilder(
    column: $table.clientSessionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get techniqueId => $composableBuilder(
    column: $table.techniqueId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get presetId =>
      $composableBuilder(column: $table.presetId, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get endedAtUtc => $composableBuilder(
    column: $table.endedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timezoneOffsetMinutes => $composableBuilder(
    column: $table.timezoneOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSecondsActual => $composableBuilder(
    column: $table.durationSecondsActual,
    builder: (column) => column,
  );

  GeneratedColumn<int> get breathsCompletedEstimated => $composableBuilder(
    column: $table.breathsCompletedEstimated,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get endedEarly => $composableBuilder(
    column: $table.endedEarly,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get syncedToCloud => $composableBuilder(
    column: $table.syncedToCloud,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
          Session,
          PrefetchHooks Function()
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> clientSessionId = const Value.absent(),
                Value<String> techniqueId = const Value.absent(),
                Value<String> presetId = const Value.absent(),
                Value<DateTime> startedAtUtc = const Value.absent(),
                Value<DateTime> endedAtUtc = const Value.absent(),
                Value<int> timezoneOffsetMinutes = const Value.absent(),
                Value<int> durationSecondsActual = const Value.absent(),
                Value<int> breathsCompletedEstimated = const Value.absent(),
                Value<bool> endedEarly = const Value.absent(),
                Value<bool> syncedToCloud = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion(
                clientSessionId: clientSessionId,
                techniqueId: techniqueId,
                presetId: presetId,
                startedAtUtc: startedAtUtc,
                endedAtUtc: endedAtUtc,
                timezoneOffsetMinutes: timezoneOffsetMinutes,
                durationSecondsActual: durationSecondsActual,
                breathsCompletedEstimated: breathsCompletedEstimated,
                endedEarly: endedEarly,
                syncedToCloud: syncedToCloud,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clientSessionId,
                required String techniqueId,
                required String presetId,
                required DateTime startedAtUtc,
                required DateTime endedAtUtc,
                required int timezoneOffsetMinutes,
                required int durationSecondsActual,
                required int breathsCompletedEstimated,
                Value<bool> endedEarly = const Value.absent(),
                Value<bool> syncedToCloud = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion.insert(
                clientSessionId: clientSessionId,
                techniqueId: techniqueId,
                presetId: presetId,
                startedAtUtc: startedAtUtc,
                endedAtUtc: endedAtUtc,
                timezoneOffsetMinutes: timezoneOffsetMinutes,
                durationSecondsActual: durationSecondsActual,
                breathsCompletedEstimated: breathsCompletedEstimated,
                endedEarly: endedEarly,
                syncedToCloud: syncedToCloud,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
      Session,
      PrefetchHooks Function()
    >;
typedef $$FavoritesTableCreateCompanionBuilder =
    FavoritesCompanion Function({
      required String techniqueId,
      required DateTime addedAt,
      Value<int> rowid,
    });
typedef $$FavoritesTableUpdateCompanionBuilder =
    FavoritesCompanion Function({
      Value<String> techniqueId,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });

class $$FavoritesTableFilterComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get techniqueId => $composableBuilder(
    column: $table.techniqueId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoritesTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get techniqueId => $composableBuilder(
    column: $table.techniqueId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoritesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get techniqueId => $composableBuilder(
    column: $table.techniqueId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$FavoritesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoritesTable,
          Favorite,
          $$FavoritesTableFilterComposer,
          $$FavoritesTableOrderingComposer,
          $$FavoritesTableAnnotationComposer,
          $$FavoritesTableCreateCompanionBuilder,
          $$FavoritesTableUpdateCompanionBuilder,
          (Favorite, BaseReferences<_$AppDatabase, $FavoritesTable, Favorite>),
          Favorite,
          PrefetchHooks Function()
        > {
  $$FavoritesTableTableManager(_$AppDatabase db, $FavoritesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> techniqueId = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoritesCompanion(
                techniqueId: techniqueId,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String techniqueId,
                required DateTime addedAt,
                Value<int> rowid = const Value.absent(),
              }) => FavoritesCompanion.insert(
                techniqueId: techniqueId,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoritesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoritesTable,
      Favorite,
      $$FavoritesTableFilterComposer,
      $$FavoritesTableOrderingComposer,
      $$FavoritesTableAnnotationComposer,
      $$FavoritesTableCreateCompanionBuilder,
      $$FavoritesTableUpdateCompanionBuilder,
      (Favorite, BaseReferences<_$AppDatabase, $FavoritesTable, Favorite>),
      Favorite,
      PrefetchHooks Function()
    >;
typedef $$SafetyAckTableCreateCompanionBuilder =
    SafetyAckCompanion Function({
      required String techniqueId,
      required DateTime acknowledgedAt,
      Value<int> rowid,
    });
typedef $$SafetyAckTableUpdateCompanionBuilder =
    SafetyAckCompanion Function({
      Value<String> techniqueId,
      Value<DateTime> acknowledgedAt,
      Value<int> rowid,
    });

class $$SafetyAckTableFilterComposer
    extends Composer<_$AppDatabase, $SafetyAckTable> {
  $$SafetyAckTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get techniqueId => $composableBuilder(
    column: $table.techniqueId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get acknowledgedAt => $composableBuilder(
    column: $table.acknowledgedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SafetyAckTableOrderingComposer
    extends Composer<_$AppDatabase, $SafetyAckTable> {
  $$SafetyAckTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get techniqueId => $composableBuilder(
    column: $table.techniqueId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get acknowledgedAt => $composableBuilder(
    column: $table.acknowledgedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SafetyAckTableAnnotationComposer
    extends Composer<_$AppDatabase, $SafetyAckTable> {
  $$SafetyAckTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get techniqueId => $composableBuilder(
    column: $table.techniqueId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get acknowledgedAt => $composableBuilder(
    column: $table.acknowledgedAt,
    builder: (column) => column,
  );
}

class $$SafetyAckTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SafetyAckTable,
          SafetyAckData,
          $$SafetyAckTableFilterComposer,
          $$SafetyAckTableOrderingComposer,
          $$SafetyAckTableAnnotationComposer,
          $$SafetyAckTableCreateCompanionBuilder,
          $$SafetyAckTableUpdateCompanionBuilder,
          (
            SafetyAckData,
            BaseReferences<_$AppDatabase, $SafetyAckTable, SafetyAckData>,
          ),
          SafetyAckData,
          PrefetchHooks Function()
        > {
  $$SafetyAckTableTableManager(_$AppDatabase db, $SafetyAckTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SafetyAckTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SafetyAckTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SafetyAckTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> techniqueId = const Value.absent(),
                Value<DateTime> acknowledgedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SafetyAckCompanion(
                techniqueId: techniqueId,
                acknowledgedAt: acknowledgedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String techniqueId,
                required DateTime acknowledgedAt,
                Value<int> rowid = const Value.absent(),
              }) => SafetyAckCompanion.insert(
                techniqueId: techniqueId,
                acknowledgedAt: acknowledgedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SafetyAckTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SafetyAckTable,
      SafetyAckData,
      $$SafetyAckTableFilterComposer,
      $$SafetyAckTableOrderingComposer,
      $$SafetyAckTableAnnotationComposer,
      $$SafetyAckTableCreateCompanionBuilder,
      $$SafetyAckTableUpdateCompanionBuilder,
      (
        SafetyAckData,
        BaseReferences<_$AppDatabase, $SafetyAckTable, SafetyAckData>,
      ),
      SafetyAckData,
      PrefetchHooks Function()
    >;
typedef $$StatsCacheTableCreateCompanionBuilder =
    StatsCacheCompanion Function({
      Value<int> id,
      Value<int> currentStreakDays,
      Value<int> longestStreakDays,
      Value<int> practiceDaysAllTime,
      Value<int> minutesThisWeek,
      Value<int> minutesAllTime,
      Value<int> sessionsAllTime,
      Value<String> minutesByTechniqueJson,
      Value<int> longestSessionMinutes,
      Value<String?> favoriteTechniqueId,
      Value<int> totalBreathsEstimated,
      Value<int> totalXp,
      Value<int> currentLevel,
      required DateTime updatedAt,
    });
typedef $$StatsCacheTableUpdateCompanionBuilder =
    StatsCacheCompanion Function({
      Value<int> id,
      Value<int> currentStreakDays,
      Value<int> longestStreakDays,
      Value<int> practiceDaysAllTime,
      Value<int> minutesThisWeek,
      Value<int> minutesAllTime,
      Value<int> sessionsAllTime,
      Value<String> minutesByTechniqueJson,
      Value<int> longestSessionMinutes,
      Value<String?> favoriteTechniqueId,
      Value<int> totalBreathsEstimated,
      Value<int> totalXp,
      Value<int> currentLevel,
      Value<DateTime> updatedAt,
    });

class $$StatsCacheTableFilterComposer
    extends Composer<_$AppDatabase, $StatsCacheTable> {
  $$StatsCacheTableFilterComposer({
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

  ColumnFilters<int> get currentStreakDays => $composableBuilder(
    column: $table.currentStreakDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get longestStreakDays => $composableBuilder(
    column: $table.longestStreakDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get practiceDaysAllTime => $composableBuilder(
    column: $table.practiceDaysAllTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minutesThisWeek => $composableBuilder(
    column: $table.minutesThisWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minutesAllTime => $composableBuilder(
    column: $table.minutesAllTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionsAllTime => $composableBuilder(
    column: $table.sessionsAllTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get minutesByTechniqueJson => $composableBuilder(
    column: $table.minutesByTechniqueJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get longestSessionMinutes => $composableBuilder(
    column: $table.longestSessionMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get favoriteTechniqueId => $composableBuilder(
    column: $table.favoriteTechniqueId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalBreathsEstimated => $composableBuilder(
    column: $table.totalBreathsEstimated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalXp => $composableBuilder(
    column: $table.totalXp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentLevel => $composableBuilder(
    column: $table.currentLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StatsCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $StatsCacheTable> {
  $$StatsCacheTableOrderingComposer({
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

  ColumnOrderings<int> get currentStreakDays => $composableBuilder(
    column: $table.currentStreakDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get longestStreakDays => $composableBuilder(
    column: $table.longestStreakDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get practiceDaysAllTime => $composableBuilder(
    column: $table.practiceDaysAllTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minutesThisWeek => $composableBuilder(
    column: $table.minutesThisWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minutesAllTime => $composableBuilder(
    column: $table.minutesAllTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionsAllTime => $composableBuilder(
    column: $table.sessionsAllTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get minutesByTechniqueJson => $composableBuilder(
    column: $table.minutesByTechniqueJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get longestSessionMinutes => $composableBuilder(
    column: $table.longestSessionMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get favoriteTechniqueId => $composableBuilder(
    column: $table.favoriteTechniqueId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalBreathsEstimated => $composableBuilder(
    column: $table.totalBreathsEstimated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalXp => $composableBuilder(
    column: $table.totalXp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentLevel => $composableBuilder(
    column: $table.currentLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StatsCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $StatsCacheTable> {
  $$StatsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get currentStreakDays => $composableBuilder(
    column: $table.currentStreakDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get longestStreakDays => $composableBuilder(
    column: $table.longestStreakDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get practiceDaysAllTime => $composableBuilder(
    column: $table.practiceDaysAllTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minutesThisWeek => $composableBuilder(
    column: $table.minutesThisWeek,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minutesAllTime => $composableBuilder(
    column: $table.minutesAllTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sessionsAllTime => $composableBuilder(
    column: $table.sessionsAllTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get minutesByTechniqueJson => $composableBuilder(
    column: $table.minutesByTechniqueJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get longestSessionMinutes => $composableBuilder(
    column: $table.longestSessionMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get favoriteTechniqueId => $composableBuilder(
    column: $table.favoriteTechniqueId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalBreathsEstimated => $composableBuilder(
    column: $table.totalBreathsEstimated,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalXp =>
      $composableBuilder(column: $table.totalXp, builder: (column) => column);

  GeneratedColumn<int> get currentLevel => $composableBuilder(
    column: $table.currentLevel,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$StatsCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StatsCacheTable,
          StatsCacheData,
          $$StatsCacheTableFilterComposer,
          $$StatsCacheTableOrderingComposer,
          $$StatsCacheTableAnnotationComposer,
          $$StatsCacheTableCreateCompanionBuilder,
          $$StatsCacheTableUpdateCompanionBuilder,
          (
            StatsCacheData,
            BaseReferences<_$AppDatabase, $StatsCacheTable, StatsCacheData>,
          ),
          StatsCacheData,
          PrefetchHooks Function()
        > {
  $$StatsCacheTableTableManager(_$AppDatabase db, $StatsCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StatsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StatsCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StatsCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> currentStreakDays = const Value.absent(),
                Value<int> longestStreakDays = const Value.absent(),
                Value<int> practiceDaysAllTime = const Value.absent(),
                Value<int> minutesThisWeek = const Value.absent(),
                Value<int> minutesAllTime = const Value.absent(),
                Value<int> sessionsAllTime = const Value.absent(),
                Value<String> minutesByTechniqueJson = const Value.absent(),
                Value<int> longestSessionMinutes = const Value.absent(),
                Value<String?> favoriteTechniqueId = const Value.absent(),
                Value<int> totalBreathsEstimated = const Value.absent(),
                Value<int> totalXp = const Value.absent(),
                Value<int> currentLevel = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => StatsCacheCompanion(
                id: id,
                currentStreakDays: currentStreakDays,
                longestStreakDays: longestStreakDays,
                practiceDaysAllTime: practiceDaysAllTime,
                minutesThisWeek: minutesThisWeek,
                minutesAllTime: minutesAllTime,
                sessionsAllTime: sessionsAllTime,
                minutesByTechniqueJson: minutesByTechniqueJson,
                longestSessionMinutes: longestSessionMinutes,
                favoriteTechniqueId: favoriteTechniqueId,
                totalBreathsEstimated: totalBreathsEstimated,
                totalXp: totalXp,
                currentLevel: currentLevel,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> currentStreakDays = const Value.absent(),
                Value<int> longestStreakDays = const Value.absent(),
                Value<int> practiceDaysAllTime = const Value.absent(),
                Value<int> minutesThisWeek = const Value.absent(),
                Value<int> minutesAllTime = const Value.absent(),
                Value<int> sessionsAllTime = const Value.absent(),
                Value<String> minutesByTechniqueJson = const Value.absent(),
                Value<int> longestSessionMinutes = const Value.absent(),
                Value<String?> favoriteTechniqueId = const Value.absent(),
                Value<int> totalBreathsEstimated = const Value.absent(),
                Value<int> totalXp = const Value.absent(),
                Value<int> currentLevel = const Value.absent(),
                required DateTime updatedAt,
              }) => StatsCacheCompanion.insert(
                id: id,
                currentStreakDays: currentStreakDays,
                longestStreakDays: longestStreakDays,
                practiceDaysAllTime: practiceDaysAllTime,
                minutesThisWeek: minutesThisWeek,
                minutesAllTime: minutesAllTime,
                sessionsAllTime: sessionsAllTime,
                minutesByTechniqueJson: minutesByTechniqueJson,
                longestSessionMinutes: longestSessionMinutes,
                favoriteTechniqueId: favoriteTechniqueId,
                totalBreathsEstimated: totalBreathsEstimated,
                totalXp: totalXp,
                currentLevel: currentLevel,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StatsCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StatsCacheTable,
      StatsCacheData,
      $$StatsCacheTableFilterComposer,
      $$StatsCacheTableOrderingComposer,
      $$StatsCacheTableAnnotationComposer,
      $$StatsCacheTableCreateCompanionBuilder,
      $$StatsCacheTableUpdateCompanionBuilder,
      (
        StatsCacheData,
        BaseReferences<_$AppDatabase, $StatsCacheTable, StatsCacheData>,
      ),
      StatsCacheData,
      PrefetchHooks Function()
    >;
typedef $$LeaderboardCacheTableCreateCompanionBuilder =
    LeaderboardCacheCompanion Function({
      required String ranking,
      required String rowsJson,
      required DateTime generatedAtUtc,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$LeaderboardCacheTableUpdateCompanionBuilder =
    LeaderboardCacheCompanion Function({
      Value<String> ranking,
      Value<String> rowsJson,
      Value<DateTime> generatedAtUtc,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$LeaderboardCacheTableFilterComposer
    extends Composer<_$AppDatabase, $LeaderboardCacheTable> {
  $$LeaderboardCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ranking => $composableBuilder(
    column: $table.ranking,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rowsJson => $composableBuilder(
    column: $table.rowsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get generatedAtUtc => $composableBuilder(
    column: $table.generatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LeaderboardCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $LeaderboardCacheTable> {
  $$LeaderboardCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ranking => $composableBuilder(
    column: $table.ranking,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rowsJson => $composableBuilder(
    column: $table.rowsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get generatedAtUtc => $composableBuilder(
    column: $table.generatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LeaderboardCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $LeaderboardCacheTable> {
  $$LeaderboardCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ranking =>
      $composableBuilder(column: $table.ranking, builder: (column) => column);

  GeneratedColumn<String> get rowsJson =>
      $composableBuilder(column: $table.rowsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get generatedAtUtc => $composableBuilder(
    column: $table.generatedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$LeaderboardCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LeaderboardCacheTable,
          LeaderboardCacheData,
          $$LeaderboardCacheTableFilterComposer,
          $$LeaderboardCacheTableOrderingComposer,
          $$LeaderboardCacheTableAnnotationComposer,
          $$LeaderboardCacheTableCreateCompanionBuilder,
          $$LeaderboardCacheTableUpdateCompanionBuilder,
          (
            LeaderboardCacheData,
            BaseReferences<
              _$AppDatabase,
              $LeaderboardCacheTable,
              LeaderboardCacheData
            >,
          ),
          LeaderboardCacheData,
          PrefetchHooks Function()
        > {
  $$LeaderboardCacheTableTableManager(
    _$AppDatabase db,
    $LeaderboardCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LeaderboardCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LeaderboardCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LeaderboardCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ranking = const Value.absent(),
                Value<String> rowsJson = const Value.absent(),
                Value<DateTime> generatedAtUtc = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LeaderboardCacheCompanion(
                ranking: ranking,
                rowsJson: rowsJson,
                generatedAtUtc: generatedAtUtc,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ranking,
                required String rowsJson,
                required DateTime generatedAtUtc,
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => LeaderboardCacheCompanion.insert(
                ranking: ranking,
                rowsJson: rowsJson,
                generatedAtUtc: generatedAtUtc,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LeaderboardCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LeaderboardCacheTable,
      LeaderboardCacheData,
      $$LeaderboardCacheTableFilterComposer,
      $$LeaderboardCacheTableOrderingComposer,
      $$LeaderboardCacheTableAnnotationComposer,
      $$LeaderboardCacheTableCreateCompanionBuilder,
      $$LeaderboardCacheTableUpdateCompanionBuilder,
      (
        LeaderboardCacheData,
        BaseReferences<
          _$AppDatabase,
          $LeaderboardCacheTable,
          LeaderboardCacheData
        >,
      ),
      LeaderboardCacheData,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      required String entityType,
      required String entityId,
      required String payload,
      Value<String> status,
      Value<int> attempts,
      Value<DateTime?> lastAttemptAt,
      required DateTime createdAt,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> payload,
      Value<String> status,
      Value<int> attempts,
      Value<DateTime?> lastAttemptAt,
      Value<DateTime> createdAt,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
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

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
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

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueData,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueData,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
          ),
          SyncQueueData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                payload: payload,
                status: status,
                attempts: attempts,
                lastAttemptAt: lastAttemptAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityType,
                required String entityId,
                required String payload,
                Value<String> status = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                required DateTime createdAt,
              }) => SyncQueueCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                payload: payload,
                status: status,
                attempts: attempts,
                lastAttemptAt: lastAttemptAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueData,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueData,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
      ),
      SyncQueueData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PreferencesTableTableManager get preferences =>
      $$PreferencesTableTableManager(_db, _db.preferences);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$FavoritesTableTableManager get favorites =>
      $$FavoritesTableTableManager(_db, _db.favorites);
  $$SafetyAckTableTableManager get safetyAck =>
      $$SafetyAckTableTableManager(_db, _db.safetyAck);
  $$StatsCacheTableTableManager get statsCache =>
      $$StatsCacheTableTableManager(_db, _db.statsCache);
  $$LeaderboardCacheTableTableManager get leaderboardCache =>
      $$LeaderboardCacheTableTableManager(_db, _db.leaderboardCache);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}
