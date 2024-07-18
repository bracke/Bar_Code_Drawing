-- A library for drawing bar codes
-- Drawing bar codes as an SVG file's contents
--
-- Copyright (C) by PragmAda Software Engineering
--
-- Released under the terms of the 3-Clause BSD License. See https://opensource.org/licenses/BSD-3-Clause

package Bar_Code_Drawing.How.SVG is
   function Image (Info : in Drawing_Info; Width : in Float := 1.0; Height : in Float := 1.0) return String;
   -- After calling an approprate What.*.Draw procedure, converts Info into the contents of an SVG file containing the drawn bar
   -- code
   -- Writing the resulting String to a text file will produce an SVG file
   -- Each module will be Width mm wide
   -- If Info.Dimensions = 1, modules will be Height mm high; otherwise, Height is ignored and modules will be Width mm square
   -- Although PBM files may be easily converted to most other graphic formats, SVG files are an exception
end Bar_Code_Drawing.How.SVG;
