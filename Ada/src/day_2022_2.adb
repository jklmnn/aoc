with Ada.Text_IO;

procedure Day_2022_2 with
   SPARK_Mode
is
   subtype Other_Shape is Character range 'A' .. 'C';
   subtype Self_Shape is Character range 'X' .. 'Z';
   type Shape_Points is array (Self_Shape) of Natural;
   type Result_Points is array (Other_Shape, Self_Shape) of Natural;
   Shapes : constant Shape_Points := ('X' => 1, 'Y' => 2, 'Z' => 3);
   Results : constant Result_Points :=
      ('A' => ('X' => 3, 'Y' => 6, 'Z' => 0),
       'B' => ('X' => 0, 'Y' => 3, 'Z' => 6),
       'C' => ('X' => 6, 'Y' => 0, 'Z' => 3));
   Line : String (1 .. 3);
   Last : Natural;
   Score : Natural := 0;
begin
   while not Ada.Text_IO.End_Of_File loop
      Ada.Text_IO.Get_Line (Line, Last);
      if
         Last = Line'Last
         and then Line (Line'First) in Other_Shape'Range
         and then Line (Line'Last) in Self_Shape'Range
      then
         declare
            Result : constant Natural :=
               Results (Line (Line'First), Line (Line'Last));
            Points : constant Natural := Shapes (Line (Line'Last));
         begin
            if Natural'Last - Score > Result + Points then
               Score := Score + Result + Points;
            else
               Ada.Text_IO.Put_Line ("Max score reached:" & Score'Image);
               return;
            end if;
         end;
      end if;
   end loop;
   Ada.Text_IO.Put_Line ("Score:" & Score'Image);
end Day_2022_2;
