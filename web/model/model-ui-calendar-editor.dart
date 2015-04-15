part of model;

class UICalendarEditor extends UIModel {
  HtmlElement      _myFirstTabElement;
  HtmlElement      _myFocusElement;
  HtmlElement      _myLastTabElement;
  final DivElement _myRoot;

  UICalendarEditor(DivElement this._myRoot) {
    _myFocusElement    = _textArea;
    _myFirstTabElement = _textArea;
    _myLastTabElement  = _cancelButton;

    _registerEventListeners();
  }

  @override HtmlElement    get _firstTabElement => _myFirstTabElement;
  @override HtmlElement    get _focusElement    => _myFocusElement;
  @override HeadingElement get _header          => _root.querySelector('h4');
  @override DivElement     get _help            => _root.querySelector('div.help');
  @override HtmlElement    get _lastTabElement  => _myLastTabElement;
  @override HtmlElement    get _root            => _myRoot;

  ButtonElement        get _cancelButton     => _root.querySelector('.cancel');
  ButtonElement        get _deleteButton     => _root.querySelector('.delete');
  ElementList<Element> get _inputFields      => _root.querySelectorAll('[input-field]');
  ButtonElement        get _saveButton       => _root.querySelector('.save');
  InputElement         get _startHourInput   => _root.querySelector('.start-hour');
  InputElement         get _startMinuteInput => _root.querySelector('.start-minute');
  InputElement         get _startDayInput    => _root.querySelector('.start-day');
  InputElement         get _startMonthInput  => _root.querySelector('.start-month');
  InputElement         get _startYearInput   => _root.querySelector('.start-year');
  InputElement         get _stopHourInput    => _root.querySelector('.stop-hour');
  InputElement         get _stopMinuteInput  => _root.querySelector('.stop-minute');
  InputElement         get _stopDayInput     => _root.querySelector('.stop-day');
  InputElement         get _stopMonthInput   => _root.querySelector('.stop-month');
  InputElement         get _stopYearInput    => _root.querySelector('.stop-year');
  ElementList<Element> get _tabElements      => _root.querySelectorAll('[tabindex]');
  TextAreaElement      get _textArea         => _root.querySelector('textarea');

  /**
   * Return the click event stream for the cancel button.
   */
  Stream<MouseEvent> get onCancel => _cancelButton.onClick;

  /**
   * Return the click event stream for the delete button.
   */
  Stream<MouseEvent> get onDelete => _deleteButton.onClick;

  /**
   * Return the click event stream for the save button.
   */
  Stream<MouseEvent> get onSave => _saveButton.onClick;

  void _registerEventListeners() {
    /// Enables focused element memory for this widget.
    _tabElements.forEach((HtmlElement element) {
      element.onFocus.listen((Event event) => _myFocusElement = (event.target as HtmlElement));
    });

    _hotKeys.onTab     .listen(_handleTab);
    _hotKeys.onShiftTab.listen(_handleShiftTab);

    /// NOTE (TL): These onInput listeners is here because it's a bit of a pain
    /// to put them in the view. Also I don't think it's too insane to consider
    /// the inputs of this widget to have some intrinsic management of which
    /// values are allowed and which are not, especially considering the HTML5
    /// type="number" attribute.
    _textArea.onInput   .listen((_) => _toggleButtons());
    _startHourInput.onInput  .listen((_) => _sanitizeInput(_startHourInput));
    _startMinuteInput.onInput.listen((_) => _sanitizeInput(_startMinuteInput));
    _startDayInput.onInput   .listen((_) => _sanitizeInput(_startDayInput));
    _startMonthInput.onInput .listen((_) => _sanitizeInput(_startMonthInput));
    _startYearInput.onInput  .listen((_) => _sanitizeInput(_startYearInput));
    _stopHourInput.onInput   .listen((_) => _sanitizeInput(_stopHourInput));
    _stopMinuteInput.onInput .listen((_) => _sanitizeInput(_stopMinuteInput));
    _stopDayInput.onInput    .listen((_) => _sanitizeInput(_stopDayInput));
    _stopMonthInput.onInput  .listen((_) => _sanitizeInput(_stopMonthInput));
    _stopYearInput.onInput   .listen((_) => _sanitizeInput(_stopYearInput));
  }

  void _sanitizeInput(InputElement input) {
    if(input.validity.badInput) {
      input.classes.toggle('bad-input', true);
    } else {
      input.classes.toggle('bad-input', false);
    }

    _toggleButtons();
  }

  /**
   * Enable/disable the widget buttons and as a sideeffect set the value of
   * last tab element as this depends on the state of the buttons.
   */
  void _toggleButtons() {
    bool toggle = !_inputFields.any((element) => element.value.isEmpty);

    _deleteButton.disabled = !toggle;
    _saveButton.disabled   = !toggle;

    _myLastTabElement = toggle ? _saveButton : _cancelButton;
  }
}
