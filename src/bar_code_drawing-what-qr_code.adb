-- A library for drawing bar codes
--
-- Copyright (C) by PragmAda Software Engineering
--
-- Released under the terms of the 3-Clause BSD License. See https://opensource.org/licenses/BSD-3-Clause

-- Parts of this software are modified from Bar_Codes.Encode_QR by Gautier de Montmollin
--  Copyright (c) Gautier de Montmollin
--  http://ada-bar-codes.sf.net
--
--  Copyright (c) Project Nayuki
--  https://www.nayuki.io/page/qr-code-generator-library
--
--  (MIT License)
--  Permission is hereby granted, free of charge, to any person obtaining a copy of
--  this software and associated documentation files (the "Software"), to deal in
--  the Software without restriction, including without limitation the rights to
--  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
--  the Software, and to permit persons to whom the Software is furnished to do so,
--  subject to the following conditions:
--  - The above copyright notice and this permission notice shall be included in
--    all copies or substantial portions of the Software.
--  - The Software is provided "as is", without warranty of any kind, express or
--    implied, including but not limited to the warranties of merchantability,
--    fitness for a particular purpose and noninfringement. In no event shall the
--    authors or copyright holders be liable for any claim, damages or other
--    liability, whether in an action of contract, tort or otherwise, arising from,
--    out of or in connection with the Software or the use or other dealings in the
--    Software.

with Interfaces;

package body Bar_Code_Drawing.What.QR_Code is
   subtype QR_Version is Integer range 1 .. 40;

   function Num_Raw_Data_Modules (Ver : in QR_Version) return Positive;
   --  Returns the number of data bits that can be stored in a QR Code of the given version number, after
   --  all function modules are excluded. This includes remainder bits, so it might not be a multiple of 8.
   --  The result is in the range [208, 29648].

   function Num_Raw_Data_Modules (Ver : in QR_Version) return Positive is
      Result : Positive := (16 * Ver + 128) * Ver + 64;

      NumAlign                        : constant Natural := Ver / 7 + 2;
      Num_Alignment_Pattern_Modules   : constant Natural := (25 * NumAlign - 10) * NumAlign - 55;
      Num_Version_Information_Modules : constant Natural := 18 * 2;
   begin -- Num_Raw_Data_Modules
      if Ver >= 2 then
         Result := Result - Num_Alignment_Pattern_Modules;

         if Ver >= 7 then
            Result := Result - Num_Version_Information_Modules;
         end if;
      end if;

      return Result;
   end Num_Raw_Data_Modules;

   type QR_Param is array (Error_Correction_Level, QR_Version) of Positive;

   ECC_Codewords_Per_Block : constant QR_Param :=
     --  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
     -- 32, 33, 34, 35, 36, 37, 38, 39, 40
      ( (7, 10, 15, 20, 26, 18, 20, 24, 30, 18, 20, 24, 26, 30, 22, 24, 28, 30, 28, 28, 28, 28, 30, 30, 26, 28, 30, 30, 30, 30, 30,
        30, 30, 30, 30, 30, 30, 30, 30, 30),   -- Low
       (10, 16, 26, 18, 24, 16, 18, 22, 22, 26, 30, 22, 22, 24, 24, 28, 28, 26, 26, 26, 26, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28,
        28, 28, 28, 28, 28, 28, 28, 28, 28),   -- Medium
       (13, 22, 18, 26, 18, 24, 18, 22, 20, 24, 28, 26, 24, 20, 30, 24, 28, 28, 26, 30, 28, 30, 30, 30, 30, 28, 30, 30, 30, 30, 30,
        30, 30, 30, 30, 30, 30, 30, 30, 30),   -- Quartile
       (17, 28, 22, 16, 22, 28, 26, 26, 24, 28, 24, 28, 22, 24, 24, 30, 28, 28, 26, 28, 30, 24, 30, 30, 30, 30, 30, 30, 30, 30, 30,
        30, 30, 30, 30, 30, 30, 30, 30, 30) ); -- High

   Num_Error_Correction_Blocks : constant QR_Param :=
     --  1, 2, 3, 4, 5, 6, 7, 8, 9,10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33,
     -- 34, 35, 36, 37, 38, 39, 40
      ( (1, 1, 1, 1, 1, 2, 2, 2, 2, 4,  4,  4,  4,  4,  6,  6,  6,  6,  7,  8,  8,  9,  9, 10, 12, 12, 12, 13, 14, 15, 16, 17, 18,
        19, 19, 20, 21, 22, 24, 25),   -- Low
        (1, 1, 1, 2, 2, 4, 4, 4, 5, 5,  5,  8,  9,  9, 10, 10, 11, 13, 14, 16, 17, 17, 18, 20, 21, 23, 25, 26, 28, 29, 31, 33, 35,
        37, 38, 40, 43, 45, 47, 49),   -- Medium
        (1, 1, 2, 2, 4, 4, 6, 6, 8, 8,  8, 10, 12, 16, 12, 17, 16, 18, 21, 20, 23, 23, 25, 27, 29, 34, 34, 35, 38, 40, 43, 45, 48,
        51, 53, 56, 59, 62, 65, 68),   -- Quartile
        (1, 1, 2, 4, 4, 4, 5, 6, 8, 8, 11, 11, 16, 16, 18, 16, 19, 21, 25, 25, 25, 34, 30, 32, 35, 37, 40, 42, 45, 48, 51, 54, 57,
        60, 63, 66, 70, 74, 77, 81) ); -- High

   function Num_Data_Codewords (Ver : in QR_Version; Ecl : in Error_Correction_Level) return Positive is
      (Num_Raw_Data_Modules (Ver) / 8 - ECC_Codewords_Per_Block (Ecl, Ver) * Num_Error_Correction_Blocks (Ecl, Ver) );
   --  Returns the number of 8-bit data (i.e. not error correction) codewords contained in any
   --  QR Code of the given version number and error correction level, with remainder bits discarded.

   type Segment_Mode is (Numeric, Alphanumeric, Byte, Kanji, ECI);

   type Char_Count_Bits is array (0 .. 2) of Natural;

   type Segment_Mode_Param is record
      Mode_Bits : Positive;
      Cc_Bits   : Char_Count_Bits;
   end record;

   Segment_Params : constant array (Segment_Mode) of Segment_Mode_Param :=
      (Numeric      => (Mode_Bits => 1, Cc_Bits => (10, 12, 14) ),
       Alphanumeric => (Mode_Bits => 2, Cc_Bits =>  (9, 11, 13) ),
       Byte         => (Mode_Bits => 4, Cc_Bits =>  (8, 16, 16) ),
       Kanji        => (Mode_Bits => 8, Cc_Bits =>  (8, 10, 12) ),
       ECI          => (Mode_Bits => 7, Cc_Bits =>  (0,  0,  0) ) );

   function Border_Size (Version : in QR_Version) return Positive is
      (Version * 4 + 17);

   Max_Modules : constant Integer := Border_Size (QR_Version'Last) ** 2;

   type Bit is range 0 .. 1;
   type Bit_Array is array (Positive range <>) of Bit;
   type Bit_Buffer is record
      Length  : Natural := 0;
      Element : Bit_Array (1 .. Max_Modules);
   end record;

   subtype U8  is Interfaces.Unsigned_8;
   subtype U16 is Interfaces.Unsigned_16;
   subtype U32 is Interfaces.Unsigned_32;

   use type U8;
   use type U16;
   use type U32;

   procedure Append (Bb : in out Bit_Buffer; Value : in Bit) is
      -- Empty
   begin -- Append
      Bb.Length := Bb.Length + 1;
      Bb.Element (Bb.Length) := Value;
   end Append;

   procedure Append (Bb : in out Bit_Buffer; Values : in Bit_Buffer) is
      -- Empty
   begin -- Append
      Bb.Element (Bb.Length + 1 .. Bb.Length + Values.Length) := Values.Element (1 .. Values.Length);
      Bb.Length := Bb.Length + Values.Length;
   end Append;

   procedure Append_Bits (Bb : in out Bit_Buffer; Value : in U32; Number_Of_Bits : in Natural) is
      -- Empty
   begin -- Append_Bits
      for Pos in reverse 0 .. Number_Of_Bits - 1 loop
         Append (Bb, Bit (Interfaces.Shift_Right (Value, Pos) and 1) );
      end loop;
   end Append_Bits;

   type Byte_Array is array (Natural range <>) of U8;

   function To_Bytes (Bits : in Bit_Buffer) return Byte_Array;
   --  Packs this buffer's bits into bytes in big endian,
   --  padding with '0' bit values, and returns the new array.

   function To_Bytes (Bits : in Bit_Buffer) return Byte_Array is
      Result : Byte_Array (0 .. Bits.Length / 8 - 1) := (others => 0);
      Idx    : Integer;
   begin -- To_Bytes
      for I in 1 .. Bits.Length loop
         Idx := (I - 1) / 8;
         Result (Idx) := Result (Idx) Or Interfaces.Shift_Left (U8 (Bits.Element (I) ), 7 - ( (I - 1) mod 8) );
      end loop;

      return Result;
   end To_Bytes;

   type Segment is record
      Mode      : Segment_Mode;
      Num_Chars : Natural;
      Bit_Data  : Bit_Buffer;
   end record;

   type Segment_List is array (Positive range <>) of Segment;

   function Num_Char_Count_Bits (Mode : in Segment_Mode; Ver : in QR_Version) return Natural is
      (case Ver is
       when  1 ..  9 => Segment_Params (Mode).Cc_Bits (0),
       when 10 .. 26 => Segment_Params (Mode).Cc_Bits (1),
       when 27 .. 40 => Segment_Params (Mode).Cc_Bits (2) );

   function Total_Bits (Segs : in Segment_List; Version : in QR_Version) return Natural is
      Result  : Natural := 0;
      Cc_Bits : Positive;
   begin -- Total_Bits
      for I in Segs'Range loop
         Cc_Bits := Num_Char_Count_Bits (Segs (I).Mode, Version);

         if Segs (I).Num_Chars >= 2 ** Cc_Bits then --  Fail if segment length value doesn't fit in the length field's bit-width
            raise Constraint_Error with "Segment data too long";
         end if;

         Result := Result + 4 + Cc_Bits + Segs (I).Bit_Data.Length;
      end loop;

      return Result;
   end Total_Bits;

   function To_Bytes (Text : in String) return Segment is
      Bit_Soup : Bit_Buffer;
   begin -- To_Bytes
      for I in Text'Range loop
         Append_Bits (Bit_Soup, Character'Pos (Text (I) ), 8);
      end loop;

      return (Mode => Byte, Num_Chars => Text'Length, Bit_Data => Bit_Soup);
   end To_Bytes;

   function To_Segments (Text : in String) return Segment_List is
      (1 => To_Bytes (Text) );

   function Min_Version (Ecl : in Error_Correction_Level; Text : in String) return QR_Version is
      Data_Used_Bits     : Positive;
      Data_Capacity_Bits : Positive;

      Segs : constant Segment_List := To_Segments (Text);
   begin -- Min_Version
      for Version in QR_Version loop
         Data_Capacity_Bits := Num_Data_Codewords (Version, Ecl) * 8;

         begin
            Data_Used_Bits := Total_Bits (Segs, Version);

            if Data_Used_Bits <= Data_Capacity_Bits then
               return Version;
            end if;
         exception
         when Constraint_Error =>
            null; -- Skip this version: one segment's data would be too long
         end;
      end loop;

      raise Constraint_Error with "Message to be encoded doesn't fit in any QR version";
   end Min_Version;

   --  Error correction codes (could be in a separate package)

   function Finite_Field_Multiply (X : in U8; Y : in U8) return U8;
   --  Returns the product of the two given field elements modulo GF(2^8/16#11D#).

   function Finite_Field_Multiply (X : in U8; Y : in U8) return U8 is
      Z : U8 := 0;
   begin -- Finite_Field_Multiply
      for I in reverse 0 .. 7 loop --  Russian peasant multiplication
         Z := Interfaces.Shift_Left (Z, 1) xor (Interfaces.Shift_Right (Z, 7) * 16#1D#);
         Z := Z xor (Interfaces.Shift_Right (Y, I) and 1) * X;
      end loop;

      return Z;
   end Finite_Field_Multiply;

   procedure Calc_Reed_Solomon_Generator (Result : out Byte_Array);
   --  Calculates the Reed-Solomon generator polynomial of the given degree, storing in result[0 : degree].

   procedure Calc_Reed_Solomon_Generator (Result : out Byte_Array) is
      Degree : constant Positive := Result'Last + 1;

      Root : U8;
   begin --Calc_Reed_Solomon_Generator
      Result := (others => 0); --  Start with the monomial x^0
      Result (Degree - 1) := 1;
      --  Compute the product polynomial (x - r^0) * (x - r^1) * (x - r^2) * ... * (x - r^{degree-1}),
      --  drop the highest term, and store the rest of the coefficients in order of descending powers.
      --  Note that r = 2, which is a generator element of this field GF(2^8/16#11D#).
      Root := 1;

      for I in 0 .. Degree - 1 loop
         for J in 0 .. Degree - 1 loop --  Multiply the current product by (x - r^i)
            Result (J) := Finite_Field_Multiply (Result (J), Root);

            if J + 1 < Degree then
               Result (J) := Result (J) xor Result (J + 1);
            end if;
         end loop;

         Root := Finite_Field_Multiply (Root, 2);
      end loop;
   end Calc_Reed_Solomon_Generator;

   procedure Calc_Reed_Solomon_Remainder (Data : in Byte_Array; Generator : in Byte_Array; Result : out Byte_Array) with
      Pre => Generator'Length = Result'Length or else raise Constraint_Error with "Generator'Length /= Result'Length";
   --  Calculates the remainder of the polynomial data when divided by the generator, where all
   --  polynomials are in big endian and the generator has an implicit leading 1 term,
   --  storing the result in result[0 : degree].

   procedure Calc_Reed_Solomon_Remainder (Data : in Byte_Array; Generator : in  Byte_Array; Result : out Byte_Array) is
      Factor : U8;

      Degree : constant Natural := Generator'Length;
      --  Perform polynomial division
   begin -- Calc_Reed_Solomon_Remainder
      Result := (others => 0);

      for I in Data'Range loop
         Factor := Data (I) xor Result (Result'First);

         --  Shift.
         Result (Result'First .. Result'First + Degree - 2) := Result (Result'First + 1 .. Result'First + Degree - 1);
         Result (Result'First + Degree - 1) := 0;

         for J in 0 .. Degree - 1 loop
            Result (Result'First + J) :=
               Result (Result'First + J) xor Finite_Field_Multiply (Generator (Generator'First + J), Factor);
         end loop;
      end loop;
   end Calc_Reed_Solomon_Remainder;

   function Width (Text : in String; Level : in Error_Correction_Level := Medium) return Natural is
      (Border_Size (Min_Version (Level, Text) ) );

   procedure Draw (Info : in out Drawing_Info; Text : in String; Level : in Error_Correction_Level := Medium) is
      Version      : constant QR_Version := Min_Version (Level, Text);
      Border_Size  : constant Positive   := QR_Code.Border_Size (Version);

      subtype Module_Range is Integer range 0 .. Border_Size - 1; -- Coordinates in the QR square

      type Grid is array (Module_Range, Module_Range) of Boolean; -- The grid y axis is top-down; coordinates are (y,x).

      Modules     : Grid := (others => (others => False) );
      Is_Function : Grid := Modules;

      procedure Set_Function_Module (X : in Module_Range; Y : in Module_Range; Is_Black : in Boolean);
      --  Sets the color of a module and marks it as a function module.

      procedure Set_Function_Module (X : in Module_Range; Y : in Module_Range; Is_Black : in Boolean) is
         -- Empty
      begin -- Set_Function_Module
         Modules (Y, X)     := Is_Black;
         Is_Function (Y, X) := True;  --  Cell is marked, be it black or white.
      end Set_Function_Module;

      type Mask_Pattern_Reference is range 0 .. 7; -- Table 23: Mask pattern generation (8 different ways of XOR masking).

      function Get_Bit (X : in U16; Bit : in Natural) return Boolean is
         ( (Interfaces.Shift_Right (X, Bit) and 1) /= 0);

      --  8.9 Format Information

      procedure Draw_Format_Bits (Mask_Ref : in Mask_Pattern_Reference) is
         --  The Format Information is a 15 bit sequence containing 5 data bits,
         --  with 10 error correction bits calculated using the (15, 5) BCH code.
         Data : U16;
         Bch  : U16;
      begin
         --  Table 25 - Error correction level indicators
         case Level is
         when Low      => Data := 1;
         when Medium   => Data := 0;
         when Quartile => Data := 3;
         when High     => Data := 2;
         end case;

         Data := Interfaces.Shift_Left (Data, 3) + U16 (Mask_Ref);  --  5 bits data.
         --  Now we add 10 bits of an error-correcting code specific to the
         --  format bits only! Used: BCH (Bose-Chaudhuri-Hocquenghem) code.
         Bch := Data;

         for I in 1 .. 10 loop
            Bch := Interfaces.Shift_Left (Bch, 1) xor (Interfaces.Shift_Right (Bch, 9) * 16#537#);
         end loop;

         Data := Interfaces.Shift_Left (Data, 10) + Bch;
         --  Ensure that no combination of Error Correction Level and
         --  Mask Pattern Reference will result in an all-zero data string.
         Data := Data xor 2#101010000010010#;

         --  Figure 19 - Format Information positioning

         --  Draw first copy on top left corner
         for I in 0 .. 5 loop
            Set_Function_Module (8, I, Get_Bit (Data, I) );
         end loop;

         Set_Function_Module (8, 7, Get_Bit (Data, 6) );
         Set_Function_Module (8, 8, Get_Bit (Data, 7) );
         Set_Function_Module (7, 8, Get_Bit (Data, 8) );

         for I in 9 .. 14 loop
            Set_Function_Module (14 - I, 8, Get_Bit (Data, I) );
         end loop;

         --  Draw second copy
         for I in 0 .. 7 loop
            Set_Function_Module (Border_Size - 1 - I, 8, Get_Bit (Data, I) );
         end loop;

         for I in 8 .. 14 loop
            Set_Function_Module (8, Border_Size - 15 + I, Get_Bit (Data, I) );
         end loop;

         --  The lonely Dark Module ("...shall always be dark and
         --  does not form part of the Format Information.")
         Set_Function_Module (8, Border_Size - 8, True);
      end Draw_Format_Bits;

      procedure Draw_Function_Patterns;
      --  Draw patterns that do not belong to encoded data: the three
      --  big squares for finding the orientation and bounds, the small
      --  squares for alignment, etc. This is done before drawing the data.
      --  Function patterns are turned around when drawing data.

      procedure Draw_Function_Patterns is
         procedure Draw_Finder_Pattern (X : in Module_Range; Y : in Module_Range);
         --  7.3.2 - Draws a 7x7 finder pattern, plus the surrounding white
         --          border separator (7.3.3), with the center module at (x, y).

         procedure Draw_Finder_Pattern (X : in Module_Range; Y : in Module_Range) is
            Dist : Integer;
            Xx   : Integer;
            Yy   : Integer;
         begin --Draw_Finder_Pattern
            for Dx in -4 .. 4 loop
               for Dy in -4 .. 4 loop
                  Dist := Integer'Max (abs Dx, abs Dy);  --  Chebyshev / infinity norm
                  Xx := X + Dx;
                  Yy := Y + Dy;

                  if Xx in Module_Range and then Yy in Module_Range then
                     Set_Function_Module (Xx, Yy, Dist /= 2 and Dist /= 4);
                  end if;
               end loop;
            end loop;
         end Draw_Finder_Pattern;

         --  Annex E - Position of Alignment Patterns - Table E.1

         procedure Draw_Alignment_Patterns is
            procedure Draw_Alignment_Pattern (X : in Module_Range; Y : in Module_Range);
            --  Draws a 5x5 alignment pattern, with the center module at (x, y).

            procedure Draw_Alignment_Pattern (X : in Module_Range; Y : in Module_Range) is
               Dist : Integer;
            begin
               for Dx in -2 .. 2 loop
                  for Dy in -2 .. 2 loop
                     Dist := Integer'Max (abs Dx, abs Dy);  --  Chebyshev / infinity norm
                     Set_Function_Module (X + Dx, Y + Dy, Dist /= 1);
                  end loop;
               end loop;
            end Draw_Alignment_Pattern;

            Num_Align : Natural := 0;
            Step      : Integer := 26;
            Pos       : Integer := Version * 4 + 10;
            Align_Pos : array (1 .. 7) of Integer;
         begin -- Draw_Alignment_Patterns
            if Version > 1 then
               Num_Align := Version / 7 + 2;

               if Version /= 32 then
                  Step := ( (Version * 4 + Num_Align * 2 + 1) / (2 * Num_Align - 2) ) * 2;
               end if;

               Align_Pos (1) := 6;

               for I in reverse 2 .. Num_Align loop
                  Align_Pos (I) := Pos;
                  Pos := Pos - Step;
               end loop;
            end if;

            for I in 1 .. Num_Align loop -- Draw the lattice
               for J in 1 .. Num_Align loop
                  if (I = 1 and J = 1)         or
                     (I = 1 and J = Num_Align) or
                     (I = Num_Align and J = 1)
                  then
                     null;  --  Skip the three finder corners
                  else
                     Draw_Alignment_Pattern (Align_Pos (I), Align_Pos (J) );
                  end if;
               end loop;
            end loop;
         end Draw_Alignment_Patterns;

         --  8.10 Version Information

         procedure Draw_Version;
         --  Draws two copies of the version bits (with its own error correction code),
         --  based on this object's version field (which only has an effect for 7 <= version <= 40).

         procedure Draw_Version is
            --  The Version Information is an 18 bit sequence containing 6 data bits, with 12 error
            --  correction bits calculated using the (18, 6) BCH code.
            Data : U16;
            Bch  : U16;
            A    : Module_Range;
            B    : Module_Range;
            Bit  : Boolean;
         begin
            if Version < 7 then
               return;
            end if;

            --  Calculate error correction code and pack bits
            Bch := U16 (Version);

            for I in 1 .. 12 loop
               Bch := Interfaces.Shift_Left (Bch, 1) xor (Interfaces.Shift_Right (Bch, 11) * 16#1F25#);
            end loop;

            Data := Interfaces.Shift_Left (U16 (Version), 12) + Bch;

            --  Draw two copies
            for I in 0 .. 17 loop
               A := Border_Size - 11 + I mod 3;
               B := I / 3;
               Bit := Get_Bit (Data, I);
               Set_Function_Module (A, B, Bit);
               Set_Function_Module (B, A, Bit);
            end loop;
         end Draw_Version;
      begin -- Draw_Function_Patterns
         --  7.3.4 - Draw horizontal and vertical timing
         --          patterns (dotted lines).
         for I in Module_Range loop
            Set_Function_Module (6, I, I mod 2 = 0);
            Set_Function_Module (I, 6, I mod 2 = 0);
         end loop;

         --  7.3.2 - Draw 3 finder patterns (all corners except bottom
         --          right; overwrites some timing modules)
         Draw_Finder_Pattern (3, 3);
         Draw_Finder_Pattern (Border_Size - 4, 3);
         Draw_Finder_Pattern (3, Border_Size - 4);
         --  7.3.5 - Draw alignment patterns
         Draw_Alignment_Patterns;

         --  The mask ref. is fake; this is just for marking the modules
         --  as Function and avoid data being written there.
         Draw_Format_Bits (Mask_Ref => 0);
         --  8.10 - Draw Version Information
         Draw_Version;
      end Draw_Function_Patterns;

      function Append_Error_Correction (In_Data : in Byte_Array) return Byte_Array;
      --  Appends error correction bytes to each block of the given data array, then interleaves bytes
      --  from the blocks and stores them in the result array. data (0 .. Raw_Codewords - totalEcc - 1) contains
      --  the input data. data (Raw_Codewords - totalEcc .. Raw_Codewords - 1) is used as a temporary work area.
      --  The final answer is stored in result.

      function Append_Error_Correction (In_Data : in Byte_Array) return Byte_Array is
         Num_Blocks           : constant Integer := Num_Error_Correction_Blocks (Level, Version);
         Block_Ecc_Len        : constant Integer := ECC_Codewords_Per_Block (Level, Version);
         Raw_Codewords        : constant Integer := Num_Raw_Data_Modules (Version) / 8;
         Data_Len             : constant Integer := Raw_Codewords - Block_Ecc_Len * Num_Blocks;
         Num_Short_Blocks     : constant Integer := Num_Blocks - Raw_Codewords mod Num_Blocks;
         Short_Block_Data_Len : constant Integer := Raw_Codewords / Num_Blocks - Block_Ecc_Len;

         Data      : Byte_Array (0 .. Raw_Codewords - 1);
         Result    : Byte_Array (0 .. Raw_Codewords - 1);
         Generator : Byte_Array (0 .. Block_Ecc_Len - 1);
         J         : Integer;
         K         : Integer;
         L         : Integer;
         BlockLen  : Integer;
      begin -- Append_Error_Correction
         Data (0 .. Data_Len - 1) := In_Data;

         --  8.5.2 Generating the error correction codeword

         --  Split data into blocks and append ECC after all data
         Calc_Reed_Solomon_Generator (Generator);

         J := Data_Len;
         K := 0;

         for I in 0 .. Num_Blocks - 1 loop
            BlockLen := Short_Block_Data_Len;

            if I >= Num_Short_Blocks then
               BlockLen := BlockLen + 1;
            end if;

            Calc_Reed_Solomon_Remainder (Data (K .. K + BlockLen - 1), Generator, Data (J .. J + Generator'Length - 1) );
            J := J + Block_Ecc_Len;
            K := K + BlockLen;
         end loop;

         --  8.6 Constructing the final message codeword sequence

         --  Interleave (not concatenate) the bytes from every block into a single sequence
         K := 0;

         for I in 0 .. Num_Blocks - 1 loop
            L := I;

            for J in 0 .. Short_Block_Data_Len - 1 loop
               Result (L) := Data (K);
               K := K + 1;
               L := L + Num_Blocks;
            end loop;

            if I >= Num_Short_Blocks then
               K := K + 1;
            end if;
         end loop;

         K := (Num_Short_Blocks + 1) * Short_Block_Data_Len;
         L := Num_Blocks * Short_Block_Data_Len;

         for I in Num_Short_Blocks .. Num_Blocks - 1 loop
            Result (L) := Data (K);
            K := K + Short_Block_Data_Len + 1;
            L := L + 1;
         end loop;

         K := Data_Len;

         for I in 0 .. Num_Blocks - 1 loop
            L := Data_Len + I;
            for J in 0 .. Block_Ecc_Len - 1 loop
               Result (L) := Data (K);
               K := K + 1;
               L := L + Num_Blocks;
            end loop;
         end loop;

         return Result;
      end Append_Error_Correction;

      procedure Draw_Data is
         procedure Draw_Codewords (Data_And_Ecc_Bytes : in Byte_Array);
         --  Draw codewords (data with ecc) in zigzag

         procedure Draw_Codewords (Data_And_Ecc_Bytes : in Byte_Array) is
            I      : Integer := 0;                --  Bit index into the data
            Idx    : Integer;                     --  Codeword (Byte) index
            Right  : Integer := Border_Size - 1;  --  Index of right column in each column pair
            X      : Integer;
            Y      : Integer;
            Upward : Boolean;
         begin -- Draw_Codewords
            loop
               if Right = 6 then
                  Right := 5;
               end if;

               Upward := (U32 (Right + 1) and 2) = 0;

               for Vert in Module_Range loop
                  for J in 0 .. 1 loop
                     X := Right - J;  --  Actual x coordinate

                     --  Actual y coordinate:
                     if Upward then
                        Y := Border_Size - 1 - Vert;
                     else
                        Y := Vert;
                     end if;

                     if not Is_Function (Y, X) then
                        Idx := Data_And_Ecc_Bytes'First + I / 8;

                        if Idx > Data_And_Ecc_Bytes'Last then
                           --  If there are any remainder bits (0 to 7), they are already
                           --  set to 0/false/white when the grid of modules was initialized
                           null;
                        else
                           Modules (Y, X) := Get_Bit (U16 (Data_And_Ecc_Bytes (Idx) ), 7 - (I mod 8) );
                        end if;

                        I := I + 1;
                     end if;
                  end loop;
               end loop;

               Right := Right - 2;

               exit when Right < 1;
            end loop;
         end Draw_Codewords;

         --  Apply XOR mask

         procedure Apply_Mask (Mask_Ref : in Mask_Pattern_Reference);
         --  XORs the data modules in this QR Code with the given mask pattern. Due to XOR's mathematical
         --  properties, calling applyMask(m) twice with the same value is equivalent to no change at all.
         --  This means it is possible to apply a mask, undo it, and try another mask. Note that a final
         --  well-formed QR Code symbol needs exactly one mask applied (not zero, not two, etc.).

         procedure Apply_Mask (Mask_Ref : in Mask_Pattern_Reference) is
            Invert : Boolean;
         begin
            for Y in Module_Range loop
               for X in Module_Range loop
                  if not Is_Function (Y, X) then
                     case Mask_Ref is
                     when 0 => Invert := (X + Y) mod 2 = 0;
                     when 1 => Invert := Y mod 2 = 0;
                     when 2 => Invert := X mod 3 = 0;
                     when 3 => Invert := (X + Y) mod 3 = 0;
                     when 4 => Invert := (X / 3 + Y / 2) mod 2 = 0;
                     when 5 => Invert := X * Y mod 2 + X * Y mod 3 = 0;
                     when 6 => Invert := (X * Y mod 2 + X * Y mod 3) mod 2 = 0;
                     when 7 => Invert := ( (X + Y) mod 2 + X * Y mod 3) mod 2 = 0;
                     end case;

                     Modules (Y, X) := Modules (Y, X) xor Invert;
                  end if;
               end loop;
            end loop;
         end Apply_Mask;

         Data_Capacity_Bits : constant Positive     := Num_Data_Codewords (Version, Level) * 8;
         Segs               : constant Segment_List := To_Segments (Text);

         Bb       : Bit_Buffer;
         Pad_Byte : U8;
      begin -- Draw_Data
         for Si in Segs'Range loop -- Create the data bit string by concatenating all segments
            Append_Bits (Bb, U32 (Segment_Params (Segs (Si).Mode).Mode_Bits), 4);
            Append_Bits (Bb, U32 (Segs (Si).Num_Chars), Num_Char_Count_Bits (Segs (Si).Mode, Version) );
            Append (Bb, Segs (Si).Bit_Data); --  Copy bits into concatenated buffer
         end loop;

         --  Add terminator and pad up to a Byte if applicable
         Append_Bits (Bb, 0, Integer'Min (4, Data_Capacity_Bits - Bb.Length) );
         Append_Bits (Bb, 0, (8 - Bb.Length mod 8) mod 8);
         Pad_Byte := 16#EC#; --  Pad with alternate bytes until data capacity is reached

         while Bb.Length < Data_Capacity_Bits loop
            Append_Bits (Bb, U32 (Pad_Byte), 8);
            Pad_Byte := Pad_Byte xor 16#EC# xor 16#11#;
         end loop;

         if Bb.Length mod 8 /= 0 then
            raise Constraint_Error with "Wrong padding";
         end if;

         --  Now bb contains the exact bit sequence to be drawn, turn it into a Byte buffer

         declare
            Data_Bytes         : constant Byte_Array             := To_Bytes (Bb);
            Data_And_Ecc_Bytes : constant Byte_Array             := Append_Error_Correction (Data_Bytes);
            Mask_Ref_Chosen    : constant Mask_Pattern_Reference := 0;
         begin
            Draw_Codewords (Data_And_Ecc_Bytes);
            Draw_Format_Bits (Mask_Ref_Chosen);
            Apply_Mask (Mask_Ref_Chosen);
         end;
      end Draw_Data;

      procedure Output_To_Media is
         -- Empty
      begin -- Output_To_Media
         for Y in Module_Range loop
            for X in Module_Range loop
               if Modules (Y, X) then
                  Draw_Module (Info => Info, X => X, Y => Border_Size - 1 - Y);
               end if;
            end loop;
         end loop;
      end Output_To_Media;
   begin
      Draw_Function_Patterns;
      Draw_Data;
      Output_To_Media;
   end Draw;
end Bar_Code_Drawing.What.QR_Code;
