classdef Data

    properties
        name
        time % Unix time
        meas
        configuration % optional
        fwd_model FwdModel % optional
    end
    
    properties (Access = private)
        type = 'data'
    end
    
end