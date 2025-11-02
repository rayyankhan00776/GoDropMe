import 'package:flutter_test/flutter_test.dart';
import 'package:godropme/features/driverSide/driverRegistration/models/personal_info.dart';

void main() {
  group('PersonalInfo', () {
    test('toJson/fromJson round-trip', () {
      const info = PersonalInfo(
        firstName: 'Muhammad',
        surName: 'Rayyan',
        lastName: 'Khan',
        photoPath: '/tmp/p.png',
      );
      final json = info.toJson();
      final parsed = PersonalInfo.fromJson(json);

      expect(parsed.firstName, info.firstName);
      expect(parsed.surName, info.surName);
      expect(parsed.lastName, info.lastName);
      expect(parsed.photoPath, info.photoPath);
    });
  });
}
