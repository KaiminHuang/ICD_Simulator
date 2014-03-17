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
		cl.UpperBound := 110; -- the default value move it to measures latter
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
			-- Set all components to On 
			HRM.On(cl.Monitor, cl.Hrt);
			ImpulseGenerator.On(cl.Generator);
			ICD.On(cl.Icds, cl.Monitor);
			Put_Line("Switched to On mode");
		else
			-- set all components to Off
			HRM.Off(cl.Monitor);
			ImpulseGenerator.Off(cl.Generator);
			ICD.Off(cl.Icds);
			Put_Line("Switched to Off mode");
		end if;

	end switch;

	procedure setUpperBound (cl : out ClosedLoopType; ub : in Integer) is
	begin
		ICD.setUpperBound(cl.Icds, ub);
	end setUpperBound;

	procedure tick (cl: in out ClosedLoopType) is 
	begin

		ICD.Tick(cl.Icds, cl.Monitor, cl.Generator);
		ImpulseGenerator.Tick(cl.Generator, cl.Hrt);
		HRM.Tick(cl.Monitor, cl.Hrt);
		Heart.Tick(cl.Hrt);
	end tick;
	

end ClosedLoop;