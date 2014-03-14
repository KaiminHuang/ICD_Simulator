with Ada.Text_IO; use Ada.Text_IO;

-- this package implements the functionality of 
-- the on mode of the system. That is, it provides 
-- the necessary calculations of the 
-- impulse based on the measured heart rate.
Package ICD is

	-- The record type for a ICD 
	type ICDType is
		record
			UpperBound 	: Integer; -- Setting the upper bound for a tachycardia
			IsOn 		: Boolean; -- Indeicates whether ICD is on
		end record;
		
	-- Create and initialise a HRM.
	procedure Init(Hrm :in Heart.HeartType);
