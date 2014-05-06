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

part of protocol;

/**
 * Get a list of peers.
 *
 * Completes with
 *  On success : [Response] object with status OK (data)
 *  On error   : [Response] object with status ERROR or CRITICALERROR (data)
 */
Future<Response<Map>> peerList() {
  final String                   base      = configuration.callFlowBaseUrl.toString();
  final Completer<Response<Map>> completer = new Completer<Response<Map>>();
  final String                   path      = '/debug/peer/list';
  HttpRequest                    request;
  final String                   url       = _buildUrl(base, path);

  request = new HttpRequest()
    ..open(GET, url)
    ..withCredentials = true
    ..onLoad.listen((_) {
      switch(request.status) {
        case 200:
          Map data = _parseJson(request.responseText);
          completer.complete(new Response<Map>(Response.OK, data));
          break;

        default:
          completer.completeError(new Response.error(Response.CRITICALERROR, '${url} [${request.status}] ${request.statusText}'));
      }
    })
    ..onError.listen((e) {
      _logError(request, url);
      completer.completeError(new Response.error(Response.CRITICALERROR, e.toString()));
    })
    ..send();

  return completer.future;
}

/**
 * Get a list of PBX channels.
 *
 * Completes with
 *  On success : [Response] object with status OK (data)
 *  On error   : [Response] object with status ERROR or CRITICALERROR (data)
 */
Future<Response<Map>> channelList() {
  final String                   base      = configuration.callFlowBaseUrl.toString();
  final Completer<Response<Map>> completer = new Completer<Response<Map>>();
  final String                   path      = '/debug/channel/list';
  HttpRequest                    request;
  final String                   url       = _buildUrl(base, path);

  request = new HttpRequest()
    ..open(GET, url)
    ..withCredentials = true
    ..onLoad.listen((_) {
      switch(request.status) {
        case 200:
          Map data = _parseJson(request.responseText);
          completer.complete(new Response<Map>(Response.OK, data));
          break;

        default:
          completer.completeError(new Response.error(Response.CRITICALERROR, '${url} [${request.status}] ${request.statusText}'));
      }
    })
    ..onError.listen((e) {
      _logError(request, url);
      completer.completeError(new Response.error(Response.CRITICALERROR, e.toString()));
    })
    ..send();

  return completer.future;
}