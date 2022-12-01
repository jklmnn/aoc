with Ada.Text_IO;
with Basalt.Strings;

procedure Day_2022_1 with
   SPARK_Mode
is
   package Nat_Val renames Basalt.Strings.Value_Natural;
   type Elf is record
      Index    : Natural := 0;
      Calories : Natural := 0;
   end record;
   type Elves is array (Positive range <>) of Elf;
   Line     : String (1 .. 10);
   Last     : Natural;
   Calories : Natural  := 0;
   Current  : Positive := 1;
   Top_3    : Elves (1 .. 3);
   procedure Print
   is
      Sum : Natural := 0;
   begin
      for E of Top_3 loop
         Ada.Text_IO.Put_Line (E.Index'Image & ": " & E.Calories'Image);
         if Natural'Last - Sum > E.Calories then
            Sum := Sum + E.Calories;
         end if;
      end loop;
      Ada.Text_IO.Put_Line (Sum'Image);
   end Print;
begin
   while not Ada.Text_IO.End_Of_File loop
      Ada.Text_IO.Get_Line (Line, Last);
      if Last = 0 then
         if Current = Positive'Last then
            Print;
            Ada.Text_IO.Put_Line ("Too many Elves");
            return;
         end if;
         declare
            Match : Positive := Top_3'First;
         begin
            for E of Top_3 loop
               exit when E.Calories < Calories;
               Match := Match + 1;
            end loop;
            for I in reverse Match + 1 .. Top_3'Last loop
               Top_3 (I) := Top_3 (I - 1);
            end loop;
            if Match in Top_3'Range then
               Top_3 (Match) := Elf'(Index => Current, Calories => Calories);
            end if;
         end;
         Current := Current + 1;
         Calories := 0;
      else
         declare
            Current : Nat_Val.Optional;
         begin
            Current := Nat_Val.Value (Line (Line'First .. Last));
            if
               Current.Valid
               and then Natural'Last - Calories > Current.Value
            then
               Calories := Calories + Current.Value;
            end if;
         end;
      end if;
   end loop;
   Print;
end Day_2022_1;
