with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Measures;
with Heart;
with HRM;

package body ICD is  

	procedure Init(Icd :out ICDType) is
	begin
		Icd.IsOn 				:= False;
		Icd.Rate 				:= Measures.BPM'First;
		Icd.isTachycardia 		:= False;
		Icd.Impulse 			:= 0;
		Icd.ImpulseRate 		:= 0;
		Icd.UpperBound 			:= 110;
		Icd.Offset 				:= 0;
		Icd.TickToNextImpulse 	:= 0;
		Icd.Signal 				:= 10;
		Icd.isImpulse 			:= False;
	end Init;
	
	procedure On(Icd: out ICDType ; Hm : in HRM.HRMType) is
	begin
	 	-- Get an initial reading for the heart
	 	Icd.IsOn := True;
		HRM.GetRate(Hm, Icd.Rate);
	end On;

	procedure Off(Icd : out ICDType) is
	begin
    	Icd.IsOn := False;
   	end Off;
   
   	function IsOn(Icd : in ICDType) return Boolean is
  	begin
    	return Icd.IsOn;
	end IsOn;

	procedure GetRate (Icd : in ICDType ; Rate : out Measures.BPM) is
	begin
	  if Icd.IsOn then 
	     Rate := Icd.Rate;
	  else 
	     Rate := Measures.BPM'First;
	  end if;
	end GetRate;

	procedure isTachycardia(Icd : in out ICDType) is
	begin
		--check wheter the heart rate is higher than the upper bound
		if Icd.Rate >= Icd.UpperBound  then 
			Icd.isTachycardia := True;
			Icd.isImpulse := True;
		else
			Icd.isTachycardia := False;
		end if;
	end isTachycardia;

	procedure CalculateImpluse(Icd : out ICDType) is
	begin
		if Icd.isImpulse then
			--caculate the bpm, which equals Upper Bound + 15
			Icd.ImpulseRate := Icd.UpperBound + 15;
			--caculate the offset between inpulse
			Icd.offset := 600 / Icd.ImpulseRate;

			if Icd.TickToNextImpulse = 0 then
				-- set Impluse value to 2 j;
				Icd.Impulse := 2;
				-- update how many signal remains need to send
				Icd.Signal := Icd.Signal - 1;
				-- set next impulse time to offset once it is 0
				Icd.TickToNextImpulse := Icd.offset;
			else
				Icd.Impulse := 0;
				Icd.TickToNextImpulse := Icd.TickToNextImpulse - 1;
			end if;
			-- if singal equals to 0 set the isTachycardia to False
			-- reset singal to 10
			if Icd.Signal = 0 then
				Icd.Impulse := 0;
				Icd.Signal := 10;
				Icd.isImpulse := False;
			end if;
		end if;
	end CalculateImpluse;
	
	procedure Tick(Icd : in out ICDType; Hm : in HRM.HRMType; Gen : in out ImpulseGenerator.GeneratorType) is
	begin
		if Icd.IsOn then
			-- read the heart rate from hrm
			HRM.GetRate(Hm, Icd.Rate);
			Put("Heart rate  = ");
			Put(Item => Icd.Rate);
			New_Line;
			isTachycardia(Icd);
			if Icd.isTachycardia then
				Put_Line("!!! A ventricular tachycardia was detected !!!");
			end if;
			-- calculate and set the impluse
			CalculateImpluse(Icd);
			ImpulseGenerator.SetImpulse(Gen, Icd.Impulse);
		else
			--if icd is off return 0
			icd.Rate := Measures.BPM'First;
		end if;
	end Tick;
end ICD;