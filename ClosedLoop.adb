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

   		--Initalise hrt, monitor, gen, icd
		Heart.Init(cl.Hrt);
		HRM.Init(cl.Monitor);
		ICD.Init(cl.Icds);
		ImpulseGenerator.Init(cl.Generator);

	end Init;

	procedure switch (cl : in out ClosedLoopType) is
	begin
		cl.IsOn := not cl.IsOn;
		if cl.IsOn then
			-- Set all components to On or Off
			HRM.On(cl.Monitor, cl.Hrt);
			ImpulseGenerator.On(cl.Generator);
			ICD.On(cl.Icds, cl.Monitor);
		end if;

	end switch;

	procedure setUpperBound (cl : out ClosedLoopType; ub : in Integer) is
	begin
		cl.UpperBound := ub;
	end setUpperBound;

	-- procedure tick ( Icds : in out ICD.ICDType; Monitor : in out HRM.HRMType; 
	-- Gen : in out ImpulseGenerator.GeneratorType; Hrt : in out Heart.HeartType; 
	-- cl: in out ClosedLoopType) is   --recheck in out later !!!!!!
	procedure tick (cl: in out ClosedLoopType) is   --recheck in out later !!!!!!
	begin

		ICD.Tick(cl.Icds, cl.Monitor, cl.Generator);
		ImpulseGenerator.Tick(cl.Generator, cl.Hrt);
		HRM.Tick(cl.Monitor, cl.Hrt);
		Heart.Tick(cl.Hrt);
	end tick;
	

end ClosedLoop;