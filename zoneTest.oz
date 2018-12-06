declare
fun {Cut Start Finish Music}
   local
      fun{CutHelper S F Mus A}
	 if F =< 1.0 then {Reverse A}
	 elseif {And Mus == nil S > ~1.0} then {CutHelper S-1.0 F-1.0 Mus A}
	 elseif {And Mus == nil S < 0.0} then {CutHelper S-1.0 F -1.0 Mus 0.0|A}
	 elseif Mus == nil then {CutHelper S -1.0 F -1.0 Mus 0.0|A}
	 elseif S > 0.0 then {CutHelper S -1.0 F -1.0 Mus.2 A}
	 else {CutHelper S - 1.0 F - 1.0 Mus.2 Mus.1|A}
	 end
      end
   in
      {CutHelper Start Finish Music nil}
   end
end

{Browse {Cut 2.0 6.0 nil}}
	    
	    