import 'package:flutter_test/flutter_test.dart';

import 'package:physio_ghar/core/localization/app_language.dart';
import 'package:physio_ghar/core/utils/validators.dart';

void main() {
  test('phone accepts Nepali mobiles only', () {
    expect(validatePhone('9841234567'), isNull);
    expect(validatePhone('+977 9741234567'), isNull);
    expect(validatePhone('984-123-4567'), isNull);
    expect(validatePhone('9641234567'), isNotNull);
    expect(validatePhone('984123'), isNotNull);
  });

  test('email', () {
    expect(validateEmail('a@b.co'), isNull);
    expect(validateEmail('not-an-email'), isNotNull);
    expect(validateEmail(''), isNotNull);
  });

  test('experience is a whole number from 0 to 50', () {
    expect(validateExperience('0'), isNull);
    expect(validateExperience('50'), isNull);
    expect(validateExperience('51'), isNotNull);
    expect(validateExperience('abc'), isNotNull);
  });

  test('password needs 8+ characters with a letter and a number', () {
    expect(validatePassword('physio123'), isNull);
    expect(validatePassword('short1'), isNotNull);
    expect(validatePassword('lettersonly'), isNotNull);
  });

  test('length', () {
    expect(validateLength('Hello', min: 5, max: 80, field: 'subject'), isNull);
    expect(validateLength('   ', min: 5, max: 80, field: 'subject'), 'Enter a subject');
    expect(
      validateLength('Hi', min: 5, max: 80, field: 'subject'),
      'Subject must be at least 5 characters',
    );
  });

  test('Nepali strings translate names, places and ages', () {
    const ne = AppStrings.ne;
    expect(ne.name('Sita Sharma'), 'सीता शर्मा');
    expect(ne.name('Unknown Person'), 'Unknown Person');
    expect(ne.place('Baneshwor, Kathmandu'), 'बानेश्वर, काठमाडौं');
    expect(ne.age(42), 'उमेर ४२');
    expect(AppStrings.en.age(42), 'Age 42');
  });
}
