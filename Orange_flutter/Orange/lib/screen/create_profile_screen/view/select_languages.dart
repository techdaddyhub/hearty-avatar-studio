import 'package:flutter/material.dart';
import 'package:orange_ui/common/button/custom_text_button.dart';
import 'package:orange_ui/common/login_setup_view.dart';
import 'package:orange_ui/generated/l10n.dart';
import 'package:orange_ui/model/user/registration_user.dart';
import 'package:orange_ui/screen/create_profile_screen/create_profile_screen_view_model.dart';
import 'package:orange_ui/screen/create_profile_screen/widget/border_text_card.dart';
import 'package:orange_ui/screen/create_profile_screen/widget/error_text_widget.dart';
import 'package:orange_ui/utils/color_res.dart';
import 'package:stacked/stacked.dart';

class SelectLanguages extends StatefulWidget {
  final UserData? userData;
  final CreateProfileScreenViewModel model;

  const SelectLanguages({super.key, this.userData, required this.model});

  @override
  State<SelectLanguages> createState() => _SelectLanguagesState();
}

class _SelectLanguagesState extends State<SelectLanguages> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CreateProfileScreenViewModel>.reactive(
      viewModelBuilder: () => widget.model,
      disposeViewModel: false,
      builder: (context, viewModel, child) {
        final filteredLanguages = viewModel.languages.where((l) {
          if (_searchQuery.isEmpty) return true;
          return (l.title ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        return LoginSetupView(
          title: S.of(context).selectLanguages,
          description: 'Select languages you are familiar with',
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search 100+ languages...',
                    hintStyle: const TextStyle(
                      color: ColorRes.grey2,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(Icons.search, color: ColorRes.grey2, size: 20),
                    filled: true,
                    fillColor: ColorRes.grey10,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: filteredLanguages.isEmpty
                    ? (viewModel.languages.isEmpty
                        ? ErrorTextWidget(
                            S.of(context).pleaseAddLanguagesInTheAdminPanelToContinue)
                        : const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(
                                'No matching languages found',
                                style: TextStyle(color: ColorRes.grey2, fontSize: 14),
                              ),
                            ),
                          ))
                    : ListView.builder(
                        itemCount: filteredLanguages.length,
                        itemBuilder: (context, index) {
                          bool isSelected = viewModel.selectedLanguages.any(
                              (element) => element.id == filteredLanguages[index].id);
                          return BorderTextCard(
                            text: filteredLanguages[index].title ?? '',
                            onTap: () =>
                                viewModel.onSelectLanguages(filteredLanguages[index]),
                            isSelected: isSelected,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            isCheckBtnVisible: true,
                            margin: const EdgeInsets.only(bottom: 5),
                          );
                        },
                      ),
              ),
              CustomTextButton(
                onTap: () =>
                    viewModel.onContinueTap(CreateProfileContinueTap.language),
              )
            ],
          ),
        );
      },
    );
  }
}
