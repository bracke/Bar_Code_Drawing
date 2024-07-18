-- A program to test drawing bar codes in PBM format
--
-- Copyright (C) by PragmAda Software Engineering
--
-- Released under the terms of the 3-Clause BSD License. See https://opensource.org/licenses/BSD-3-Clause

with Ada.Command_Line;
with Ada.Text_IO;
with Bar_Code_Drawing.How.PBM;
with Bar_Code_Drawing.What.QR_Code;

procedure PBMQR is
   package CQR renames Bar_Code_Drawing.What.QR_Code;

   Text_Arg : Positive := 1;
   ECL      : CQR.Error_Correction_Level := CQR.Medium;
begin -- PBMQR
   if Ada.Command_Line.Argument_Count < 1 then
      Ada.Text_IO.Put_Line (Item => "Usage: pbmqr [-L | -M | -Q | -H] <text to encode>");
      Ada.Text_IO.Put_Line (Item => "   Switch indicates the Error Correction Level to use (default M)");
      Ada.Text_IO.Put_Line (Item => "   Outputs a QR code containing the argument to standard output");

      return;
   end if;

   if Ada.Command_Line.Argument_Count > 1 then
      Check_Switch : declare
         Arg : constant String := Ada.Command_Line.Argument (1);
      begin -- Check_Switch
         if Arg'Length = 2 and then (Arg (1) = '-' and Arg (2) in 'l' | 'L' | 'm' | 'M' | 'q' | 'Q' | 'h' | 'H') then
            Text_Arg := 2;

            ECL := (case Arg (2) is
                    when 'l' | 'L' => CQR.Low,
                    when 'm' | 'M' => CQR.Medium,
                    when 'q' | 'Q' => CQR.Quartile,
                    when 'h' | 'H' => CQR.High,
                    when others    => raise Program_Error with "Invalid level");
         end if;
      end Check_Switch;
   end if;

   Get_Text : declare
      Text  : constant String   := Ada.Command_Line.Argument (Text_Arg);
      Width : constant Natural  := CQR.Width (Text, ECL);
      Scale : constant Positive := Integer'Max (250 / Width, 2);

      Info : Bar_Code_Drawing.Drawing_Info := Bar_Code_Drawing.New_Info (Width, Width, 2);
   begin -- Get_Text
      CQR.Draw (Info => Info, Text => Text, Level => ECL);
      Ada.Text_IO.Put (Item => Bar_Code_Drawing.How.PBM.Image (Info, Scale) );
   exception -- Get_Text
   when others =>
      Ada.Text_IO.Put_Line (Item => "Text too long");
   end Get_Text;
end PBMQR;
