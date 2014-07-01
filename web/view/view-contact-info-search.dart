part of view;

class ContactInfoSearch {

  static const String className = '${libraryName}.ContactInfoSearch';
  static const String NavShortcut = 'S'; 

  
               model.Contact       contact              = model.nullContact;
               Context             context;
               UListElement        displayedContactList;
               DivElement          element;
               List<model.Contact> filteredContactList  = new List<model.Contact>();
  static const int                 incrementSteps       = 20;
               model.Reception     reception            = model.nullReception;
               String              placeholder          = 'Søg...';
               model.ContactList   contactList;
               InputElement        searchBox;
               Element             widget;
  static const String              SELECTED             = 'contact-info-active';

  bool hasFocus = false;

  ContactInfoSearch(DivElement this.element, Context this.context, Element this.widget) {
    searchBox = element.querySelector('#contact-info-searchbar') as InputElement
      ..disabled = true;

    displayedContactList = element.querySelector('#contactlist');

    registerEventListeners();
  }

  void activeContact(model.Contact contact) {
    for(LIElement element in displayedContactList.children) {
      element.classes.toggle(SELECTED, element.value == contact.id);
    }

    Controller.Contact.change(contact);
  }

  void _clearDisplayedContactList() {
    displayedContactList
      ..children.clear()
      ..scrollTop = 0;
  }

  void contactClick(Event e) {
    LIElement element = e.target;
    model.Contact contact = contactList.getContact(element.value);
    activeContact(contact);
    if(!hasFocus) {
      event.bus.fire(event.locationChanged, new nav.Location(context.id, widget.id, searchBox.id));
    }
  }

  bool _overflows(Element element) => element.scrollHeight > element.clientHeight;

  LIElement makeContactElement(model.Contact contact) =>
    new LIElement()
      ..text = contact.name
      ..value = contact.id
      ..onClick.listen(contactClick);

  void onkeydown(KeyboardEvent e) {
    if(e.keyCode == Keys.DOWN) {
      nextElement(e);
    } else if(e.keyCode == Keys.UP) {
      previousElement(e);
    }
  }

  void previousElement(KeyboardEvent e) {
    LIElement li = displayedContactList.querySelector('.${SELECTED}');
    LIElement previous = li.previousElementSibling;
    
    if(previous != null) {
      li.classes.toggle(SELECTED, false);
      previous.classes.toggle(SELECTED, true);
      int contactId = previous.value;
      model.Contact con = contactList.getContact(contactId);
      if(con != null) {
        Controller.Contact.change(con);
      }
    }
    e.preventDefault();
  }

  void nextElement(KeyboardEvent e) {
    for(LIElement li in displayedContactList.children) {
      if(li.classes.contains(SELECTED)) {
        LIElement next = li.nextElementSibling;
        if(next != null) {
          li.classes.remove(SELECTED);
          next.classes.add(SELECTED);
          int contactId = next.value;
          model.Contact con = contactList.getContact(contactId);
          if(con != null) {
            Controller.Contact.change(con);
          }
        }
        break;
      }
    }
    e.preventDefault();
  }

  void _performSearch(String search) {
    model.Contact _selectedContact;
    //Clear filtered list
    filteredContactList.clear();

    //Do the search.
    if(search.isEmpty) {
      filteredContactList.addAll(contactList);
    } else {
      filteredContactList.addAll(contactList.where((model.Contact contact) => searchContact(contact, search)));
    }

    _clearDisplayedContactList();

    if(filteredContactList.isNotEmpty) {
      _selectedContact = filteredContactList.first;
      _showMoreElements(incrementSteps);
    } else {
      _selectedContact = model.nullContact;
    }
    activeContact(_selectedContact);
  }

  void registerEventListeners() {

    event.bus.on(event.receptionChanged).listen((model.Reception value) {
      reception = value;
      searchBox.disabled = value == model.nullReception;
      if(value == model.nullReception) {
        searchBox.value = '';
      }

      model.Contact.list(reception.ID).then((model.ContactList list) {
        contactList = list;
        _performSearch(searchBox.value);
      }).catchError((error) => contactList = new model.ContactList.emptyList());
    });

    event.bus.on(event.contactChanged).listen((model.Contact value) {
      contact = value;
    });

    event.bus.on(event.locationChanged).listen((nav.Location location) {
      bool active = location.widgetId == widget.id;
      widget.classes.toggle(FOCUS, active);
      if(location.elementId == searchBox.id) {
        searchBox.focus();
      }
    });

    searchBox.onInput.listen((_) {
      _performSearch(searchBox.value);
    });

    searchBox.onClick.listen((MouseEvent e) {
      event.bus.fire(event.locationChanged, new nav.Location(context.id, widget.id, searchBox.id));
    });

    searchBox
     ..onKeyDown.listen(onkeydown);

    displayedContactList.onScroll.listen(scrolling);

  }

  void scrolling(Event _) {
    var procentage = (displayedContactList.scrollTop + displayedContactList.clientHeight) / displayedContactList.scrollHeight;
    if(procentage >= 1.0) {
      _showMoreElements(incrementSteps);
    }
  }

  bool searchContact(model.Contact value, String search) {
    String searchTerm = search.trim();
    if(searchTerm.contains(' ')) {
      var terms = searchTerm.toLowerCase().split(' ');
      var names = value.name.toLowerCase().split(' ');
      int termIndex = 0;
      int nameIndex = 0;
      while(termIndex < terms.length && nameIndex < names.length) {
        if(names[nameIndex].startsWith(terms[termIndex])) {
          termIndex += 1;
        }
        nameIndex += 1;
      }
      return termIndex >= terms.length;
    }

    return value.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
           value.tags.any((tag) => tag.toLowerCase().contains(searchTerm.toLowerCase()));
  }

  void _showMoreElements(int numberOfElementsMore) {
    int numberOfContactsDisplaying = displayedContactList.children.length;
    //If it don't have a scrollbar, add elements until it gets one, or there are no more elements to show.
    if(!this._overflows(displayedContactList)) {
      int triesStep = 5;
      while(!this._overflows(displayedContactList) && displayedContactList.children.length != filteredContactList.length) {
        var appendingList = filteredContactList.skip(displayedContactList.children.length).take(triesStep);
        displayedContactList.children.addAll(appendingList.map(makeContactElement));
      }

      //TODO: Add some spacing.
      var appendingList = filteredContactList.skip(displayedContactList.children.length).take(triesStep);
      displayedContactList.children.addAll(appendingList.map(makeContactElement));

    } else if (numberOfContactsDisplaying < filteredContactList.length) {
      var appendingList = filteredContactList.skip(numberOfContactsDisplaying).take(numberOfElementsMore);
      displayedContactList.children.addAll(appendingList.map(makeContactElement));
    }
  }
}