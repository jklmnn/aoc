with Ada.Text_IO;

procedure Day_2022_3 with
   SPARK_Mode
is
   function Priority (C : Character) return Natural with
      Post => Priority'Result <= 52
   is
   begin
      case C is
         when 'a' .. 'z' =>
            return Character'Pos (C) - Character'Pos ('a') + 1;
         when 'A' .. 'Z' =>
            return Character'Pos (C) - Character'Pos ('A') + 27;
         when others =>
            return 0;
      end case;
   end Priority;

   type Elf_Line is record
      Line : String (1 .. 1024) := (others => Character'First);
      Last : Natural := 0;
   end record;
   type Index is mod 3;
   type Line_Buffer is array (Index) of Elf_Line;

   Lines : Line_Buffer;
   Priority_Sum : Natural := 0;
   Curr : Index := 0;
begin
   while not Ada.Text_IO.End_Of_File loop
      Ada.Text_IO.Get_Line (Lines (Curr).Line, Lines (Curr).Last);
      pragma Assert (Lines (Curr).Last in 0 .. Lines (Curr).Line'Last);
      if Lines (Curr).Last > 0 and then Lines (Curr).Last mod 2 = 0 then
         declare
            Split  : constant Natural := Lines (Curr).Last / 2;
            First  : constant String (1 .. Split) :=
               Lines (Curr).Line (1 .. Split);
            Second : constant String (1 .. Split) :=
               Lines (Curr).Line (Split + 1 .. Lines (Curr).Last);
         begin
            Outer :
            for F of First loop
               pragma Loop_Invariant (Lines (Curr).Last in 0 .. Lines (Curr).Line'Last);
               for S of Second loop
                  pragma Loop_Invariant (Lines (Curr).Last in 0 .. Lines (Curr).Line'Last);
                  if
                     F = S
                     and then Natural'Last - Priority_Sum > Priority (F)
                  then
                     Priority_Sum := Priority_Sum + Priority (F);
                     exit Outer;
                  end if;
               end loop;
            end loop Outer;
         end;
      else
         Ada.Text_IO.Put_Line ("Invalid contents");
      end if;
      pragma Assert (Lines (Curr).Last in 0 .. Lines (Curr).Line'Last);
      Curr := Curr + 1;
   end loop;
   Ada.Text_IO.Put_Line ("Priority:" & Priority_Sum'Image);
end Day_2022_3;
