function fmdl = create_fmdl(name, chamber)

arguments % argument validator
    name string
    chamber EitData 
end

fmdl = make_fwd_model_ngmkgenmodel();
fmdl.name = name;
%%

%% Set Solving Parameter fo Solving the forward model
fmdl.solve=EIDORS.sim.fmdl_solve;
fmdl.jacobian=EIDORS.sim.fmdl_jacobian;
fmdl.system_mat=EIDORS.sim.fmdl_system_mat;
fmdl.misc.perm_sym=EIDORS.sim.fmdl_miscperm_sym;
fmdl.get_all_meas = 1;
% EIDORS.fmdl.coarse2fine=1;


end

