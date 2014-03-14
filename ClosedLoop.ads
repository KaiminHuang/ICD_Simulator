with Ada.Text_IO; use Ada.Text_IO;
with ImpulseGenerator;
with Measures;
with Heart;
with HRM;

-- this package encapsulates the ICD, Heart, HRM, and 
-- ImpulseGenerator package including (a) Switching between modes.
-- (b) Turning the heart rate monitor and impulse generator on/o↵.
-- (c) Increasing/decreasing the upper bound of tachycardia.
-- (d) “Ticking” the clock one decisecond, which simply ticks all other
-- entities in the system (ICD, Heart, HRM, and ImpulseGenerator).

Package ClosedLoop is 
	type ClosedLoopType is
		record
			IsOn : Boolean;
			UpperBound : Integer; -- might set a normal boundary in measure later !!!!!!!
		end record;
	
	-- Create and initalise a ClosedLoop
	procedure Init(cl : out ClosedLoopType);

	-- Switch between on/off mode
	procedure switch (cl : in out ClosedLoopType);

	-- Set Upper Bound for tachycardia
	procedure setUpperBound (cl : out ClosedLoopType; ub : in Integer);

	-- tick heart, monitor, ICD, Umpilse
	procedure tick (  Icds : in ICD.ICDType; Hm : in HRM.HRMType; Gen : in ImpulseGenerator.GeneratorType; Hrt : in out Heart.HeartType; cl: in out ClosedLoopType);   --recheck in out later !!!!!!


end ClosedLoop;