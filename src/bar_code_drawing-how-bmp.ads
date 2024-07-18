-- A library for drawing bar codes
-- Drawing bar codes as a BMP file
--
-- Copyright (C) by PragmAda Software Engineering
--
-- Released under the terms of the 3-Clause BSD License. See https://opensource.org/licenses/BSD-3-Clause

package Bar_Code_Drawing.How.BMP is
   procedure Write (Info : in Drawing_Info; Name : in String; Scale : in Positive := 1);
   -- After calling an approprate What.*.Draw procedure, converts Info into a BMP file named Name
   -- A BMP file can be easily converted into other graphic formats
   -- Each module will be Scale pixels wide
end Bar_Code_Drawing.How.BMP;
