classdef Eidors_imdl < handle

    properties
        type = 'inv_model';
        name
        solve
        RtR_prior
        R_prior % provided if no RtR_prior
        hyperparameter
        jacobian_bkgnd
        meas_icov % optional
        reconst_type
        fwd_model
    end

    methods 
        function obj = Eidors_imdl(obj,args)
            obj.meas_icov='default_meas_icov';
            
        end

        function imdl4EIDORS = imdl(obj) % to EIDORS
            %Returns the present object as a structure for use in EIDORS

            imdl4EIDORS = struct(obj);
        end



        function set_inv_solver(obj, name, solve, RtR_prior, R_prior, hyper_value, hyper_func, hyper_params,jac_bkgnd_value, jac_bkgnd_func, reconst_type)
            %Set the solving part of the fwd_model
            obj.name= name;
            obj.solve= solve;
            obj.RtR_prior= str2func(RtR_prior);
            obj.R_prior= R_prior;

            hyperparameter.value= hyper_value;
            % hyperparameter.func=  hyper_func;
            % hyperparameter.parameters= hyper_params;
            obj.hyperparameter= hyperparameter;
            jacobian_bkgnd.value= jac_bkgnd_value;
            % jacobian_bkgnd.func= jac_bkgnd_func;
            obj.jacobian_bkgnd= jacobian_bkgnd;
            obj.reconst_type=reconst_type;
            

%             EIDORS.imdl.name = ['EIT inv_mdl for fwd_mdl: ' EIDORS.fmdl.name];
%             EIDORS.imdl.type = 'inv_model';
%             EIDORS.imdl.solve= EIDORS.sim.imdl_solve;
%             EIDORS.imdl.hyperparameter.value = EIDORS.sim.imdl_hyperparametervalue;
%             %     EIDORS.imdl.hyperparameter.func=EIDORS.sim.imdl_hyperparameterfunc;
%             %     EIDORS.imdl.hyperparameter.parameters= EIDORS.sim.imdl_hyperparameterparameters;
%             EIDORS.imdl.RtR_prior= EIDORS.sim.imdl_RtR_prior;
%             EIDORS.imdl.jacobian_bkgnd.value= EIDORS.sim.imdl_jacobian_bkgndvalue;
%             %     EIDORS.imdl.jacobian_bkgnd.func= EIDORS.sim.imdl_jacobian_bkgndfunc;
%             EIDORS.imdl.reconst_type= EIDORS.sim.imdl_reconst_type;
%             EIDORS.imdl.fwd_model = EIDORS.fmdl;
% disp('Create IMDL: Done')
        end

        function set_fwd_model(obj, fwd_model)

            arguments
                obj
                fwd_model Eidors_fmdl
            end

            obj.fwd_model=fwd_model.fmdl();
            
        end





    end
    
    
end