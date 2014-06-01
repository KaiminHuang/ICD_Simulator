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
		icdInstance.TachycardiaBound 	:= Measures.TUB'First;
		icdInstance.ImpulseRateBound	:= Measures.TUB'Last - 15;
		icdInstance.isTachycardia 		:= False;
		icdInstance.isInImpulseProcess 	:= False;
		icdInstance.Impulse 			:= 0;
		icdInstance.ImpulseRate 		:= 0;
		icdInstance.Offset 				:= 0;
		icdInstance.TickToNextImpulse 	:= 0;
		icdInstance.Signal 				:= 10;
		--Fibrillation realated variables
		icdInstance.FibrillationBound 	:= Measures.FUB'First;
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
		icdInstance.TachycardiaBound 	:= Measures.TUB'First;
		icdInstance.isTachycardia 		:= False;
		icdInstance.isInImpulseProcess 	:= False;
		icdInstance.Impulse 			:= 0;
		icdInstance.ImpulseRate 		:= 0;
		icdInstance.Offset 				:= 0;
		icdInstance.TickToNextImpulse 	:= 0;
		icdInstance.Signal 				:= 10;
		--Fibrillation realated variables
		icdInstance.FibrillationBound 	:= Measures.FUB'First;
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

	procedure GetAbnormalNum (icdInstance : in out ICDType) is
	begin 
		icdInstance.AbnormalNum := 0;
		if abs(icdInstance.Last6thRate - icdInstance.Last5thRate) >= icdInstance.FibrillationBound then
			icdInstance.AbnormalNum := icdInstance.AbnormalNum + 1;
		end if;
		if abs(icdInstance.Last5thRate - icdInstance.Last4thRate) >= icdInstance.FibrillationBound then
			icdInstance.AbnormalNum := icdInstance.AbnormalNum + 1;
		end if;
		if abs(icdInstance.Last4thRate - icdInstance.Last3rdRate) >= icdInstance.FibrillationBound then
			icdInstance.AbnormalNum := icdInstance.AbnormalNum + 1;
		end if;
		if abs(icdInstance.Last3rdRate - icdInstance.Last2ndRate) >= icdInstance.FibrillationBound then
			icdInstance.AbnormalNum := icdInstance.AbnormalNum + 1;
		end if;
		if abs(icdInstance.Last2ndRate - icdInstance.Last1stRate) >= icdInstance.FibrillationBound then
			icdInstance.AbnormalNum := icdInstance.AbnormalNum + 1;
		end if;
	end GetAbnormalNum;	

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
		GetAbnormalNum(icdInstance);
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
			icdInstance.FibrillationBound :=  Measures.LimitFUB(ub);
		end if;
	end setFibrillationBound;

	procedure setTachycardiaBound (icdInstance : in out ICDType; ub : in Integer) is
	begin
		-- The Fibrillation Bound can only be changed in Off mode
		if not icdInstance.IsOn then
			-- make sure the Ub is in the range
			icdInstance.TachycardiaBound := Measures.LimitTUB(ub);   
		end if;
	end setTachycardiaBound;

	procedure BPMArrayUpdate (icdInstance : in out ICDType) is
	begin 
		icdInstance.Last6thRate := icdInstance.Last5thRate;
		icdInstance.Last5thRate := icdInstance.Last4thRate;
		icdInstance.Last4thRate := icdInstance.Last3rdRate;
		icdInstance.Last3rdRate := icdInstance.Last2ndRate;
		icdInstance.Last2ndRate := icdInstance.Last1stRate;
		icdInstance.Last1stRate := icdInstance.Rate;
		-- Update the last 1,2,3,4,5,6

	end BPMArrayUpdate;

	procedure CalculateAndSetImpluse(icdInstance : in out ICDType) is
	begin
		if icdInstance.Ison = True then
			-- reset impulse to 0 before each caculation
			 icdInstance.Impulse := 0;
			--check whether there is 1s after giving a shock
			if not icdInstance.isWait then
				-- Check whether there is a Fibrillation
				if icdInstance.isFibrillation then
					-- since Fibrillation is heavier than Tachycardia then if a Fibrillation is detected
					--, set impulse to 30, and terminate all in process impulse
					icdInstance.Impulse 			:= 30;
					icdInstance.isInImpulseProcess 	:= False;
					icdInstance.isWait				:= True;
					-- reset tick and sinal to it's defualt value
					icdInstance.TickToNextImpulse 	:= 0;
					icdInstance.Signal 				:= 10;
				end if;
					
				-- check whether there is a Tachycardia detected or a impulse treatment in process
				if (icdInstance.isTachycardia or icdInstance.isInImpulseProcess) then
					-- set the isInImpulseProcess to true indicatong that there is a treatment in 
					-- process it will be changed to false when  a process is finised (signal == 0)
					icdInstance.isInImpulseProcess := True;
					--caculate the bpm, which equals Upper Bound + 15
					if icdInstance.ImpulseRate  <= icdInstance.ImpulseRateBound then
						icdInstance.ImpulseRate := icdInstance.TachycardiaBound + 15;
					end if;
					--caculate the offset between inpulse
					icdInstance.offset := 600 / icdInstance.ImpulseRate;

					if icdInstance.TickToNextImpulse = 0 then
						-- if yes print "--Already in impulse procedure"
						-- set Impluse value to 2 j;
						icdInstance.Impulse := 2;
						-- update how many signal remains need to send
						if icdInstance.Signal > 0 then
							icdInstance.Signal := icdInstance.Signal - 1;
						end if;
						-- set next impulse time to offset once it is 0
						icdInstance.TickToNextImpulse := icdInstance.offset -1 ;
					else
						icdInstance.Impulse := 0;
						if icdInstance.TickToNextImpulse > 0 then
							icdInstance.TickToNextImpulse := icdInstance.TickToNextImpulse - 1;
						end if;
					end if;
					-- if singal equals to 0 means the treatment is fninished then set the isTachycardia
					-- to False set TickToNextImpulse to default 0 reset singal to 10
					if icdInstance.Signal = 0 then
						icdInstance.TickToNextImpulse := 0;
						icdInstance.Signal := 10;
						icdInstance.isInImpulseProcess := False;
					end if;
				end if;
			end if;
		end if;
	end CalculateAndSetImpluse;

	procedure isWait(icdInstance : in out ICDType) is
	begin
		if icdInstance.isWait then
			if icdInstance.waitAfterShock > 1 then
				icdInstance.waitAfterShock := icdInstance.waitAfterShock -1 ;
				if icdInstance.waitAfterShock = 0 then
					icdInstance.waitAfterShock := 10;
					icdInstance.isWait := False;
				end if;
			end if;
		end if;
	end isWait;

	procedure Tick(icdInstance : in out ICDType; Hm : in HRM.HRMType; Gen : in out ImpulseGenerator
		.GeneratorType) is
	begin
		-- read the heart rate from hrm
		HRM.GetRate(Hm, icdInstance.Rate);
		BPMArrayUpdate(icdInstance);
		--check whether there is 1s after giving a shock
		isWait(icdInstance);
		--check whether there is a Tachycardia
		isTachycardia(icdInstance);
		--check whether there is a Fibrillation
		isFibrillation(icdInstance);		
		CalculateAndSetImpluse(icdInstance);
		-- calculate and set the impluse
		ImpulseGenerator.SetImpulse(Gen, icdInstance.Impulse);    
	end Tick;
end ICD;
