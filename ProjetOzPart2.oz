declare
  fun {NoteToExtended Note}
     case Note
     of note(name : Name octave : Octave sharp : Sharp duration:Duration instrument:Instrument) then
	note(name : Name octave : Octave sharp : Sharp duration:Duration instrument:Instrument)
     [] note(duration : 0.0) then
	note(duration : 0.0)
     [] Name#Octave then
	note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
     [] Atom then
	case {AtomToString Atom}
	of [_] then
	   note(name:Atom octave:4 sharp:false duration:1.0 instrument:none)
	[] [N O] then
	   note(name:{StringToAtom [N]} octave:{StringToInt [O]} sharp:false duration:1.0 instrument: none)
	[] "silence" then note(duration : 0.0)
	    
         end
      end
  end

  fun {ChordToExtended Chord}
     local C in
	C = {NewCell nil}
	for E in Chord do
	   C := {NoteToExtended E}|@C
	end
	C:= {Reverse @C}
	@C
     end
  end

 fun {PartitionTimedList Partition}
     local C in
	C = {NewCell nil}
	for E in Partition do
	   case E
	   of H|T then
	      C := {ChordToExtended E}|@C
	   else
	      C := {NoteToExtended E}|@C
	   end
	end
	C := {Reverse @C}
	@C
     end
  end


 fun {Mix P2T Music}
    local
      C = {NewCell 0}
      FlatPartiton = {PartitionTimedList Partition}
      SemitonesList = [C C# D D# E F F# G G# A A# B]
   in
      for E in FlatPartiton do
	 for F in SemitonesList do
	    C := @C+1
	    if E == F then
	       {List.Nth SemitonesList ((@C+Semitones) mod 12)}
	    end
	 end
      end
   end
end
    