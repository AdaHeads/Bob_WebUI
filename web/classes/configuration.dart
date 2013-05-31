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

library configuration;

import 'dart:async';
import 'dart:html';
import 'dart:json' as json;
import 'dart:uri';

import 'package:logging/logging.dart';
import 'package:web_ui/web_ui.dart';

import 'common.dart';
import 'logger.dart';

final _Configuration configuration = new _Configuration();

/**
 * Access to configuration parameters provided by Alice.
 */
class _Configuration {
  @observable bool _loaded = false;

  const String _CONFIGURATION_URL = 'http://alice.adaheads.com:4242/configuration';

  int _agentID;
  Uri _aliceBaseUrl;
  Uri _notificationSocketInterface;
  int _notificationSocketReconnectInterval;
  Level _serverLogLevel = Level.OFF;
  Uri _serverLogInterfaceCritical;
  Uri _serverLogInterfaceError;
  Uri _serverLogInterfaceInfo;
  String _standardGreeting;
  int _userLogSizeLimit = 100000;

  int    get agentID => _agentID;
  Uri    get aliceBaseUrl => _aliceBaseUrl;
  bool   get loaded => _loaded;
  Uri    get notificationSocketInterface => _notificationSocketInterface;
  int    get notificationSocketReconnectInterval => _notificationSocketReconnectInterval;
  Level  get serverLogLevel => _serverLogLevel;
  Uri    get serverLogInterfaceCritical => _serverLogInterfaceCritical;
  Uri    get serverLogInterfaceError => _serverLogInterfaceError;
  Uri    get serverLogInterfaceInfo => _serverLogInterfaceInfo;
  String get standardGreeting => _standardGreeting;
  int    get userLogSizeLimit => _userLogSizeLimit;

  /**
   * Constructor
   */
  _Configuration() {
    HttpRequest.request(_CONFIGURATION_URL)
      .then(_onComplete)
      .catchError(_onError);
  }

  /**
   * TODO comment
   */
  void _onComplete(HttpRequest req) {
    switch(req.status) {
      case 200:
        _parseConfiguration(json.parse(req.responseText)['dart']);
        _loaded = true;
        break;

      default:
        log.critical('Configuration ERROR ${_CONFIGURATION_URL} - ${req.status} - ${req.statusText}');
    }
  }

  /**
   * TODO comment
   */
  void _onError(Object error) {
    log.critical('Configuration ERROR ${error} - ${error.runtimeType.toString()}');
  }

  /**
   * Parse and validate the configuration JSON from Alice.
   */
  void _parseConfiguration(Map json) {
    _agentID = _intValue (json, 'agentID', 0);
    _aliceBaseUrl = new Uri(_stringValue(json, 'aliceBaseUrl', 'http://alice.adaheads.com:4242'));

    Map notificationSocketMap = json['notificationSocket'];
    _notificationSocketReconnectInterval = _intValue(notificationSocketMap,
                                                     'reconnectInterval', 1000);
    _notificationSocketInterface = new Uri(_stringValue(notificationSocketMap,
                                           'interface',
                                           'ws://alice.adaheads.com:4242/notifications'));

    Map serverLogMap = json['serverLog'];
    switch (serverLogMap['level'].toLowerCase()){
      case 'info':
        _serverLogLevel = Log.INFO;
        break;
      case 'error':
        _serverLogLevel = Log.ERROR;
        break;
      case 'critical':
        _serverLogLevel = Log.CRITICAL;
        break;
      default:
        _serverLogLevel = Level.INFO;
        log.error('Configuration logLevel had the invalid value: ${json['serverLogLevel']}');
        break;
    }

    String criticalPath = _stringValue(serverLogMap['interface'], 'critical', '/log/critical');
    _serverLogInterfaceCritical = new Uri('${aliceBaseUrl}${criticalPath}');

    String errorPath = _stringValue(serverLogMap['interface'], 'error', '/log/error');
    _serverLogInterfaceError = new Uri('${aliceBaseUrl}${errorPath}');

    String infoPath = _stringValue(serverLogMap['interface'], 'info', '/log/info');
    _serverLogInterfaceInfo = new Uri('${aliceBaseUrl}${infoPath}');

    _standardGreeting = _stringValue(json, 'standardGreeting', 'Velkommen til...');
  }

  /**
   * Return a bool from [configMap] or [defaultValue].
   *
   * If [key] is found in [configMap] and the value is a bool, return the found bool.
   * if [key] is not found or does not validate as a bool, return [defaultValue].
   */
  bool _boolValue (Map configMap, String key, bool defaultValue) {
    if ((configMap.containsKey(key)) && (configMap[key] is bool)) {
      return configMap[key];
    } else {
      log.critical('Configuration parameter ${key} does not validate as bool');
      return defaultValue;
    }
  }

  /**
   * Return an int from [configMap] or [defaultValue].
   *
   * If [key] is found in [configMap] and the value is an int, return the found int.
   * if [key] is not found or does not validate as an int, return [defaultValue].
   */
  int _intValue (Map configMap, String key, int defaultValue) {
    if ((configMap.containsKey(key)) && (configMap[key] is int)) {
      return configMap[key];
    } else {
      log.critical('Configuration parameter ${key} does not validate as int');
      return defaultValue;
    }
  }

  /**
   * Return a String from [configMap] or [defaultValue].
   *
   * If [key] is found in [configMap] and the value is a String, return the found String.
   * if [key] is not found or does not validate as a String, return [defaultValue].
   * Note that [defaultValue] is also returned if the found String is empty.
   */
  String _stringValue (Map configMap, String key, String defaultValue) {
    if ((configMap.containsKey(key)) && (configMap[key] is String)) {
      return (configMap[key].trim().isEmpty) ? defaultValue : configMap[key];
    } else {
      log.critical('Configuration parameter ${key} does not validate as String');
      return defaultValue;
    }
  }
}

/**
 * Fetch the configuration.
 *
 * Completes when [configuration.loaded] is true.
 */
Future<bool> fetchConfig() {
  Completer completer = new Completer();

  if (configuration.loaded) {
    completer.complete(true);
  } else {
    final Duration repeatTime = new Duration(milliseconds: 5);
    final Duration maxWait = new Duration(milliseconds: 3000);
    var count = 0;

    new Timer.periodic(repeatTime, (timer) {
      count += 1;
      if (configuration.loaded) {
        timer.cancel();
        completer.complete(true);
      }

      if (count >= maxWait.inMilliseconds/repeatTime.inMilliseconds) {
       timer.cancel();
       completer.completeError(
           new TimeoutException("Could not fetch configuration."));
     }
    });
  }

  return completer.future;
}
