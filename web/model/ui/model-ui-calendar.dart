/*                  This file is part of OpenReception
                   Copyright (C) 2015-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of model;

/**
 * Provides methods for manipulating the calendar UI widget.
 */
class UICalendar extends UIModel {
  final Map<String, String> _langMap;
  final DivElement _myRoot;
  final ORUtil.WeekDays _weekDays;
  final NodeValidatorBuilder _validator = new NodeValidatorBuilder()
    ..allowTextElements()
    ..allowHtml5()
    ..allowInlineStyles()
    ..allowNavigation(new AllUriPolicy());

  /**
   * Constructor.
   */
  UICalendar(DivElement this._myRoot, ORUtil.WeekDays this._weekDays,
      Map<String, String> this._langMap) {
    _setupLocalKeys();
    _observers();
  }

  @override
  HtmlElement get _firstTabElement => _root;
  @override
  HtmlElement get _focusElement => _root;
  @override
  HtmlElement get _lastTabElement => _root;
  @override
  HtmlElement get _listTarget => _list;
  @override
  HtmlElement get _root => _myRoot;

  OListElement get _list => _root.querySelector('.generic-widget-list');

  /**
   * Add [items] to the [CalendarEntry] list.
   */
  set calendarEntries(Iterable<CalendarEntry> items) {
    final List<LIElement> list = new List<LIElement>();
    final DateTime now = new DateTime.now();

    bool isToday(DateTime stamp) =>
        stamp.day == now.day &&
        stamp.month == now.month &&
        stamp.year == now.year;

    String whenWhatLabel(ORModel.CalendarEntry entry) {
      final StringBuffer sb = new StringBuffer();
      String l = entry.ID == ORModel.CalendarEntry.noID ? 'L' : '';
      String r = entry.owner is ORModel.OwningReception ? 'R' : '';

      if (l.isNotEmpty || r.isNotEmpty) {
        sb.write('**[$r$l]** ');
      }

      return sb.toString();
    }

    SpanElement labelElement(ORModel.CalendarEntry entry) {
      final SpanElement label = new SpanElement();

      if (!entry.active) {
        final DateTime now = new DateTime.now();
        if (entry.start.isBefore(now)) {
          label.classes.add('label-past');
          label.text = _langMap[Key.past];
        } else {
          label.classes.add('label-future');
          label.text = _langMap[Key.future];
        }
      }

      return label;
    }

    items.forEach((CalendarEntry ce) {
      final LIElement li = new LIElement();
      final DivElement content = new DivElement()
        ..classes.add('markdown')
        ..setInnerHtml(
            Markdown.markdownToHtml(
                '${whenWhatLabel(ce.calendarEntry)}${ce.calendarEntry.content}'),
            validator: _validator);

      content.querySelectorAll('a').forEach((elem) {
        elem.onClick.listen((MouseEvent event) {
          event.preventDefault();
          final AnchorElement a = event.target;
          window.open(a.href, a.text);
          _markSelected(li);
        });
      });

      String start =
          ORUtil.humanReadableTimestamp(ce.calendarEntry.start, _weekDays);
      String stop =
          ORUtil.humanReadableTimestamp(ce.calendarEntry.stop, _weekDays);

      if (isToday(ce.calendarEntry.start) && !isToday(ce.calendarEntry.stop)) {
        start = '${_langMap[Key.today]} $start';
      }

      if (isToday(ce.calendarEntry.stop) && !isToday(ce.calendarEntry.start)) {
        stop = '${_langMap[Key.today]} $stop';
      }

      final DivElement labelAndTimestamp = new DivElement()
        ..classes.add('label-and-timestamp')
        ..children.addAll([
          labelElement(ce.calendarEntry),
          new SpanElement()
            ..classes.add('timestamp')
            ..text = '${start} - ${stop}'
        ]);

      list.add(li
        ..children.addAll([content, labelAndTimestamp])
        ..title = ce.calendarEntry.ID == ORModel.CalendarEntry.noID
            ? 'WhenWhat'
            : 'Id: ${ce.calendarEntry.ID.toString()}'
        ..dataset['object'] = JSON.encode(ce)
        ..dataset['editable'] = ce.editable.toString()
        ..classes.toggle('active', ce.calendarEntry.active));
    });

    _list.children = list;
  }

  /**
   * Remove all entries from the entry list and clear the header.
   */
  void clear() {
    _headerExtra.text = '';
    _list.children.clear();
  }

  /**
   * Return the first editable [CalendarEntry]. Return empty entry if none is
   * found.
   */
  CalendarEntry get firstEditableCalendarEntry {
    final LIElement li = _list.children.firstWhere(
        (Element elem) => elem.dataset['editable'] == 'true',
        orElse: () => null);

    if (li != null) {
      return new CalendarEntry.fromJson(JSON.decode(li.dataset['object']));
    } else {
      return new CalendarEntry.empty();
    }
  }

  /**
   * Return currently selected [CalendarEntry]. Return empty entry if nothing is
   * selected or if the selected item is not editable.
   */
  CalendarEntry get selectedCalendarEntry {
    final LIElement selected = _list.querySelector('.selected');

    if (selected == null || selected.dataset['editable'] != 'true') {
      return new CalendarEntry.empty();
    } else {
      return new CalendarEntry.fromJson(
          JSON.decode(selected.dataset['object']));
    }
  }

  /**
   * Observers
   */
  void _observers() {
    _root.onKeyDown.listen(_keyboard.press);
    _root.onClick.listen(_selectFromClick);
  }

  /**
   * Mark a [LIElement] in the calendar entry list selected, if one such is the
   * target of the [event].
   */
  void _selectFromClick(MouseEvent event) {
    if (event.target is LIElement) {
      _markSelected(event.target);
    }
  }

  /**
   * Setup keys and bindings to methods specific for this widget.
   */
  void _setupLocalKeys() {
    _hotKeys.registerKeysPreventDefault(_keyboard, _defaultKeyMap(myKeys: {}));
  }
}
