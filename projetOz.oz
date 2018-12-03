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
   {List.map Chord NoteToExtended}
end

fun {ChordOrNoteToExtended ChordOrNote}
   case ChordOrNote of H|T then
      {ChordToExtended ChordOrNote}
   else
      {NoteToExtended ChordOrNote}
   end
end

fun {PartitionTimedList Partition}
   local
      fun {PartitionTimedListHelper Partition L}
	 if Partition == nil then {List.reverse L}
	 else
	    {PartitionTimedListHelper Partition.2 {ChordOrNoteToExtended Partition.1}|L}
	 end
      end
   in
      {PartitionTimedListHelper Partition nil}
   end
end

fun {Duration Duration Partition}
   local FlatPartition = {PartitionTimedList Partition}
      LF = {List.flatten FlatPartition}
      Total
      fun {TotalDuration L Sum}
	 case L
	 of nil then Sum
	 else {TotalDuration L.2 (Sum + L.1.duration)}
	 end
      end	 
   in
      Total = {TotalDuration LF 0.0}
      if Total == 0.0 then
	 {Stretch 0.0 FlatPartition}
      else
	 {Stretch (Duration/Total) FlatPartition}
      end
      
   end
end


fun {Stretch Factor Partition}
   local
      FlatPartition = {PartitionTimedList Partition}
      F = fun {$ Note}
	     note(name:Note.name octave:Note.octave sharp:Note.sharp duration:Note.duration*Factor instrument:Note.instrument)
	  end	  
      fun {StretchHelper Funct NoteL L}
	 case NoteL
	 of nil then {List.reverse L}
	 [] H|T then
	    case H of K|L then
	       {StretchHelper Factor NoteL.2 {List.map H Funct}|L}
	    else
	       {StretchHelper Factor NoteL.2 {Funct H}|L}
	    end
	 end
      end
   in
      {StretchHelper F FlatPartition nil}
   end
end

   
fun {Drone ChordOrNote Amount}
     local ExtendedChordOrNote
	C = {NewCell nil} in
	case ChordOrNote of H|T then
	   ExtendedChordOrNote = {ChordToExtended ChordOrNote}
	else
	   ExtendedChordOrNote = {NoteToExtended ChordOrNote}
	end
	for I in 1..Amount do
	   C := ExtendedChordOrNote|@C
     end
	@C
     end
end


fun {Transpose Semitones Partition}
   local
      FlatPartition = {PartitionTimedList Partition}
      L = {NewCell nil}
      F = fun {$ Note} {TransposeHelper Note Semitones} end	
      fun {TransposeHelper Note N}
	 local
	    fun{TransposeHelperHelper Note}
	       if {And Note.name == c Note.sharp == false} then
		  note(name:c octave:Note.octave sharp:true  duration:Note.duration instrument:Note.instrument)
	       elseif {And Note.name == c Note.sharp == true} then
		  note(name:d octave:Note.octave sharp:false  duration:Note.duration instrument:Note.instrument)
	       elseif {And Note.name == d Note.sharp == false} then
		  note(name:d octave:Note.octave sharp:true  duration:Note.duration instrument:Note.instrument)
	       elseif {And Note.name == d Note.sharp == true} then
		  note(name:e octave:Note.octave sharp:false  duration:Note.duration instrument:Note.instrument)	
	       elseif {And Note.name == e Note.sharp == false} then
		  note(name:f octave:Note.octave sharp:false  duration:Note.duration instrument:Note.instrument)	      
	       elseif {And Note.name == f Note.sharp == false} then
		    note(name:f octave:Note.octave sharp:true  duration:Note.duration instrument:Note.instrument)
	       elseif {And Note.name == f Note.sharp == true} then
		  note(name:g octave:Note.octave sharp:false  duration:Note.duration instrument:Note.instrument)
	       elseif {And Note.name == g Note.sharp == false} then
		  note(name:g octave:Note.octave sharp:true  duration:Note.duration instrument:Note.instrument)
	       elseif {And Note.name == g Note.sharp == true} then
		  note(name:a octave:Note.octave sharp:false  duration:Note.duration instrument:Note.instrument)
	       elseif {And Note.name == a Note.sharp == false} then
		  note(name:a octave:Note.octave sharp:true  duration:Note.duration instrument:Note.instrument)
	       elseif {And Note.name == a Note.sharp == true} then
		  note(name:b octave:Note.octave sharp:false  duration:Note.duration instrument:Note.instrument)
	       else
		  note(name:c octave:Note.octave+1 sharp:false  duration:Note.duration instrument:Note.instrument)
	     
	       end
	    end
	 in
	    if N==0 then Note
	    else
	       {TransposeHelper {TransposeHelperHelper Note} N-1}
	    end
	 end
      end
      
   in
      for E in FlatPartition do
	 case E
	 of H|T then
	    L := {List.map E  F}|@L
	 else
	    L := {F E}|@L
	 end
      end
      {List.reverse @L}
   end
end



local
   L = [[a b c d e] e#2]
in
   {Browse {Transpose 3 {PartitionTimedList L}}}
end


  
	      
	      
	
	   
	   
	
	