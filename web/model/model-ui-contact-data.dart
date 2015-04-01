part of model;

class UIContactData extends UIModel {
  final DivElement _myRoot;

  UIContactData(DivElement this._myRoot) {
    _focusElement = _telNumList;
  }

  @override HtmlElement get _root => _myRoot;

  UListElement get _additionalInfoList => _root.querySelector('.additional-info');
  UListElement get _backupsList        => _root.querySelector('.backups');
  UListElement get _commandsList       => _root.querySelector('.commands');
  UListElement get _departmentList     => _root.querySelector('.department');
  UListElement get _emailAddressesList => _root.querySelector('.email-addresses');
  UListElement get _relationsList      => _root.querySelector('.relations');
  UListElement get _responsibilityList => _root.querySelector('.responsibility');
  OListElement get _telNumList         => _root.querySelector('.telephone-number');
  UListElement get _titleList          => _root.querySelector('.title');
  UListElement get _workHoursList      => _root.querySelector('.work-hours');

  /**
   *
   */
  set additionalInfo(List<String> items) => _populateList(_additionalInfoList, items);

  /**
   *
   */
  set backups (List<String> items) => _populateList(_backupsList, items);

  /**
   * Returns the onClick stream for the telephone numbers list.
   */
  Stream<MouseEvent> get clickSelectTelNum => _telNumList.onClick;

  /**
   *
   */
  set commands      (List<String> items) => _populateList(_commandsList, items);

  /**
   *
   */
  set departments   (List<String> items) => _populateList(_departmentList, items);

  /**
   *
   */
  set emailAddresses(List<String> items) => _populateList(_emailAddressesList, items);

  /**
   *
   */
  void focusOnTelNumList() {
    _telNumList.focus();
  }

  /**
   * Return the selected [TelNum] from [_telNumList]
   * MAY return null if nothing is selected.
   */
  TelNum getSelectedTelNum() {
    try {
      return new TelNum.fromElement(_telNumList.querySelector('.selected'));
    } catch (e) {
      print(e);
      return null;
    }
  }

  /**
   * Return the [TelNum] the user clicked on.
   * MAY return null if the user did not click on an actual valid [TelNum].
   */
  TelNum getTelNumFromClick(MouseEvent event) {
    try {
      if((event.target is LIElement) || (event.target is SpanElement)) {
        LIElement clickedElement =
            (event.target is SpanElement) ? (event.target as Element).parentNode : event.target;
        return new TelNum.fromElement(clickedElement);
      }

      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /**
   * Return the [index] [TelNum] from [_telNumList]
   * MAY return null if index does not exist in the list.
   */
  TelNum getTelNumFromIndex(int index) {
    try {
      return new TelNum.fromElement(_telNumList.children[index]);
    } catch(e) {
      print(e);
      return null;
    }
  }

  /**
   * Return true if [telNum] is marked ringing.
   */
  bool isRinging(TelNum telNum) =>
      telNum._li.classes.contains('ringing');

  /**
   * Return true if [telNum] is marked selected.
   */
  bool isSelected(TelNum telNo) =>
      telNo._li.classes.contains('selected');

  void _mark(TelNum telNum, String mark) {
    if(telNum != null) {
      _telNumList.children.forEach((Element element) => element.classes.remove(mark));
      telNum._li.classes.add(mark);
      telNum._li.focus();
    }
  }

  /**
   * Mark [telNum] ringing. This is NOT the same as actually ringing. It is
   * mere a visual effect.
   */
  void markRinging(TelNum telNum) {
    _mark(telNum, 'ringing');
  }

  /**
   * Mark [telNum] selected.
   */
  void markSelected(TelNum telNum) {
    _mark(telNum, 'selected');
  }

  /**
   * Return the [TelNum] following the currently selected [TelNum].
   * Return null if we're at last element.
   */
  TelNum nextTelNumInList() {
    try {
      LIElement li = _telNumList.querySelector('.selected').nextElementSibling;
      return li != null ? new TelNum.fromElement(li) : null;
    } catch(e) {
      print(e);
      return null;
    }
  }

  /**
   * Return true if no telNumList items are marked "ringing".
   */
  bool get noRinging => !_telNumList.children.any((e) => e.classes.contains('ringing'));

  /**
   * Return the mouse click event stream for this widget.
   */
  Stream<MouseEvent> get onClick => _myRoot.onClick;

  /**
   *
   */
  void _populateList(UListElement parent, List<String> list) {
    list.forEach((String item) {
      parent.append(new LIElement()..text = item);
    });
  }

  /**
   * Return the [TelNum] preceeding the currently selected [TelNum].
   * Return null if we're at first element.
   */
  TelNum previousTelNumInList() {
    try {
      LIElement li = _telNumList.querySelector('.selected').previousElementSibling;
      return li != null ? new TelNum.fromElement(li) : null;
    } catch(e) {
      print(e);
      return null;
    }
  }

  /**
   *
   */
  set relations     (List<String> items) => _populateList(_relationsList, items);

  /**
   *
   */
  set responsibility(List<String> items) => _populateList(_responsibilityList, items);

  /**
   *
   */
  set telnums       (List<TelNum> items) => items.forEach((TelNum item) {_telNumList.append(item._li);});

  /**
   *
   */
  set titles        (List<String> items) => _populateList(_titleList, items);

  /**
   *
   */
  set workHours     (List<String> items) => _populateList(_workHoursList, items);
}

/**
 * A telephone number.
 */
class TelNum {
  LIElement   _li         = new LIElement()..tabIndex = -1;
  bool        _secret;
  SpanElement _spanLabel  = new SpanElement();
  SpanElement _spanNumber = new SpanElement();

  TelNum(String number, String label, this._secret) {
    if(_secret) {
      _spanNumber.classes.add('secret');
    }

    _spanNumber.text = number;
    _spanNumber.classes.add('number');
    _spanLabel.text = label;
    _spanLabel.classes.add('label');

    _li.children.addAll([_spanNumber, _spanLabel]);
    _li.dataset['number'] = number;
  }

  TelNum.fromElement(LIElement element) {
    if(element != null && element is LIElement) {
      _li = element;
    } else {
      throw new ArgumentError('element is not a LIElement');
    }
  }
}
