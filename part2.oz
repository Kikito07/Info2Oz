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
      fun {PartitionTimedListHelper Part L}
	 case Part
	 of nil then {List.reverse L}
	 [] H|T then case H
		     of duration(seconds:Dur P) then {PartitionTimedListHelper Part.2 {Duration H.seconds H.1}|L}
		     [] stretch(factor:Factor P) then {PartitionTimedListHelper Part.2 {Stretch H.factor H.1}|L}
		     [] drone(note:NoteOrchord amount:Natural) then {PartitionTimedListHelper Part.2 {Drone H.note H.amount}|L}
		     []	transpose(semitones:Integer P) then {PartitionTimedListHelper Part.2 {Transpose H.semitones H.1}|L}
		     else {PartitionTimedListHelper Part.2 {ChordOrNoteToExtended Part.1}|L}
		     end
	 else 'You re not supposed to be here'
	 
	 end
      end
   in
      {PartitionTimedListHelper Partition nil}
   end
end


fun {Duration Duration Partition}
   local FlatPartition = {PartitionTimedList Partition}
      Total
      fun {TotalDuration L Sum}
	 case L
	 of nil then Sum
	 [] H|T then
	    case H
	    of K|L then {TotalDuration L.2 (Sum + K.duration)}
	    else
	       {TotalDuration L.2 (Sum + L.1.duration)}
	    end
	 end
      end	 
   in
      Total = {TotalDuration FlatPartition 0.0}
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
	 of nil then {Reverse L}
	 [] H|T then
	    case H of K|M then
	       {TransposeBis Semitones T {TransposeBis Semitones M {TransposeHelper Semitones K}|nil}|L}
	    else
	       {TransposeBis Semitones T {TransposeHelper Semitones H}|L}
	    end
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



fun {Mix P2T Music}
   local
      FlatPartition = {P2T Music}
      fun {MixHelper Note Index L}
	 local
	    Length = Note.duration*44100.0
	    Numvalue
	    Height
	    F
	 in
	    if {And Note.name == c Note.sharp == false} then
	       Numvalue = 1
	    elseif {And Note.name == c Note.sharp == true} then
	       Numvalue = 2
	    elseif {And Note.name == d Note.sharp == false} then
	       Numvalue = 3
	    elseif {And Note.name == d Note.sharp == true} then
	       Numvalue = 4
	    elseif {And Note.name == e Note.sharp == false} then
	       Numvalue = 5
	    elseif {And Note.name == f Note.sharp == false} then
	       Numvalue = 6
	    elseif {And Note.name == f Note.sharp == true} then
	       Numvalue = 7
	    elseif {And Note.name == g Note.sharp == false} then
	       Numvalue = 8
	    elseif {And Note.name == g Note.sharp == true} then
	       Numvalue = 9
	    elseif {And Note.name == a Note.sharp == false} then
	       Numvalue = 10
	    elseif {And Note.name == a Note.sharp == true} then
	       Numvalue = 11
	    elseif {And Note.name == b Note.sharp == false} then
	       Numvalue = 12
	    else
	       skip
	    end
	    
	    if Index > Length then L
	    else
	       {MixHelper Note Index+1 (1.0/2.0)*{Float.sin (2.0*3.14159265359*{Number.pow 2.0 {Int.toFloat (Numvalue - 10) + (( Note.octave - 4)*12)}/12.0}*440.0*Index/44100.0)}|L}
	    end
	 end
      end
      
      fun {MixHelperBis Fpartition Index LS}
	 case Fpartition of nil then
	    {List.reverse LS}
	 [] H|T then
	    case H of K|L then
	       {MixHelperBis T (Index + 1.0) {FoldR {MixHelperBis L Index {MisHelper K}|nil} fun {$ X Y} X + Y end 0.0}|LS}
	    end
	 else	
	    {MixHelperBis Fpartition.2 (Index + 1.0) {MixHelper Fpartition.1 Index}|LS}
	 end
      end
   in
      {MixHelperBis FlatPartition 0.0 nil}
   end
end






declare
fun{Reverse Music}
   {Reverse {Mix P2T Music}}
end

declare
fun{Repeat Amount Music}
   local
      fun {RepeatHelper X N L}
	 case N
	 of 0 then L
	 else
	    {RepeatHelper X N-1 {Append X L}}
	 end
      end
   in
      {RepeatHelper Music Amount nil}
   end
end

declare
fun {Merge L}
   local
      fun {Sum L1 L2 Ans}
	 if {And L1 == nil L2 == nil} then {Reverse Ans}
	 elseif {And L1 \= nil L2 == nil} then {Sum L1.2 nil (L1.1|Ans)}
	 elseif {And L1 == nil L2 \= nil} then {Sum nil L2.2 (L2.1|Ans)}	   
	 else
	    {Sum L1.2 L2.2 (L1.1 + L2.1)|Ans}
	 end
      end
      
      fun {MergeHelper L Acc}
	 if L == nil then Acc
	 else
	    {MergeHelper L.2 {Sum Acc {Map L.1.2 fun {$ X} X*L.1.1 end} nil}}
	 end
      end
   in
      {MergeHelper L nil}
   end
end

declare
fun{Loop Duration Music}
   local
      fun {LoopHelper Duration Music Acc}
	 local
	    Samples = Music
	 in 
	    if {And Music == nil Duration < 0.0} then {Reverse Acc.2}
	    elseif {And Music == nil Duration \= 0.0} then {LoopHelper Duration-{Int.toFloat {Length Samples.1}}/44100.0 Samples.2 Samples.1|Acc}
	    else {LoopHelper Duration-{Int.toFloat {Length Music.1}}/44100.0 Music.2 Music.1|Acc}
	    end
	 end
      end
   in
      {LoopHelper Duration Music nil}
   end
end





local
   Music
   [Project] = {Link ['D:/unif/2018-2019/info2/ProjetOz/Info2Oz/Project2018.ozf']}
   fun{PartitionToTimedList}
   0
   end
   fun {NoteToExtended Note}
      case Note
      of Name#Octave then
	 note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
      [] Atom then
	 case {AtomToString Atom}
	 of [_] then
	    note(name:Atom octave:4 sharp:false duration:1.0 instrument:none)
	 [] [N O] then
	    note(name:{StringToAtom [N]}
		 octave:{StringToInt [O]}
		 sharp:false
		 duration:1.0
		 instrument: none)
	    
	 end
      end
   end
   
   fun {Loop Duration Music}
      local
	 fun {LoopHelper Duration Music Acc}
	    local
	       Samples = Music
	    in 
	       if Duration < 0.0 then {Reverse Acc.2}
	       elseif Music == nil then {LoopHelper Duration-{Int.toFloat {Length Samples.1}} Samples.2 Samples.1|Acc}
	       else {LoopHelper Duration-{Int.toFloat {Length Music.1}} Music.2 Music.1|Acc}
	       end
	    end
	 end
      in
	 {LoopHelper Duration Music nil}
      end
   end
   
   fun {Mix P2T Music}
      {Repeat 10 {Project.readFile 'D:/unif/2018-2019/info2/ProjetOz/Info2Oz/wave/animals/owl.wav'}}
   end
   
in
   Music = {Project.load 'D:/unif/2018-2019/info2/ProjetOz/Info2Oz/joy.dj.oz'}
   {ForAll [NoteToExtended Music] Wait}
   {Browse {Project.run Mix PartitionToTimedList Music 'D:/unif/2018-2019/info2/ProjetOz/Info2Oz/test/out.wav'}}	 
end
