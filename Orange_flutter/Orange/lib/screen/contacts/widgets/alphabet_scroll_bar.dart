import 'package:flutter/material.dart';
import 'package:orange_ui/utils/color_res.dart';

class AlphabetScrollBar extends StatelessWidget {
  final List<String> alphabets;
  final ValueChanged<String> onSelect;

  const AlphabetScrollBar({
    super.key,
    required this.alphabets,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (alphabets.isEmpty) return const SizedBox.shrink();

    return Container(
      width: 24,
      alignment: Alignment.center,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: alphabets.length,
        itemBuilder: (context, index) {
          final letter = alphabets[index];
          return GestureDetector(
            onTap: () => onSelect(letter),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Center(
                child: Text(
                  letter,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: ColorRes.dimGrey2,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

