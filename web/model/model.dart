library model;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import '../controller/controller.dart' as Controller;
import '../dummies.dart';
import '../enums.dart';

import 'package:markdown/markdown.dart' as Markdown;
import 'package:okeyee/okeyee.dart';
import 'package:openreception_framework/bus.dart';

part 'model-ui-agent-info.dart';
part 'model-ui-calendar-editor.dart';
part 'model-ui-contact-calendar.dart';
part 'model-ui-contact-data.dart';
part 'model-ui-contact-selector.dart';
part 'model-ui-contexts.dart';
part 'model-ui-global-call-queue.dart';
part 'model-ui-hint.dart';
part 'model-ui-message-archive.dart';
part 'model-ui-message-archive-edit.dart';
part 'model-ui-message-archive-filter.dart';
part 'model-ui-message-compose.dart';
part 'model-ui-my-call-queue.dart';
part 'model-ui-reception-addresses.dart';
part 'model-ui-reception-alt-names.dart';
part 'model-ui-reception-bank-info.dart';
part 'model-ui-reception-calendar.dart';
part 'model-ui-reception-commands.dart';
part 'model-ui-reception-email.dart';
part 'model-ui-reception-mini-wiki.dart';
part 'model-ui-reception-opening-hours.dart';
part 'model-ui-reception-product.dart';
part 'model-ui-reception-salesmen.dart';
part 'model-ui-reception-selector.dart';
part 'model-ui-reception-telephone-numbers.dart';
part 'model-ui-reception-type.dart';
part 'model-ui-reception-vat-numbers.dart';
part 'model-ui-reception-websites.dart';
part 'model-ui-receptionistclient-ready.dart';
part 'model-ui-receptionistclient-disaster.dart';
part 'model-ui-receptionistclient-loading.dart';
part 'model-ui-welcome-message.dart';

final Controller.HotKeys  _hotKeys  = new Controller.HotKeys();

/**
 * TODO (TL): Comment
 */
abstract class UIModel {
  final Keyboard _keyboard = new Keyboard();

  HtmlElement get _firstTabElement;
  HtmlElement get _focusElement;
  HtmlElement get _lastTabElement;
  HtmlElement get _root;

  /**
   * Return true if the widget is in focus.
   */
  bool get isFocused => _root.classes.contains('focus');

  /**
   * Blur the widget and set tabindex to -1.
   */
  void blur() {
    if(isFocused) {
      _root.classes.toggle('focus', false);
      _focusElement.blur();
      _setTabIndex(-1);
    }
  }

  /**
   * Focus the widget and set tabindex to 1.
   */
  void focus() {
    if(!isFocused) {
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
  void _handleShiftTab(KeyboardEvent event) {
    if(isFocused && focusIsOnFirst) {
      event.preventDefault();
      tabToLast();
    }
  }

  /**
   * Tab from last to first tab element when last is in focus an a Tab event
   * is caught.
   */
  void _handleTab(KeyboardEvent event) {
    if(isFocused && focusIsOnLast) {
      event.preventDefault();
      tabToFirst();
    }
  }

  /**
   * Return the header element.
   */
  SpanElement get _header => _root.querySelector('h4 > span');

  /**
   * Set the widget header.
   */
  set header(String headline) => _header.text = headline;

  /**
   * Return the headerExtra element.
   */
  SpanElement get _headerExtra => _root.querySelector('h4 > span + span');

  /**
   * Set the widgets extra header. This one can be used for a bit of extra data
   * to decorate the widget.
   */
  set headerExtra(String headlineExtra) => _headerExtra.text = headlineExtra;

  /**
   * Return the hint element.
   */
  DivElement get _hint => _root.querySelector('div.hint');

  /**
   * "Tab" and "Shift+Tab" are already in this map, pointing to [_handleTab] and
   * [_handleShiftTab] respectively.
   * To change this simply add those to [myKeys] or override the [_handleTab]
   * and/or [_handleShiftTab] methods.
   */
  Map<String, EventListener> _defaultKeyMap({Map<String, EventListener> myKeys}) {
    Map<String, EventListener> map = {'Shift+Tab': _handleShiftTab,
                                      'Tab'      : _handleTab};
    if(myKeys != null) {
      map.addAll(myKeys);
    }

    return map;
  }

  /**
   * Return the mouse click event stream for this widget.
   */
  Stream<MouseEvent> get onClick => _root.onClick;

  /**
   * Return the first [LIElement] that is not hidden. Search is forward,
   * starting with and including [li].
   */
  LIElement _scanForwardForVisibleElement(LIElement li) {
    if(li != null && li.classes.contains('hide')) {
      return _scanForwardForVisibleElement(li.nextElementSibling);
    } else {
      return li;
    }
  }

  /**
   * Return the first [LIElement] that is not hidden. Search is backwards,
   * starting with and including [li].
   */
  LIElement _scanBackwardsForVisibleElement(LIElement li) {
    if(li != null && li.classes.contains('hide')) {
      return _scanBackwardsForVisibleElement(li.previousElementSibling);
    } else {
      return li;
    }
  }

  /**
   * Set hint text
   */
  void setHint(String hint) {
    _hint.text = hint;
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
