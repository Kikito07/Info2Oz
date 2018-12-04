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
	 case Partition of nil then {List.reverse L}
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
      fun {StretchHelper NoteL L}
	 case NoteL
	 of nil then {List.reverse L}
	 [] H|T then
	    case H of K|M then {StretchHelper T {StretchHelper M {F K}|nil}|L}
	    else
	       {StretchHelper T {F H}|L}
	    end
	 end
      end
   in
      {StretchHelper FlatPartition nil}
   end
end


fun {Drone ChordOrNote Amount}
   local
      CNExtended = {ChordOrNoteToExtended ChordOrNote}
      fun {DroneBis X N L}
	 case N
	 of 0 then L
	 else
	    {DroneBis X N - 1 (X|L)}
	 end
      end
   in
      {DroneBis CNExtended Amount nil}
   end   
end


fun {Transpose Semitones Partition}
   local
      FlatPartition = {PartitionTimedList Partition}
      fun {TransposeBis Semitones FlatP L}
	 case FlatP
	 of nil then {List.reverse L}
	 [] H|T then
	    case H of K|L then
	       {TransposeBis Semitones T {List.map H fun {$ X} {TransposeHelper Semitones X} end}|List}
	    else
	       {TransposeBis Semitones T {TransposeHelper Semitones H}|List}
	    end
	 else
	    1
	 end
      end
      fun {TransposeHelper N Note}
	 local
	    fun{TransposeHelperBis Note}
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
	       {TransposeHelper N-1 {TransposeHelperBis Note}}
	    end
	 end
      end
   in
      {TransposeBis Semitones FlatPartition nil}
   end
end

      

local
   L =[[g b c d] a [e f g]]
in
   {Browse {Stretch 2.0 L}}
end


{Browse {PartitionTimedList [[k l m n] g [a b c d]]}}
local
   Factor = 5.0
   L = {PartitionTimedList [a b c d e]}
   F = fun {$ Note}
	  note(name:Note.name octave:Note.octave sharp:Note.sharp duration:Note.duration*Factor instrument:Note.instrument)
       end
in
   {Browse ({List.map L F})}
end


   {Browse [a b c]|[g e f]|a|[i k j]|nil}

{Browse {List.is [a b].2}}    
	
	   
	   
	
	