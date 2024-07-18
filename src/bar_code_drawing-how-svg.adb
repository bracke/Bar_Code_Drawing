-- A library for drawing bar codes
--
-- Copyright (C) by PragmAda Software Engineering
--
-- Released under the terms of the 3-Clause BSD License. See https://opensource.org/licenses/BSD-3-Clause

with Ada.Characters.Latin_1;
with Ada.Strings.Unbounded;
with PragmARC.Images;

package body Bar_Code_Drawing.How.SVG is
   function Image (Info : in Drawing_Info; Width : in Float := 1.0; Height : in Float := 1.0) return String is
      use Ada.Strings.Unbounded;

      LF : constant Character := Ada.Characters.Latin_1.LF;

      function Image is new PragmARC.Images.Float_Image (Number => Float);

      Unit : constant String := "mm";

      Result : Unbounded_String := To_Unbounded_String ("<?xml version=""1.0"" encoding=""UTF-8""?>" & LF &
                                                        "<!DOCTYPE svg" & LF &
                                                        "  PUBLIC '-//W3C//DTD SVG 1.1//EN'" & LF &
                                                        "  'http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd'>" & LF &
                                                        "<!-- Created by " & Name & " -->" &  LF &
                                                        "<!-- " & URL & " -->" &  LF &
                                                        "<svg height=" & '"' &
                                                        Image ( (if Info.Dim = 1 then Height
                                                                 else Float (Info.Height) * Width), 1, 2, 0) &
                                                        Unit &
                                                        '"' & " width=" & '"' & Image (Float (Info.Width) * Width, 1, 2, 0) & Unit &
                                                        '"' & " version=""1.1"" xmlns=""http://www.w3.org/2000/svg"">" & LF &
                                                        "    <rect height=""100%"" width=""100%"" style=""fill:#FFFFFF""/>" & LF);
                                                        --  White rectangle as background
   begin  -- Image
      if Info.Dim = 1 then -- 1D barcode
         All_X : for X in Info.Bitmap'Range (1) loop
            if Info.Bitmap (X, 0) then
               Append (Source => Result, New_Item => "    <rect style=" & '"' & "fill:#000000;" & '"' &
                                                     " x=" & '"' & Image (Float (X) * Width, 1, 2, 0) & Unit & '"' &
                                                     " y=" & '"' & "0.0" & Unit & '"' &
                                                     " width=" & '"' & Image (Width, 1, 2, 0) & Unit & '"' &
                                                     " height=" & '"' & Image (Height, 1, 2, 0) & Unit & '"' & "/>" & LF);
            end if;
         end loop All_X;
      else
        X_2 : for X in Info.Bitmap'Range (1) loop
            Y_2 : for Y in Info.Bitmap'Range (2) loop
               if Info.Bitmap (X, Y) then
                  Append (Source => Result, New_Item => "    <rect style=" & '"' & "fill:#000000;" & '"' &
                                                        " x=" & '"' & Image (Float (X) * Width, 1, 2, 0) & Unit & '"' &
                                                        " y=" & '"' &
                                                        Image (Float (Info.Width) * Width - Float (Y + 1) * Width, 1, 2, 0) & Unit &
                                                        '"' &
                                                        " width=" & '"' & Image (Width, 1, 2, 0) & Unit & '"' &
                                                        " height=" & '"' & Image (Width, 1, 2, 0) & Unit & '"' & "/>" & LF);
               end if;
            end loop Y_2;
         end loop X_2;
      end if;

      Append (Source => Result, New_Item => "</svg>" & LF);

      return To_String (Result);
   end Image;
end Bar_Code_Drawing.How.SVG;
