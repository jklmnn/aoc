with Ada.Text_IO;
with Basalt.Strings;

procedure Day_2022_4 with
   SPARK_Mode
is
   type Assignment (Valid : Boolean) is record
      case Valid is
         when True =>
            First : Natural;
            Last : Natural;
         when False =>
            null;
      end case;
   end record;
   function Contained (L, R : Assignment) return Boolean is
      (L.Valid
       and then R.Valid
       and then ((L.First >= R.First
                  and then L.Last <= R.Last)
                 or else (L.First <= R.First
                          and then L.Last >= R.Last)));

   function Overlaps (L, R : Assignment) return Boolean is
      (L.Valid
       and then R.Valid
       and then ((L.Last >= R.First
                  and then L.First <= R.Last)
                 or else (R.Last >= L.First
                          and then R.First <= L.Last)));

   function Get_Assignment (S : String;
                            E : Basalt.Strings.String_Slice)
   return Assignment with
      Pre => (if E.Valid then E.First in S'Range and then E.Last in S'Range)
   is
      First, Last : Basalt.Strings.Value_Natural.Optional;
      Head, Tail  : Basalt.Strings.String_Slice;
   begin
      if not E.Valid then
         return Assignment'(Valid => False);
      end if;
      Basalt.Strings.Split (S (E.First .. E.Last), '-', Head, Tail);
      if not Head.Valid or else not Tail.Valid then
         return Assignment'(Valid => False);
      end if;
      First :=
         Basalt.Strings.Value_Natural.Value (S (Head.First .. Head.Last));
      Last :=
         Basalt.Strings.Value_Natural.Value (S (Tail.First .. Tail.Last));
      if not First.Valid or else not Last.Valid then
         return Assignment'(Valid => False);
      end if;
      return Assignment'(Valid => True,
                         First => First.Value,
                         Last  => Last.Value);
   end Get_Assignment;
   Line : String (1 .. 256);
   Last : Natural;
   Elf_1, Elf_2 : Basalt.Strings.String_Slice;
   Contained_Assignments : Natural := 0;
   Overlapping_Assignments : Natural := 0;
begin
   while not Ada.Text_IO.End_Of_File loop
      Ada.Text_IO.Get_Line (Line, Last);
      Basalt.Strings.Split (Line (Line'First .. Last), ',', Elf_1, Elf_2);
      declare
         Assignment_1 : constant Assignment := Get_Assignment (Line, Elf_1);
         Assignment_2 : constant Assignment := Get_Assignment (Line, Elf_2);
      begin
         if
            Contained (Assignment_1, Assignment_2)
            and then Contained_Assignments < Natural'Last
         then
            Contained_Assignments := Contained_Assignments + 1;
         end if;
         if
            Overlaps (Assignment_1, Assignment_2)
            and then Overlapping_Assignments < Natural'Last
         then
            Overlapping_Assignments := Overlapping_Assignments + 1;
         end if;
      end;
   end loop;
   Ada.Text_IO.Put_Line ("Contained Assignments:"
                         & Contained_Assignments'Image);
   Ada.Text_IO.Put_Line ("Overlapping Assinments:"
                         & Overlapping_Assignments'Image);
end Day_2022_4;
