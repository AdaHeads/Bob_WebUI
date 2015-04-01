part of model;

class UIAgentInfo extends UIModel {
  final DivElement _myRoot;

  UIAgentInfo(DivElement this._myRoot);

  @override HtmlElement get _root => _myRoot;

  TableCellElement get _activeCountElement => _root.querySelector('.active-count');
  ImageElement     get _agentStateElement  => _root.querySelector('.agent-state');
  ImageElement     get _alertStateElement  => _root.querySelector('.alert-state');
  TableCellElement get _pausedCountElement => _root.querySelector('.paused-count');
  ImageElement     get _portraitElement    => _root.querySelector('.portrait');

  /**
   * Set the ::active:: count.
   */
  set activeCount (int value) => _activeCountElement.text = value.toString();

  /**
   * Set the visual representation of the current agents state.
   */
  set agentState (AgentState agentState) {
    switch(agentState) {
      case AgentState.BUSY:
        _agentStateElement.src = 'images/agentsactive.svg';
        break;
      case AgentState.IDLE:
        /// TODO (TL): Need idle state graphic
        _agentStateElement.src = 'images/agentsactive.svg';
        break;
      case AgentState.PAUSE:
        _agentStateElement.src = 'images/agentssleep.svg';
        break;
      case AgentState.UNKNOWN:
        /// TODO (TL): Need unknown state graphic
        _agentStateElement.src = 'images/agentsactive.svg';
        break;
    }
  }

  /**
   * Toggle the alert state graphic.
   */
  set alertState (AlertState alertState) {
    switch(alertState) {
      case AlertState.OFF:
        /// TODO (TL): Need alert state OFF graphic
        break;
      case AlertState.ON:
        _alertStateElement.src = 'images/alert.svg';
        break;
    }
  }

  /**
   * Set the ::paused:: count.
   */
  set pausedCount (int value) => _pausedCountElement.text = value.toString();

  /**
   * Set the agent portrait. [path] must be a valid source path to an image.
   */
  set portrait (String path) => _portraitElement.src = path;
}
