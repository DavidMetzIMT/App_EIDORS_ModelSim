classdef TrainingDataGenerator
    %UNTITLED9 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties ( Access = public )
       Objects cellClass
       fmdl
       Buffer_conduct
       
       
    end
    
    
    methods
        
        function obj= TrainingDataGenerator()
            global EIDORS
            obj.Buffer_conduct= EIDORS.sim.bufferConduct
            
        end
        
        
       
        
    end
    
    
end

