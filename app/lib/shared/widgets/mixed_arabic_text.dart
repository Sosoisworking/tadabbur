import 'package:flutter/material.dart';

import '../../core/theme/app_typography.dart';

/// Renders a string that mixes plain English prose with inline Arabic
/// script — e.g. a quiz question like "What is the name of this letter:
/// ب" — so the Arabic portion always renders in the Arabic typeface at a
/// legible size, instead of silently falling back to whatever font is
/// rendering the surrounding English text.
///
/// Per docs/design-system.md Brand Principle 2 ("The Arabic is the
/// star"): every place Arabic script appears should go through
/// AppTypography.arabic(), not just the dedicated reading/vocab screens.
class MixedArabicText extends StatelessWidget {
  const MixedArabicText(
    this.text, {
    super.key,
    this.baseStyle,
    this.arabicFontSize = 28,
    this.textAlign,
  });

  final String text;
  final TextStyle? baseStyle;
  final double arabicFontSize;
  final TextAlign? textAlign;

  static final _arabicRun = RegExp(r'[؀-ۿ]+');

  @override
  Widget build(BuildContext context) {
    final style = baseStyle ?? DefaultTextStyle.of(context).style;
    final spans = <InlineSpan>[];
    var lastEnd = 0;

    for (final match in _arabicRun.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start), style: style));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: AppTypography.arabic(fontSize: arabicFontSize, color: style.color),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd), style: style));
    }

    return Text.rich(TextSpan(children: spans), textAlign: textAlign);
  }
}
