import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

class Country {
  String countryCode;
  String countryName;
  String phoneCode;

  Country({
    required this.countryCode,
    required this.countryName,
    required this.phoneCode,
  });

  @override
  String toString() {
    return 'Country(countryCode: $countryCode, countryName: $countryName, phoneCode: $phoneCode)';
  }
}

class CountryState {
  String name;
  String countryCode;
  String stateCode;

  CountryState({
    required this.name,
    required this.countryCode,
    required this.stateCode,
  });

  @override
  String toString() {
    return 'State(name: $name, countryCode: $countryCode, stateCode: $stateCode)';
  }
}

class City {
  String name;
  String stateCode;

  City({
    required this.name,
    required this.stateCode,
  });

  @override
  String toString() {
    return 'City(name: $name, stateCode: $stateCode)';
  }
}

// Helper Functions
Future<List<T>> parseCsv<T>(
  String filePath,
  T Function(List<dynamic> row) factoryFunction,
) async {
  try {
    final content = await rootBundle.loadString(filePath);
    final rows = csv.decode(content);
    final list = <T>[];
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty) continue;
      try {
        list.add(factoryFunction(row));
      } catch (_) {
        // Skip malformed row
      }
    }
    return list;
  } catch (_) {
    return [];
  }
}

Future<List<Country>> parseCountries({required String filePath}) async {
  final list = await parseCsv(
    filePath,
    (row) => Country(
      countryCode: row[0].toString().trim(),
      countryName: row[1].toString().trim(),
      phoneCode: row.length > 2
          ? (row[2] is int ? '+${row[2]}' : row[2].toString().trim())
          : '',
    ),
  );
  if (list.isNotEmpty) return list;
  return defaultCountryList;
}

Future<List<CountryState>> parseStates({required String filePath}) {
  return parseCsv(
    filePath,
    (row) => CountryState(
      name: row[0].toString().trim(),
      countryCode: row[1].toString().trim(),
      stateCode: row.length > 2
          ? (row[2] is int ? '${row[2]}' : row[2].toString().trim())
          : row[0].toString().trim(),
    ),
  );
}

Future<List<City>> parseCities({required String filePath}) async {
  return await parseCsv(
    filePath,
    (row) => City(
      name: row[0].toString().trim(),
      stateCode: row.length > 1
          ? (row[1] is int ? '${row[1]}' : row[1].toString().trim())
          : '',
    ),
  );
}

final List<Country> defaultCountryList = [
  Country(countryCode: "US", countryName: "United States", phoneCode: "+1"),
  Country(countryCode: "GB", countryName: "United Kingdom", phoneCode: "+44"),
  Country(countryCode: "CA", countryName: "Canada", phoneCode: "+1"),
  Country(countryCode: "NG", countryName: "Nigeria", phoneCode: "+234"),
  Country(countryCode: "IN", countryName: "India", phoneCode: "+91"),
  Country(countryCode: "AU", countryName: "Australia", phoneCode: "+61"),
  Country(countryCode: "DE", countryName: "Germany", phoneCode: "+49"),
  Country(countryCode: "FR", countryName: "France", phoneCode: "+33"),
  Country(countryCode: "IT", countryName: "Italy", phoneCode: "+39"),
  Country(countryCode: "ES", countryName: "Spain", phoneCode: "+34"),
  Country(countryCode: "BR", countryName: "Brazil", phoneCode: "+55"),
  Country(countryCode: "ZA", countryName: "South Africa", phoneCode: "+27"),
  Country(countryCode: "GH", countryName: "Ghana", phoneCode: "+233"),
  Country(countryCode: "KE", countryName: "Kenya", phoneCode: "+254"),
  Country(countryCode: "EG", countryName: "Egypt", phoneCode: "+20"),
  Country(countryCode: "AE", countryName: "United Arab Emirates", phoneCode: "+971"),
  Country(countryCode: "SA", countryName: "Saudi Arabia", phoneCode: "+966"),
  Country(countryCode: "PK", countryName: "Pakistan", phoneCode: "+92"),
  Country(countryCode: "BD", countryName: "Bangladesh", phoneCode: "+880"),
  Country(countryCode: "PH", countryName: "Philippines", phoneCode: "+63"),
  Country(countryCode: "ID", countryName: "Indonesia", phoneCode: "+62"),
  Country(countryCode: "MY", countryName: "Malaysia", phoneCode: "+60"),
  Country(countryCode: "SG", countryName: "Singapore", phoneCode: "+65"),
  Country(countryCode: "JP", countryName: "Japan", phoneCode: "+81"),
  Country(countryCode: "CN", countryName: "China", phoneCode: "+86"),
  Country(countryCode: "KR", countryName: "South Korea", phoneCode: "+82"),
  Country(countryCode: "MX", countryName: "Mexico", phoneCode: "+52"),
  Country(countryCode: "CO", countryName: "Colombia", phoneCode: "+57"),
  Country(countryCode: "AR", countryName: "Argentina", phoneCode: "+54"),
  Country(countryCode: "CL", countryName: "Chile", phoneCode: "+56"),
  Country(countryCode: "NL", countryName: "Netherlands", phoneCode: "+31"),
  Country(countryCode: "BE", countryName: "Belgium", phoneCode: "+32"),
  Country(countryCode: "SE", countryName: "Sweden", phoneCode: "+46"),
  Country(countryCode: "NO", countryName: "Norway", phoneCode: "+47"),
  Country(countryCode: "DK", countryName: "Denmark", phoneCode: "+45"),
  Country(countryCode: "FI", countryName: "Finland", phoneCode: "+358"),
  Country(countryCode: "IE", countryName: "Ireland", phoneCode: "+353"),
  Country(countryCode: "NZ", countryName: "New Zealand", phoneCode: "+64"),
  Country(countryCode: "CH", countryName: "Switzerland", phoneCode: "+41"),
  Country(countryCode: "AT", countryName: "Austria", phoneCode: "+43"),
  Country(countryCode: "PL", countryName: "Poland", phoneCode: "+48"),
  Country(countryCode: "PT", countryName: "Portugal", phoneCode: "+351"),
  Country(countryCode: "GR", countryName: "Greece", phoneCode: "+30"),
  Country(countryCode: "TR", countryName: "Turkey", phoneCode: "+90"),
  Country(countryCode: "RU", countryName: "Russia", phoneCode: "+7"),
  Country(countryCode: "UA", countryName: "Ukraine", phoneCode: "+380"),
  Country(countryCode: "TH", countryName: "Thailand", phoneCode: "+66"),
  Country(countryCode: "VN", countryName: "Vietnam", phoneCode: "+84"),
  Country(countryCode: "IL", countryName: "Israel", phoneCode: "+972"),
  Country(countryCode: "QA", countryName: "Qatar", phoneCode: "+974"),
  Country(countryCode: "KW", countryName: "Kuwait", phoneCode: "+965"),
  Country(countryCode: "OM", countryName: "Oman", phoneCode: "+968"),
  Country(countryCode: "BH", countryName: "Bahrain", phoneCode: "+973"),
  Country(countryCode: "JO", countryName: "Jordan", phoneCode: "+962"),
  Country(countryCode: "LB", countryName: "Lebanon", phoneCode: "+961"),
  Country(countryCode: "MA", countryName: "Morocco", phoneCode: "+212"),
  Country(countryCode: "DZ", countryName: "Algeria", phoneCode: "+213"),
  Country(countryCode: "TN", countryName: "Tunisia", phoneCode: "+216"),
  Country(countryCode: "UG", countryName: "Uganda", phoneCode: "+256"),
  Country(countryCode: "TZ", countryName: "Tanzania", phoneCode: "+255"),
  Country(countryCode: "ET", countryName: "Ethiopia", phoneCode: "+251"),
  Country(countryCode: "RW", countryName: "Rwanda", phoneCode: "+250"),
  Country(countryCode: "CM", countryName: "Cameroon", phoneCode: "+237"),
  Country(countryCode: "SN", countryName: "Senegal", phoneCode: "+221"),
  Country(countryCode: "CI", countryName: "Ivory Coast", phoneCode: "+225"),
  Country(countryCode: "JM", countryName: "Jamaica", phoneCode: "+1-876"),
  Country(countryCode: "TT", countryName: "Trinidad and Tobago", phoneCode: "+1-868"),
];

// Search Functions
List<CountryState> getStatesByCountryCode(
    List<CountryState> states, String countryCode) {
  return states.where((state) => state.countryCode == countryCode).toList();
}

List<City> getCitiesByStateCode(List<City> cities, String stateCode) {
  return cities.where((city) => city.stateCode == stateCode).toList();
}
