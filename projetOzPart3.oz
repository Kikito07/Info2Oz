
fun {Wave FileName}
   {Project.readFile 'FileName'}
end

fun {Merge L}
   local
      Length
      fun {LengthCounter L MaxLength}
	 case L of nil then MaxLength
	 [] H|T then
	    {LengthCounter T {Max {List.length H} MaxLength}}
	 end
      end
      fun{MergeHelper L Length Ans}
	 case Length of 0 then Ans
	 [] H|T then
	    case H of nil then 
	    {MergeHelper H Length-1}
	   
   in
      Length = {LengthCounter L 0}
      
      
      
      
      
      
      

      
      
	 
 




local
   [Project] = {Link ['D:/unif/2018-2019/info2/ProjetOz/Info2Oz/Project2018.ozf']}

in
   {Browse {Project.readFile 'D:/unif/2018-2019/info2/ProjetOz/Info2Oz/wave/animals/cow.wav'}}
end








   