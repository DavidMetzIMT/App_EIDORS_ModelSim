classdef InvModel

    properties
        name
        solve
        RtR_prior
        R_prior % provided if no RtR_prior
        hyperparameter
        jacobian_bkgnd
        meas_icov % optional
        reconst_type
        fwd_model FwdModel
    end
    
    properties (Access = private)
        type = 'inv_model'
    end

    methods 
        function obj = InvModel(obj,args)
            
        end
    end
    
    
end