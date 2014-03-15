with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
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
			Put_Line("Switched to On mode");
		else
			Put_Line("Switched to Off mode");
		end if;

	end switch;

	procedure setUpperBound (cl : out ClosedLoopType; ub : in Integer) is
	begin
		if not cl.IsOn then
			cl.UpperBound := ub;
			Put_Line("The Upper Bound has been changed to");
			Put(Item => cl.UpperBound);
		else
			Put_Line("The UpperBound can only be changed in Off mode");
			Put_Line("Please use Switch to change the mode");
		end if;
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