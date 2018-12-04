declare
fun{Sum L M Ans}
   case L of nil then A
   [] H|T then
      case M of I|J then
	 {Sum T J {Append Ans H+I}}
      else
	 {Sum T nil {Append Ans H}}
      end
   else
      case M of I|J then
	 {Sum nil J {Append Ans I}}
      else
	 Ans
      end
   end
end
fun{Merge L A}
   local
      Answer
      fun{MergeHelper L Ans}
	 case L of nil then Ans
	 [] H|T then
	    case H of Intensitie#Music then
	       Answer = {Map A fun{$ X} Intensitie*X end}
	       {MergeHelper T {Sum Ans Answer nil}}
	    end
	 end
      end
   in
      {MergeHelper L nil}
   end
end

local
   A=[a b c d]
   L=[[f g] [a d e]]
in
   {Merge L A}
end

   


A={Mix P2T Music}