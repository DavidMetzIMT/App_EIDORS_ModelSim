classdef EIT_pattern
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        injAmplitude
        injType % ad, op,....
        injSpecial %some types need some special infos
        measType % ad, op,....
        measSpecial %some types need some special infos
        patternOption % patterning function can accept some options
        patternFunc % patterning function maybe handle?
    end
    
    methods
        function obj = EIT_pattern(obj,injAmplitude, injType, injSpecial, measType, measSpecial,patternOption,patternFunc )
            
        end

    end
end
