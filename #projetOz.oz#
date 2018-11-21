declare
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
	   of Name#Octave then
	      C := {NoteToExtended E}|@C
	   [] Atom then
	      C := {NoteToExtended E}|@C
	   end	
	end
	C := {Reverse @C}
	@C
     end
  end
  	      
{Browse {PartitionTimedList [a b c d e]}}


