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

class CompanyAddresses {
  Box             box;
  Context         context;
  Element      element;
  bool            hasFocus  = false;
  SpanElement     header;
  model.Reception reception = model.nullReception;
  UListElement    ul;
  String          title     = 'Adresser';

  CompanyAddresses(Element this.element, Context this.context) {
    String defaultElementId = 'data-default-element';
    assert(element.attributes.containsKey(defaultElementId));
    
    ul = element.querySelector('#${id.COMPANY_ADDRESSES_LIST}');

    header = new SpanElement()
      ..text = title;

    registerEventListeners();
  }

  void registerEventListeners() {
    event.bus.on(event.receptionChanged).listen(render);

    element.onClick.listen((_) {
      event.bus.fire(event.locationChanged, new nav.Location(context.id, element.id, ul.id));
    });

    event.bus.on(event.locationChanged).listen((nav.Location location) {
      bool active = location.widgetId == element.id;
      element.classes.toggle(FOCUS, active);
      if(active) {
        ul.focus();
      }
    });
  }

  void render(model.Reception reception) {
    ul.children.clear();

    for(var value in reception.addressList) {
      ul.children.add(new LIElement()
                        ..text = value.value);
    }
  }
}