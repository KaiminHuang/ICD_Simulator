with Measures;
with Heart;
with HRM;
with ImpulseGenerator;
with ICD;

package body ClosedLoop is
 	procedure Init(cl : out ClosedLoopType) is
	begin
   		--Initalise hrt, monitor, gen, icd
		Heart.Init(cl.Hrt);
		HRM.Init(cl.Monitor);
		ICD.Init(cl.Icds);
		ImpulseGenerator.Init(cl.Generator);

	end Init;

	procedure Off (cl : in out ClosedLoopType) is
	begin
		-- set all components to Off
		ICD.Off(cl.Icds);
    	HRM.Off(cl.Monitor);
		ImpulseGenerator.Off(cl.Generator);
	end Off;

	procedure On (cl : in out ClosedLoopType) is
	begin
		HRM.On(cl.Monitor, cl.Hrt);
		ImpulseGenerator.On(cl.Generator);
		Heart.Init(cl.Hrt);
		HRM.GetRate(cl.Monitor, cl.Icds.Rate);
		ICD.On(cl.Icds);

	end On;

	procedure setTachycardiaBound (cl : out ClosedLoopType; ub : in Integer) is
	begin
		ICD.setTachycardiaBound(cl.Icds, ub);
	end setTachycardiaBound;

	procedure setFibrillationBound (cl : out ClosedLoopType; ub : in Integer) is
	begin
		ICD.setFibrillationBound(cl.Icds, ub);
	end setFibrillationBound;

	procedure tick (cl: in out ClosedLoopType) is 
	begin
		-- tick all components
		Heart.Tick(cl.Hrt);
		HRM.Tick(cl.Monitor, cl.Hrt);
		ICD.Tick(cl.Icds, cl.Monitor, cl.Generator);
		ImpulseGenerator.Tick(cl.Generator, cl.Hrt);

	end tick;
	
end ClosedLoop;
