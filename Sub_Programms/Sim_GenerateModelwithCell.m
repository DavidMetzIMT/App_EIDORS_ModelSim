function Sim_GenerateModelwithCell()
%
%
disp('Generate model with cell: Start')
disp('please wait ...')

global EIDORS
close all

fmdl = EIDORS.fmdl; %% buffer fmdl

if EIDORS.flag.AddcellinFEMmodel % rebuild fwd model with cell
    text='';
    switch EIDORS.flag.Object
        case 'Cell'
            for i=1:size(EIDORS.sim.cell,1)
                c=EIDORS.sim.cell(i);
                text= [text '\n\r ' 'solid cell_' num2str(i) ' = sphere(' num2str(c.PosX) ',' num2str(c.PosY) ',' num2str(c.PosZ) ';' num2str(c.Radius) ');\n\r ' 'tlo cell_' num2str(i) ';'];
            end
            fig_name='Foward Model with cell';
            
        case 'Cylinder'
            for i=1:size(EIDORS.sim.cell,1)
                c=EIDORS.sim.cell(i);
                text=['solid wall_cyc = cylinder (0,0,0; 0,0,1;' num2str(c.Radius) ');\n' ...
                    'solid top_cyc = plane(0,0,' num2str(EIDORS.chamber.body.depth/2-0.1) ';0,0,1);\n' ...
                    'solid bottom_cyc = plane(0,0,-' num2str(c.PosZ) ';0,0,-1);\n' ...
                    'solid mainobj_cyc = top_cyc and bottom_cyc and wall_cyc -maxh=' num2str( EIDORS.chamber.body.FEM_refinement/2) ';\n' 'tlo mainobj_cyc' ';\n']
            end
            fig_name= 'Foward Model with cylinder';
            
    end
    
    EIDORS.sim.netgenAdditionalText=text;
    create_fmdl(); % new fmdl in EIDORS.fmdl
    h= gcf;
    set(h,'Name',fig_name )
end

EIDORS.sim.fmdl = EIDORS.fmdl;
EIDORS.fmdl= fmdl; % end  Buffering

EIDORS.sim.fmdl.name = [fmdl.name '_wCell'];
EIDORS.sim.fmdl.stimulation=fmdl.stimulation; % Set solving parameters
EIDORS.sim.fmdl.meas_select = fmdl.meas_select;
EIDORS.sim.fmdl.solve=fmdl.solve;
EIDORS.sim.fmdl.jacobian=fmdl.jacobian;
EIDORS.sim.fmdl.system_mat=fmdl.system_mat;
EIDORS.sim.fmdl.misc.perm_sym=fmdl.misc.perm_sym;
EIDORS.sim.fmdl.get_all_meas=fmdl.get_all_meas;

%% Set homogenious conductivity
EIDORS.sim.img_h = mk_image(EIDORS.sim.fmdl, EIDORS.sim.bufferConduct);


%% Set inhomogenious conductivity

for i=1:size(EIDORS.sim.cell,1)
    c=EIDORS.sim.cell(i);
    switch EIDORS.flag.Object
        case 'Cell'
            select_cell = @(x,y,z) (x-c.PosX).^2 + (y-c.PosY).^2+(z-c.PosZ).^2 <= c.Radius^2;
            
        case 'Cylinder'
            select_cell = @(x,y,z) (x-c.PosX).^2 + (y-c.PosY).^2 <= (ones(size(y))*c.Radius).^2 & z>=c.PosZ;
    end
    cell_frac(:,i) = elem_select( EIDORS.sim.img_h.fwd_model, select_cell);
% select_rst = @(x,y,z) (x-c.PosX).^2 + (y-c.PosY).^2+(z-c.PosZ).^2 > c.Radius^2 ;
% layer_frac(:,i) = elem_select( EIDORS.sim.img_h.fwd_model, select_rst);%% do we really need this one???
end



if size(EIDORS.sim.cell,1)==0
    EIDORS.sim.img_ih=EIDORS.sim.img_h;
else
    c_is=sum(cell_frac>0,2);
%     l_is=sum(layer_frac>0,2);
    for i=1:size(cell_frac,1)
        if c_is(i)==0
            c_frac(i,1) =0;
        elseif c_is(i)==1
            c_frac(i,1) = sum(cell_frac(i,:));
        elseif c_is(i)>1
            c_frac(i,1) = 1;
        end
%         if sum(layer_frac(i,:),2)==size(layer_frac,2)
%             l_frac(i,1) =1;
%         else
%             l_frac(i,1) = 0;
%         end
    end
    
%     EIDORS.sim.img_ih = mk_image(EIDORS.sim.img_h, EIDORS.sim.bufferConduct + c_frac*(EIDORS.sim.cellConduct) + l_frac*(EIDORS.sim.layerConduct));
    EIDORS.sim.img_ih = mk_image(EIDORS.sim.img_h, EIDORS.sim.bufferConduct + c_frac*(EIDORS.sim.cellConduct-EIDORS.sim.bufferConduct));
end

%%  Make data for simulation

EIDORS.sim.img_h.fwd_solve.get_all_nodes=0;
EIDORS.sim.data_h = fwd_solve(EIDORS.sim.img_h);
EIDORS.sim.data_ih = fwd_solve(EIDORS.sim.img_ih);


%%Plot 3D images
figName= '3D Image of homogenious conductivity';
h= getCurrentFigure_with_figName(figName);
show_fem( EIDORS.sim.img_h, [1,1.012,0]);
if ~EIDORS.flag.displaymesh
    set(h,'EdgeColor','none');
end
figName= '3D Image of inhomogenious conductivity';
h= getCurrentFigure_with_figName(figName);
show_fem(EIDORS.sim.img_ih,[1,0,0]);
if ~EIDORS.flag.displaymesh
    set(h,'EdgeColor','none');
end
show_cell(h,EIDORS.sim.iimg.calc_slices.levels,1)
disp('Generate model with cell: Done!')


end 



