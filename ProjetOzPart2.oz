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
       FlatPartition = {P2T Music}
       fun {MixHelper Note Index}
	  local
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
	     Height = {Int.toFloat (Numvalue - 10) + (( Note.octave - 4)*12)}
	     F = {Number.pow 2.0 Height/12.0}*440.0
	     (1.0/2.0)*{Float.sin (2.0*3.14159265359*F*Index/44100.0)}
	  end
       end
       fun {MixHelperBis Fpartition Index LS}
	  case Fpartition of nil then
	     {List.reverse LS}
	  [] H|T then
	     case H of K|L then
		{MixHelperBis T (Index + 1.0) {FoldR {MixHelperBis H Index LS} fun {$ X Y} X + Y end 0.0}|LS}
	     else
		skip
	     end
	  else	
	     {MixHelperBis Fpartition.2 (Index + 1.0) {MixHelper Fpartition.1 Index}|LS}
	  end
       end
    in
       {MixHelperBis FlatPartition 0.0 nil}
    end
 end
 
 

 
    

 local
    L = [a b c d#3 e]
 in
    {Browse {Mix PartitionTimedList L}}
 end


 


 
 












	     
	     
	     

	     
		
	  

