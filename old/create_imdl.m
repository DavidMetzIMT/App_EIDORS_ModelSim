function create_imdl()

global EIDORS
disp('Create IMDL: Start')
EIDORS.imdl.name = ['EIT inv_mdl for fwd_mdl: ' EIDORS.fmdl.name];
EIDORS.imdl.type = 'inv_model';
EIDORS.imdl.solve= EIDORS.sim.imdl_solve;
EIDORS.imdl.hyperparameter.value = EIDORS.sim.imdl_hyperparametervalue;
%     EIDORS.imdl.hyperparameter.func=EIDORS.sim.imdl_hyperparameterfunc;
%     EIDORS.imdl.hyperparameter.parameters= EIDORS.sim.imdl_hyperparameterparameters;
EIDORS.imdl.RtR_prior= EIDORS.sim.imdl_RtR_prior;
EIDORS.imdl.jacobian_bkgnd.value= EIDORS.sim.imdl_jacobian_bkgndvalue;
%     EIDORS.imdl.jacobian_bkgnd.func= EIDORS.sim.imdl_jacobian_bkgndfunc;
EIDORS.imdl.reconst_type= EIDORS.sim.imdl_reconst_type;
EIDORS.imdl.fwd_model = EIDORS.fmdl;
disp('Create IMDL: Done')
end
