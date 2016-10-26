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

part of view;

/**
 * Handles all calendar entries.
 */
class Calendar extends ViewWidget {
  final Model.UIContactSelector _contactSelector;
  final Logger _log = new Logger('$libraryName.Calendar');
  final Controller.Destination _myDestination;
  final Controller.Notification _notification;
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UICalendar _uiModel;
  final Controller.Contact _contactController;
  final Controller.Calendar _calendarController;

  /**
   * Constructor.
   */
  Calendar(
      Model.UICalendar this._uiModel,
      Controller.Destination this._myDestination,
      Model.UIContactSelector this._contactSelector,
      Model.UIReceptionSelector this._receptionSelector,
      Controller.Contact this._contactController,
      Controller.Calendar this._calendarController,
      Controller.Notification this._notification) {
    _ui.setHint('alt+k | ctrl+k | ctrl+e');

    _observers();
  }

  @override
  Controller.Destination get _destination => _myDestination;
  @override
  void _onBlur(Controller.Destination _) {}
  @override
  void _onFocus(Controller.Destination _) {}
  @override
  Model.UICalendar get _ui => _uiModel;

  /**
   * Activate this widget if it's not already activated.
   */
  void _activateMe() {
    _navigateToMyDestination();
  }

  /**
   * Fetch all calendar entries and [WhenWhat]'s for [contact] and [reception].
   */
  void _fetchCalendar(ORModel.Contact contact, ORModel.Reception reception) {
    final List<Model.CalendarEntry> entries = <Model.CalendarEntry>[];
    final List<Model.CalendarEntry> whenWhats = <Model.CalendarEntry>[];

    Future.wait([
      _calendarController.receptionCalendar(reception),
      _calendarController.contactCalendar(contact)
    ]).then((List responses) {
      for (Iterable response in responses) {
        entries.addAll((response as Iterable<ORModel.CalendarEntry>)
            .map((ORModel.CalendarEntry entry) =>
                new Model.CalendarEntry.empty()..calendarEntry = entry)
            .toList());
      }

      entries.sort(
          (a, b) => a.calendarEntry.start.compareTo(b.calendarEntry.start));

      final bool activeEntry = entries
          .any((Model.CalendarEntry entry) => entry.calendarEntry.active);

      whenWhats.addAll(_getWhenWhats(activeEntry, reception.whenWhats,
          new ORModel.OwningReception(reception.ID)));
      whenWhats.addAll(_getWhenWhats(activeEntry, contact.whenWhats,
          new ORModel.OwningContact(contact.ID)));
      whenWhats.sort(
          (a, b) => a.calendarEntry.start.compareTo(b.calendarEntry.start));

      entries.addAll(whenWhats);

      _ui.calendarEntries = entries;
    });
  }

  /**
   * Return a list of [Model.CalendarEntry] based on the given
   * [ORModel.WhenWhat] objects.
   */
  List<Model.CalendarEntry> _getWhenWhats(bool otherActiveEntry,
      List<ORModel.WhenWhat> whenWhats, ORModel.Owner owner) {
    final List<ORModel.WhenWhatMatch> matches = <ORModel.WhenWhatMatch>[];
    final DateTime now = new DateTime.now();

    for (ORModel.WhenWhat ww in whenWhats) {
      matches.addAll(ww.matches(now));
    }

    ORModel.CalendarEntry entry(ORModel.WhenWhatMatch match) =>
        new ORModel.CalendarEntry.empty()
          ..beginsAt = match.begin
          ..until = match.end
          ..content = match.what
          ..owner = owner;

    return matches
        .map((ORModel.WhenWhatMatch match) => new Model.CalendarEntry.empty()
          ..editable = false
          ..otherActiveWarning = otherActiveEntry
          ..calendarEntry = entry(match))
        .toList();
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(_setWidgetState);

    _hotKeys.onAltK.listen((KeyboardEvent _) => _activateMe());
    _ui.onClick.listen((MouseEvent _) => _activateMe());

    _notification.onCalendarChange.listen(_updateOnChanges);

    _contactSelector.onSelect.listen((Model.ContactWithFilterContext c) =>
        _render(c.contact, _receptionSelector.selectedReception));
  }

  /**
   * Render the widget with [contact] and [reception].
   */
  void _render(ORModel.Contact contact, ORModel.Reception reception) {
    if (contact.isNotEmpty && contact.receptionID != reception.ID) {
      _log.warning('Contact and Reception does not match. No calendars loaded');
    } else {
      if (contact.isEmpty) {
        _ui.clear();
      } else {
        _fetchCalendar(contact, reception);
      }
    }
  }

  /**
   * Check if changes to the calendar matches the currently selected contact or
   * reception, and update accordingly if so.
   */
  void _updateOnChanges(OREvent.CalendarChange calendarChange) {
    final ORModel.Contact currentContact = _contactSelector.selectedContact;
    final ORModel.Reception currentReception =
        _receptionSelector.selectedReception;

    if (calendarChange.contactID == currentContact.ID ||
        calendarChange.receptionID == currentReception.ID) {
      _fetchCalendar(currentContact, currentReception);
    }
  }
}
