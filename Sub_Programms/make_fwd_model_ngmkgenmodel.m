function fmdl = make_fwd_model_ngmkgenmodel()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
global EIDORS



DoNotGenerate=0;

%% Use "ng_mk_gen_models"
% EIDORS.chamber.body Shape
b_radius_str = num2str(EIDORS.chamber.body.diameter_length/2);
b_radius_cham=EIDORS.chamber.body.diameter_length/2;
b_length_str = num2str(EIDORS.chamber.body.diameter_length/2);
b_depth_str = num2str(EIDORS.chamber.body.depth/2);
b_height_str = num2str(EIDORS.chamber.body.height/2); %mit height_cyl=2 & maxh=0.2 scheint es probleme zu geben, nur zur Info!
maxh_str = num2str( EIDORS.chamber.body.FEM_refinement);

switch EIDORS.chamber.body.typ
    case 'Cylinder'
        shape_str = [['solid wall    = cylinder (0,0,0; 0,0,1;' b_radius_str '); \n'], ...
            'solid top    = plane(0,0,' b_height_str ';0,0,1);\n' ...
            'solid bottom = plane(0,0,-' b_height_str ';0,0,-1);\n' ...
            'solid mainobj= top and bottom and wall -maxh=' maxh_str ';\n'];
    case 'Cubic'
        shape_str = [['solid wall    =     plane (-' b_length_str ',-' b_depth_str ',-' b_height_str '; 0,-1,0)' ...
            'and plane (-' b_length_str ',-' b_depth_str ',-' b_height_str '; -1,0,0)'...
            'and plane (' b_length_str ',' b_depth_str ',' b_height_str '; 0,1,0)'...
            'and plane (' b_length_str ',' b_depth_str ',' b_height_str '; 1,0,0); \n'], ...
            'solid top    = plane(' b_length_str ',' b_depth_str ',' b_height_str ';0,0,1);\n' ...
            'solid bottom = plane(-' b_length_str ',-' b_depth_str ',-' b_height_str ';0,0,-1);\n' ...
            'solid mainobj= top and bottom and wall -maxh=' maxh_str ';\n'];
    case '2D_Circ'
        cyl_shape = [0, EIDORS.chamber.body.diameter_length/2, EIDORS.chamber.body.FEM_refinement];
        
             
        
        
        
    otherwise error('shouldn''t come here')
end


%% Electrodes

alpha = 0;

for i= 1:size(EIDORS.chamber.electrode,1) % sets of electrodes
    
    nb_elecs= EIDORS.chamber.electrode(i).Number;
    
    Radius_elecs= EIDORS.chamber.electrode(i).Diameter_Width/2;
    Z_height = EIDORS.chamber.body.height/2;
    
    
    if ~mod(nb_elecs,1)==0 % by
        nb_elecs = [round(nb_elecs-mod(nb_elecs,1)) round(mod(nb_elecs,1)*100)];
    end
    
    switch EIDORS.chamber.electrode(i).Design
        case 'Ring'
            theta = linspace(0, 2*pi, nb_elecs + 1)';
            theta(end) = [];
            nb_elecs= nb_elecs(1); % only one number
            switch EIDORS.chamber.electrode(i).Position
                case 'Wall'
                    if strcmp(EIDORS.chamber.body.typ,'Cylinder') || strcmp(EIDORS.chamber.body.typ,'2D_Circ')
                        Radius_Ring = EIDORS.chamber.body.diameter_length/2;
                        elec_set(i).obj = 'wall';
                        x=Radius_Ring*cos(theta);
                        y=Radius_Ring*sin(theta);
                        z=0*ones(nb_elecs,1);
                        nx=cos(theta);
                        ny=sin(theta);
                        nz=0*ones(nb_elecs,1);
                        elec_pos_2D=[nb_elecs,1];
                        if (2*pi*b_radius_cham)<=(2*asin(Radius_elecs/b_radius_cham)*b_radius_cham*nb_elecs)
                            msgbox('Forward Model not Generated: Too big or too much electrode... incompatible with Chamber diameter')
                            DoNotGenerate=1;
                        end
                    
                    else
                        
                        msgbox('Forward Model not Generated: Chamber_typ and Design electrode incompatible')
                        DoNotGenerate=1;
                    end
                case 'Top'
                    Radius_Ring = EIDORS.chamber.electrode(i).Diameter/2;
                    elec_set(i).obj = 'top';
                    x=Radius_Ring*cos(theta);
                    y=Radius_Ring*sin(theta);
                    z=Z_height*ones(nb_elecs,1);
                    nx=0*ones(nb_elecs,1);
                    ny=0*ones(nb_elecs,1);
                    nz=-ones(nb_elecs,1);
                    if (b_radius_cham)<(Radius_elecs+Radius_Ring)
                        msgbox('Forward Model not Generated: Too big electrode diame te... incompatible with Chamber diameter and ring diameter')
                        DoNotGenerate=1;
                    end
                    if (2*pi*Radius_Ring)<=(2*asin(Radius_elecs/Radius_Ring)*Radius_Ring*nb_elecs)% not exactly the reigt arclength...
                        msgbox('Forward Model not Generated: Too big electrode diame te... incompatible with Chamber diameter and ring diameter')
                        DoNotGenerate=1;
                    end
                case 'Bottom'
                    Radius_Ring = EIDORS.chamber.electrode(i).Diameter/2;
                    elec_set(i).obj = 'bottom';
                    x=Radius_Ring*cos(theta);
                    y=Radius_Ring*sin(theta);
                    z=-Z_height*ones(nb_elecs,1);
                    nx=0*ones(nb_elecs,1);
                    ny=0*ones(nb_elecs,1);
                    nz=ones(nb_elecs,1);
                    if (b_radius_cham)<(Radius_elecs+Radius_Ring)
                        msgbox('Forward Model not Generated: Too big electrode diame te... incompatible with Chamber diameter and ring diameter')
                        DoNotGenerate=1;
                    end
                    if (2*pi*Radius_Ring)<=(2*asin(Radius_elecs/Radius_Ring)*Radius_Ring*nb_elecs)% not exactly the reigt arclength...
                        msgbox('Forward Model not Generated: Too big electrode diame te... incompatible with Chamber diameter and ring diameter')
                        DoNotGenerate=1;
                    end
                otherwise
                    msgbox('Forward Model not Generated: Electrode position/design combination not implemented/incompatible')
                    DoNotGenerate=1;
            end
            
        case {'Array_PolkaDot 0', 'Array_PolkaDot 45'}
            % only 13 electrodes....
            if size(nb_elecs,2)==2
                if (sum(mod(nb_elecs,2))==0)
                    errordlg('please give only uneven number of electrodes for Array_PolkaDot ')
                else
                    d = EIDORS.chamber.electrode(i).Diameter;
                    ratio=nb_elecs(1)/nb_elecs(2);
                    Width_grid = [sqrt(d^2/(1+1/ratio^2)) sqrt(d^2/(1+ratio^2))];
                    for xy=1:2
                        switch nb_elecs(xy)
                            case 1
                                vector(xy).v= 0;
                            case 2
                                vector(xy).v=[-Width_grid(xy)/2 Width_grid(xy)/2];
                            otherwise
                                vector(xy).v=linspace(-Width_grid(xy)/2,Width_grid(xy)/2,nb_elecs(xy));
                        end
                    end
                    [x,y] = meshgrid(vector(1).v,vector(2).v);
                end
            else
                if ~(nb_elecs==13)
                    warndlg('number of electrodes set to 13 ')
                    nb_elecs=13;
                end
                EIDORS.chamber.electrode(i).Number=nb_elecs;
                Width_grid = EIDORS.chamber.electrode(i).Diameter/sqrt(2);
                [x,y] = meshgrid(linspace( -Width_grid/2,Width_grid/2,5));
            end
            
            x=x(1:2:end);
            y=y(1:2:end);
            nb_elecs= max(size(x(:)));
            
            z=Z_height*ones(nb_elecs,1);
            nx=0*ones(nb_elecs,1);
            ny=0*ones(nb_elecs,1);
            nz=-ones(nb_elecs,1);
            switch EIDORS.chamber.electrode(i).Position
                case 'Top'
                    elec_set(i).obj = 'top';
                case 'Bottom'
                    % only 13 electrodes....
                    elec_set(i).obj = 'bottom';
                    z=-z;
                    nz=-nz;
                otherwise
                    msgbox('Forward Model not Generated: Electrode position/design combination not implemented/incompatible')
                    DoNotGenerate=1;
            end
            if contains(EIDORS.chamber.electrode(i).Design,'45')
                alpha = pi/4;
            end
            
        case {'Array_Grid 0', 'Array_Grid 45'}
            if size(nb_elecs,2)==2
                d = EIDORS.chamber.electrode(i).Diameter;
                ratio=nb_elecs(1)/nb_elecs(2);
                Width_grid = [sqrt(d^2/(1+1/ratio^2)) sqrt(d^2/(1+ratio^2))];
                for xy=1:2
                    switch nb_elecs(xy)
                        case 1
                            vector(xy).v= 0;
                        case 2
                            vector(xy).v=[-Width_grid(xy)/2 Width_grid(xy)/2];
                        otherwise
                            vector(xy).v=linspace(-Width_grid(xy)/2,Width_grid(xy)/2,nb_elecs(xy));
                    end
                end
                [x,y] = meshgrid(vector(1).v,vector(2).v);
            else % square array
                if ~(round(sqrt(nb_elecs))^2==nb_elecs)
                    warndlg('number of electrodes set to 16 (please give a a^2 number of electrodes for square Array_Grid) ')
                    nb_elecs=16;
                end
                EIDORS.chamber.electrode(i).Number=nb_elecs;
                Width_grid = EIDORS.chamber.electrode(i).Diameter/sqrt(2);
                [x,y] = meshgrid(linspace( -Width_grid/2,Width_grid/2,sqrt(nb_elecs)));
            end
            nb_elecs= max(size(x(:)));
            
            z=Z_height*ones(nb_elecs,1);
            nx=0*ones(nb_elecs,1);
            ny=0*ones(nb_elecs,1);
            nz=-ones(nb_elecs,1);
            switch EIDORS.chamber.electrode(i).Position
                case 'Top'
                    elec_set(i).obj = 'top';
                case 'Bottom'
                    % only 13 electrodes....
                    elec_set(i).obj = 'bottom';
                    z=-z;
                    nz=-nz;
                otherwise
                    msgbox('Forward Model not Generated: Electrode position/design combination not implemented/incompatible')
                    DoNotGenerate=1;
            end
            if contains(EIDORS.chamber.electrode(i).Design,'45')
                alpha = pi/4;
            end
        otherwise
            msgbox('Forward Model not Generated: Electrode Design not implemented')
            DoNotGenerate=1;
    end
    
    
    if DoNotGenerate== 0
        elec_set(i).pos = [x(:),y(:),z(:),nx(:),ny(:),nz(:)];
        R = [cos(alpha),-sin(alpha),0; sin(alpha),cos(alpha),0;0,0,1];
        elec_set(i).pos(:,1:3)=(R*elec_set(i).pos(:,1:3)')';
        switch EIDORS.chamber.electrode(i).Form
            case 'Circular'
                tmp_shape=[Radius_elecs,0,EIDORS.chamber.body.FEM_refinement];
            case 'Rectangular'
                tmp_shape=[EIDORS.chamber.electrode(i).Diameter_Width,EIDORS.chamber.electrode(i).Height,EIDORS.chamber.body.FEM_refinement];
                tmp_shape=[Radius_elecs,0,EIDORS.chamber.body.FEM_refinement];
            case 'Point'
                tmp_shape=[0,0,EIDORS.chamber.body.FEM_refinement];
                tmp_shape=[Radius_elecs,0,EIDORS.chamber.body.FEM_refinement];
            otherwise
        end
        elec_set(i).shape = tmp_shape.*ones(nb_elecs,1);
        clear tmp
        for k=1:nb_elecs
            tmp(k)= {elec_set(i).obj};
        end
        if (i==1)
            elec_pos = elec_set(i).pos;
            elec_shape = elec_set(i).shape;
            elec_obj= tmp;
        else
            elec_pos = [elec_pos ;elec_set(i).pos];
            elec_shape = [elec_shape;elec_set(i).shape];
            elec_obj= [elec_obj,tmp];
        end
        
        
    end
end


if EIDORS.flag.manualMeshGenerate
    fmdl = ng_mk_gen_models_Yue(shape_str, elec_pos, elec_shape, elec_obj);
else
    if strcmp(EIDORS.chamber.body.typ,'2D_Circ')
    [fmdl,mat_idx] = ng_mk_cyl_models(cyl_shape, elec_pos_2D, elec_shape(1,:), EIDORS.sim.netgenAdditionalText);
    
    else
    
    fmdl = ng_mk_gen_models(shape_str, elec_pos, elec_shape, elec_obj,EIDORS.sim.netgenAdditionalText);
    EIDORS.sim.netgenAdditionalText="";
    end
end

for i= 1:size(fmdl.electrode,2)
    fmdl.electrode(i).pos =elec_pos(i,:);
    fmdl.electrode(i).shape=elec_shape(i);
    fmdl.electrode(i).obj=elec_obj(i);
end



