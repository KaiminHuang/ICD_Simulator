with Measures; 
with Heart;
with HRM;
with ImpulseGenerator;
with ICD;

--# inherit Measures,
--#         Heart,
--#         HRM,
--#         ImpulseGenerator,
--#         ICD;
package ClosedLoop is
	type ClosedLoopType is
		record
			Hrt 		: Heart.HeartType;                	-- The simulated heart
	   		Monitor 	: HRM.HRMType;                		-- The simulated heart rate monitor
	   		Generator 	: ImpulseGenerator.GeneratorType; 	-- The simulated generator
	   		Icds 		: ICD.ICDType; 						-- The simulated ICD software 
		end record;
	
	-- Create and initalise a ClosedLoop
	procedure Init(cl : out ClosedLoopType);
	--# derives cl from ;

	-- Switch between on/off mode
	procedure On (cl : in out ClosedLoopType);
	--# derives cl from cl;

	-- Switch between on/off mode
	procedure Off (cl : in out ClosedLoopType);
	--# derives cl from cl;

	-- Set Upper Bound for tachycardia
	procedure setTachycardiaBound (cl : out ClosedLoopType; ub : in Integer);
	--# derives cl from ub;

	-- Set Upper Bound for tachycardia
	procedure setFibrillationBound (cl : out ClosedLoopType; ub : in Integer);
	--# derives cl from ub;

	-- tick heart, monitor, ICD, Umpilse
	procedure tick (cl: in out ClosedLoopType);
	--# derives cl from cl;

end ClosedLoop;

