class ChildrenFormOptions {
  final List<String> ages;
  final List<String> genders;
  final List<String> schools;
  final List<String> relations;

  const ChildrenFormOptions({
    required this.ages,
    required this.genders,
    required this.schools,
    required this.relations,
  });

  factory ChildrenFormOptions.fallback() {
    final ages = List<String>.generate(22, (i) => (i + 4).toString()); // 4..25
    const genders = ['Male', 'Female'];
    const relations = [
      'Father',
      'Mother',
      'Brother',
      'Sister',
      'Uncle',
      'Aunt',
      'Guardian',
      'Grandfather',
      'Grandmother',
    ];
    const schools = [
      'Peshawar Model School Boys I (Hayatabad)',
      'Peshawar Model School Boys II (Dalazak Road)',
      'Peshawar Model School Boys III (Warsak Road)',
      'Peshawar Model School Boys IV (Charsadda Road)',
      'Peshawar Model School Girls I (Dalazak Road)',
      'Peshawar Model School Girls II (Warsak Road)',
      'Peshawar Model School Girls III (Charsadda Road)',
      'Peshawar Model School Girls IV (Hayatabad)',
      'Peshawar Model Degree College (Boys)',
      'Peshawar Model Degree College (Girls)',
      'Beaconhouse School System',
      'The City School',
      'Roots International Schools',
      'Edwardes College School',
      'Lahore Grammar School (LGS)',
      'ICMS School System',
      'Frontier Children Academy',
      'Forward Public School',
      'St. Mary’s High School',
      'Qurtuba School & College',
      'Allied School Peshawar Campus',
      'Oxford Public School',
      'The Peace School & College',
      'Pak-Turk Maarif International School',
      'Frontier Model School',
      'Rehman Baba School System',
      'Iqra School System',
      'The Knowledge School',
      'Usman Public School',
      'Khyber Model School',
      'Hudaibiya Public School',
      'Al-Huda International School (Peshawar Campus)',
    ];
    return ChildrenFormOptions(
      ages: ages,
      genders: genders,
      schools: schools,
      relations: relations,
    );
  }
}
