-- A library for drawing bar codes
-- Drawing UPC-A/EAN-13 bar codes
--
-- Copyright (C) by PragmAda Software Engineering
--
-- Released under the terms of the 3-Clause BSD License. See https://opensource.org/licenses/BSD-3-Clause

package Bar_Code_Drawing.What.UPCA_EAN13 is
   Width : constant := 95;
   -- All UPC-A codes are 95 modules wide

   function Valid (Text : in String) return Boolean is
      (Text'Length in 11 .. 12 and (for all C of Text => C in Digit) ); -- 11 = UPC-A; 12 = EAN-13

   subtype Digit_Value is Integer range 0 .. 9;

   function Checksum (Text : in String) return Digit_Value with
      Pre => Valid (Text);
   -- Calculates the UPC-A/EAN-13 checksum digit for Text

   function Checksum (Text : in String) return Digit is
      (Character'Val (Checksum (Text) + Character'Pos ('0') ) );

   procedure Draw (Info : in out Drawing_Info; Text : in String) with
      Pre => Info.Dimensions = 1 and Valid (Text);
   -- If Text'Length = 11, draws a UPC-A bar code representing Text with its associated checksum digit
   -- Otherwise, draws an EAN-13 bar code representing Text with its associated checksum digit
   -- Only draws the bar code; cutouts and text are not included
end Bar_Code_Drawing.What.UPCA_EAN13;
