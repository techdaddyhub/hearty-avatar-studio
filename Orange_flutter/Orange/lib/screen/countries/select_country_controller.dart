import 'dart:developer';

import 'package:get/get.dart';
import 'package:orange_ui/service/extention/list_extension.dart';
import 'package:orange_ui/utils/asset_res.dart';

import 'countries_model.dart';

class SelectCountryController extends GetxController {
  List<Country> allCountries = [];
  List<CountryState> allStates = [];
  List<City> allCities = [];

  RxList<Country> filteredCountries = <Country>[].obs;
  Rx<Country?> selectedCountry = Rx(null);

  List<CountryState> selectedStatesFromCountry = [];
  RxList<CountryState> filteredStates = <CountryState>[].obs;
  Rx<CountryState?> selectedState = Rx(null);

  List<City> selectedCitiesFromState = [];
  RxList<City> filteredCities = <City>[].obs;
  Rx<City?> selectedCity = Rx(null);

  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  @override
  void onReady() {
    super.onReady();
    if (allCountries.isEmpty) {
      loadData();
    }
  }

  Future<void> loadData() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      if (allCountries.isEmpty) {
        allCountries = await parseCountries(filePath: AssetRes.countries);
        filteredCountries.assignAll(allCountries);
      }
      if (allStates.isEmpty) {
        allStates = await parseStates(filePath: AssetRes.states);
      }
      if (allCities.isEmpty) {
        allCities = await parseCities(filePath: AssetRes.cities);
      }
    } catch (e) {
      log('Error loading country data: $e');
    } finally {
      isLoading.value = false;
      if (filteredCountries.isEmpty && allCountries.isNotEmpty) {
        filteredCountries.assignAll(allCountries);
      }
    }
  }

  void selectCountry({required Country country}) {
    selectedCountry.value = country;
    selectedStatesFromCountry =
        getStatesByCountryCode(allStates, country.countryCode);
    if (selectedStatesFromCountry.isEmpty) {
      selectedStatesFromCountry = [
        CountryState(
          name: country.countryName,
          countryCode: country.countryCode,
          stateCode: country.countryCode,
        ),
      ];
    }
    filteredStates.assignAll(selectedStatesFromCountry);
    filteredCities.clear();
    selectedCity.value = null;
    selectedState.value = null;
  }

  void selectState({required CountryState state}) {
    selectedState.value = state;
    selectedCitiesFromState = getCitiesByStateCode(allCities, state.stateCode);
    if (selectedCitiesFromState.isEmpty) {
      selectedCitiesFromState = [
        City(
          name: state.name,
          stateCode: state.stateCode,
        ),
      ];
    }
    filteredCities.assignAll(selectedCitiesFromState);
    selectedCity.value = null;
  }

  void selectCity({required City city}) {
    selectedCity.value = city;
  }

  void searchCountry(String query) {
    if (query.trim().isEmpty) {
      filteredCountries.assignAll(allCountries);
      return;
    }
    filteredCountries.value = allCountries.search(
        query.trim(), (model) => model.countryName, (model) => model.countryCode);
  }

  void searchState(String query) {
    if (query.trim().isEmpty) {
      filteredStates.assignAll(selectedStatesFromCountry);
      return;
    }
    filteredStates.value = selectedStatesFromCountry.search(
        query.trim(), (model) => model.name, (model) => model.stateCode);
  }

  void searchCity(String query) {
    if (query.trim().isEmpty) {
      filteredCities.assignAll(selectedCitiesFromState);
      return;
    }
    filteredCities.value =
        selectedCitiesFromState.search(query.trim(), (model) => model.name);
  }
}
