import 'package:flutter/material.dart';

/// Gedeelde kaartstijl, dezelfde als op de Today- en Progress-pagina:
/// effen beige kaart (surfaceMuted), ronde hoeken van 24.
/// Gebruik op elke nieuwe pagina:
///   Container(padding: ..., decoration: appCardDecoration(context), child: ...)
const double appCardRadius = 24;

Color appCardColor(BuildContext context) =>
    Theme.of(context).cardTheme.color ??
    Theme.of(context).colorScheme.surfaceContainerHighest;

BoxDecoration appCardDecoration(BuildContext context, {double radius = appCardRadius}) {
  final theme = Theme.of(context);
  final dark = theme.brightness == Brightness.dark;
  return BoxDecoration(
    color: appCardColor(context),
    borderRadius: BorderRadius.circular(radius),
    // In donker thema een dunne rand, zodat de kaart zichtbaar blijft
    border: dark
        ? Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.18))
        : null,
  );
}
