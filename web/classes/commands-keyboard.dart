/*                  This file is part of OpenReception
                   Copyright (C) 2012-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library commands_keyboard;

import 'dart:async';
import 'dart:html';

import 'constants.dart';
import 'events.dart' as event;
import 'location.dart' as nav;
import 'logger.dart';
import '../controller/controller.dart' as Controller;
import '../model/model.dart' as Model;

import 'package:okeyee/okeyee.dart';

final _KeyboardHandler keyboardHandler = new _KeyboardHandler();

const bool BACKWARD = false;
const bool FORWARD = true;

/**
 * [Keys] is a simple mapping between constant literals and integer key codes.
 */
class Keys {
  static const int TAB   =  9;
  static const int ENTER = 13;
  static const int SHIFT = 16;
  static const int CTRL  = 17;
  static const int ALT   = 18;
  static const int ESC   = 27;
  static const int SPACE = 32;
  static const int PGUP  = 33;
  static const int PGDOWN= 34;
  static const int END   = 35;
  static const int HOME  = 36;
  static const int UP    = 38;
  static const int DOWN  = 40;
  static const int ZERO  = 48;
  static const int ONE   = 49;
  static const int TWO   = 50;
  static const int THREE = 51;
  static const int FOUR  = 52;
  static const int FIVE  = 53;
  static const int SIX   = 54;
  static const int SEVEN = 55;
  static const int EIGHT = 56;
  static const int A     = 65;
  static const int B     = 66;
  static const int C     = 67;
  static const int D     = 68;
  static const int E     = 69;
  static const int F     = 70;
  static const int G     = 71;
  static const int H     = 72;
  static const int I     = 73;
  static const int J     = 74;
  static const int K     = 75;
  static const int L     = 76;
  static const int M     = 77;
  static const int N     = 78;
  static const int O     = 79;
  static const int P     = 80;
  static const int Q     = 81;
  static const int R     = 82;
  static const int S     = 83;
  static const int T     = 84;
  static const int U     = 85;
  static const int V     = 86;
  static const int W     = 87;
  static const int X     = 88;
  static const int Y     = 89;
  static const int Z     = 90;
}

typedef void KeyboardListener(KeyboardEvent event);

KeyboardListener customKeyboardHandler(Map<String, EventListener> keymappings) {
  Keyboard keyboard = new Keyboard();
  keymappings.forEach((key, callback) => keyboard.register(key, callback));
  return keyboard.press;
}

/**
 * [_KeyboardHandler] handles sinking of keycodes on associated streams. User of
 * this class may subscribe to these streams using the [onKeyName] method.
 *
 * Using this class guarantees that only ONE key event at a time is processed.
 *
 * NOTE: It is up to the users of this class to decide whether to react on a
 * key events or not. This class merely dump the keycodes of fired key events on
 * a stream.
 */
class _KeyboardHandler {

  static const String NavKey     = 'Alt';
  static const String CommandKey = 'Ctrl';

  Map<int, String>                   _keyToName           = new Map<int, String>();
  Map<String, StreamController<int>> _StreamControllerMap = new Map<String, StreamController<int>>();
  int                                _locked              = null;
  nav.Location                       _currentLocation;
  Keyboard keyboard = new Keyboard();

  List<nav.Location> contextHome =
      [new nav.Location(Id.contextHome, Id.receptionSelector,     Id.receptionSelectorSearchbar),
       new nav.Location(Id.contextHome, Id.receptionEvents,       Id.receptionEventsList),
       new nav.Location(Id.contextHome, Id.receptionHandling,     Id.receptionHandlingList),
       new nav.Location(Id.contextHome, Id.receptionOpeningHours, Id.receptionOpeningHoursList),
       new nav.Location(Id.contextHome, Id.receptionSalesCalls,   Id.receptionSalesCallsList),
       new nav.Location(Id.contextHome, Id.receptionProduct,      Id.receptionProductBody),
       new nav.Location(Id.contextHome, Id.contactSelector,       Id.contactSelectorInput),
       new nav.Location(Id.contextHome, Id.contactSelector,       Id.contactCalendar)];

  List<nav.Location> contextHomePlus =
      [new nav.Location(Id.contextHomeplus, Id.receptionCustomerType,       Id.receptionCustomerTypeBody),
       new nav.Location(Id.contextHomeplus, Id.receptionTelephoneNumbers,   Id.receptionTelephoneNumbersList),
       new nav.Location(Id.contextHomeplus, Id.receptionAddresses,          Id.receptionAddressesList),
       new nav.Location(Id.contextHomeplus, Id.receptionAlternateNames,     Id.receptionAlternateNamesList),
       new nav.Location(Id.contextHomeplus, Id.receptionBankingInformation, Id.receptionBankingInformationList),
       new nav.Location(Id.contextHomeplus, Id.receptionEmailAddresses,     Id.receptionEmailAddressesList),
       new nav.Location(Id.contextHomeplus, Id.receptionWebsites,           Id.receptionWebsitesList),
       new nav.Location(Id.contextHomeplus, Id.receptionRegistrationNumber, Id.receptionRegistrationNumberList),
       new nav.Location(Id.contextHomeplus, Id.receptionExtraInformation,   Id.receptionExtraInformationBody)];

  List<nav.Location> contextPhone =
      [new nav.Location(Id.contextPhone, Id.phoneBooth, Id.phoneBoothNumberField)];

  Map<String, Map<nav.Location, int>> tabMap =
      {Id.contextHome       : new Map<nav.Location, int>(),
       Id.contextMessages   : new Map<nav.Location, int>(),
       Id.contextLog        : new Map<nav.Location, int>(),
       Id.contextStatistics : new Map<nav.Location, int>(),
       Id.contextPhone      : new Map<nav.Location, int>(),
       Id.contextVoicemails : new Map<nav.Location, int>()};

  Map<String, List<nav.Location>> locationLists;

  /**
   * [KeyboardHandler] constructor.
   * Initialize (setup named streams) and setup listeners for key events.
   */
  _KeyboardHandler() {
    _buildTabMaps();
    _ctrlAltInitialize();
  }

  /**
   * TODO Blah blah
   */
  void _buildTabMaps() {
    for(int index = 0; index < contextHome.length; index++) {
      tabMap[Id.contextHome][contextHome[index]] = index;
    }

    for(int index = 0; index < contextPhone.length; index++) {
      tabMap[Id.contextPhone][contextPhone[index]] = index;
    }

    locationLists =
      {Id.contextHome : contextHome,
       Id.contextPhone : contextPhone};
  }

  void registerHandler (key, callback) {
    keyboard.register(key, (KeyboardEvent event) {
      event.preventDefault();
      callback(event);
    });
  }

  void registerNavShortcut(key, callback)     => this.registerHandler('${NavKey}+${key}', callback);
  void registerCommandShortcut(key, callback) => this.registerHandler('${CommandKey}+${key}', callback);

  void _ctrlAltInitialize() {
    event.bus.on(event.locationChanged).listen((nav.Location location) {
      _currentLocation = location;
    });

    Map<String, EventListener> keybindings = {
      'Alt+P'      : (_) => Controller.Call.pickupNext(),
      'Alt+L'      : (_) => Controller.Call.park(Model.Call.currentCall),
      'Alt+G'      : (_) => Controller.Call.hangup(Model.Call.currentCall),
      'Alt+U'      : (_) => Model.CallList.instance.parkedCalls.isNotEmpty
                              ? Controller.Call.pickupParked(Model.CallList.instance.parkedCalls.first)
                              : null,
      'Alt+O'      : (_) => Model.CallList.instance.parkedCalls.isNotEmpty
                              ? Controller.Call.transfer(Model.Call.currentCall, Model.CallList.instance.parkedCalls.first)
                              : null,
      'Alt+1'      : (_) => event.bus.fire(event.CallSelectedContact, 1),
      'Alt+2'      : (_) => event.bus.fire(event.CallSelectedContact, 2),
      'Alt+3'      : (_) => event.bus.fire(event.CallSelectedContact, 3),
      'ALT+I'      : (_) => Controller.Call.dialSelectedContact(),
      'Ctrl+K'     : (_) => event.bus.fire(event.CreateNewContactEvent, null),
      'Ctrl+S'     : (_) => event.bus.fire(event.Save, null),
      'Ctrl+Alt+Enter' : Controller.User.signalReady,
      'Ctrl+Alt+P' : Controller.User.signalPaused,
      'Ctrl+Enter' : (_) => event.bus.fire(event.Send, null),
      'Ctrl+Backspace' : (_) => event.bus.fire(event.Delete, null),
      'Ctrl+E'    : (_) => event.bus.fire(event.Edit, null),
      NavKey       : (_) => event.bus.fire(event.keyNav, true),
      CommandKey   : (_) => event.bus.fire(event.keyCommand, true),
      [Key.NumMult]  : (_) => Controller.Call.dialSelectedContact(),
      [Key.NumPlus]  : (_) => Controller.Call.pickupNext(),
      [Key.NumDiv]   : (_) => Controller.Call.hangup(Model.Call.currentCall),
      [Key.NumMinus] : (_) => event.bus.fire(event.TransferFirstParkedCall, null),
          //Controller.Call.completeTransfer(Model.TransferRequest.current,  Model.Call.currentCall)

//      'Tab'       : (_) => tab(mode: FORWARD),
//      'Shift+Tab' : (_) => tab(mode: BACKWARD),

      //TODO This means that every component with a scroll have to handle arrow up/down.
      //'up'        : (_) => event.bus.fire(event.keyUp, null),
      //'down'      : (_) => event.bus.fire(event.keyDown, null)
    };
    // TODO God sigende kommentar - Thomas Løcke
    window.document.onKeyDown.listen(this.keyboard.press);

    keybindings.forEach(this.registerHandler);

    Keyboard keyUp = new Keyboard();
    keybindings = {
      NavKey     : (_) => event.bus.fire(event.keyNav, false),
      CommandKey : (_) => event.bus.fire(event.keyCommand, false),
      'enter'    : (_) => event.bus.fire(event.keyEnter, null),
      'esc'      : (_) => event.bus.fire(event.keyEsc, null),
      'up'       : (_) => event.bus.fire(event.keyUp, null),
      'down'     : (_) => event.bus.fire(event.keyDown, null)
    };

    keybindings.forEach((key, callback) => keyUp.register(key, (KeyboardEvent event) {
      event.preventDefault();
      callback(event);
    }));

    window.document.onKeyUp.listen(keyUp.press);

//    ctrlAlt.Keys.shortcuts({
//      'Ctrl+1'    : () => event.bus.fire(event.locationChanged, new nav.Location.context(id.CONTEXT_HOME)),
//      'Ctrl+5'    : () => event.bus.fire(event.locationChanged, new nav.Location.context(id.CONTEXT_PHONE)),
//      'Ctrl+C'    : () => event.bus.fire(event.locationChanged, new nav.Location(id.CONTEXT_HOME, id.COMPANY_SELECTOR, id.COMPANY_SELECTOR_SEARCHBAR)),
//      'Ctrl+E'    : () => event.bus.fire(event.locationChanged, new nav.Location(id.CONTEXT_HOME, id.receptionEvents, id.receptionEventsList)),
//      'Ctrl+H'    : () => event.bus.fire(event.locationChanged, new nav.Location(id.CONTEXT_HOME, id.companyHandling, id.companyHandlingList)),
//      'Ctrl+M'    : () => event.bus.fire(event.locationChanged, new nav.Location(id.CONTEXT_HOME, 'sendmessage', 'sendmessagecellphone')),
//      'Ctrl+P'    : () => event.bus.fire(event.pickupNextCall, 'Keyboard'),
//      'Tab'       : () => tab(mode: FORWARD),
//      'Shift+Tab' : () => tab(mode: BACKWARD)
//    });
  }

  void tab({bool mode}) {
    String contextId = _currentLocation.contextId;
    if(tabMap.containsKey(contextId) && locationLists.containsKey(contextId)) {
      Map<nav.Location, int> map = tabMap[contextId];
      List<nav.Location> list = locationLists[contextId];

      if(map.containsKey(_currentLocation)) {
        int index = (map[_currentLocation] + (mode ? 1 : -1)) % map.length;
        event.bus.fire(event.locationChanged, list[index]);
      } else {
        log.error('keyboard.tab() bad location ${_currentLocation}');
      }

    } else {
      log.error('keyboard.tab() bad context ${_currentLocation}');
    }
  }
}