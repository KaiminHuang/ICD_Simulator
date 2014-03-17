with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with RandomNumber;
with Heart;

package body ImpulseGenerator is
   
   procedure Init(Gen : out GeneratorType) is
   begin
      Gen.IsOn := False;
      Gen.Impulse := Measures.Joules'First;
   end Init;
   
   procedure On(Gen : in out GeneratorType) is
   begin
      Gen.IsOn := True;
   end On;
      
   procedure Off(Gen : in out GeneratorType) is
   begin
      Gen.IsOn := False;
   end Off;
   
   function IsOn(Gen : in GeneratorType) return Boolean is
   begin
      return Gen.IsOn;
   end IsOn;
   
   procedure SetImpulse(Gen : in out GeneratorType; J : in Measures.Joules) is
   begin
      -- Only set the impulse if the machine is on
      if Gen.IsOn then
         Gen.Impulse := J;
      end if;
   end SetImpulse;
   
   procedure Tick(Gen : in GeneratorType; Hrt : in out Heart.HeartType) is
      HrtVariable : Heart.HeartType;
   begin
      -- Administer the impulse if the generator is on
      if Gen.IsOn then
         --  For an 'out' variable, we must create a new variable for
         --  the call, and the copy the output value from
         --  Heart.SetImpulse back to Ptnt
         HrtVariable := Hrt;
         Heart.SetImpulse(HrtVariable, Gen.Impulse);
         if (Gen.Impulse /= 0) then
            Put("generate a impulse -->");
            Put(Item => Gen.Impulse);
            New_Line;
         end if;

         Hrt := HrtVariable;
      end if;
   end Tick;
   
end ImpulseGenerator;
