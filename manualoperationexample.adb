with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

with Measures; use Measures;
with Heart;
with HRM;
with ImpulseGenerator;

-- This procedure demonstrates a simple composition of a heart rate
--  monitor (HRM), heart, and impulse generator.
procedure ManualOperationExample is
   Hrt : Heart.HeartType;                -- The simulated heart
   Monitor : HRM.HRMType;                -- The simulated heart rate monitor
   Generator : ImpulseGenerator.GeneratorType; -- The simulated generator
   HeartRate : BPM;
begin
   -- Initialise the patient and turn the machines on
   Heart.Init(Hrt); --set Hrt.Rate=random systolic pressure and Hrt.Impluse=0
   HRM.Init(Monitor);
   ImpulseGenerator.Init(Generator);
   
   HRM.On(Monitor, Hrt); -- set flag, and call Heart.GetRate()
   ImpulseGenerator.On(Generator);
   
   -- Set the new impulse to 0
   ImpulseGenerator.SetImpulse(Generator, 0); 

   -- -- Loop 100 times with no impulse
   for I in Integer range 0..4 loop
      Put_Line("Loop Start");
      -- Read and print the current heart rate
      HRM.GetRate(Monitor, HeartRate); -- the reason for giveing Monitor is to check whether it's on
      Put("Heart rate  = ");
      Put(Item => HeartRate);
      New_Line;
            
      -- Tick all components
      ImpulseGenerator.Tick(Generator, Hrt);
      HRM.Tick(Monitor, Hrt); --this is calling Heart.GetRate()
      Heart.Tick(Hrt);

      -- Why HRM is ticking before Heart?
      -- Because HRM.tick() set HRM.rate = "new rate"
      -- Then Heart.tick() set Heart.rate = "new rate"
      -- Is it Cheating   ???
      delay 0.1;
   end loop;
   
   -- -- Turn off the monitor: should return -1.0 for the next readings
   -- HRM.Off(Monitor);
   
   -- HRM.GetRate(Monitor, HeartRate);
   -- ImpulseGenerator.Tick(Generator, Hrt);
   -- HRM.Tick(Monitor, Hrt);
   -- Heart.Tick(Hrt);
   
   -- Put("Heart rate should be -1 = ");
   -- Put(Item => HeartRate);
   -- New_Line;
   
   -- -- Turn the machine back on
   -- HRM.On(Monitor, Hrt);
   
   -- -- Ramp up the impulse 
   -- ImpulseGenerator.SetImpulse(Generator, 4);
   -- for I in Integer range 0..100 loop
   --    HRM.GetRate(Monitor, HeartRate);
      
   --    Put("After turn on = ");
   --    Put(Item => HeartRate);
   --    New_Line;     
      
   --    ImpulseGenerator.Tick(Generator, Hrt);
   --    HRM.Tick(Monitor, Hrt);
   --    Heart.Tick(Hrt);
   --    delay 0.1;
   -- end loop; 
end ManualOperationExample;
