
NOT USED for the moment
classdef Eidors_data
    % Eidors_data describe the eit data


    properties
        type = 'data'
        name
        time % Unix time
        meas
        configuration % optional
        fwd_model Eidors_fmdl % optional
    end

    methods (MethodAttributes)
        function obj = methodName(obj,args)
            
        end
    end
    
end