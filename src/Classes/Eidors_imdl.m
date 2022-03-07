classdef Eidors_imdl < handle
    % EIDORS_IMDL Class version of the Eidors inv_model object

    properties
        type = 'inv_model'  
        name % name if the inverse model
        solve % solver of the inverse model
        RtR_prior % RtR_prior of the inverse model (for the solver)
        R_prior % R_prior of the inverse model, provided if no RtR_prior (for the solver)
        hyperparameter % hyperparameter of the inverse model (for the solver)
        jacobian_bkgnd % jacobian background of the inverse model (for the solver)
        meas_icov % optional
        reconst_type % reconstruction type (difference, static/absolute)
        fwd_model % associated forward model object from EIDORS
    end

    methods 
        function obj = Eidors_imdl(obj)
            %EIDORS_IMDL Constructor set default values
            obj.name                = 'imdl_defaulft_name';
            obj.solve               = 'eidors_default';
            obj.RtR_prior           = 'eidors_default';
            obj.R_prior             = ''; % provided if no RtR_prior
            hyperparameter.value = 0.01;
            obj.hyperparameter      = hyperparameter;
            jacobian_bkgnd.value= 1;
            obj.jacobian_bkgnd      = jacobian_bkgnd;
            obj.meas_icov           ='default_meas_icov';
            obj.reconst_type        ='difference';
            % obj.fwd_model
        end

        function imdl4EIDORS = imdl(obj)
            %IMDL Return itself as a structure for use in EIDORS Toolbox
            imdl4EIDORS = struct(obj);
        end

        function set_inv_solver(obj, name, solve, RtR_prior, R_prior, hyper_value, hyper_func, hyper_params,jac_bkgnd_value, jac_bkgnd_func, reconst_type)
            %SET_INV_SOLVER Set the inverse solver parameters
            obj.name= name;
            obj.solve= solve;
            obj.RtR_prior= RtR_prior;
            obj.R_prior= R_prior;
            hyperparameter.value= hyper_value;
            % hyperparameter.func=  hyper_func;
            % hyperparameter.parameters= hyper_params;
            obj.hyperparameter= hyperparameter;
            jacobian_bkgnd.value= jac_bkgnd_value;
            % jacobian_bkgnd.func= jac_bkgnd_func;
            obj.jacobian_bkgnd= jacobian_bkgnd;
            obj.reconst_type=reconst_type;
        end

        function set.fwd_model(obj, fwd_model)
            %SETTER of fwd_model
            %   if fwd_model can be an obj from the class "Eidors_fmdl" or 
            %   an fwd_model object from EIDORS toolbox 
            if  isa(fwd_model,'Eidors_fmdl')
                fwd_model=fwd_model.fmdl();
            end

            if valid_fwd_model(fwd_model)
                obj.fwd_model=fwd_model;
            else
                disp('ERROR TYPE: fwd_model should be an "Eidors_fmdl" or an EIDORS "fwd_model" object')
            end
            
        end





    end
    
    
end