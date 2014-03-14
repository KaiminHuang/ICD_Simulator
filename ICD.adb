with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;with Measures;
with Heart;
with HRM;

package body ICD is  

	procedure Init(Icd :out ICDType) is
	begin
		Icd.IsOn := False;
		Icd.Rate := Measures.BPM'First;
		Icd.isTachycardia := False;
		Icd.Impulse :=0;
		Icd.UpperBound :=110;
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

	function isTachycardia(Icd : in ICDType) return Boolean is
	begin
		return Icd.isTachycardia;
	end isTachycardia;

	procedure CalculateImpluse(Icd : out ICDType) is
	begin
		Icd.Impulse := 1; -- set the impluse here !!!!!!
	end CalculateImpluse;
	
	procedure Tick(Icd : in out ICDType; Hm : in HRM.HRMType; Gen : in out ImpulseGenerator.GeneratorType) is
	begin
		if Icd.IsOn then
			-- read the heart rate from hrm
			HRM.GetRate(Hm, Icd.Rate);
			Put("Heart rate  = ");
			Put(Item => Icd.Rate);
			New_Line;
			if Icd.isTachycardia then
				-- if there is a Tachyardia detected calculate and set the impluse
				CalculateImpluse(Icd);
			end if;
			ImpulseGenerator.SetImpulse(Gen, Icd.Impulse);

		else
			--if icd is off return 0
			icd.Rate := Measures.BPM'First;
		end if;
	end Tick;
end ICD;
