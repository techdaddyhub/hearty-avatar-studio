import 'package:flutter/material.dart';
import 'package:orange_ui/service/language_location_service.dart';
import 'package:orange_ui/utils/color_res.dart';
import 'package:orange_ui/utils/font_res.dart';

class TranslatableTextWidget extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final bool isDark;
  final bool autoTranslate;

  const TranslatableTextWidget({
    super.key,
    required this.text,
    this.style,
    this.isDark = false,
    this.autoTranslate = false,
  });

  @override
  State<TranslatableTextWidget> createState() => _TranslatableTextWidgetState();
}

class _TranslatableTextWidgetState extends State<TranslatableTextWidget> {
  bool _isTranslated = false;
  bool _isLoading = false;
  String _translatedText = '';

  @override
  void initState() {
    super.initState();
    if (widget.autoTranslate && widget.text.trim().isNotEmpty) {
      _translate();
    }
  }

  @override
  void didUpdateWidget(covariant TranslatableTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _isTranslated = false;
      _translatedText = '';
      if (widget.autoTranslate && widget.text.trim().isNotEmpty) {
        _translate();
      }
    }
  }

  Future<void> _translate() async {
    if (_translatedText.isNotEmpty) {
      setState(() {
        _isTranslated = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final res = await LanguageLocationService.translateText(text: widget.text);
      if (mounted) {
        setState(() {
          _translatedText = res;
          _isTranslated = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleTranslation() {
    if (_isTranslated) {
      setState(() {
        _isTranslated = false;
      });
    } else {
      _translate();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.text.trim().isEmpty) {
      return const SizedBox();
    }

    final displayText = _isTranslated && _translatedText.isNotEmpty
        ? _translatedText
        : widget.text;

    final actionColor = widget.isDark
        ? ColorRes.white.withValues(alpha: 0.7)
        : ColorRes.themeColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          displayText,
          style: widget.style,
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: _isLoading ? null : _toggleTranslation,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isLoading)
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation<Color>(actionColor),
                    ),
                  )
                else
                  Icon(
                    Icons.translate_rounded,
                    size: 13,
                    color: actionColor,
                  ),
                const SizedBox(width: 4),
                Text(
                  _isLoading
                      ? 'Translating...'
                      : _isTranslated
                          ? 'See original'
                          : 'Translate',
                  style: TextStyle(
                    fontFamily: FontRes.medium,
                    fontSize: 11,
                    color: actionColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
