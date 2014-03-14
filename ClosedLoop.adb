with Ada.Text_IO; use Ada.Text_IO;
with ImpulseGenerator;
with Measures;
with Heart;
with HRM;
with ICD;

Package body ClosedLoop is 

	procedure Init(cl : out ClosedLoopType) is
		UpperBound : Integer := 110;
	begin
		cl.IsOn := False;
		cl.UpperBound := 110; -- the default value
	end Init;

	procedure switch (cl : in out ClosedLoopType) is
	begin
		cl.IsOn := not cl.IsOn;
	end switch;

	procedure setUpperBound (cl : out ClosedLoopType; ub : in Integer) is
	begin
		cl.UpperBound := ub;
	end setUpperBound;

	procedure tick ( Icds : in out ICD.ICDType; Monitor : in out HRM.HRMType; 
	Gen : in out ImpulseGenerator.GeneratorType; Hrt : in out Heart.HeartType; 
	cl: in out ClosedLoopType) is   --recheck in out later !!!!!!
	begin
		ICD.Tick(Icds, Monitor, Gen);
		ImpulseGenerator.Tick(Gen, Hrt);
		HRM.Tick(Monitor, Hrt);
		Heart.Tick(Hrt);
  		Put_Line("");
	end tick;
	

end ClosedLoop;