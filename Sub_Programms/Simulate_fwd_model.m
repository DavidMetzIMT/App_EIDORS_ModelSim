function Simulate_fwd_model()
global EIDORS
close all
name=EIDORS.fmdl.name;

%% Simulation
if EIDORS.flag.redraw==0
    %% make inv_model
    disp('Simulation: create imdl')
    disp('please wait ...')
    create_imdl()
    disp('Simulation: imdl created!')
    %% make inv model for sim
    EIDORS.sim.imdl= EIDORS.imdl;
    EIDORS.sim.imdl.name = ['EIT inv_mdl for fwd_mdl: ' EIDORS.sim.fmdl.name];
    EIDORS.sim.imdl.fwd_model = EIDORS.sim.fmdl;
    
    disp('Simulation: Start')
    disp('please wait ...')
    
    EIDORS.sim.iimg = inv_solve(EIDORS.sim.imdl, EIDORS.sim.data_h,EIDORS.sim.data_ih);
    
    disp('Simulation: Done!')
else
    EIDORS.flag.redraw=0;
end

figName= '3D Image of resolved inverse Problem';
h= getCurrentFigure_with_figName(figName);
EIDORS.sim.iimg.fwd_model.show_fem.alpha_inhomogeneities=EIDORS.sim.transparency;
h=show_fem(EIDORS.sim.iimg,[1,0,0]);
show_cell(h,EIDORS.sim.iimg.calc_slices.levels,1)
% set(h,'EdgeColor','none');

for i= 1:size(EIDORS.sim.levels,1)
    EIDORS.sim.iimg.calc_slices.levels= EIDORS.sim.levels(i,:);
    param=eval_GREIT_fig_merit(EIDORS.sim.iimg, [[EIDORS.sim.cell(:).PosX]; [EIDORS.sim.cell(:).PosY]; [EIDORS.sim.cell(:).PosZ]; [EIDORS.sim.cell(:).Radius]]);
    figName= sprintf('Slice x = %d , y = %d , z = %d', EIDORS.sim.iimg.calc_slices.levels);
    h= getCurrentFigure_with_figName(figName);
    h=show_slices(EIDORS.sim.iimg,EIDORS.sim.iimg.calc_slices.levels);
    show_cell(h,EIDORS.sim.iimg.calc_slices.levels,0)
    title(sprintf('Amplitude: %0.3d, Pos Error: %0.3d Res: %0.3d, Shape: %0.3d, Ringing: %0.3d', param'));
    
    param=param';
    EIDORS.sim.GREIT(i,1).AmpR=param(:,1);
    EIDORS.sim.GREIT(i,1).PosError=param(:,2);
    EIDORS.sim.GREIT(i,1).Res=param(:,3);
    EIDORS.sim.GREIT(i,1).ShapeDef=param(:,4);
    EIDORS.sim.GREIT(i,1).Ringing=param(:,5);
    
    EIDORS.sim.RES_Yue=calc_Res_Yue();
    end
end

function Res_Yue=calc_Res_Yue()
global EIDORS
GREIT=EIDORS.sim.GREIT;
A1=pi*(EIDORS.chamber.body.diameter_length/2)^2;
A3=pi*(EIDORS.sim.cell.Radius^2);
for i=1:length(EIDORS.sim.GREIT)
    
Res_Yue(i)=GREIT(i).Res*sqrt(A1/A3);

end
end
