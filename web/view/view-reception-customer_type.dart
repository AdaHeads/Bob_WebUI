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

class ReceptionCustomerType {
  
  final Context        context;
  final Element        element;
  
  bool get muted => this.context != Context.current;
  
  static const String className = '${libraryName}.ReceptionCustomerType';
  static const String NavShortcut = 'D';
  List<Element> get nudges => this.element.querySelectorAll('.nudge');
  void set nudgesHidden(bool hidden) => this.nudges.forEach((Element element) => element.hidden = hidden);

  ParagraphElement get body   => this.element.querySelector('#${id.COMPANY_CUSTOMERTYPE_BODY}');
  Element          get header => this.element.querySelector('legend');
  String           title     = 'Kundetype';

  ReceptionCustomerType(Element this.element, Context this.context) {
    assert(element.attributes.containsKey(defaultElementId));
    header.text = title;

    ///Navigation shortcuts
    this.element.insertBefore(new Nudge(NavShortcut).element,  this.header);
    keyboardHandler.registerNavShortcut(NavShortcut, this._select);

    registerEventListeners();
  }

  void _select(_) {
    if (!muted) {
      Controller.Context.changeLocation(new nav.Location(this.context.id, this.element.id, this.body.id));
    } else {
      print (this.context);
    }
  }

  void registerEventListeners() {

    event.bus.on(event.keyNav).listen((bool isPressed) => this.nudgesHidden = !isPressed);

    event.bus.on(event.receptionChanged).listen((model.Reception value) {
      body.text = value.customerType;
    });

    element.onClick.listen((_) {
      Controller.Context.changeLocation(new nav.Location(context.id, element.id, body.id));
    });

    event.bus.on(event.locationChanged).listen((nav.Location location) {
      bool active = location.widgetId == element.id;
      element.classes.toggle(FOCUS, active);
      if(active) {
        body.focus();
      }
    });
  }
}
