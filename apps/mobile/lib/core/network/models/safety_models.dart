import 'json_parsing.dart';

class SafetyAcknowledgements {
  const SafetyAcknowledgements({required this.techniqueIds});

  factory SafetyAcknowledgements.fromJson(JsonMap json) {
    return SafetyAcknowledgements(
      techniqueIds: readStringList(json, 'technique_ids'),
    );
  }

  final List<String> techniqueIds;

  JsonMap toJson() {
    return {'technique_ids': techniqueIds};
  }
}

