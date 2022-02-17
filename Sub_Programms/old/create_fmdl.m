function fmdl = create_fmdl(eit_env)

arguments % argument validator
    eit_env EIT_env
end

fmdl = make_fwd_model_ngmkgenmodel();
%%

%% Set Solving Parameter fo Solving the forward model
fmdl.get_all_meas = 1;
% EIDORS.fmdl.coarse2fine=1;


end

