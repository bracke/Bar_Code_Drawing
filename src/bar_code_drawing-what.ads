-- A library for drawing bar codes
--
-- Copyright (C) by PragmAda Software Engineering
--
-- Released under the terms of the 3-Clause BSD License. See https://opensource.org/licenses/BSD-3-Clause

package Bar_Code_Drawing.What is
   -- The What hierarchy of packages knows what modules to draw to draw bar codes of various types: Code 128, QR Code, ...

   -- The parallel How hierarchy of packages knows how to process the resulting Drawing_Info for various output formats:
   -- Ada-GUI, PDF, PBM, ...

   subtype ASCII is Character range Character'Val (0) .. Character'Val (127);
   subtype Digit is Character range '0' .. '9';
end Bar_Code_Drawing.What;
