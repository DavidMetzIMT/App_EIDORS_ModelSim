classdef AI_sample
    %data.Voltages(nMeas,nsamples,1:2); 1 for homogenious 2 for inhomogenious
        %      data.Conduct(nElems,nsamples,1:2);
    properties
        type  = 'ai_sample'; 
        Voltages
        Conduct
    end
    
    methods
        function obj = AI_sample(voltages, conduct)
            %AI_SAMPLES constructor 
            obj.Voltages= voltages;
            obj.Conduct= conduct;
            
        end
    end

end