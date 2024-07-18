-- A library for drawing bar codes
--
-- Copyright (C) by PragmAda Software Engineering
--
-- Released under the terms of the 3-Clause BSD License. See https://opensource.org/licenses/BSD-3-Clause

with Ada.Characters.Latin_1;
with PragmARC.Luhn_Generation;

package body Bar_Code_Drawing.What.MSI_Code is
   Symbol_Width : constant := 12; -- Each digit has 4 bits of 3 bars
   Start_Width  : constant :=  3; -- Start symbol is a 1 bit
   Stop_Width   : constant :=  4; -- Stop symbol is 00; trailing white bars ignored

   function Width (Text : in String) return Natural is
      (Symbol_Width * (Text'Length + 1) + Start_Width + Stop_Width); -- +1 for Luhn checksum digit

   procedure Draw (Info : in out Drawing_Info; Text : in String) is
      subtype Nibble is String (1 .. 4);

      type Nibble_Map is array (Digit) of Nibble;

      Map : constant Nibble_Map := ('0' => "0000", '1' => "0001", '2' => "0010", '3' => "0011", '4' => "0100",
                                    '5' => "0101", '6' => "0110", '7' => "0111", '8' => "1000", '9' => "1001");

      procedure Draw_Bit (Info : in out Drawing_Info; X : in out Natural; Bit : in Character) with
         Pre => Bit in '0' .. '1';
      -- Draws the 3 modules for Bit at X

      procedure Draw_Bit (Info : in out Drawing_Info; X : in out Natural; Bit : in Character) is
         -- Empty
      begin -- Draw_Bit
         Draw_Module (Info => Info, X => X, Y => 0); -- All start with bar

         if Bit = '1' then
            Draw_Module (Info => Info, X => X + 1, Y => 0); -- 1 bits have double bar
         end if;

         X := X + 3;
      end Draw_Bit;

      X   : Natural := 0;
      Bit : Nibble;
   begin -- Draw
      Draw_Bit (Info => Info, X => X, Bit => '1'); -- Start code

      All_Digits : for I in Text'Range loop
         Bit := Map (Text (I) );

         All_Bits : for J in Bit'Range loop
            Draw_Bit (Info => Info, X => X, Bit => Bit (J) );
         end loop All_Bits;
      end loop All_Digits;

      Bit := Map (Character'Val (PragmARC.Luhn_Generation.Checksum (Text) + Character'Pos ('0') ) );

      All_Checksum_Bits : for J in Bit'Range loop
         Draw_Bit (Info => Info, X => X, Bit => Bit (J) );
      end loop All_Checksum_Bits;

      Draw_Bit (Info => Info, X => X, Bit => '0'); -- Stop code
      Draw_Bit (Info => Info, X => X, Bit => '0');
   end Draw;
end Bar_Code_Drawing.What.MSI_Code;
