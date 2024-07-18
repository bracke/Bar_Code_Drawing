-- A program to test drawing bar codes in PBM format
--
-- Copyright (C) by PragmAda Software Engineering
--
-- Released under the terms of the 3-Clause BSD License. See https://opensource.org/licenses/BSD-3-Clause

with Ada.Command_Line;
with Ada.Text_IO;
with Bar_Code_Drawing.How.PBM;
with Bar_Code_Drawing.What.MSI_Code;

procedure PBMMSI is
   -- Empty
begin -- PBMMSI
   if Ada.Command_Line.Argument_Count < 1 then
      Ada.Text_IO.Put_Line (Item => "Usage: pbmmsi <digits to encode>");
      Ada.Text_IO.Put_Line (Item => "   Outputs an MSI bar code containing the argument to standard output");

      return;
   end if;

   Get_Text : declare
      package CMSI renames Bar_Code_Drawing.What.MSI_Code;

      Text  : constant String   := Ada.Command_Line.Argument (1);
      Width : constant Natural  := CMSI.Width (Text);
      Scale : constant Positive := (if Width < 500 then 2 else 1);

      Info : Bar_Code_Drawing.Drawing_Info := Bar_Code_Drawing.New_Info (Width, 100, 1);
   begin -- Get_Text
      CMSI.Draw (Info => Info, Text => Text);
      Ada.Text_IO.Put (Item => Bar_Code_Drawing.How.PBM.Image (Info, Scale) );
   end Get_Text;
end PBMMSI;
