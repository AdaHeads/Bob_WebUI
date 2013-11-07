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

part of components;

class CompanyProduct {
  DivElement         body;
  Box                box;
  DivElement         element;
  bool               hasFocus = false;
  SpanElement        header;
  model.Organization organization = model.nullOrganization;
  String             title        = 'Produktbeskrivelse';

  CompanyProduct(DivElement this.element) {
    element.classes.add('minibox');

    //TODO ??? FIXME XXX WARNING ERROR TL LØCKE ALERT Skal det "bare" være en Div med teksten inde i????
    body = new DivElement()
      ..style.padding = '5px'
      ..id = 'company-product-body'
      ..tabIndex = getTabIndex('company-product-body');

    header = new SpanElement()
      ..text = title;

    box = new Box.withHeader(element, header, body);

    registerEventListeners();
  }

  void registerEventListeners() {
    event.bus.on(event.organizationChanged).listen((model.Organization value) {
      organization = value;
      body.text = value.product;
    });

    event.bus.on(event.focusChanged).listen((Focus value) {
      if(value.old == body.id) {
        hasFocus = false;
        element.classes.remove(focusClassName);
      }

      if(value.current == body.id) {
        hasFocus = true;
        element.classes.add(focusClassName);
        body.focus();
      }
    });

    body.onFocus.listen((_) {
      setFocus(body.id);
    });

    element.onClick.listen((_) {
      setFocus(body.id);
    });
  }
}
