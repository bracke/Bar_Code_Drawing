-- A library for drawing bar codes
-- Drawing QR codes
--
-- Copyright (C) by PragmAda Software Engineering
--
-- Released under the terms of the 3-Clause BSD License. See https://opensource.org/licenses/BSD-3-Clause

package Bar_Code_Drawing.What.QR_Code is
   type Error_Correction_Level is (Low, Medium, Quartile, High);

   function Width (Text : in String; Level : in Error_Correction_Level := Medium) return Natural;
   -- Returns the width in modules to represent Text

   procedure Draw (Info : in out Drawing_Info; Text : in String; Level : in Error_Correction_Level := Medium) with
      Pre => Info.Dimensions = 2;
   -- Draws a QR code representing Text
end Bar_Code_Drawing.What.QR_Code;
