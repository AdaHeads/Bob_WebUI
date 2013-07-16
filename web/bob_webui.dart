/*                     This file is part of Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

/**
 * The Bob client. Helping receptionists do their work every day.
 */
import 'dart:async';

import 'package:web_ui/web_ui.dart';

import 'classes/common.dart';
import 'classes/configuration.dart';
import 'classes/logger.dart';
import 'classes/notification.dart';

@observable bool bobReady = false;

Future _configurationCheck() => repeatCheck(configuration.isLoaded, 20, new Duration(milliseconds: 50), timeoutMessage: 'configuration.isLoaded is false');
Future _notificationCheck() => repeatCheck(notification.isConnected, 20, new Duration(milliseconds: 50), timeoutMessage: 'notification.isConnected is false');

/**
 * Get Bob going as soon as the configuration is loaded.
 */
void main() {
  _configurationCheck().then((_) => _notificationCheck())
                       .then((_) => bobReady = true)
                       .catchError((error) => log.critical('Bob main exception: ${error}'));
}
