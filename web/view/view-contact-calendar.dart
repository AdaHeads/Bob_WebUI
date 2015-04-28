part of view;

/**
 * TODO (TL): Comment
 */
class ContactCalendar extends ViewWidget {
  final Model.UIContactSelector   _contactSelector;
  final Controller.Destination    _myDestination;
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UIContactCalendar   _ui;
  final Controller.Contact        _contactController;

  /**
   * Constructor.
   */
  ContactCalendar(Model.UIModel this._ui,
                  Controller.Destination this._myDestination,
                  Model.UIContactSelector this._contactSelector,
                  Model.UIReceptionSelector this._receptionSelector,
                  Controller.Contact this._contactController) {
    _ui.setHint('alt+k');
    _observers();
  }

  @override Controller.Destination get myDestination => _myDestination;
  @override Model.UIModel          get ui            => _ui;

  @override void onBlur(_){}
  @override void onFocus(_){}

  /**
   * Activate this widget if it's not already activated.
   */
  void activateMe(_) {
    navigateToMyDestination();
  }

  /**
   * Empty the [CalendarEvent] list on null [Reception].
   */
  void clear(Model.Reception reception) {
    if(reception.isEmpty) {
      _ui.clear();
    }
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(setWidgetState);

    _hotKeys.onAltK.listen(activateMe);

    _ui.onClick .listen(activateMe);
    _ui.onEdit  .listen((_) => _navigate.goCalendarEdit(from: _myDestination..cmd = Cmd.EDIT));
    _ui.onNew   .listen((_) => _navigate.goCalendarEdit(from: _myDestination..cmd = Cmd.NEW));

    _contactSelector.onSelect.listen(render);

    _receptionSelector.onSelect.listen(clear);
  }

  /**
   * Render the widget with [contact].
   */
  void render(Model.Contact contact) {
    if(contact.isEmpty) {
      _ui.clear();
    } else {
      _ui.headerExtra = 'for ${contact.fullName}';

      this._contactController.getCalendar(contact)
        .then((Iterable<Model.ContactCalendarEntry> entries) {

        Iterable<Model.ContactCalendarEntry> sortedEntries = entries.toList()
          ..sort((x,y) => x.startTime.compareTo(y.startTime));

        _ui.calendarEntries = sortedEntries;
      });

      _ui.selectFirstCalendarEntry();
    }
  }
}
