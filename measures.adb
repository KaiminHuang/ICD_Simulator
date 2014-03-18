with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
package body Measures is
   
   function Limit(Input : in Integer; Fst : in Integer; Lst : in Integer) return Integer
   is
      Output : Integer;
   begin
      if Input < Fst then
	     Output := Fst;
      elsif Input > Lst then
	     Output := Lst;
      else
	     Output := Input;
      end if;

      return Output;
   end Limit;
   
   function LimitBPM(Input : in Integer) return BPM 
   is begin
      return Limit(Input, BPM'First, BPM'Last);
   end LimitBPM;
   
   function LimitJoules(Input : in Integer) return Joules
   is begin
      return Limit(Input, Joules'First, Joules'Last);
   end LimitJoules;

   function LimitTUB(Input : in Integer) return TUB
   is begin
      Put("--the range of Tachycardia Upper Bound is between ");
      Put(Item => TUb'First, width => 0);
      Put(" and ");
      Put(Item => TUb'Last, width => 0);
      New_Line;
      return Limit(Input, TUB'First, TUB'Last);
   end LimitTUB;

   function LimitFUB(Input : in Integer) return FUB
   is begin
      Put("--the range of Fibrillation Upper Bound is between ");
      Put(Item => FUb'First, width => 0);
      Put(" and ");
      Put(Item => FUb'Last, width => 0);
      New_Line;
      return Limit(Input, FUB'First, FUB'Last);
   end LimitFUB;
end Measures;

