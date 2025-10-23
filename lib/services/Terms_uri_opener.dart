// ignore_for_file: file_names

import 'package:url_launcher/url_launcher.dart';

void termsUriOpener() async {
  final Uri url = Uri.parse('https://rayonixsolutions.com/privacy-policy');
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {}
}
