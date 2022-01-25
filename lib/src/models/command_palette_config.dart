import 'package:command_palette/src/command_palette_options.dart';
import 'package:command_palette/src/controller/command_palette_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../command_palette.dart';

final _defaultOpenKeySet =
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyK);
final _defaultCloseKeySet = LogicalKeySet(LogicalKeyboardKey.escape);

/// Configuration options for the command palette
class CommandPaletteConfig {
  /// Text that's displayed in the command palette when nothing has been entered
  final String hintText;

  /// List of all the actions that are supported by this command palette
  // final List<CommandPaletteAction> actions;

  /// Used to filter which actions are displayed based upon the currently
  /// entered text of the search bar
  final ActionFilter filter;

  /// Used to build the actions which're displayed when the command palette is
  /// open
  ///
  /// For an idea on how to builder your own custom builder, see
  /// [defaultBuilder]
  final ActionBuilder builder;

  /// How long it takes for the command palette to be opened or closed.
  ///
  /// Defaults to 150 ms
  final Duration transitionDuration;

  /// Curves used when fading the command palette in and out.
  ///
  /// Defaults to [Curves.linear]
  final Curve transitionCurve;

  /// Provides options to style the look of the command palette.
  ///
  /// Note for development: Changes to style while the command palette is open
  /// will require the command palette to be closed and reopened.
  final CommandPaletteStyle? style;

  /// The set of keys used to open the command palette.
  ///
  /// Defaults to Ctrl-/Cmd- C
  final LogicalKeySet openKeySet;

  /// The set of keys used to close the command palette.
  ///
  /// Please note that at this time escape will always close the command
  /// palette.
  /// Regardless of if it's set or not. This is something defined at the
  /// App-level. If you want to prevent this, see: https://stackoverflow.com/questions/63763478/disable-escape-key-navigation-in-flutter-web
  ///
  /// Defaults to Esc.
  final LogicalKeySet closeKeySet;

  /// Action filtering rates actions on a scale of 0.0 to 1.0. The threshold is
  /// the value that an action must score greater than or equal to, in order to
  /// be considering a match
  final double scoreThreshold;

  CommandPaletteConfig({
    ActionFilter? filter,
    Key? key,
    ActionBuilder? builder,
    this.hintText = "Begin typing to search for something",
    this.transitionDuration = const Duration(milliseconds: 150),
    this.transitionCurve = Curves.linear,
    this.style,
    LogicalKeySet? openKeySet,
    LogicalKeySet? closeKeySet,
    this.scoreThreshold = 0.25,
  })  : filter = filter ?? defaultFilter,
        builder = builder ?? defaultBuilder,
        openKeySet = openKeySet ?? _defaultOpenKeySet,
        closeKeySet = closeKeySet ?? _defaultCloseKeySet;

  bool equals(Object other) {
    if (identical(this, other)) return true;

    return other is CommandPaletteConfig &&
        other.hintText == hintText &&
        other.filter == filter &&
        other.builder == builder &&
        other.transitionDuration == transitionDuration &&
        other.transitionCurve == transitionCurve &&
        other.style == style &&
        other.openKeySet == openKeySet &&
        other.closeKeySet == closeKeySet &&
        other.scoreThreshold == scoreThreshold;
  }
}
