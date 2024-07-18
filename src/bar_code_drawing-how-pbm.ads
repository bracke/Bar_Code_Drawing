-- A library for drawing bar codes
-- Drawing bar codes as a PBM file's contents
--
-- Copyright (C) by PragmAda Software Engineering
--
-- Released under the terms of the 3-Clause BSD License. See https://opensource.org/licenses/BSD-3-Clause

package Bar_Code_Drawing.How.PBM is
   function Image (Info : in Drawing_Info; Scale : in Positive := 1) return String;
   -- After calling an approprate What.*.Draw procedure, converts Info into the contents of a PBM file containing the drawn bar code
   -- Writing the resulting String to a text file will produce a PBM file
   -- A PBM file can be easily converted into other graphic formats
   -- Each module will be Scale pixels wide
end Bar_Code_Drawing.How.PBM;
