import 'package:flutter/material.dart';

import 'base_select_sheet.dart';
import 'countries_model.dart';
import 'select_country_controller.dart';

class SelectStateSheet extends StatelessWidget {
  final SelectCountryController controller;

  const SelectStateSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.filteredStates.isEmpty && controller.selectedStatesFromCountry.isNotEmpty) {
      controller.filteredStates.assignAll(controller.selectedStatesFromCountry);
    }
    return BaseSelectSheet<CountryState>(
      title: "State",
      isLoading: controller.isLoading,
      items: controller.filteredStates,
      selectedItem: controller.selectedState,
      getDisplayText: (state) => state.name,
      onSelect: (state) {
        controller.selectState(state: state);
      },
      onSearch: controller.searchState,
    );
  }
}
