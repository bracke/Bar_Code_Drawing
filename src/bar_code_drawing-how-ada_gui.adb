-- A library for drawing bar codes
--
-- Copyright (C) by PragmAda Software Engineering
--
-- Released under the terms of the 3-Clause BSD License. See https://opensource.org/licenses/BSD-3-Clause

package body Bar_Code_Drawing.How.Ada_GUI is
   procedure Render (Info : in Drawing_Info; ID : in GUI.Widget_ID; Scale : in Positive := 1) is
      Start : Natural := Info.Bitmap'First (1);
      Stop  : Natural;
   begin -- Render
      if Info.Dim = 2 then -- 2D code
         Draw_X : for X in Info.Bitmap'Range (1) loop
            Draw_Y : for Y in Info.Bitmap'Range (2) loop
               if Info.Bitmap (X, Y) then
                  ID.Draw_Rectangle (From_X     => Scale * X,
                                     From_Y     => Info.Last_Y - Scale * Y,
                                     To_X       => Scale * X + Scale - 1,
                                     To_Y       => Info.Last_Y - Scale * Y - Scale + 1,
                                     Line_Color => (None => True),
                                     Fill_Color => (None => False, Color => GUI.To_Color (GUI.Black) ) );
               end if;
            end loop Draw_Y;
         end loop Draw_X;
      else -- 1D code
         All_Bars : loop
            exit All_Bars when Start not in Info.Bitmap'Range (1);

            Find_Bar : loop
               exit Find_Bar when Start not in Info.Bitmap'Range (1) or else Info.Bitmap (Start, 0);

               Start := Start + 1;
            end loop Find_Bar;

            exit All_Bars when Start not in Info.Bitmap'Range (1);

            Stop := Start + 1;

            Find_Edge : loop
               exit Find_Edge when Stop not in Info.Bitmap'Range (1) or else not Info.Bitmap (Stop, 0);

               Stop := Stop + 1;
            end loop Find_Edge;

            ID.Draw_Rectangle (From_X     => Scale * Start,
                               From_Y     => 0,
                               To_X       => Scale * Stop - 1,
                               To_Y       => Info.Height,
                               Line_Color => (None => True),
                               Fill_Color => (None => False, Color => GUI.To_Color (GUI.Black) ) );
            Start := Stop + 1;
         end loop All_Bars;
      end if;
   end Render;
end Bar_Code_Drawing.How.Ada_GUI;
