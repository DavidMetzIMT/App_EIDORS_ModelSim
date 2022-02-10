classdef Eidors_data
    % Eidors_data describe the eit data 

    properties
        name
        time % Unix time
        meas
        configuration % optional
        fwd_model Eidors_fmdl % optional
    end
    
    properties (Access = private)
        type = 'data'
    end

    methods (MethodAttributes)
        function obj = methodName(obj,args)
            
        end
    end
    
end