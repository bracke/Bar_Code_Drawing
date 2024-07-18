-- A program to test drawing bar codes in SVG format
--
-- Copyright (C) by PragmAda Software Engineering
--
-- Released under the terms of the 3-Clause BSD License. See https://opensource.org/licenses/BSD-3-Clause

with Ada.Command_Line;
with Ada.Text_IO;
with Bar_Code_Drawing.How.SVG;
with Bar_Code_Drawing.What.Code_128;

procedure SVG128 is
   -- Empty
begin --SVG128
   if Ada.Command_Line.Argument_Count < 1 then
      Ada.Text_IO.Put_Line (Item => "Usage: svg128 <text to encode>");
      Ada.Text_IO.Put_Line (Item => "   Outputs a Code-128 bar code containing the argument to standard output");

      return;
   end if;

   Get_Text : declare
      package C128 renames Bar_Code_Drawing.What.Code_128;

      Text  : constant String  := Ada.Command_Line.Argument (1);
      Width : constant Natural := C128.Width (Text);

      Info : Bar_Code_Drawing.Drawing_Info := Bar_Code_Drawing.New_Info (Width, 10, 1);
   begin -- Get_Text
      C128.Draw (Info => Info, Text => Text);
      Ada.Text_IO.Put (Item => Bar_Code_Drawing.How.SVG.Image (Info, 0.5, 20.0) );
   end Get_Text;
end SVG128;
