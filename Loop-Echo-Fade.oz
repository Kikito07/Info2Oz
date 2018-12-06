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


declare
fun {Mix P2T Music}
   local
      FlatPartition = {P2T Music}
      fun {MixHelper Note Index}
	 local
	    Numvalue
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
	    end
	    (1.0/2.0)*{Float.sin 2.0*3.14159865359 *({Number.pow 2.0 {Int.toFloat (Numvalue - 10) + (( Note.octave - 4)*12)}/12.0}*440.0)*Index/44100.0}
	 end
      end
      
      fun {MixBis FPartition I A}
	 case FPartition
	 of nil then {List.reverse A}
	 [] H|T then
	    case H
	    of K|L then {MixBis T I + 1.0 {FoldR {MixBis L I {MixHelper K I}} fun {$ X Y} X + Y end 0.0}|A}
	    else
	       {MixBis T I + 1.0 {MixHelper H I}|A}
	    end
	 end
      end
   in
      {MixBis FlatPartition 1.0 nil}
   end
end

      
      
      

      {Browse {MixHelper {NoteToExtended a} 1.0}}
    


{Browse {Mix PartitionTimedList [a b c]}}
{Browse {PartitionTimedList [a b c]}}


declare
fun{Reverse Music}
   {List.reverse {Mix P2T Music}}
end

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
fun {Merge MusicList}
   local 								     
      fun {Sum L1 L2 Ans}
	 if {And L1 == nil L2 == nil} then {Reverse  Ans}
	 elseif {And L1 \= nil L2 == nil} then {Sum L1.2 nil (L1.1|Ans)}
	 elseif {And L1 == nil L2 \= nil} then {Sum nil L2.2 (L2.1|Ans)}	   
	 else
	    {Sum L1.2 L2.2 (L1.1 + L2.1)|Ans}
	 end
      end
      fun {MergeHelper L Acc}
	 if L == nil then Acc
	 else
	    {MergeHelper L.2 {Sum {Map L.1.2 fun {$ X} X*L.1.1 end}  Acc nil}}
	 end
      end
   in
      {MergeHelper MusicList nil}
   end
end

local
   X = [3.0#[1.0 2.0 3.0] 4.0#[5.0 6.0] 3.0#[1.0 2.2 4.1 5.0]]
in
   {Browse {Merge X}}
end



declare
fun{Loop Duration Music}
   local
      TrueDuration = Duration*44100.0
      fun {LoopHelper TDuration Music FixedMusic A}
	 if TDuration =< 0.0 then A
	 elseif Music == nil then {LoopHelper (TDuration - 1.0) FixedMusic.2 FixedMusic FixedMusic.1|A}
	 else
	    {LoopHelper TDuration - 1.0 Music.2 FixedMusic Music.1|A}
	 end
      end
   in
      {LoopHelper TrueDuration Music Music nil}
   end
end

{Browse {Loop 10.0 [0.2 0.6 5.0 6.0 7.0]}}

end

declare
fun {Clip Low High Music}
   local
      fun{ClipHelper Low High L Acc}
	 if L == nil then {Reverse Acc}
	 elseif L.1 < Low then {ClipHelper Low High L.2 Low|Acc}
	 elseif L.1 > High then {ClipHelper Low High L.2 High|Acc}
	 else {ClipHelper Low High L.2 L.1|Acc}
	 end
      end
   in
      {ClipHelper Low High Music nil}
   end
end

{Browse {Clip ~0.5 0.5 [4.5 1.5 0.3 ~0.3 ~0.5]}}

local
declare
fun{Echo Duration Factor Music}
   local
      TrueDuration = Duration*44100.0
      fun{Silence Duration Acc}
	 if Duration =< 0.0 then Acc
	 else {Silence Duration-1.0 0.0|Acc}
	 end
      end
      
   in
      {Merge [Factor#Music 1.0#{Append {Silence TrueDuration nil} Music}]}
   end
end

declare
 fun{Silence Duration Acc}
	 if Duration =< 0.0 then Acc
	 else {Silence Duration-1.0 0.0|Acc}
	 end
 end

{Browse {Append {Silence 3.0 nil} [1.0 5.0 9.0]}}
{Browse {Echo 1.0 1.0 [1.0 5.0 9.0 2.0 1.0 1.2 1.3 1.4 1.5]}}

declare
fun {Fade Start Out Music}
   local
      TrueStart = Start*44100.0
      TrueOut = Out*44100.0
      
      fun {FadeHelper Start FixedSart Out Music A}
	 if {Length A} <= 0.0 then A
	 elseif {FadeHelper 1-1/FixedStart FixedSart Out Music.2 Music.1*} 
	    
end


declare
fun {Cut Start Finish Music}
   local
      fun {CutHelper Start Finish Music A}
	 if {Finish =< 0.0} then A
	 elseif Music == nil then {CutHelper Start-1.0 Finish-1.0 Music 0.0|A}	 
	 elseif Start >= 0.0 then {CutHelper Start-1.0 Finish-1.0 Music.2 A}
	 elseif {And Start < 0 Finish >0} then {CutHelper Start-1.0 Finish-1.0 Music.2 Music.1|A}
	 else
	    'problème'
	 end
      end
   in
      {CutHelper Start Finish Music nil}
   end
end


{Browse {Cut 0.0 1.0 [1.0 2.0]}}

   
   
	 
						 
	 
      TrueStart = Start*44100
      TrueFinish = Finish*44100
      Long = {List.length Music}
   in
      if(Long-TrueFinish + 1) < 0 then 
      else
	 {List.reverse {List.drop {List.reverse {List.drop Music TrueStart}} Long-TrueFinish+1}}
      end
   end
end


{Browse {Cut 3 8 [1 2 3 4 5 6 7 8 9 10]}}
   


	 

{Browse {Copie [[1.0 2.0 3.5 0.0 0.1] [2.2 3.3 4.4] [123.456 0.0 ~21.0]]}}

     
   



      
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
    
   fun {Mix P2T Music}
      {Cut 3 7 {Loop 10.0 {Project.readFile 'D:/unif/2018-2019/info2/ProjetOz/Info2Oz/wave/animals/monkey.wav'}}}
   end
   
in
   
   Music = {Project.load 'D:/unif/2018-2019/info2/ProjetOz/Info2Oz/joy.dj.oz'}
   {ForAll [NoteToExtended Music] Wait}
   {Browse {Project.run Mix PartitionToTimedList Music 'D:/unif/2018-2019/info2/ProjetOz/Info2Oz/test/out.wav'}}	 
end