import 'package:command_bar/src/models/command_bar_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:command_bar/src/command_bar_modal.dart';
import 'package:command_bar/src/controller/command_bar_controller.dart';
import 'package:command_bar/src/models/command_bar_action.dart';

import '../command_bar.dart';

/// Default filter for actions. Splits the entered query, and then wraps it in
/// groups and wild cards
// ignore: prefer_function_declarations_over_variables
final ActionFilter _defaultFilter = (query, actions) {
  final String expression =
      query.split(" ").map((e) => "(${e.replaceAll("\\", "\\\\")}).*").join("");
  // debugPrint(expression);
  final re = RegExp(expression, caseSensitive: false);
  return actions
      .where(
        (action) => re.hasMatch(action.label),
      )
      .toList();
};

/// Command bar is a widget that is summoned by a keyboard shortcut, or by
/// programmatic means.
///
/// The command bar displays a list of actions and the user can type text into
/// the search bar to filter those actions.
class CommandBar extends StatefulWidget {
  /// Child which is wrapped by the command bar
  final Widget child;

  /// Text that's displayed in the command bar when nothing has been entered
  final String hintText;

  /// List of all the actions that are supported by this command bar
  final List<CommandBarAction> actions;

  /// Used to filter which actions are displayed based upon the currently
  /// entered text of the search bar
  final ActionFilter filter;

  /// How long it takes for the command bar to be opened or closed.
  ///
  /// Defaults to 150 ms
  final Duration transitionDuration;

  /// Curves used when fading the command bar in and out.
  ///
  /// Defaults to [Curves.linear]
  final Curve transitionCurve;

  /// Provides options to style the look of the command bar.
  ///
  /// Note for development: Changes to style while the command bar is open will
  /// require the command bar to be closed and reopened.
  final CommandBarStyle? style;

  CommandBar({
    ActionFilter? filter,
    Key? key,
    required this.child,
    this.hintText = "Begin typing to search for something",
    required this.actions,
    this.transitionDuration = const Duration(milliseconds: 150),
    this.transitionCurve = Curves.linear,
    this.style,
  })  : filter = filter ?? _defaultFilter,
        super(key: key);

  @override
  State<CommandBar> createState() => _CommandBarState();
}

class _CommandBarState extends State<CommandBar> {
  bool _commandBarOpen = false;

  late CommandBarController controller;

  late CommandBarStyle style;

  @override
  void initState() {
    super.initState();

    controller = CommandBarController(widget.actions, filter: widget.filter);
  }

  @override
  void didUpdateWidget(covariant CommandBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.actions != widget.actions ||
        oldWidget.filter != widget.filter ||
        oldWidget.style != widget.style) {
      controller = CommandBarController(widget.actions, filter: widget.filter);
      _initStyle();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _initStyle();
  }

  /// Initialize all the styles and stuff
  void _initStyle() {
    CommandBarStyle styleToCopy = widget.style ?? const CommandBarStyle();

    style = CommandBarStyle(
      actionColor: styleToCopy.actionColor ?? Theme.of(context).canvasColor,
      selectedColor:
          styleToCopy.selectedColor ?? Theme.of(context).highlightColor,
      actionLabelTextStyle: styleToCopy.actionLabelTextStyle ??
          Theme.of(context).primaryTextTheme.subtitle1?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
      highlightedLabelTextStyle: styleToCopy.highlightedLabelTextStyle ??
          Theme.of(context).primaryTextTheme.subtitle1?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
      actionLabelTextAlign: styleToCopy.actionLabelTextAlign,
      borderRadius: styleToCopy.borderRadius,
      commandBarBarrierColor: styleToCopy.commandBarBarrierColor,
      elevation: styleToCopy.elevation,
      highlightSearchSubstring: styleToCopy.highlightSearchSubstring,
      textFieldInputDecoration: styleToCopy.textFieldInputDecoration == null
          ? const InputDecoration(
              hintText: "Begin typing to search for something",
              contentPadding: EdgeInsets.all(8),
            ).applyDefaults(Theme.of(context).inputDecorationTheme)
          : styleToCopy.textFieldInputDecoration!
              .applyDefaults(Theme.of(context).inputDecorationTheme),
    );

    controller.style = style;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommandBarControllerProvider(
      controller: controller,
      child: Builder(
        builder: (context) {
          return Focus(
            autofocus: true,
            onKey: (node, event) {
              KeyEventResult result = KeyEventResult.ignored;

              // if ctrl-c is pressed, and the command bar isn't open, open it
              if (LogicalKeySet(
                          LogicalKeyboardKey.control, LogicalKeyboardKey.keyK)
                      .accepts(event, RawKeyboard.instance) &&
                  !_commandBarOpen) {
                _openCommandBar(context);

                result = KeyEventResult.handled;
              }

              // if esc is pressed, and the command bar isn't open, close it
              else if (LogicalKeySet(LogicalKeyboardKey.escape)
                      .accepts(event, RawKeyboard.instance) &&
                  _commandBarOpen) {
                _closeCommandBar();
                result = KeyEventResult.handled;
              }

              return result;
            },
            child: widget.child,
          );
        },
      ),
    );
  }

  /// Closes the command bar
  void _closeCommandBar() {
    setState(() {
      _commandBarOpen = false;
    });
    Navigator.of(context).pop();
  }

  /// Opens the command bar
  void _openCommandBar(BuildContext context) {
    setState(() {
      _commandBarOpen = true;
    });

    Navigator.of(context)
        .push(
          CommandBarModal(
            hintText: widget.hintText,

            // we pass the controller in so that it can be re-provided within the
            // tree of the modal
            commandBarController: CommandBarControllerProvider.of(context),
            transitionCurve: widget.transitionCurve,
            transitionDuration: widget.transitionDuration,
          ),
        )
        .then(
          (value) => setState(() {
            _commandBarOpen = false;
          }),
        );
  }
}
