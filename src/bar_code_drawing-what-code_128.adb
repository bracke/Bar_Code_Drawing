-- A library for drawing bar codes
--
-- Copyright (C) by PragmAda Software Engineering
--
-- Released under the terms of the 3-Clause BSD License. See https://opensource.org/licenses/BSD-3-Clause

-- Parts of this software are modified from Bar_Codes.Encode_Code_128 by Gautier de Montmollin
--   Copyright (c) 2018 Gautier de Montmollin

--   Permission is hereby granted, free of charge, to any person obtaining a copy
--   of this software and associated documentation files (the "Software"), to deal
--   in the Software without restriction, including without limitation the rights
--   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--   copies of the Software, and to permit persons to whom the Software is
--   furnished to do so, subject to the following conditions:

--   The above copyright notice and this permission notice shall be included in
--   all copies or substantial portions of the Software.

--   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
--   THE SOFTWARE.

with Ada.Characters.Latin_1;

package body Bar_Code_Drawing.What.Code_128 is
   subtype Code_Range is Integer range 0 .. 106;

   type Sequence is array (Positive range <>) of Code_Range;

   function Compose_Code (Text : in String) return Sequence;
   -- Converts Text into a Sequence of codes; each code defines a pattern of lines in the bar code

   function Compose_Code (Text : in String) return Sequence is
      --  Worst case: we switch subcode for each symbol!
      Max_Length : constant Integer := Text'Length * 2 + 2;

      Code        : Sequence (1 .. Max_Length);
      Code_Length : Natural := 0;

      type Code_128_Subcode is (Undefined, A, B, C);

      Subcode  : Code_128_Subcode := Undefined;
      Checksum : Natural          := 0;

      procedure Add_Symbol (Symbol : in Code_Range);
      -- Adds Symbol to Code

      procedure Add_Symbol (Symbol : in Code_Range) is
         -- Empty
      begin -- Add_Symbol
         Checksum := Checksum + Symbol * Integer'Max (1, Code_Length);
         Code_Length := Code_Length + 1;
         Code (Code_Length) := Symbol;
      end Add_Symbol;

      subtype Defined_Subcode is Code_128_Subcode range A .. C;

      First_Digit : Boolean;  --  First digit in a pair of digits for subcode C

      procedure Switch_To (New_Subcode : in Defined_Subcode);
      -- Adds a symbol to Code to switch subcodes

      procedure Switch_To (New_Subcode : in Defined_Subcode) is
         -- Empty
      begin
         if Subcode = Undefined then
            --  Start code A/B/C:
            case New_Subcode is
            when A => Add_Symbol (103);
            when B => Add_Symbol (104);
            when C => Add_Symbol (105);
            end case;
         else
            case New_Subcode is
            when A => Add_Symbol (101);
            when B => Add_Symbol (100);
            when C => Add_Symbol (099);
            end case;
         end if;

         if New_Subcode = C then
            First_Digit := True;
         end if;

         Subcode := New_Subcode;
      end Switch_To;

      Four_Digits  : Boolean;
      Digit_Buffer : Natural;
      Digit        : Natural;
   begin -- Compose_Code
      for I in Text'Range loop
         --  Choice of a subcode
         case Text (I) is
         when Ada.Characters.Latin_1.NUL .. Ada.Characters.Latin_1.US =>
            if Subcode /= A then
               Switch_To (A);
            end if;
         when Character'Val (96) .. Ada.Characters.Latin_1.DEL =>
            if Subcode /= B then
               Switch_To (B);
            end if;
         when '0' .. '9' =>
            if Subcode = C then
               --  If text (i) is meant to be the first digit of a pair,
               --  ensure there is a second digit after.
               if First_Digit then
                  if I = Text'Last or else Text (I + 1) not in '0' .. '9' then
                     Switch_To (B);  --  We need to encode this digit with subcode A or B
                  end if;
               end if;
            else
               if I + 3 <= Text'Last then
                  Four_Digits := (for all C of Text (I .. I + 3) => C in '0' .. '9');

                  if Four_Digits then
                     Switch_To (C);
                  end if;
               end if;

               if Subcode = Undefined then
                  Switch_To (B);
               end if;
            end if;
         when others =>
            --  A or B is good.
            if Subcode not in A .. B then
               Switch_To (B);  --  Just an assumption: characters like 'a' .. 'z' more likely.
            end if;
         end case;

         --  Encode Text (I)
         case Subcode is
         when Undefined =>
            null;
         when A =>
            if Text (I) <= Ada.Characters.Latin_1.US then
               Add_Symbol (Character'Pos (Text (I) ) + 64);
            else
               Add_Symbol (Character'Pos (Text (I) ) - 32);
            end if;
         when B =>
            Add_Symbol (Character'Pos (Text (I) ) - 32);
         when C =>
            Digit := Character'Pos (Text (I) ) - Character'Pos ('0');

            if First_Digit then
               Digit_Buffer := Digit;
            else
               Add_Symbol (10 * Digit_Buffer + Digit);
            end if;

            First_Digit := not First_Digit;
         end case;
      end loop;

      --  Checksum symbol
      Add_Symbol (Checksum mod 103);
      --  Stop symbol
      Add_Symbol (106);

      return Code (1 .. Code_Length);
   end Compose_Code;

   Symbol_Width     : constant := 11;  --  Each symbol has 3 bars and takes 11 "modules" in total.
   Stop_Extra_Width : constant :=  2;  --  Supplemental bar after stop symbol.

   function Width (Text : in String) return Natural is
      (Compose_Code (Text)'Length * Symbol_Width + Stop_Extra_Width);

   procedure Draw (Info : in out Drawing_Info; Text : in String) is
      Code : constant Sequence := Compose_Code (Text);

      type Width_Sequence is array (1 .. 5) of Positive;

      Width : constant array (Code_Range) of Width_Sequence :=
      --  These are the widths for:  bar, space, bar, space, bar (last space width is implicit).
         (  0 => (2, 1, 2, 2, 2),
            1 => (2, 2, 2, 1, 2),
            2 => (2, 2, 2, 2, 2),
            3 => (1, 2, 1, 2, 2),
            4 => (1, 2, 1, 3, 2),
            5 => (1, 3, 1, 2, 2),
            6 => (1, 2, 2, 2, 1),
            7 => (1, 2, 2, 3, 1),
            8 => (1, 3, 2, 2, 1),
            9 => (2, 2, 1, 2, 1),
           10 => (2, 2, 1, 3, 1),
           11 => (2, 3, 1, 2, 1),
           12 => (1, 1, 2, 2, 3),
           13 => (1, 2, 2, 1, 3),
           14 => (1, 2, 2, 2, 3),
           15 => (1, 1, 3, 2, 2),
           16 => (1, 2, 3, 1, 2),
           17 => (1, 2, 3, 2, 2),
           18 => (2, 2, 3, 2, 1),
           19 => (2, 2, 1, 1, 3),
           20 => (2, 2, 1, 2, 3),
           21 => (2, 1, 3, 2, 1),
           22 => (2, 2, 3, 1, 1),
           23 => (3, 1, 2, 1, 3),
           24 => (3, 1, 1, 2, 2),
           25 => (3, 2, 1, 1, 2),
           26 => (3, 2, 1, 2, 2),
           27 => (3, 1, 2, 2, 1),
           28 => (3, 2, 2, 1, 1),
           29 => (3, 2, 2, 2, 1),
           30 => (2, 1, 2, 1, 2),
           31 => (2, 1, 2, 3, 2),
           32 => (2, 3, 2, 1, 2),
           33 => (1, 1, 1, 3, 2),
           34 => (1, 3, 1, 1, 2),
           35 => (1, 3, 1, 3, 2),
           36 => (1, 1, 2, 3, 1),
           37 => (1, 3, 2, 1, 1),
           38 => (1, 3, 2, 3, 1),
           39 => (2, 1, 1, 3, 1),
           40 => (2, 3, 1, 1, 1),
           41 => (2, 3, 1, 3, 1),
           42 => (1, 1, 2, 1, 3),
           43 => (1, 1, 2, 3, 3),
           44 => (1, 3, 2, 1, 3),
           45 => (1, 1, 3, 1, 2),
           46 => (1, 1, 3, 3, 2),
           47 => (1, 3, 3, 1, 2),
           48 => (3, 1, 3, 1, 2),
           49 => (2, 1, 1, 3, 3),
           50 => (2, 3, 1, 1, 3),
           51 => (2, 1, 3, 1, 1),
           52 => (2, 1, 3, 3, 1),
           53 => (2, 1, 3, 1, 3),
           54 => (3, 1, 1, 1, 2),
           55 => (3, 1, 1, 3, 2),
           56 => (3, 3, 1, 1, 2),
           57 => (3, 1, 2, 1, 1),
           58 => (3, 1, 2, 3, 1),
           59 => (3, 3, 2, 1, 1),
           60 => (3, 1, 4, 1, 1),
           61 => (2, 2, 1, 4, 1),
           62 => (4, 3, 1, 1, 1),
           63 => (1, 1, 1, 2, 2),
           64 => (1, 1, 1, 4, 2),
           65 => (1, 2, 1, 1, 2),
           66 => (1, 2, 1, 4, 2),
           67 => (1, 4, 1, 1, 2),
           68 => (1, 4, 1, 2, 2),
           69 => (1, 1, 2, 2, 1),
           70 => (1, 1, 2, 4, 1),
           71 => (1, 2, 2, 1, 1),
           72 => (1, 2, 2, 4, 1),
           73 => (1, 4, 2, 1, 1),
           74 => (1, 4, 2, 2, 1),
           75 => (2, 4, 1, 2, 1),
           76 => (2, 2, 1, 1, 1),
           77 => (4, 1, 3, 1, 1),
           78 => (2, 4, 1, 1, 1),
           79 => (1, 3, 4, 1, 1),
           80 => (1, 1, 1, 2, 4),
           81 => (1, 2, 1, 1, 4),
           82 => (1, 2, 1, 2, 4),
           83 => (1, 1, 4, 2, 1),
           84 => (1, 2, 4, 1, 1),
           85 => (1, 2, 4, 2, 1),
           86 => (4, 1, 1, 2, 1),
           87 => (4, 2, 1, 1, 1),
           88 => (4, 2, 1, 2, 1),
           89 => (2, 1, 2, 1, 4),
           90 => (2, 1, 4, 1, 2),
           91 => (4, 1, 2, 1, 2),
           92 => (1, 1, 1, 1, 4),
           93 => (1, 1, 1, 3, 4),
           94 => (1, 3, 1, 1, 4),
           95 => (1, 1, 4, 1, 1),
           96 => (1, 1, 4, 3, 1),
           97 => (4, 1, 1, 1, 1),
           98 => (4, 1, 1, 3, 1),
           99 => (1, 1, 3, 1, 4),
          100 => (1, 1, 4, 1, 3),
          101 => (3, 1, 1, 1, 4),
          102 => (4, 1, 1, 1, 3),
          103 => (2, 1, 1, 4, 1),
          104 => (2, 1, 1, 2, 1),
          105 => (2, 1, 1, 2, 3),
          106 => (2, 3, 3, 1, 1) );

      X : Natural;

      procedure Bar (Offset : in Natural;  Width : in Natural);
      -- Draw a bar of width Width at X + Offset

      procedure Bar (Offset : in Natural;  Width : in Natural) is
         -- Empty
      begin
         All_Bars : for I in 0 .. Width - 1 loop
            Draw_Module (Info => Info, X => X + Offset + I, Y => 0);
         end loop All_Bars;
      end Bar;
   begin -- Draw
      for I in Code'Range loop
         X := (I - 1) * Symbol_Width;

         declare
            Ws : constant Width_Sequence := Width (Code (I) );
         begin
            Bar (Offset => 0,                                 Width => Ws (1) );
            Bar (Offset => Ws (1) + Ws (2),                   Width => Ws (3) );
            Bar (Offset => Ws (1) + Ws (2) + Ws (3) + Ws (4), Width => Ws (5) );
         end;
      end loop;

      --  Extra bar after the Stop symbol; this gives the Reverse Stop symbol
      --  when the bar code is scanned turned 180°.
      X := Code'Length * Symbol_Width;
      Bar (Offset => 0, Width => 2);
   end Draw;
end Bar_Code_Drawing.What.Code_128;
