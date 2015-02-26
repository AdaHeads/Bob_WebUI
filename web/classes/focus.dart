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

library focus;

import 'constants.dart';
import 'events.dart' as event;
import 'logger.dart';

String _currentFocusId = '';
Map<String, int> _tabIndexes =
  {Id.receptionSelectorSearchbar:       1,
   'reception-events-list':             2,
   Id.receptionHandlingList:            3,
   Id.contactSelectorInput:             4,
   'contact-calendar':                  6,
   Id.sendMessageSearchBox:             8,
   'sendmessagesearchresult':           9,
   Id.sendMessageName:                 10,
   Id.sendMessageReception:            11,
   Id.sendMessagePhone:                12,
   Id.sendMessageCellPhone:            13,
   Id.sendMessageLocalNo:              14,
   Id.sendMessageText:                 15,
   'send-message-checkbox1':           16,
   'send-message-checkbox2':           17,
   'send-message-checkbox3':           18,
   'send-message-checkbox4':           19,
   Id.sendMessageCancel:               20,
   Id.sendMessageDraft:                21,
   Id.sendMessageSend:                 22,
   Id.receptionOpeningHoursList:       25,
   Id.receptionSalesCallsList:         26,
   Id.receptionProductBody:            27,
   Id.receptionCustomerTypeBody:       28,
   Id.receptionTelephoneNumbersList:   29,
   Id.receptionAddressesList:          30,
   Id.receptionAlternateNamesList:     31,
   Id.receptionBankingInformationList: 32,
   Id.receptionEmailAddressesList:     33,
   Id.receptionWebsitesList:           34,
   Id.receptionRegistrationNumberList: 35,
   Id.receptionExtraInformationBody:   36,
   Id.globalCallQueueList:             37,
   'local-queue-list':                 38,

   'message-search-agent-searchbar':    1,
   'message-search-type-searchbar':     2,
   'message-search-company-searchbar':  3,
   'message-search-contact-searchbar':  4,
   'message-search-print':              5,
   'message-search-resend':             6,

   'phone-booth-reception-search-bar':  1,
   'phone-booth-number-field':          2,
   'phone-booth-button':                3};

int getTabIndex (String id) {
  if(_tabIndexes.containsKey(id)) {
    return _tabIndexes[id];
  } else {
    log.error('Focus getTabIndex: Unknown id asked for tabIndex: ${id}');
    return -1;
  }
}

void setFocus(String newFocusId) {
  if(newFocusId != _currentFocusId) {
    var focusEvent = new Focus(_currentFocusId, newFocusId);
    _currentFocusId = newFocusId;
    event.bus.fire(event.focusChanged, focusEvent);
  }
}

class Focus{
  String _old, _current;

  String get old => _old;
  String get current => _current;

  Focus(String this._old, String this._current);
}
