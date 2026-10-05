import 'package:flutter/material.dart';
import 'package:orange_ui/common/top_bar_area.dart';
import 'package:orange_ui/generated/l10n.dart';
import 'package:orange_ui/screen/languages_screen/languages_screen_view_model.dart';
import 'package:orange_ui/utils/color_res.dart';
import 'package:orange_ui/utils/font_res.dart';
import 'package:stacked/stacked.dart';

class LanguagesScreen extends StatelessWidget {
  const LanguagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LanguagesScreenViewModel>.reactive(
      onViewModelReady: (viewModel) => viewModel.init(),
      viewModelBuilder: () => LanguagesScreenViewModel(),
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: ColorRes.white,
          body: Column(
            children: [
              TopBarArea(title2: S.current.languages.toUpperCase()),
              // Auto-Translate / Auto-Detect by location toggle
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorRes.grey10.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: viewModel.isAutoTranslate
                        ? ColorRes.themeColor.withValues(alpha: 0.4)
                        : ColorRes.borderColor,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ColorRes.themeColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.my_location_rounded,
                        color: ColorRes.themeColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Auto-detect by Location',
                            style: TextStyle(
                              color: ColorRes.darkGrey5,
                              fontFamily: FontRes.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Auto-translates by location (${viewModel.detectedCountryText})',
                            style: const TextStyle(
                              color: ColorRes.darkGrey,
                              fontFamily: FontRes.regular,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: viewModel.isAutoTranslate,
                      activeTrackColor: ColorRes.themeColor.withValues(alpha: 0.5),
                      activeThumbColor: ColorRes.themeColor,
                      onChanged: viewModel.toggleAutoTranslate,
                    ),
                  ],
                ),
              ),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  onChanged: viewModel.onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search language...',
                    hintStyle: const TextStyle(
                      color: ColorRes.grey2,
                      fontFamily: FontRes.regular,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(Icons.search, color: ColorRes.grey2, size: 20),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    filled: true,
                    fillColor: ColorRes.grey10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: SafeArea(
                  top: false,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: viewModel.filteredIndices.length,
                    itemBuilder: (context, index) {
                      final langIndex = viewModel.filteredIndices[index];
                      return RadioGroup(
                        onChanged: viewModel.onLanguageChange,
                        groupValue: viewModel.value,
                        child: RadioListTile(
                          value: langIndex,
                          activeColor: ColorRes.themeColor,
                          splashRadius: 0,
                          hoverColor: Colors.transparent,
                          dense: true,
                          title: Text(
                            viewModel.languages[langIndex],
                            style: const TextStyle(
                              color: ColorRes.darkGrey5,
                              fontFamily: FontRes.semiBold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            viewModel.subLanguage[langIndex],
                            style: const TextStyle(
                              color: ColorRes.darkGrey,
                              fontFamily: FontRes.regular,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
