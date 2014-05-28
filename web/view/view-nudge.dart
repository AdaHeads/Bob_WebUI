/*                     This file is part of Bob
                   Copyright (C) 2014-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/


/**
 * Nudge widget. 
 */
part of view;

class Nudge {
  final SpanElement element = new SpanElement()
                             ..classes.add(StyleClass.NUDGE)
                             ..hidden = true;

  Nudge (String shortcutText) {
    this.element.text = shortcutText; 
  }
}
