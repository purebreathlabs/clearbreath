import 'package:clearbreath/core/network/models/auth_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('toJson includes first_name and last_name when provided', () {
    final req = ProviderSignInRequest(
      provider: 'google',
      idToken: 'token',
      deviceId: 'device1',
      firstName: 'Jane',
      lastName: 'Doe',
    );
    final json = req.toJson();
    expect(json['first_name'], equals('Jane'));
    expect(json['last_name'], equals('Doe'));
  });

  test('toJson omits first_name and last_name when null', () {
    final req = ProviderSignInRequest(
      provider: 'google',
      idToken: 'token',
      deviceId: 'device1',
    );
    final json = req.toJson();
    expect(json.containsKey('first_name'), isFalse);
    expect(json.containsKey('last_name'), isFalse);
  });

  test('toJson omits first_name and last_name when blank', () {
    final req = ProviderSignInRequest(
      provider: 'google',
      idToken: 'token',
      deviceId: 'device1',
      firstName: '  ',
      lastName: '',
    );
    final json = req.toJson();
    expect(json.containsKey('first_name'), isFalse);
    expect(json.containsKey('last_name'), isFalse);
  });
}
