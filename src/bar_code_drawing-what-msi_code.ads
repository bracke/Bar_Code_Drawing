-- A library for drawing bar codes
-- Drawing MSI bar codes (also called MSI Plessey and Modified Plessey)
--
-- Copyright (C) by PragmAda Software Engineering
--
-- Released under the terms of the 3-Clause BSD License. See https://opensource.org/licenses/BSD-3-Clause

package Bar_Code_Drawing.What.MSI_Code is
   function Width (Text : in String) return Natural with
      Pre => (for all C of Text => C in Digit);
   -- Returns the width in modules to represent Text

   procedure Draw (Info : in out Drawing_Info; Text : in String) with
      Pre => Info.Dimensions = 1 and (for all C of Text => C in Digit);
   -- Draws an MSI bar code representing Text, with a Luhn checksum digit added
end Bar_Code_Drawing.What.MSI_Code;
