/*                  This file is part of OpenReception
                   Copyright (C) 2015-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of model;

/**
 * This handles that we want to link out of our own domain. The default UriPolicy
 * limits all links to same origin, which does not work for us.
 */
class _AllUriPolicy implements UriPolicy {
  bool allowsUri(String _) => true;
}

/**
 * Provides access to methods and fields in the mini wiki UX component.
 */
class UIReceptionMiniWiki extends UIModel {
  final DivElement _myRoot;
  final NodeValidatorBuilder _validator = new NodeValidatorBuilder()
    ..allowTextElements()
    ..allowHtml5()
    ..allowInlineStyles()
    ..allowNavigation(new _AllUriPolicy());

  /**
   * Constructor.
   */
  UIReceptionMiniWiki(DivElement this._myRoot) {
    _setupLocalKeys();
    _observers();
  }

  @override HtmlElement get _firstTabElement => _body;
  @override HtmlElement get _focusElement => _body;
  @override HtmlElement get _lastTabElement => _body;
  @override HtmlElement get _root => _myRoot;

  DivElement get _body => _root.querySelector('.generic-widget-body');

  /**
   * Remove all data from the body and clear the header.
   */
  void clear() {
    _headerExtra.text = '';
    _body.text = '';
  }

  /**
   * Add [miniWiki] markdown to the widget.
   */
  set miniWiki(String miniWiki) {
    if (miniWiki != null && miniWiki.isNotEmpty) {
      _body.setInnerHtml(Markdown.markdownToHtml(miniWiki), validator: _validator);

      // Lets make sure all links open up in a new tab/window.
      _body.querySelectorAll('a').forEach((Element a) {
        (a as AnchorElement).target = '_blank';
      });
    } else {
      _body.text = '';
    }
  }

  /**
   * Observers.
   */
  void _observers() {
    _root.onKeyDown.listen(_keyboard.press);
    _root.onClick.listen((_) => _body.focus());
  }

  /**
   * Setup keys and bindings to methods specific for this widget.
   */
  void _setupLocalKeys() {
    _hotKeys.registerKeysPreventDefault(_keyboard, _defaultKeyMap());
  }
}
