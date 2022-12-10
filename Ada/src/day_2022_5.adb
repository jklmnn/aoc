with Ada.Text_IO;
with Basalt.Stack;
with Basalt.Slicer;
with Basalt.Strings;
with Basalt.Strings_Generic;

procedure Day_2022_5 with
   SPARK_Mode
is
   package Crates is new Basalt.Stack (Character, Character'First);
   package Columns is new Basalt.Slicer (Positive);
   subtype Stack is Crates.Context (Size => 128);
   subtype Stack_Index is Positive range 1 .. 9;
   type Stacks is array (Stack_Index) of Stack;
   type Command (Valid : Boolean := False) is record
      case Valid is
         when True =>
            Amount : Natural;
            Source : Stack_Index;
            Target : Stack_Index;
         when False =>
            null;
      end case;
   end record;

   procedure Add_Stack_Line (Line :        String;
                             S    : in out Stacks)
   is
      use type Columns.Slice;
      Column : Columns.Context :=
         Columns.Create (Line'First, Line'Last, 4);
      Slice : Columns.Slice;
      Index : Positive := Stacks'First;
   begin
      while Index in S'Range loop
         pragma Loop_Invariant (Columns.Get_Range (Column)
                                = Columns.Get_Range (Column)'Loop_Entry);
         Slice := Columns.Get_Slice (Column);
         if
            Line (Slice.First .. Slice.Last)'Length > 2
            and then Line (Slice.First + 1) in 'A' .. 'Z'
            and then not Crates.Is_Full (S (Index))
         then
            Crates.Push (S (Index), Line (Slice.First + 1));
         end if;
         exit when not Columns.Has_Next (Column);
         Columns.Next (Column);
         Index := Index + 1;
      end loop;
   end Add_Stack_Line;

   function Parse_Command (Line : String) return Command
   is
      package Index_Value is new
         Basalt.Strings_Generic.Value_Option_Ranged (Stack_Index);
      Head : Basalt.Strings.String_Slice :=
         Basalt.Strings.String_Slice'(Valid => False);
      Tail : Basalt.Strings.String_Slice :=
         Basalt.Strings.String_Slice'(Valid => False);
      Unused_Head : Basalt.Strings.String_Slice :=
         Basalt.Strings.String_Slice'(Valid => False);
      Amount : Basalt.Strings.Value_Natural.Optional;
      Source : Index_Value.Optional;
      Target : Index_Value.Optional;
   begin
      Basalt.Strings.Split (Line, ' ', Head, Tail);
      if not Tail.Valid then
         return Command'(Valid => False);
      end if;
      Basalt.Strings.Split (Line (Tail.First .. Tail.Last), ' ', Head, Tail);
      if not Tail.Valid or else not Head.Valid then
         return Command'(Valid => False);
      end if;
      Amount :=
         Basalt.Strings.Value_Natural.Value (Line (Head.First .. Head.Last));
      Basalt.Strings.Split (Line (Tail.First .. Tail.Last), ' ', Head, Tail);
      if not Amount.Valid or else not Tail.Valid then
         return Command'(Valid => False);
      end if;
      Basalt.Strings.Split (Line (Tail.First .. Tail.Last), ' ', Head, Tail);
      if not Head.Valid or else not Tail.Valid then
         return Command'(Valid => False);
      end if;
      Source := Index_Value.Value (Line (Head.First .. Head.Last));
      Basalt.Strings.Split (Line (Tail.First .. Tail.Last), ' ',
                            Unused_Head, Tail);
      if not Source.Valid or else not Tail.Valid then
         return Command'(Valid => False);
      end if;
      Target := Index_Value.Value (Line (Tail.First .. Tail.Last));
      if not Target.Valid then
         return Command'(Valid => False);
      end if;
      return Command'(Valid  => True,
                      Amount => Amount.Value,
                      Source => Source.Value,
                      Target => Target.Value);
   end Parse_Command;

   procedure Move (Amount :        Natural;
                   Source : in out Stack;
                   Target : in out Stack)
   is
      Crate : Character;
   begin
      for I in Natural range 1 .. Amount loop
         if
            not Crates.Is_Empty (Source)
            and then not Crates.Is_Full (Target)
         then
            Crates.Pop (Source, Crate);
            Crates.Push (Target, Crate);
         end if;
      end loop;
   end Move;

   procedure Execute_Command (Cmd :        Command;
                              S   : in out Stacks)
   is
   begin
      if not Cmd.Valid then
         return;
      end if;
      Move (Cmd.Amount, S (Cmd.Source), S (Cmd.Target));
   end Execute_Command;

   procedure Execute_Command_Order (Cmd :        Command;
                                    S   : in out Stacks)
   is
      Temp  : Stack;
   begin
      if not Cmd.Valid then
         return;
      end if;
      Move (Cmd.Amount, S (Cmd.Source), Temp);
      Move (Cmd.Amount, Temp, S (Cmd.Target));
   end Execute_Command_Order;

   procedure Print (S : in out Stacks)
   is
   begin
      for St of S loop
         declare
            Top : Character;
         begin
            if not Crates.Is_Empty (St) then
               Crates.Pop (St, Top);
               Ada.Text_IO.Put (Top);
            end if;
         end;
      end loop;
      Ada.Text_IO.New_Line;
   end Print;

   Line : String (1 .. 128);
   Last : Natural;
   Crate_Stacks   : Stacks;
   Crate_Stacks_2 : Stacks;
   Command_Stage  : Boolean := False;
begin
   while not Ada.Text_IO.End_Of_File loop
      Ada.Text_IO.Get_Line (Line, Last);
      if Command_Stage then
         declare
            Cmd : constant Command :=
               Parse_Command (Line (Line'First .. Last));
         begin
            Execute_Command (Cmd ,Crate_Stacks);
            Execute_Command_Order (Cmd, Crate_Stacks_2);
         end;
      else
         if Last > 0 then
            Add_Stack_Line (Line (Line'First .. Last),
                            Crate_Stacks);
         else
            Command_Stage := True;
            for S of Crate_Stacks loop
               Crates.Reversed (S);
            end loop;
            Crate_Stacks_2 := Crate_Stacks;
         end if;
      end if;
   end loop;
   Print (Crate_Stacks);
   Print (Crate_Stacks_2);
end Day_2022_5;
