-- A library for drawing bar codes
--
-- Copyright (C) by PragmAda Software Engineering
--
-- Released under the terms of the 3-Clause BSD License. See https://opensource.org/licenses/BSD-3-Clause

with Image_IO.Operations;

package body Bar_Code_Drawing.How.BMP is
   procedure Write (Info : in Drawing_Info; Name : in String; Scale : in Positive := 1) is
      Black : constant Image_IO.Color_Info := (Red | Green | Blue =>   0);
      White : constant Image_IO.Color_Info := (Red | Green | Blue => 255);

      Result : Image_IO.Image_Data := (0 .. Scale * Info.Height - 1 => (0 .. Scale * Info.Width - 1 => White) );

      R : Natural := 0;
      X : Natural := 0;
   begin -- Write
      if Info.Dim = 1 then -- 1D code
         One_Row : for C in Info.Bitmap'Range (1) loop
            if not Info.Bitmap (C, 0) then
               X := X + Scale;
            else
               Apply_Scale : for J in 1 .. Scale loop
                  Result (0, X) := Black;
                  X := X + 1;
               end loop Apply_Scale;
            end if;
         end loop One_Row;

         Copy_Rows : for R in 1 .. Result'Last (1) loop
            Columns : for C in Result'Range (2) loop
               Result (R, C) := Result (0, C);
            end loop Columns;
         end loop Copy_Rows;
      else -- 2D code
         All_Y : for Y in reverse Info.Bitmap'Range (2) loop
            X := 0;

            All_X : for C in Info.Bitmap'Range (1) loop
               if not Info.Bitmap (C, Y) then
                  X := X + Scale;
               else
                  Scale_X : for I in 1 .. Scale loop
                     Result (R, X) := Black;
                     X := X + 1;
                  end loop Scale_X;
               end if;
            end loop All_X;

            Scale_Y : for I in 1 .. Scale - 1 loop
               Copy_X : for C in Result'Range (2) loop
                  Result (R + I, C) := Result (R, C);
               end loop Copy_X;
            end loop Scale_Y;

            R := R + Scale;
         end loop All_Y;
      end if;

      Image_IO.Operations.Write_BMP (File_Name => Name, Image => Result);
   end Write;
end Bar_Code_Drawing.How.BMP;
