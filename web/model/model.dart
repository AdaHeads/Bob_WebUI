library model;

import 'dart:async';
import 'dart:html';

import '../controller/controller.dart';

import 'package:openreception_framework/bus.dart';

part 'model-ui-agent-info.dart';
part 'model-ui-calendar-editor.dart';
part 'model-ui-contact-calendar.dart';
part 'model-ui-contact-data.dart';
part 'model-ui-contact-selector.dart';
part 'model-ui-contexts.dart';
part 'model-ui-help.dart';
part 'model-ui-message-compose.dart';
part 'model-ui-reception-calendar.dart';
part 'model-ui-reception-commands.dart';
part 'model-ui-reception-selector.dart';
part 'model-ui-receptionistclient-ready.dart';
part 'model-ui-receptionistclient-disaster.dart';
part 'model-ui-receptionistclient-loading.dart';

final HotKeys  _hotKeys  = new HotKeys();

enum AgentState {Busy, Idle, Pause, Unknown}
enum AlertState {Off, On}

///
///
///
/// TODO (TL): Look into whether the similar functionality of selecting items in
/// a list (contact and calendar list for example) can be moved to UIModel.
///
///
///

abstract class UIModel {
  HtmlElement    get _firstTabElement;
  HtmlElement    get _focusElement;
  HeadingElement get _header;
  DivElement     get _help;
  HtmlElement    get _lastTabElement;
  HtmlElement    get _root;

  /**
   * Return true if the widget is in focus.
   */
  bool get active => _root.classes.contains('focus');

  /**
   * Blur the widget and set tabindex to -1.
   */
  void blur() {
    if(active) {
      _root.classes.toggle('focus', false);
      _focusElement.blur();
      _setTabIndex(-1);
    }
  }

  /**
   * Focus the widget and set tabindex to 1.
   */
  void focus() {
    if(!active) {
      _setTabIndex(1);
      _root.classes.toggle('focus', true);
      _focusElement.focus();
    }
  }

  /**
   * Return true if the currently focused element is the first element with
   * tabindex set for this widget.
   */
  bool get focusIsOnFirst => _focusElement == _firstTabElement;

  /**
   * Return true if the currently focused element is the last element with
   * tabindex set for this widget.
   */
  bool get focusIsOnLast  => _focusElement == _lastTabElement;

  /**
   * Tab from first to last tab element when first is in focus an a Shift+Tab
   * event is caught.
   */
  void handleShiftTab(KeyboardEvent event) {
    if(active && focusIsOnFirst) {
      event.preventDefault();
      tabToLast();
    }
  }

  /**
   * Tab from last to first tab element when last is in focus an a Tab event
   * is caught.
   */
  void handleTab(KeyboardEvent event) {
    if(active && focusIsOnLast) {
      event.preventDefault();
      tabToFirst();
    }
  }

  /**
   * Set the widget header.
   */
  set header(String headline) => _header.text = headline;

  /**
   * Set the help text.
   *
   * TODO (TL): Do some placing/sizing magic, so the help box is always centered,
   * no matter the length of the help text.
   */
  set help(String help) => _help.text = help;

  /**
   * Return the mouse click event stream for this widget.
   */
  Stream<MouseEvent> get onClick => _root.onClick;

  /**
   * Find the first proceeding sibling that is not hidden.
   */
  LIElement scanAheadForVisibleSibling(LIElement li) {
    LIElement next = li.nextElementSibling;

    if(next != null && next.classes.contains('hide')) {
      return scanAheadForVisibleSibling(next);
    } else {
      return next;
    }
  }

  /**
   * Find the first preceeding sibling that is not hidden.
   */
  LIElement scanBackForVisibleSibling(LIElement li) {
    LIElement previous = li.previousElementSibling;

    if(previous != null && previous.classes.contains('hide')) {
      return scanBackForVisibleSibling(previous);
    } else {
      return previous;
    }
  }

  /**
   * Set tabindex="[index]" on [root].querySelectorAll('[tabindex]') elements.
   */
  void _setTabIndex(int index) {
    _root.querySelectorAll('[tabindex]').forEach((HtmlElement element) {
      element.tabIndex = index;
    });
  }

  /**
   * Focus the first element with tabindex set for this widget.
   */
  void tabToFirst() {
    _firstTabElement.focus();
  }

  /**
   * Focus the last element with tabindex set for this widget.
   */
  void tabToLast() {
    _lastTabElement.focus();
  }
}

/**
 * Dummy ApplicationState class
 */
class ApplicationState {
  static final ApplicationState _singleton = new ApplicationState._internal();
  factory ApplicationState() => _singleton;

  Bus<AppState> _bus = new Bus<AppState>();

  ApplicationState._internal();

  Stream<AppState> get onChange => _bus.stream;

  set state(AppState state) => _bus.fire(state);
}

/**
 * Dummy calendar entry class
 */
class CalendarEntry {
  LIElement    _li = new LIElement()..tabIndex = -1;
  String       content;

  CalendarEntry(String this.content) {
    _li.text = content;
  }

  CalendarEntry.fromElement(LIElement element) {
    if(element != null) {
      _li = element;
    }
  }
}

/**
 * Dummy contact class
 */
class Contact {
  LIElement    _li = new LIElement()..tabIndex = -1;
  String       name;
  List<String> tags;

  Contact(String this.name, {List<String> this.tags}) {
    _li.text = name;
    if(tags == null) {
      tags = new List<String>();
    }
  }

  Contact.fromElement(LIElement element) {
    if(element != null && element is LIElement) {
      _li = element;
      name = _li.text;
      tags = _li.dataset['tags'].split(',');
    } else {
      throw new ArgumentError('element is not a LIElement');
    }
  }
}

/**
 * Dummy reception class
 */
class Reception {
  LIElement    _li = new LIElement()..tabIndex = -1;
  String       name;

  Reception(String this.name) {
    _li.text = name;
  }

  Reception.fromElement(LIElement element) {
    if(element != null && element is LIElement) {
      _li = element;
      name = _li.text;
    } else {
      throw new ArgumentError('element is not a LIElement');
    }
  }
}

/**
 * A dummy telephone number.
 */
class TelNum {
  LIElement   _li         = new LIElement()..tabIndex = -1;
  bool        _secret;
  SpanElement _spanLabel  = new SpanElement();
  SpanElement _spanNumber = new SpanElement();

  TelNum(String number, String label, this._secret) {
    if(_secret) {
      _spanNumber.classes.add('secret');
    }

    _spanNumber.text = number;
    _spanNumber.classes.add('number');
    _spanLabel.text = label;
    _spanLabel.classes.add('label');

    _li.children.addAll([_spanNumber, _spanLabel]);
    _li.dataset['number'] = number;
  }

  TelNum.fromElement(LIElement element) {
    if(element != null && element is LIElement) {
      _li = element;
    } else {
      throw new ArgumentError('element is not a LIElement');
    }
  }
}
