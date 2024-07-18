-- A library for drawing bar codes
--
-- Copyright (C) by PragmAda Software Engineering
--
-- Released under the terms of the 3-Clause BSD License. See https://opensource.org/licenses/BSD-3-Clause

with Ada.Characters.Latin_1;
with Ada.Strings.Unbounded;

package body Bar_Code_Drawing.How.PBM is
   function Image (Info : in Drawing_Info; Scale : in Positive := 1) return String is
      use Ada.Strings.Unbounded;

      LF : constant Character := Ada.Characters.Latin_1.LF;

      Result : Unbounded_String := To_Unbounded_String ("P1" & LF &
                                                        "# Created by " & Name & LF &
                                                        "# " & URL & LF &
                                                        Integer'Image (Scale * Info.Width) &
                                                        Integer'Image ( (if Info.Dim = 1 then 1 else Scale) * Info.Height) & LF);
      Line   : Unbounded_String;
   begin -- Image
      if Info.Dim = 1 then -- 1D code
         Make_Line : for X in Info.Bitmap'Range (1) loop
            Apply_Scale : for J in 1 .. Scale loop
               Append (Source => Line, New_Item => Boolean'Pos (Info.Bitmap (X, 0) )'Image);
            end loop Apply_Scale;
         end loop Make_Line;

         Append (Source => Line, New_Item => LF);

         All_Lines : for Y in 1 .. Info.Height loop
            Append (Source => Result, New_Item => Line);
         end loop All_Lines;
      else -- 2D code
         All_Y : for Y in reverse Info.Bitmap'Range (2) loop
            Line := Null_Unbounded_String;

            All_X : for X in Info.Bitmap'Range (1) loop
               Scale_X : for I in 1 .. Scale loop
                  Append (Source => Line, New_Item => Boolean'Pos (Info.Bitmap (X, Y) )'Image);
               end loop Scale_X;
            end loop All_X;

            Append (Source => Line, New_Item => LF);

            Scale_Y : for I in 1 .. Scale loop
               Append (Source => Result, New_Item => Line);
            end loop Scale_Y;
         end loop All_Y;
      end if;

      return To_String (Result);
   end Image;
end Bar_Code_Drawing.How.PBM;
