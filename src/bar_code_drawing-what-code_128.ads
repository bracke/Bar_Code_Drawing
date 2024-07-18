-- A library for drawing bar codes
-- Drawing Code-128 bar codes
--
-- Copyright (C) by PragmAda Software Engineering
--
-- Released under the terms of the 3-Clause BSD License. See https://opensource.org/licenses/BSD-3-Clause

package Bar_Code_Drawing.What.Code_128 is
   function Width (Text : in String) return Natural with
      Pre => (for all C of Text => C in ASCii);
   -- Returns the width in modules to represent Text

   procedure Draw (Info : in out Drawing_Info; Text : in String) with
      Pre => Info.Dimensions = 1 and (for all C of Text => C in ASCii);
   -- Draws a Code-128 bar code representing Text
end Bar_Code_Drawing.What.Code_128;
