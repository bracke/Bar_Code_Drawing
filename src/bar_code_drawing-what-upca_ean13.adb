-- A library for drawing bar codes
-- Drawing UPC-A/EAN-13 bar codes
--
-- Copyright (C) by PragmAda Software Engineering
--
-- Released under the terms of the 3-Clause BSD License. See https://opensource.org/licenses/BSD-3-Clause

package body Bar_Code_Drawing.What.UPCA_EAN13 is
   function Checksum (Text : in String) return Digit_Value is
      subtype S11 is String (1 .. 11);

      S : constant S11 := Text (Text'First + (If Text'Length = 11 then 0 else 1) .. Text'Last);

      Sum : Natural := 0;
   begin -- Checksum
      Add : for I in S'Range loop
         Sum := Sum + (if I rem 2 = 0 then 1 else 3) * (Character'Pos (S (I) ) - Character'Pos ('0') );
      end loop Add;

      if Text'Length = 12 then
         Sum := Sum + Character'Pos (Text (Text'First) ) - Character'Pos ('0');
      end if;

      Sum := Sum rem 10;

      return (if Sum > 0 then 10 - Sum else Sum);
   end Checksum;

   procedure Draw (Info : in out Drawing_Info; Text : in String) is
      S : constant String (1 .. Text'Length) := Text;

      subtype Digit_Pattern is String (1 .. 7); -- Each digit takes 7 modules
      type Pattern_Map is array (Digit) of Digit_Pattern;

      Set_A_Map : constant Pattern_Map := ('0' => "0001101", -- Bar patterns for alphabet A (left half)
                                           '1' => "0011001",
                                           '2' => "0010011",
                                           '3' => "0111101",
                                           '4' => "0100011",
                                           '5' => "0110001",
                                           '6' => "0101111",
                                           '7' => "0111011",
                                           '8' => "0110111",
                                           '9' => "0001011");
      Set_B_Map : constant Pattern_Map := ('0' => "0100111", -- Bar patterns for alphabet B (left half)
                                           '1' => "0110011",
                                           '2' => "0011011",
                                           '3' => "0100001",
                                           '4' => "0011101",
                                           '5' => "0111001",
                                           '6' => "0000101",
                                           '7' => "0010001",
                                           '8' => "0001001",
                                           '9' => "0010111");
      Set_C_Map : constant Pattern_Map := ('0' => "1110010", -- Bar patterns for alphabet B (right half)
                                           '1' => "1100110",
                                           '2' => "1101100",
                                           '3' => "1000010",
                                           '4' => "1011100",
                                           '5' => "1001110",
                                           '6' => "1010000",
                                           '7' => "1000100",
                                           '8' => "1001000",
                                           '9' => "1110100");
      End_Guard    : constant String := "101";
      Middle_Guard : constant String := "01010";

      type EAN_A_Pattern is array (1 .. 6) of Boolean; -- True if digit I should be drawn using Set A; False for Set B
      type EAN_Pattern_Map is array (Digit) of EAN_A_Pattern;

      EAN_A : constant EAN_Pattern_Map := ('0' => (True, True,  True,  True,  True,  True),
                                           '1' => (True, True,  False, True,  False, False),
                                           '2' => (True, True,  False, False, True,  False),
                                           '3' => (True, True,  False, False, False, True),
                                           '4' => (True, False, True,  True,  False, False),
                                           '5' => (True, False, False, True,  True,  False),
                                           '6' => (True, False, False, False, True,  True),
                                           '7' => (True, False, True,  False, True,  False),
                                           '8' => (True, False, True,  False, False, True),
                                           '9' => (True, False, False, True,  False, True) );

      procedure Draw (Info : in out Drawing_Info; X : in out Natural; Pattern : in String) with
         Pre => (for all C of Pattern => C in '0' .. '1');
      -- Draws the bits of Pattern in Info starting at X
      -- Advances X to the position after Pattern

      procedure Draw (Info : in out Drawing_Info; X : in out Natural; Pattern : in String) is
         -- Empty
      begin -- Draw
         All_Lines : for C of Pattern loop
            if C = '1' then
               Draw_Module (Info => Info, X => X, Y => 0);
            end if;

            X := X + 1;
         end loop All_Lines;
      end Draw;

      Offset : constant Natural := Text'Length - 11;
      UPC    : constant Boolean := Text'Length = 11;

      X : Natural := 0;
   begin -- Draw
      Draw (Info => Info, X => X, Pattern => End_Guard);

      Draw_Left : for I in 1 + Offset .. 6 + Offset loop
         Draw (Info => Info, X => X, Pattern => (if UPC then
                                                    Set_A_Map (S (I) )
                                                 else
                                                    (if EAN_A (S (1) ) (I - Offset) then
                                                        Set_A_Map (S (I) )
                                                     else
                                                        Set_B_Map (S (I) ) ) ) );
      end loop Draw_Left;

      Draw (Info => Info, X => X, Pattern => Middle_Guard);

      Draw_Right : for I in 7 + Offset .. 11 + Offset loop
         Draw (Info => Info, X => X, Pattern => Set_C_Map (S (I) ) );
      end loop Draw_Right;

      Draw (Info => Info, X => X, Pattern => Set_C_Map (Checksum (Text) ) );
      Draw (Info => Info, X => X, Pattern => End_Guard);
   end Draw;
end Bar_Code_Drawing.What.UPCA_EAN13;
