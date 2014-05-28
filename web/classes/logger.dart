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

library logger;

import 'dart:async';
import 'dart:html';

import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

import 'configuration.dart';
import '../protocol/protocol.dart' as protocol;
import 'state.dart';

final Log log = new Log._internal();

/**
 * [Log] manages the logging system. Log messages are written to the system using
 * the [debug()], [info()], [error()] and [critical()] methods, each of which
 * represents a log level equivalent to its name.
 *
 * Log messages of levels INFO, ERROR and CRITICAL are sent to Alice according
 * to [configuration.serverLogLevel]. DEBUG log messages are sent to console.
 *
 * Users of [Log] can listen for select log records on the [userLogStream]. See
 * [info()], [error()] and [critical()] for more information.
 */
class Log {

  static final DateFormat dateFormat = new DateFormat.Hms();

  /**
   * Loglevels that represent the levels on the server side.
   */
  static const Level DEBUG    = const Level('Debug   ',  300);
  static const Level INFO     = const Level('Info    ',  800);
  static const Level ERROR    = const Level('Error   ', 1000);
  static const Level CRITICAL = const Level('Critical', 1200);

  final Logger                  _logger            = new Logger("System");
  final Logger                  _ulogger           = new Logger("User");
  StreamSubscription<LogRecord> _consoleLogStream;
  StreamSubscription<LogRecord> _serverLogStream;

  Stream<LogRecord> get userLogStream => _ulogger.onRecord;

  /**
   * [Log] constructor.
   */
  Log._internal() {
    // we need this to keep things sane.
    hierarchicalLoggingEnabled = true;

    _logger.parent.level = Level.ALL;
    _ulogger.parent.level = Level.ALL;

    _registerEventListeners();
  }

  /**
   * Log [message] with level [CRITICAL]. If [toUserLog] is true then [message]
   * is also dumped to [userLogStream].
   */
  void critical (String message, {bool toUserLog: false}) {
    if (toUserLog) {
      _ulogger.log(CRITICAL, message);
    } else {
      _logger.log(CRITICAL, message);
    }
  }

  /**
   * Log [message] with level [DEBUG]. DEBUG level messages are only logged to
   * console.
   */
  void debug (String message)                           => print('[DEBUG]    - ${Log.dateFormat.format(new DateTime.now())} - ${message}');
  void debugContext (String message, String context)    => print('[DEBUG]    - ${Log.dateFormat.format(new DateTime.now())} - $context - ${message}');
  void fixmeContext (String message, String context)    => print('[FIXME]    - ${Log.dateFormat.format(new DateTime.now())} - $context - ${message}');
  void dataDump (String data, String context)           => print('[DATADUMP] - ${Log.dateFormat.format(new DateTime.now())} - $context - ${data}');
  void criticalContext (String message, String context) => print('[CRITICAL] - ${Log.dateFormat.format(new DateTime.now())} - $context - ${message}');
  void criticalError (Error error, String context)      => print('[CRITICAL] - ${Log.dateFormat.format(new DateTime.now())} - $context - ${error.toString()}');
  void errorContext (String message, String context)    => print('[ERROR]    - ${Log.dateFormat.format(new DateTime.now())} - $context - ${message}');

  /**
   * Log [message] with level [ERROR]. If [toUserLog] is true then [message]
   * is also dumped to [userLogStream].
   */
  void error(String message, {bool toUserLog: false}) {
    if (toUserLog) {
      _ulogger.log(ERROR, message);
    } else {
      _logger.log(ERROR, message);
    }
  }

  /**
   * Log [message] with level [INFO]. If [toUserLog] is true then [message]
   * is also dumped to [userLogStream].
   */
  void info(String message, {bool toUserLog: false}) {
    if (toUserLog) {
      _ulogger.log(INFO, message);
    } else {
      _logger.log(INFO, message);
    }
  }

  /**
   * Writes [record] to the console and then sends it to Alice.
   */
  void _consoleLogSubscriber(LogRecord record) {
    print('[${record.level.name}] - ${new DateFormat.Hms().format(new DateTime.now())} - ${record.loggerName} - ${record.message}');
  }

  /**
   * Registers event listeners.
   */
  _registerEventListeners() {
    _consoleLogStream = _logger.onRecord.listen(_consoleLogSubscriber);

    _serverLogStream = _logger.onRecord.listen(_serverLog);
    _pauseServerStream();

    _ulogger.onRecord.listen(_consoleLogSubscriber);
  }

  /**
   * Pauses server stream.
   */
  void _pauseServerStream() {
    if (!_serverLogStream.isPaused) {
      _serverLogStream.pause();
      connect();
    }
  }

  /**
   * Resumes server stream.
   */
  void _resumeServerStream() {
    if(_serverLogStream.isPaused) {
      _serverLogStream.resume();
    }
  }

  /**
   * Tests if there is a connecting to alice.
   */
  void connect() {
    if (configuration.isLoaded() && configuration.hasToken) {
      String browserInfo = window.navigator.userAgent;
      Duration retryTime = new Duration(seconds: 3);
      
      protocol.logInfo('Logger connecting from ${browserInfo}').then((protocol.Response response) {
        if (response.status == protocol.Response.OK) {
          _resumeServerStream();
          state.loggerOK();
        } else {
          new Timer(retryTime, connect);
          state.loggerError();
        }
      }).catchError((e) {
        new Timer(retryTime, connect);
        state.loggerError();
        print('${new DateTime.now()} Logger.connect failed with ${e}');
      });
    } else {
      new Timer(new Duration(milliseconds: 100), connect);
    }
  }

  /**
   * Sends the log [record] to Alice.
   */
  _serverLog(LogRecord record) {
    if (configuration.serverLogLevel <= record.level) {
      String text = '${record.loggerName} - ${record.sequenceNumber} - ${record.message}';

      if (record.level > Level.INFO && record.level <= Level.SEVERE) {
        protocol.logError(text).then((protocol.Response response) {
          _serverLogResponseHandler(response, record, text);
        })
        .catchError((e) {
          _serverLogException(record, e, text);
        });

      } else if (record.level > Level.SEVERE) {
        protocol.logCritical(text).then((protocol.Response response) {
          _serverLogResponseHandler(response, record, text);
        })
        .catchError((e) {
          _serverLogException(record, e, text);
        });

      } else {
        protocol.logInfo(text).then((protocol.Response response) {
          _serverLogResponseHandler(response, record, text);
        })
        .catchError((e) {
          _serverLogException(record, e, text);
        });
      }
    }
  }

  /**
   * Handle the response from the server connect request.
   */
  void _serverLogResponseHandler(protocol.Response response, LogRecord record, String text) {
    if (response.status != protocol.Response.OK) {
      _serverLogError(record, response, text);
    } else if(response.status == protocol.Response.OK) {
      _resumeServerStream();
    }
  }

  /**
   * TODO comment
   */
  void _serverLogException(LogRecord record, e, String text) {
    String message = '${record.sequenceNumber} ${record.level.name} server logging error: ${e} Message: ${text}';
    print(message);
    _pauseServerStream();
    critical('Retransmitting: ${message}');
  }

  /**
   * TODO comment
   */
  void _serverLogError(LogRecord record, protocol.Response response, String text) {
    String message = '${record.sequenceNumber} ${record.level.name} server logging error: ${response.data} Message: ${text}';
    print(message);
    _pauseServerStream();
    critical('Retransmitting: ${message}');
  }
}
