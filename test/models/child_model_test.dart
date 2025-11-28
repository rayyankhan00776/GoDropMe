import 'package:flutter_test/flutter_test.dart';
import 'package:godropme/features/parentSide/addChildren/models/child.dart';

void main() {
  group('ChildModel', () {
    test('toJson/fromJson round-trip preserves fields', () {
      const child = ChildModel(
        name: 'Ali',
        age: 8,
        gender: 'Male',
        schoolName: 'City School',
        pickPoint: 'Home',
        dropPoint: 'School',
        relationshipToChild: 'Father',
        schoolOpenTime: '07:30 AM',
        schoolOffTime: '02:00 PM',
      );

      final json = child.toJson();
      final parsed = ChildModel.fromJson(json);

      expect(parsed.name, child.name);
      expect(parsed.age, child.age);
      expect(parsed.gender, child.gender);
      expect(parsed.schoolName, child.schoolName);
      expect(parsed.pickPoint, child.pickPoint);
      expect(parsed.dropPoint, child.dropPoint);
      expect(parsed.relationshipToChild, child.relationshipToChild);
      expect(parsed.schoolOpenTime, child.schoolOpenTime);
      expect(parsed.schoolOffTime, child.schoolOffTime);
    });

    test('fromJson tolerates loose types', () {
      final json = <String, dynamic>{
        'name': 'Sara',
        'age': '9', // string age should be parsed
        'gender': 'Female',
        'schoolName': 'Beaconhouse',
        'pickPoint': 'Home',
        'dropPoint': 'School',
        'relationshipToChild': 'Mother',
      };

      final child = ChildModel.fromJson(json);
      expect(child.name, 'Sara');
      expect(child.age, 9);
    });
  });
}
