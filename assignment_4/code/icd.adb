with Measures;
with HRM;
with ImpulseGenerator;

package body ICD is
   	-- time : constant Integer := 5;
	procedure Init(icdInstance :out ICDType) is
	begin
		icdInstance.Rate 				:= Measures.BPM'First;
		icdInstance.Last6thRate         := Measures.BPM'First;
		icdInstance.Last5thRate         := Measures.BPM'First;
		icdInstance.Last4thRate         := Measures.BPM'First;
		icdInstance.Last3rdRate         := Measures.BPM'First;
		icdInstance.Last2ndRate         := Measures.BPM'First;
		icdInstance.Last1stRate         := Measures.BPM'First;

		icdInstance.IsOn 				:= False;
		--Tachycardia realated variables
		icdInstance.TachycardiaBound 	:= 0;
		icdInstance.isTachycardia 		:= False;
		icdInstance.isInImpulseProcess 	:= False;
		icdInstance.Impulse 			:= 0;
		icdInstance.ImpulseRate 		:= 0;
		icdInstance.Offset 				:= 0;
		icdInstance.TickToNextImpulse 	:= 0;
		icdInstance.Signal 				:= 10;
		--Fibrillation realated variables
		icdInstance.FibrillationBound 	:= 0;
		icdInstance.isFibrillation		:= False;
		icdInstance.isWait				:= False;
		icdInstance.waitAfterShock      := 10;
		icdInstance.AbnormalNum         := 0;
	end Init;

	procedure On(icdInstance: in out ICDType) is
	begin
		-- re-set the Icd, which setting all variable to default value, excepting TachycardiaBound 
		-- and FibrillationBound, because they might be changed in off mode
		icdInstance.Last6thRate         := Measures.BPM'First;
		icdInstance.Last5thRate         := Measures.BPM'First;
		icdInstance.Last4thRate         := Measures.BPM'First;
		icdInstance.Last3rdRate         := Measures.BPM'First;
		icdInstance.Last2ndRate         := Measures.BPM'First;
		icdInstance.Last1stRate         := Measures.BPM'First;
		icdInstance.IsOn 				:= True;

		--Tachycardia realated variables
		icdInstance.TachycardiaBound 	:= 0;
		icdInstance.isTachycardia 		:= False;
		icdInstance.isInImpulseProcess 	:= False;
		icdInstance.Impulse 			:= 0;
		icdInstance.ImpulseRate 		:= 0;
		icdInstance.Offset 				:= 0;
		icdInstance.TickToNextImpulse 	:= 0;
		icdInstance.Signal 				:= 10;
		--Fibrillation realated variables
		icdInstance.FibrillationBound 	:= 0;
		icdInstance.isFibrillation		:= False;
		icdInstance.isWait				:= False;
		icdInstance.waitAfterShock      := 10;
		icdInstance.AbnormalNum         := 0;



	end On;

	function IsOn(icdInstance : in ICDType) return Boolean is
  	begin
    	return icdInstance.IsOn;
	end IsOn;

	procedure Off(icdInstance: in out ICDType) is
	begin
    	-- Since ICD is the controller, it should never be turned down, only turn down Hrm and Gen
    	icdInstance.IsOn := False;
   	end Off;

	procedure isTachycardia(icdInstance : in out ICDType) is
	begin
		-- check wheter the heart rate is higher than the upper bound
		if icdInstance.Rate >= icdInstance.TachycardiaBound  then 
			icdInstance.isTachycardia := True;
		else
			icdInstance.isTachycardia := False;
		end if;
	end isTachycardia;


	procedure isFibrillation(icdInstance : in out ICDType) is
	begin
		-- if there are 3 abnormal rate in 5 ticks then it is considered as a Fibrillation
		if icdInstance.AbnormalNum > 3 then
			icdInstance.isFibrillation := true;
			-- when a Fibrillation is detected Tachycardia detection should be turn off, since 
			-- Fibrillationis more serious than Tachycardia
			icdInstance.isTachycardia := False;
		else
			icdInstance.isFibrillation := False;
		end if;
	end isFibrillation;
   	procedure setFibrillationBound (icdInstance : in out ICDType; ub : in Integer) is
	begin
		-- The Fibrillation Bound can only be changed in Off mode
		if not icdInstance.IsOn then
			-- make sure the Ub is in the range
			icdInstance.FibrillationBound := ub;
		end if;
	end setFibrillationBound;

	procedure setTachycardiaBound (icdInstance : in out ICDType; ub : in Integer) is
	begin
		-- The Fibrillation Bound can only be changed in Off mode
		if not icdInstance.IsOn then
			-- make sure the Ub is in the range
			icdInstance.TachycardiaBound := ub;   
		end if;
	end setTachycardiaBound;

	procedure BPMArrayUpdate (icdInstance : in out ICDType) is
	begin 
		icdInstance.Last6thRate := icdInstance.Last5thRate;
		icdInstance.Last5thRate := icdInstance.Last4thRate;
		icdInstance.Last4thRate := icdInstance.Last3rdRate;
		icdInstance.Last3rdRate := icdInstance.Last2ndRate;
		-- Update the last 1,2,3,4,5,6

	end BPMArrayUpdate;


	procedure Tick(icdInstance : in out ICDType; Hm : in HRM.HRMType; Gen : in out ImpulseGenerator
		.GeneratorType) is
	begin
		-- read the heart rate from hrm
		HRM.GetRate(Hm, icdInstance.Rate);
		BPMArrayUpdate(icdInstance);
		icdInstance.Last1stRate := icdInstance.Rate;
		--check whether there is 1s after giving a shock
		-- isWait(icdInstance);
		--check whether there is a Tachycardia
		isTachycardia(icdInstance);
		--check whether there is a Fibrillation
		isFibrillation(icdInstance);		
		-- CalculateImpluse(icdInstance);
		-- calculate and set the impluse
		ImpulseGenerator.SetImpulse(Gen, icdInstance.Impulse);    
	end Tick;
end ICD;
