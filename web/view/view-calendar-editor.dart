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
 * The calendar editor widget.
 */
class CalendarEditor extends ViewWidget {
  final Model.UICalendar _calendar;
  final Controller.Calendar _calendarController;
  final Model.UIContactSelector _contactSelector;
  final Map<String, String> _langMap;
  final Logger _log = new Logger('$libraryName.CalendarEditor');
  final Controller.Destination _myDestination;
  final Controller.Popup _popup;
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UICalendarEditor _uiModel;

  /**
   * Constructor
   */
  CalendarEditor(
      Model.UICalendarEditor this._uiModel,
      Controller.Destination this._myDestination,
      Model.UICalendar this._calendar,
      Model.UIContactSelector this._contactSelector,
      Model.UIReceptionSelector this._receptionSelector,
      Controller.Calendar this._calendarController,
      Controller.Popup this._popup,
      Map<String, String> this._langMap) {
    _ui.setHint('Esc | ctrl+backspace | ctrl+s ');

    _observers();
  }

  @override
  Controller.Destination get _destination => _myDestination;
  @override
  void _onBlur(Controller.Destination _) {}
  @override
  void _onFocus(Controller.Destination _) {}
  @override
  Model.UICalendarEditor get _ui => _uiModel;

  /**
   * Activate this widget if it's not already activated.
   */
  void _activateMe(Controller.Cmd cmd) {
    if (_receptionSelector.selectedReception != ORModel.Reception.noReception) {
      _setup(Controller.Widget.calendar, cmd);
    }
  }

  /**
   * Close the widget and cancel edit/create calendar entry.
   *
   * Clear the form and navigate one step back in history.
   */
  void _close() {
    _ui.reset();
    window.history.back();
  }

  /**
   * Delete the calendar entry.
   *
   * Clear the form and navigate one step back in history.
   */
  void _delete(ORModel.CalendarEntry loadedEntry) {
    _calendarController.deleteCalendarEvent(_ui.loadedEntry).then((_) {
      _log.info('${loadedEntry} successfully deleted from database');
      _popup.success(
          _langMap[Key.calendarEditorDelSuccessTitle], 'ID ${loadedEntry.ID}');
    }).catchError((error) {
      _log.shout('Could not delete calendar entry ${loadedEntry}');
      _popup.error(
          _langMap[Key.calendarEditorDelErrorTitle], 'ID ${loadedEntry.ID}');
    }).whenComplete(() => _close());
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(_setWidgetState);

    _hotKeys.onCtrlE.listen((_) => _activateMe(Controller.Cmd.edit));
    _hotKeys.onCtrlK.listen((_) => _activateMe(Controller.Cmd.create));

    _ui.onCancel.listen((MouseEvent _) => _close());
    _ui.onDelete.listen((MouseEvent _) async => await _delete(_ui.loadedEntry));
    _ui.onSave.listen((MouseEvent _) async => await _save(_ui.harvestedEntry));
  }

  /**
   * Save the calendar entry.
   *
   * Clear the form when done, and then navigate one step back in history.
   */
  void _save(ORModel.CalendarEntry entry) {
    _calendarController
        .saveCalendarEvent(entry)
        .then((ORModel.CalendarEntry savedEntry) {
      _log.info('${savedEntry} successfully saved to database');
      _popup.success(
          _langMap[Key.calendarEditorSaveSuccessTitle], 'ID ${savedEntry.ID}');
    }).catchError((error) {
      ORModel.CalendarEntry loadedEntry = _ui.loadedEntry;
      _log.shout('Could not save calendar entry ${loadedEntry}');
      _popup.error(
          _langMap[Key.calendarEditorSaveErrorTitle], 'ID ${loadedEntry.ID}');
    }).whenComplete(() => _close());
  }

  /**
   * Render the widget with [calendarEntry].
   */
  void _render(Model.CalendarEntry calendarEntry, bool isNew) {
    _ui.setCalendarEntry(calendarEntry, isNew);
  }

  /**
   * Set the [_ui.authorStamp]. This is populated with data from the latest
   * calendar entry change object for [entryId].
   */
  void _setAuthorStamp(ORModel.CalendarEntry entry) {
    _calendarController
        .calendarEntryLatestChange(entry)
        .then((ORModel.CalendarEntryChange latestChange) {
      _ui.authorStamp(latestChange.username, latestChange.changedAt);
    });
  }

  /**
   * Setup the widget accordingly to where it was opened from. [from] MUST be
   * the [Controller.Widget] that activated CalendarEditor.
   *
   * [from] decides which calendar to create/edit entries for.
   */
  void _setup(Controller.Widget from, Controller.Cmd cmd) {
    Model.CalendarEntry ce;

    if (from == Controller.Widget.calendar) {
      if (cmd == Controller.Cmd.edit) {
        ce = _calendar.selectedCalendarEntry;

        if (ce.calendarEntry == null) {
          ce = _calendar.firstEditableCalendarEntry;
        }

        if (ce.calendarEntry != null &&
            ce.calendarEntry.ID != ORModel.CalendarEntry.noID) {
          final String name = ce.calendarEntry.owner is ORModel.OwningContact
              ? _contactSelector.selectedContact.fullName
              : _receptionSelector.selectedReception.name;
          _ui.headerExtra = '(${_langMap[Key.editDelete]} $name)';

          if (_ui.currenntAuthorStamp.isEmpty) {
            _setAuthorStamp(ce.calendarEntry);
          }

          _render(ce, false);

          _navigateToMyDestination();
        }
      } else {
        final ORModel.CalendarEntry entry = new ORModel.CalendarEntry.empty()
          ..owner =
              new ORModel.OwningContact(_contactSelector.selectedContact.ID)
          ..beginsAt = new DateTime.now()
          ..until = new DateTime.now().add(new Duration(hours: 1))
          ..content = '';
        ce = new Model.CalendarEntry.empty()..calendarEntry = entry;

        _ui.headerExtra =
            '(${_langMap[Key.editorNew]} ${_contactSelector.selectedContact.fullName})';
        _ui.authorStamp(null, null);

        _render(ce, true);

        _navigateToMyDestination();
      }
    } else {
      /// No valid initiator. Go home.
      _navigate.goHome();
    }
  }
}
