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

part of view;

/**
 * 
 */

class CallManagement {

  static final String id = constant.ID.CALL_MANAGEMENT;
  static final String className = '${libraryName}.CallManagement';
  final DivElement node;

  // Temporary
  ButtonElement pickupnextcallbutton;
  ButtonElement hangupcallButton;
  ButtonElement holdcallButton;
  DivElement    currentCallContainer;
  Component.Call currentCall;

  /**
   * TODO
   */
  CallManagement(DivElement this.node) {
    pickupnextcallbutton = querySelector('#pickupnextcallbutton')
        ..onClick.listen((_) => Controller.Call.pickupNext())
        ..tabIndex = -1;

    hangupcallButton = querySelector('#hangupcallButton')
        ..onClick.listen((_) => Controller.Call.hangup(model.Call.currentCall))
        ..tabIndex = -1;

    holdcallButton = querySelector('#holdcallButton')
        ..onClick.listen((_) => Controller.Call.park(model.Call.currentCall))
        ..tabIndex = -1;
    
    registerEventListeners();
    this.currentCallContainer = this.node.querySelector("#current-call");
    _changeActiveCall(model.Call.currentCall);
  }

  _changeActiveCall(model.Call call) {
    String newText;
    this.currentCallContainer.children.clear();
    
    if (call != model.nullCall) {
      print ("!! Chaging calls");
      this.currentCall = new Component.Call (call);
      
      this.currentCallContainer.children.add(currentCall.element);
      this.currentCallContainer.children.add(new HeadElement()..text = "asd");
    } else {
      
      newText = constant.Label.NOT_IN_CALL;
    }

    this.currentCallContainer.text = newText;
  }

  void _originationStarted(String number) {
    this.node.querySelector('#current-call-info').text = 'Ringer til ${number}..';
  }

  void _originationSucceded(dynamic) {
    this.node.querySelector('#current-call-info').text = 'Forbundet!';
  }

  void _originationFailed(dynamic) {
    this.node.querySelector('#current-call-info').text = 'Fejlet!';
  }

  void _handleHangup(dynamic) {
    
  }
  
  void registerEventListeners() {
    event.bus.on(model.Call.currentCallChanged).listen(_changeActiveCall);
    event.bus.on(event.hangupCall).listen(_handleHangup);
    event.bus.on(event.originateCallRequest).listen(_originationStarted);
    event.bus.on(event.originateCallRequestSuccess).listen(_originationSucceded);
    event.bus.on(event.originateCallRequestFailure).listen(_originationFailed);
  }
}
