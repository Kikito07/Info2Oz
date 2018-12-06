local
   % See project statement for API details.
   [Project] = {Link ['Project2018.ozf']}
   Time = {Link ['x-oz://boot/Time']}.1.getReferenceTime

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Translate a note to the extended notation.
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
   
   fun {PartitionToTimedList Partition}
      local
	 fun {PartitionTimedListHelper Part L}
	    case Part
	    of nil then {List.reverse L}
	    [] H|T then case H
			of duration(seconds:Dur P) then {PartitionTimedListHelper Part.2 {Duration H.seconds H.1}|L}
		       [] stretch(factor:Factor P) then {PartitionTimedListHelper Part.2 {Stretch H.factor H.1}|L}
		       [] drone(note:NoteOrchord amount:Natural) then {PartitionTimedListHelper Part.2 {Drone H.note H.amount}|L}
		       [] transpose(semitones:Integer P) then {PartitionTimedListHelper Part.2 {Transpose H.semitones H.1}|L}
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
     local FlatPartition = {PartitionToTimedList Partition}
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
	   FlatPartition
	 else
	   {Stretch (Duration/Total) FlatPartition}
	 end
      end
   end
   
  fun {Stretch Factor Partition}
     local
	FlatPartition = {PartitionToTimedList Partition}
	F = fun {$ Note}
	       case Note of
		  note(duration:Duration) then
		  note(duration:0.0)
	       else
		  note(name:Note.name octave:Note.octave sharp:Note.sharp duration:Note.duration*Factor instrument:Note.instrument)
	       end
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
	FlatPartition = {PartitionToTimedList Partition}
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
		 case Note
		 of note(duration:Duration) then
		    note(duration:0.0)
		 else
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
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
  fun {Mix P2T Music}
     local
	fun{MixHelper2 P2T Music Acc}
	   case Music
	   of nil
	   then Acc
	   [] H|T
	      case H
	      of case K|L then
		    if {Float.is K} then {Clip ~1 1 H}|Acc
		    else {MixBis {P2T Partition} 1.0 nil}|Acc
		    end
		 end
	      [] wave(Filename) then {Wave Filename}|Acc
	      [] merge(Musics) then {Merge Musics}
	      [] reverse(Music) then {Reverse Music}
	      [] repeat(amount:Integer Music) then {Repeat Integer Music}
	      [] loop(seconds:Duration Music) then {Loop Duration Music}
	      [] clip(low:Low high:High Music) then {Clip Low High Music}
	      [] echo(delay:Duration decay:Factor Music) then {Echo Duration Factor Music]
	      [] fade(start:Dur1 out:Dur2 Music) then {Fade Dur1 Dur2 Music}
	      [] cut(start:D1 finish:D2 Music) then {Cut D1 D2 Music)
	      end
	   end
	end	 	 
	
	fun {MixHelper Note Index}
	   local
	      
	      Height
	      F
	      Numvalue
	   in
	      if Note.duration==0.0 then Numvalue = 0
	      elseif {And Note.name == c Note.sharp == false} then
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
	      if Numvalue == 0 then 0
	      else
		 
		 Height = {Int.toFloat (Numvalue - 10) + (( Note.octave - 4)*12)}
		 F = {Number.pow 2.0 Height/12.0}*440.0
		 (1.0/2.0)*{Float.sin (2.0*3.14159265359*F*Index/44100.0)}
	      end
	      
	   end
	end
	
	
	fun {MixBis FPartition I A}
	   case FPartition
	   of nil then {List.reverse A}
	   [] H|T then
	      case H
	      of K|L then {MixBis T (I + 1.0) {FoldR {MixBis L I {MixHelper K I}|nil} fun {$ X Y} X + Y end 0.0}|A}
	      else
		 {MixBis T (I + 1.0) {MixHelper H I}|A}
	      end
	   end
	end
     in
	{MixHelper2 P2T Music nil}
     end
  end
  
  fun{Reverse Music}
     {List.reverse {Mix P2T Music}}
  end
  
  fun{Repeat Amount Music}
     local
	Samples = {Mix P2T Music}
	fun {RepeatHelper X N L}
	   case N
	   of 0 then L
	   else
	      {RepeatHelper X N-1 {Append X L}}
	   end
	end
     in
	{RepeatHelper Samples Amount nil}
     end
  end
  
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
	      {MergeHelper L.2 {Sum {Map {Mix P2T L.1.2} fun {$ X} X*L.1.1 end}  Acc nil}}
	   end
	end
     in
	{MergeHelper MusicList nil}
     end
  end
  
  fun{Loop Duration Music}
     local
	Samples = {Mix P2T Music}
	TrueDuration = Duration*44100.0
	fun {LoopHelper TDuration Music FixedMusic A}
	   if TDuration =< 0.0 then A
	   elseif Music == nil then {LoopHelper (TDuration - 1.0) FixedMusic.2 FixedMusic FixedMusic.1|A}
	   else
	      {LoopHelper TDuration - 1.0 Music.2 FixedMusic Music.1|A}
	   end
	end
     in
	{LoopHelper TrueDuration Samples Samples nil}
     end
  end
  
  fun {Clip Low High Music}
     local
	Samples = {Mix P2T Music}
	fun{ClipHelper Low High L Acc}
	   if L == nil then {Reverse Acc}
	   elseif L.1 < Low then {ClipHelper Low High L.2 Low|Acc}
	   elseif L.1 > High then {ClipHelper Low High L.2 High|Acc}
	   else {ClipHelper Low High L.2 L.1|Acc}
	   end
	end
     in
	{ClipHelper Low High Samples nil}
     end
  end
  
  fun{Echo Duration Factor Music}
     local
	Samples = {Mix P2T Music}
	TrueDuration = Duration*44100.0
     in
	{Merge [Factor#Samples 1.0#{Append {Silence TrueDuration nil} Samples}]}
     end
  end
  
  fun {Silence Duration Acc}
     if Duration =< 0.0 then Acc
     else {Silence Duration-1.0 0.0|Acc}
     end
  end

 
  fun {Cut Start Finish Music}
     local
	Samples = {Mix P2T Music}
	TrueStart = Start*44100.0
	TrueFinish = Finish*44100.0
	fun{CutHelper S F Mus A}
	   if F =< 1.0 then {Reverse A}
	   elseif {And Mus == nil S >= 1.0} then {CutHelper S-1.0 F -1.0 Mus A}
	   elseif {And Mus == nil S =< 0.0} then {CutHelper S-1.0 F -1.0 Mus 0.0|A}
	   elseif S > 0.0 then {CutHelper S -1.0 F -1.0 Mus.2 A}
	   else {CutHelper S - 1.0 F - 1.0 Mus.2 Mus.1|A}
	   end
	end
     in
	{CutHelper TrueStart TrueFinish Samples nil}
     end
  end
  
fun {Fade Start Out Music}
   local
      Samples = {Mix P2T Music}
      TrueStart = Start*44100.0
      TrueOut = Out*44100.0
      S = {Cut 0.0 TrueStart + 1.0 Samples}
      M = {Cut TrueOut Out Samples}
      O = {Cut TrueOut-2.0 {Int.toFloat {Length Samples} + 1} Music}
      fun {FadeBis L X FixedStart A}
	 if L == nil then {Reverse A}
	 else
	    {FadeBis L.2 X+1.0/FixedStart FixedStart X*L.1|A}
	 end
      end
   in
      {Append {Append {FadeBis S 0.0 TrueStart nil} M} {Reverse {FadeBis O 0.0 TrueOut nil}}}  
   end
end
  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  Music = {Project.load 'joy.dj.oz'}
  Start
  
   % Uncomment next line to insert your tests.
   % \insert 'tests.oz'
   % !!! Remove this before submitting.
  in
  Start = {Time}
  
   % Uncomment next line to run your tests.
   % {Test Mix PartitionToTimedList}
  
   % Add variables to this list to avoid "local variable used only once"
   % warnings.
  {ForAll [NoteToExtended Music] Wait}
  
   % Calls your code, prints the result and outputs the result to `out.wav`.
   % You don't need to modify this.
  {Browse {Project.run Mix PartitionToTimedList Music 'out.wav'}}
  
   % Shows the total time to run your code.
  {Browse {IntToFloat {Time}-Start} / 1000.0}
  end
 