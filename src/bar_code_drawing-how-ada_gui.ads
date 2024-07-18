-- A library for drawing bar codes
-- Drawing bar codes in an Ada-GUI Graphic_Area
--
-- Copyright (C) by PragmAda Software Engineering
--
-- Released under the terms of the 3-Clause BSD License. See https://opensource.org/licenses/BSD-3-Clause

with Ada_GUI;

package Bar_Code_Drawing.How.Ada_GUI is
   package GUI renames Standard.Ada_GUI;

   procedure Render (Info : in Drawing_Info; ID : in GUI.Widget_ID; Scale : in Positive := 1) with
      Pre => GUI.Set_Up and then ID.Kind in GUI.Graphic_Area;
   -- Draws the image in Info into ID
   -- Modules will be Scale pixels wide
end Bar_Code_Drawing.How.Ada_GUI;
