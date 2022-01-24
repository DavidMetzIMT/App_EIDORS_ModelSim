function show_model(objModel, figName, displayMesh, show_colorbar, showElectrodesNo)
% 
%
% objModel should be an fwd_model or an image object from EIDORS

    if nargin == 1
        showElectrodesNo= 1.012;
    end

    show_colorbar= 1;



h=show_fem(iimg_plot, [0,show_number_elects_12pts,0]);
set(h,'EdgeColor','none');


    %% Display 
    
    getCurrentFigure_with_figName(figName);
    %% test if EIDORS.fmdl exist...
    h=show_fem( objModel, [0,1.012]);
    if ~displayMesh
        set(h,'EdgeColor','none');
    end
end