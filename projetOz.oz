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
  

  fun {Duration Duration Partition}
     local FlatPartition = {PartitionTimedList Partition}
	LF = {List.flatten FlatPartition}
	Total
	fun{TotalDuration F}
	   local C ={NewCell 0.0} in
	      for E in F do
		 C := @C + E.duration
	      end
	      @C
	   end
	end
     in
	Total = {TotalDuration LF}
	if Total == 0 then
	   {Stretch 0 FlatPartition}
	else
	   {Stretch (Duration/Total) FlatPartition}
	end
	
     end
  end
  

  fun {Stretch Factor Partition}
     
    local  C = {NewCell nil} FlatPartition = {PartitionTimedList Partition} in
    
       local fun {StretchHelper Factor ExtendedNote}
		 if Factor == 0 then
		    note(duration : 0.0)
		 end

		local TempDict = {Record.toDictionary ExtendedNote} in
		   {Dictionary.exchange TempDict duration ExtendedNote.duration ExtendedNote.duration*Factor}
		   {Dictionary.toRecord note TempDict}
		end
	     end
	
       in
	for E in FlatPartition do
	   case E
	   of H|T then
	     local  TempList = {NewCell nil} in
	      for E1 in E do
		 TempList := {StretchHelper Factor E1}|@TempList
	      end
	     TempList := {Reverse @TempList}
	     C := @TempList|@C
	      
	     end
	   else
	      C := {StretchHelper Factor E}|@C
	   end
	end
	{Reverse @C}
     end
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


  local L in
     L = [a]
     {Browse {Stretch 0.0 L}}
  end
  
  