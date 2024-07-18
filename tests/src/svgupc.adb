-- A program to test drawing bar codes in SVG format
--
-- Copyright (C) by PragmAda Software Engineering
--
-- Released under the terms of the 3-Clause BSD License. See https://opensource.org/licenses/BSD-3-Clause

with Ada.Command_Line;
with Ada.Text_IO;
with Bar_Code_Drawing.How.SVG;
with Bar_Code_Drawing.What.UPCA_EAN13;

procedure SVGUPC is
   -- Empty
begin --SVGUPC
   if Ada.Command_Line.Argument_Count < 1 then
      Ada.Text_IO.Put_Line (Item => "Usage: svgupc <11-12 digits>");
      Ada.Text_IO.Put_Line (Item => "   Outputs a UPC-A/EAN-13 bar code containing the argument to standard output");

      return;
   end if;

   Get_Text : declare
      package CUPC renames Bar_Code_Drawing.What.UPCA_EAN13;

      Text : constant String := Ada.Command_Line.Argument (1);

      Info : Bar_Code_Drawing.Drawing_Info := Bar_Code_Drawing.New_Info (CUPC.Width, 10, 1);
   begin -- Get_Text
      CUPC.Draw (Info => Info, Text => Text);
      Ada.Text_IO.Put (Item => Bar_Code_Drawing.How.SVG.Image (Info, 0.5, 20.0) );
   end Get_Text;
end SVGUPC;
