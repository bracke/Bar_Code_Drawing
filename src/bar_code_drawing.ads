-- A library for drawing bar codes
--
-- Copyright (C) by PragmAda Software Engineering
--
-- Released under the terms of the 3-Clause BSD License. See https://opensource.org/licenses/BSD-3-Clause

package Bar_Code_Drawing is
   type Drawing_Info (<>) is tagged private;
   -- Information about a drawing area, used by a What.*.Draw procedure to draw a bar code, and a How.* package operation to
   -- represent the resulting bar code in the appropriate way

   type Dimension_Number is range 1 .. 2; -- Indicates a 1- or 2-D barcode

   function New_Info (Width : in Positive; Height : in Positive; Dimensions : in Dimension_Number) return Drawing_Info;
   -- Returns a drawing area of Width x Height modules
   -- Dimensions indicates the type of barcode that will be drawn using the result
   -- Initially represents an all-white drawing area

   -- How to use a Drawing_Info object, once declared and initialized with New_Info:
   --    Pass the object to a What.*.Draw procedure, along with the Text to encode and any other information needed by the type of
   --    bar code; Draw will update the object to contain a drawing of the bar code
   --    Pass the updated object to a How.* package operation to convert the drawing into the appropriate representation
   -- For example,
   --    Declare a square Drawing_Info object for a 2-D barcode, sized using What.QR_Code.Width for the text to encode
   --    Pass it to What.QR_Code.Draw with the text to draw a QR code encoding the text in the object
   --    Pass the object to How.PBM.Image to convert the drawing to a String containing the contents of a PBM file
   --    Write the String from Image to a text file to create a PBM file of the QR code
   -- Call How.Ada_GUI.Render to draw the QR code in an Ada-GUI Graphic_Area instead
   -- Use a wide, rectangular, 1-D drawing area and What.Code_128.Draw to create a Code-128 bar code in either or both
   -- representations instead
   -- To add a new representation, create a How.* package with the appropriate operation
   -- To add a new bar-code type, create a What.* package with an appropriate Draw procedure

   procedure Reset (Info : in out Drawing_Info);
   -- Resets Info to all white to reuse it for another bar code

   function Width (Info : in Drawing_Info) return Positive;
   -- Returns the Width value supplied to New_Info

   function Height (Info : in Drawing_Info) return Positive;
   -- Returns the Height value supplied to New_Info

   function Dimensions (Info : in Drawing_Info) return Dimension_Number;
   -- Returns the Dimensions value supplied to New_Info
private -- Bar_Code_Drawing
   type Bit_Matrix is array (Natural range <>, Natural range <>) of Boolean;

   procedure Draw_Module (Info : in out Drawing_Info; X : in Natural; Y : in Natural) with
      Pre => X in 0 .. Info.Last_X and (if Info.Dimensions = 1 then Y = 0 else Y in 0 .. Info.Last_Y);
   -- Updates Info.Bitmap to contain the appropriate module
   -- A module is a black line for a 1D bar code, or a black square for a 2D bar code
   -- A module is drawn at an X, Y coordinate
   -- A module is always one module wide
   -- If Info.Dimensions = 1, the module will be height pixels tall; otherwise the module is a square

   type Drawing_Info (Last_X : Positive; Last_Y : Natural) is tagged record -- Max coordinates of drawing area in pixels
      Width  : Positive;
      Height : Positive;
      Dim    : Dimension_Number;
      Bitmap : Bit_Matrix (0 .. Last_X, 0 .. Last_Y); -- Work area
   end record;
   -- After calling an approprate What.*.Draw procedure with an object of type Drawing_Info, Bitmap contains an image of
   -- the corresponding bar code, with each element of Bitmap representing a module
   -- False represents white, and True, black
   -- Bitmap (0, 0) is the lower-left corner, and (Last_X, Last_Y), the upper-right
   -- This may be processed into an appropriate output format; the verious How.* do this for some possible formats

   function Width (Info : in Drawing_Info) return Positive is (Info.Width);

   function Height (Info : in Drawing_Info) return Positive is (Info.Height);

   function Dimensions (Info : in Drawing_Info) return Dimension_Number is (Info.Dim);

   Name : constant String := "Bar_Code_Drawing";
   URl  : constant String := "https://github.com/jrcarter/Bar_Code_Drawing";
end Bar_Code_Drawing;
