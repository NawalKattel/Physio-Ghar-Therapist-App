import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:physio_ghar/core/repository/persistence.dart';

enum AppLanguage {
  english('EN', 'English', AppStrings.en),
  nepali('ने', 'नेपाली', AppStrings.ne);

  const AppLanguage(this.shortLabel, this.nativeName, this.strings);

  final String shortLabel;
  final String nativeName;
  final AppStrings strings;
}

final languageProvider = NotifierProvider<LanguageNotifier, AppLanguage>(
  LanguageNotifier.new,
);

class LanguageNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() =>
      ref.watch(savedLanguageProvider).value ?? AppLanguage.english;

  void set(AppLanguage language) => state = language;
}

final stringsProvider = Provider<AppStrings>(
  (ref) => ref.watch(languageProvider).strings,
);

AppStrings stringsOf(BuildContext context) =>
    ProviderScope.containerOf(context, listen: false).read(stringsProvider);

Widget localizedText(
  String Function(AppStrings strings) text, {
  TextStyle? style,
  int? maxLines,
  TextOverflow? overflow,
  TextAlign? textAlign,
}) {
  return Consumer(
    builder: (context, ref, _) => Text(
      text(ref.watch(stringsProvider)),
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    ),
  );
}

Widget nameText(
  String englishName, {
  TextStyle? style,
  int? maxLines,
  TextOverflow? overflow,
  TextAlign? textAlign,
}) => localizedText(
  (strings) => strings.name(englishName),
  style: style,
  maxLines: maxLines,
  overflow: overflow,
  textAlign: textAlign,
);

class AppStrings {
  const AppStrings({
    required this.navHome,
    required this.navSchedule,
    required this.navBookings,
    required this.navPatients,
    required this.navAccount,
    required this.account,
    required this.profileSection,
    required this.preferencesSection,
    required this.supportSection,
    required this.myProfile,
    required this.editProfile,
    required this.availability,
    required this.language,
    required this.reportIssue,
    required this.logout,
    required this.ageLabel,
    required this.homeVisit,
    this.useNepaliDigits = false,
    this.names = const {},
    this.places = const {},
  });

  final String navHome;
  final String navSchedule;
  final String navBookings;
  final String navPatients;
  final String navAccount;
  final String account;
  final String profileSection;
  final String preferencesSection;
  final String supportSection;
  final String myProfile;
  final String editProfile;
  final String availability;
  final String language;
  final String reportIssue;
  final String logout;

  final String ageLabel;
  final String homeVisit;

  final bool useNepaliDigits;

  final Map<String, String> names;

  final Map<String, String> places;

  String name(String englishName) => names[englishName] ?? englishName;

  String place(String englishPlace) =>
      englishPlace.split(', ').map((part) => places[part] ?? part).join(', ');

  String digits(num number) {
    final text = '$number';
    if (!useNepaliDigits) return text;
    return text.split('').map((c) => _devanagariDigits[c] ?? c).join();
  }

  String age(int years) => '$ageLabel ${digits(years)}';

  static const _devanagariDigits = {
    '0': '०',
    '1': '१',
    '2': '२',
    '3': '३',
    '4': '४',
    '5': '५',
    '6': '६',
    '7': '७',
    '8': '८',
    '9': '९',
  };

  static const en = AppStrings(
    navHome: 'Home',
    navSchedule: 'Schedule',
    navBookings: 'Bookings',
    navPatients: 'Patients',
    navAccount: 'Account',
    account: 'Account',
    profileSection: 'Profile',
    preferencesSection: 'Preferences',
    supportSection: 'Support',
    myProfile: 'My Profile',
    editProfile: 'Edit Profile',
    availability: 'Availability',
    language: 'Language',
    reportIssue: 'Report an issue',
    logout: 'Log out',
    ageLabel: 'Age',
    homeVisit: 'Home visit',
  );

  static const ne = AppStrings(
    navHome: 'गृह',
    navSchedule: 'तालिका',
    navBookings: 'बुकिङ',
    navPatients: 'बिरामी',
    navAccount: 'खाता',
    account: 'खाता',
    profileSection: 'प्रोफाइल',
    preferencesSection: 'प्राथमिकताहरू',
    supportSection: 'सहायता',
    myProfile: 'मेरो प्रोफाइल',
    editProfile: 'प्रोफाइल सम्पादन',
    availability: 'उपलब्धता',
    language: 'भाषा',
    reportIssue: 'समस्या रिपोर्ट गर्नुहोस्',
    logout: 'लग आउट',
    ageLabel: 'उमेर',
    homeVisit: 'घर भ्रमण',
    useNepaliDigits: true,
    places: {
      'Kathmandu': 'काठमाडौं',
      'Lalitpur': 'ललितपुर',
      'Baneshwor': 'बानेश्वर',
      'Jhamsikhel': 'झम्सिखेल',
      'Lazimpat': 'लाजिम्पाट',
      'Budhanilkantha': 'बुढानीलकण्ठ',
      'Sanepa': 'सानेपा',
      'Kupondole': 'कुपण्डोल',
      'Maharajgunj': 'महाराजगञ्ज',
      'Chabahil': 'चाबहिल',
      'PhysioGhar Clinic': 'फिजियोघर क्लिनिक',
    },
    names: {
      'Dr. Aarati Joshi': 'डा. आरती जोशी',
      'Sita Sharma': 'सीता शर्मा',
      'Ram Thapa': 'राम थापा',
      'Anjali Thapa': 'अञ्जली थापा',
      'Hari Prasad Koirala': 'हरि प्रसाद कोइराला',
      'Maya Gurung': 'माया गुरुङ',
      'Bikash Shrestha': 'विकास श्रेष्ठ',
      'Nisha Rai': 'निशा राई',
    },
  );
}
