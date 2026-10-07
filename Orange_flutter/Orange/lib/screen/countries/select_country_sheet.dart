import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'base_select_sheet.dart';
import 'countries_model.dart';
import 'select_country_controller.dart';

class SelectCountrySheet extends StatelessWidget {
  final SelectCountryController controller;

  const SelectCountrySheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.allCountries.isEmpty && !controller.isLoading.value) {
      controller.loadData();
    } else if (controller.filteredCountries.isEmpty && controller.allCountries.isNotEmpty) {
      controller.filteredCountries.assignAll(controller.allCountries);
    }
    return BaseSelectSheet<Country>(
      title: "Country",
      isLoading: controller.isLoading,
      items: controller.filteredCountries,
      selectedItem: controller.selectedCountry,
      getDisplayText: (country) => country.countryName,
      onSelect: (country) {
        controller.selectCountry(country: country);
      },
      onSearch: controller.searchCountry,
    );
  }
}
