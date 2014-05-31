package body Measures is
   
   function Limit(Input : in Integer; Fst : in Integer; Lst : in Integer)
		 return Integer
   is
      Output : Integer;
   begin
      if Input < Fst then
	 Output := Fst;
      elsif Input > Lst then
	 Output := Lst;
      else
	 Output := Input;
      end if;
      
      return Output;
   end Limit;
   
   function LimitBPM(Input : in Integer) return BPM 
   is begin
      return Limit(Input, BPM'First, BPM'Last);
   end LimitBPM;
   
   function LimitJoules(Input : in Integer) return Joules
   is begin
      return Limit(Input, Joules'First, Joules'Last);
   end LimitJoules;

   function LimitTUB(Input : in Integer) return TUB
   is begin
      return Limit(Input, TUB'First, TUB'Last);
   end LimitTUB;

   function LimitFUB(Input : in Integer) return FUB
   is begin
      return Limit(Input, FUB'First, FUB'Last);
   end LimitFUB;
end Measures;

