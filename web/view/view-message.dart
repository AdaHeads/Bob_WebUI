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

class SendMessage {

  static const String className = '${libraryName}.SendMessage';

  /* Unused Variables
  final String       placeholderCellphone    = 'Mobil';
  final String       placeholderCompany      = 'Firmanavn';
  final String       placeholderLocalno      = 'Lokalnummer';
  final String       placeholderName         = 'Navn';
  final String       placeholderPhone        = 'Telefon';
  final String       placeholderSearch       = 'Søg...';
  final String       placeholderSearchResult = 'Ingen data fundet';
  final String       placeholderText         = 'Besked';
  final String       recipientTitle          = 'Modtagere';
  String localno                 = '';
  String name                    = '';
  String phone                   = '';
  bool   pleaseCall              = false;
  bool   emergency               = false;
  bool   hasCalled               = false;
  String cellphone               = '';
  String company                 = '';
  bool   callsBack               = true;
  String search                  = '';
  String searchResult            = '';
  String text                    = '';
   */

  DivElement body;
  Box box;
  final String cancelButtonLabel = 'Annuller';
  Context context;
  DivElement element;
  SpanElement header;
  final String saveButtonLabel = 'Gem';
  final String sendButtonLabel = 'Send';
  final String title = 'Besked';
  bool pleaseCallBack = false,
      willCallBack = false,
      called = false,
      urgent = false;

  InputElement sendmessagesearchbox;
  InputElement sendmessagesearchresult;
  InputElement callerNameField;
  InputElement callerCompanyField;
  InputElement callerPhoneField;
  InputElement callerCellphoneField;
  InputElement callerLocalExtensionField;
  TextAreaElement messageBodyField;

  DivElement checkbox1;
  DivElement checkbox2;
  DivElement checkbox3;
  DivElement checkbox4;

  bool hasFocus = false;

  ButtonElement cancelButton;
  ButtonElement draftButton;
  ButtonElement sendButton;

  UListElement recipientsList;

  List<Element> focusElements;

  model.Reception reception = model.nullReception;
  model.Contact contact = model.nullContact;
  List<model.Recipient> recipients = new List<model.Recipient>();

  void set isDisabled(bool disabled) {
    this.element.querySelectorAll('input').forEach((InputElement element) {
      element.disabled = disabled;
      element.tabIndex = disabled ? -1 : 1;
    });

    this.element.querySelectorAll('textarea').forEach((TextAreaElement element) {
      element.disabled = disabled;
      element.tabIndex = disabled ? -1 : 1;
    });

    this.element.querySelectorAll('button').forEach((ButtonElement element) {
      element.disabled = disabled;
      element.tabIndex = disabled ? -1 : 1;
    });
  }

  void clear() {
    this.element.querySelectorAll('input').forEach((InputElement element) {
      element.value = "";
    });

    this.element.querySelectorAll('textearea').forEach((TextAreaElement element) {
      element.value = "";
    });
  }

  SendMessage(DivElement this.element, Context this.context) {
    body = querySelector('.send-message-container');

    header = new SpanElement()..text = title;

    box = new Box.withHeader(element, header, body);

    sendmessagesearchbox = body.querySelector('#${id.SENDMESSAGE_SEARCHBOX}');
    sendmessagesearchresult = body.querySelector('#sendmessagesearchresult');
    callerNameField = body.querySelector('#sendmessagename');
    callerCompanyField = body.querySelector('#sendmessagecompany');
    callerPhoneField = body.querySelector('#sendmessagephone');
    callerCellphoneField = body.querySelector('#sendmessagecellphone');
    callerLocalExtensionField = body.querySelector('#sendmessagelocalno');
    messageBodyField = body.querySelector('#sendmessagetext');

    checkbox1 = body.querySelector('#send-message-checkbox1');
    checkbox2 = body.querySelector('#send-message-checkbox2');
    checkbox3 = body.querySelector('#send-message-checkbox3');
    checkbox4 = body.querySelector('#send-message-checkbox4');

    cancelButton = body.querySelector('#sendmessagecancel')
        ..text = cancelButtonLabel
        ..onClick.listen(cancelClick);

    draftButton = body.querySelector('#sendmessagedraft')
        ..text = saveButtonLabel
        ..onClick.listen(draftClick);

    sendButton = body.querySelector('#sendmessagesend')
        ..text = sendButtonLabel
        ..onClick.listen(sendClick);

    recipientsList = querySelector('#send-message-recipient-list');

    focusElements = [sendmessagesearchbox, callerNameField, callerCompanyField, callerPhoneField, callerCellphoneField, callerLocalExtensionField, messageBodyField, checkbox1, checkbox2, checkbox3, checkbox4, cancelButton, draftButton, sendButton];

    focusElements.forEach((e) => context.registerFocusElement(e));

    this._renderContact(contact);
    _registerEventListeners();
  }

  void render() {
    // Updates the recipient list.
    recipientsList.children.clear();
    this.recipients.forEach((model.Recipient recipient) {
      recipientsList.children.add(new LIElement()..text = recipient.role + ": " + recipient.contactName);
    });
  }


  /**
   * Click handler for the entire message element. Sets the focus to the widget.
   */
  void _onMessageElementClick(_) {
    const String context = '${className}._onMessageElementClick';
    Controller.Context.changeLocation(new nav.Location(id.CONTEXT_HOME, id.SENDMESSAGE, id.SENDMESSAGE_CELLPHONE));
  }

  /**
   * Event handler responsible for selecting the current widget.
   */
  void _onLocationChanged(nav.Location location) {
    bool active = location.widgetId == element.id;
    element.classes.toggle(FOCUS, active);
    if (location.elementId != null) {
      var elem = element.querySelector('#${location.elementId}');
      if (elem != null) {
        elem.focus();
      }
    }
  }

  /**
   * Event handler responsible for updating the recipient list (and UI) when a contact is changed.
   */
  void _renderContact(model.Contact contact) {
    this.contact = contact;

    this.recipients.clear();
    if (this.contact != model.Contact.noContact) {
      this.isDisabled = false;
      contact.dereferenceDistributionList().then((List<model.Recipient> dereferencedDistributionList) {
        // Put all the dereferenced recipients to the local list.
        dereferencedDistributionList.forEach((model.Recipient recipient) {
          this.recipients.add(recipient);
        });

        this.render();
      });
    } else {
      this.isDisabled = true;
      this.render();
    }
  }

  void _registerEventListeners() {
    element.onClick.listen(this._onMessageElementClick);
    event.bus.on(event.locationChanged).listen(this._onLocationChanged);

    event.bus.on(event.contactChanged).listen(this._renderContact);

    event.bus.on(event.receptionChanged).listen((model.Reception value) {
      reception = value;
    });

    event.bus.on(event.callChanged).listen((model.Call value) {
      callerPhoneField.value = '${value.callerId}';
    });


    /* Checkbox logic */
    checkbox1.onKeyUp.listen((KeyboardEvent event) {
      if (event.keyCode == Keys.SPACE) {
        toggle(1);
      }
    });

    checkbox2.onKeyUp.listen((KeyboardEvent event) {
      if (event.keyCode == Keys.SPACE) {
        toggle(2);
      }
    });

    checkbox3.onKeyUp.listen((KeyboardEvent event) {
      if (event.keyCode == Keys.SPACE) {
        toggle(3);
      }
    });

    checkbox4.onKeyUp.listen((KeyboardEvent event) {
      if (event.keyCode == Keys.SPACE) {
        toggle(4);
      }
    });

    checkbox1.parent.onClick.listen((_) => toggle(1));
    checkbox2.parent.onClick.listen((_) => toggle(2));
    checkbox3.parent.onClick.listen((_) => toggle(3));
    checkbox4.parent.onClick.listen((_) => toggle(4));

    element.onClick.listen((MouseEvent e) {
      if ((e.target as Element).attributes.containsKey('tabindex')) {
        event.bus.fire(event.locationChanged, new nav.Location(context.id, element.id, (e.target as Element).id));
      }
    });
  }

  void toggle(int number, {bool shouldBe}) {
    String checkedClass = 'send-message-checkbox-checked';
    switch (number) {
      case 1:
        if (shouldBe != null) {
          pleaseCallBack = shouldBe;
        } else {
          pleaseCallBack = !pleaseCallBack;
        }
        checkbox1.classes.toggle(checkedClass, pleaseCallBack);
        break;
      case 2:
        if (shouldBe != null) {
          willCallBack = shouldBe;
        } else {
          willCallBack = !willCallBack;
        }
        checkbox2.classes.toggle(checkedClass, willCallBack);
        break;
      case 3:
        if (shouldBe != null) {
          called = shouldBe;
        } else {
          called = !called;
        }
        checkbox3.classes.toggle(checkedClass, called);
        break;
      case 4:
        if (shouldBe != null) {
          urgent = shouldBe;
        } else {
          urgent = !urgent;
        }
        checkbox4.classes.toggle(checkedClass, urgent);
        break;
      default:
        log.error('sendmessage: toggle: The given number: ${number} is not accounted for');
    }
  }

  void cancelClick(_) {
    log.debug('SendMessage Cancel Button pressed');
  }

  void draftClick(_) {
    log.debug('SendMessage Draft Button pressed');
  }

  void sendClick(_) {
    log.debug('SendMessage Send Button pressed');

    contact.contextMap().then((Map contextMap) {
      model.Message pendingMessage = new model.Message.fromMap({
        'message': messageBodyField.value,
        'phone': callerPhoneField.value,
        'caller': {
          'name': callerNameField.value,
          'company': callerCompanyField.value,
          'phone': callerPhoneField.value,
          'cellphone': callerCellphoneField.value,
          'localextension': callerLocalExtensionField.value
        },
        'context': contextMap,
        'flags': []
      });


      pleaseCallBack ? pendingMessage.addFlag('urgent') : null;
      willCallBack ? pendingMessage.addFlag('willCallBack') : null;
      called ? pendingMessage.addFlag('called') : null;
      urgent ? pendingMessage.addFlag('urgent') : null;


      for (model.Recipient recipient in this.recipients) {
        pendingMessage.addRecipient(recipient);
      }

      log.dataDump(pendingMessage.toMap.toString(), "components.sendClick");

      this.isDisabled = true;

      pendingMessage.send().then((_) {
        log.debug('Sent message');
        this.clear();
      }).catchError((error) {
        this.isDisabled = false;
        log.debug('----- Send Message Unlucky Result: ${error}');
      });
    });
  }
}