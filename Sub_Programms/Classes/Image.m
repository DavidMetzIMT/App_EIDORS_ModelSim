classdef Image

    properties
        name
        elem_data
        fwd_model FwdModel
    end
    
    properties (Access = private)
        type = 'image'
    end

    
    
end