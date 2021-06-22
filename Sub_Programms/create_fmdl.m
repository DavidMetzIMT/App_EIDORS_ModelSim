function create_fmdl()

global EIDORS

if EIDORS.flag.redraw==0   
    name= EIDORS.fmdl.name;
    switch EIDORS.flag.fmdlGenerationFunction
        case 1
            EIDORS.fmdl = make_fwd_model_ngmkgenmodel();
        otherwise
            return
    end
    EIDORS.fmdl.name = name;
else
    EIDORS.flag.redraw=0;
end
%% Display 
figName= 'Forward Model';
getCurrentFigure_with_figName(figName);
%% test if EIDORS.fmdl exist...
h=show_fem( EIDORS.fmdl, [0,1.012]);
if ~EIDORS.flag.displaymesh
    set(h,'EdgeColor','none');
end
%%
% [EIDORS.meshQuality.Q, EIDORS.meshQuality.MDL] = calc_mesh_quality_Yue(EIDORS.fmdl,EIDORS.flag.showMeshQuality);
%% Set Solving Parameter fo Solving the forward model
EIDORS.fmdl.solve=EIDORS.sim.fmdl_solve;
EIDORS.fmdl.jacobian=EIDORS.sim.fmdl_jacobian;
EIDORS.fmdl.system_mat=EIDORS.sim.fmdl_system_mat;
EIDORS.fmdl.misc.perm_sym=EIDORS.sim.fmdl_miscperm_sym;
EIDORS.fmdl.get_all_meas = 1;
% EIDORS.fmdl.coarse2fine=1;





end

