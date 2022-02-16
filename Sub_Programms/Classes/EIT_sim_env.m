classdef EIT_sim_env < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name ='Simulation default'
        fmdl % Eidors_fmdl % the forward model from EIDORS
        imdl % Eidors_imdl % the inverse model from EIDORS
        objects EIT_object % objects put in the chamber
        mediumConduct % conductivity of the medium
        img_h % homogenious image only medium from EIDORS
        img_ih % inhomogenious image with the objects from EIDORS
        data_h % meas data for img_h from EIDORS (solving the fmdl)
        data_ih % meas data for img_ih from EIDORS (solving the fmdl)
        iimg  % inverse image from EIDORS (solving the imdl)
        greit % metrics fro evaluation the iimg
    end
    
    methods
        function obj = EIT_sim_env()

            obj.objects= EIT_object();
            
        end
        function add_object(obj, object)
            %UNTITLED3 Construct an instance of this class
            %   Detailed explanation goes here
            % obj.objects(length(obj.objects)+1)= EIT_object(struct_object);
            %add_elec_layout append an electrode layout
            if isa(object, 'EIT_object')
                if obj.objects.is_reset()
                    obj.objects(1)= object;
                else
                    obj.objects(length(obj.objects) + 1 ) = object;
                end
            else
                errordlg('object has to be an EIT_object cls')
            end
        end
        function reset_objects(obj)
            %reset_elec_layout clear the electrode layouts
            obj.objects=EIT_object();
        end
        
        function outputArg = method1(obj)
            %
            % disp('Generate model with cell: Start')
            % disp('please wait ...')

            % global EIDORS
            % close all

            % fmdl = EIDORS.fmdl; %% buffer fmdl

            % if EIDORS.flag.AddcellinFEMmodel % rebuild fwd model with cell
            %     text='';
            %     switch EIDORS.flag.Object
            %         case 'Cell'
            %             for i=1:size(EIDORS.sim.cell,1)
            %                 c=EIDORS.sim.cell(i);
            %                 text= [text '\n\r ' 'solid cell_' num2str(i) ' = sphere(' num2str(c.PosX) ',' num2str(c.PosY) ',' num2str(c.PosZ) ';' num2str(c.Radius) ');\n\r ' 'tlo cell_' num2str(i) ';'];
            %             end
            %             fig_name='Foward Model with cell';
                        
            %         case 'Cylinder'
            %             for i=1:size(EIDORS.sim.cell,1)
            %                 c=EIDORS.sim.cell(i);
            %                 text=['solid wall_cyc = cylinder (0,0,0; 0,0,1;' num2str(c.Radius) ');\n' ...
            %                     'solid top_cyc = plane(0,0,' num2str(EIDORS.chamber.body.depth/2-0.1) ';0,0,1);\n' ...
            %                     'solid bottom_cyc = plane(0,0,-' num2str(c.PosZ) ';0,0,-1);\n' ...
            %                     'solid mainobj_cyc = top_cyc and bottom_cyc and wall_cyc -maxh=' num2str( EIDORS.chamber.body.FEM_refinement/2) ';\n' 'tlo mainobj_cyc' ';\n']
            %             end
            %             fig_name= 'Foward Model with cylinder';
                        
            %     end
                
            %     EIDORS.sim.netgenAdditionalText=text;
            %     create_fmdl(); % new fmdl in EIDORS.fmdl
            %     h= gcf;
            %     set(h,'Name',fig_name )
            % end

            % EIDORS.sim.fmdl = EIDORS.fmdl;
            % EIDORS.fmdl= fmdl; % end  Buffering

            % EIDORS.sim.fmdl.name = [fmdl.name '_wCell'];
            % EIDORS.sim.fmdl.stimulation=fmdl.stimulation; % Set solving parameters
            % EIDORS.sim.fmdl.meas_select = fmdl.meas_select;
            % EIDORS.sim.fmdl.solve=fmdl.solve;
            % EIDORS.sim.fmdl.jacobian=fmdl.jacobian;
            % EIDORS.sim.fmdl.system_mat=fmdl.system_mat;
            % EIDORS.sim.fmdl.misc.perm_sym=fmdl.misc.perm_sym;
            % EIDORS.sim.fmdl.get_all_meas=fmdl.get_all_meas;

            %% Set homogenious conductivity
            obj.gen_homogenious_image();
            obj.gen_inhomogenious_image();
        

            obj.solve_fwd();
            


            % %%Plot 3D images
            % figName= '3D Image of homogenious conductivity';
            % h= getCurrentFigure_with_figName(figName);
            % show_fem( EIDORS.sim.img_h, [1,1.012,0]);
            % if ~EIDORS.flag.displaymesh
            %     set(h,'EdgeColor','none');
            % end
            % figName= '3D Image of inhomogenious conductivity';
            % h= getCurrentFigure_with_figName(figName);
            % show_fem(EIDORS.sim.img_ih,[1,0,0]);
            % if ~EIDORS.flag.displaymesh
            %     set(h,'EdgeColor','none');
            % end
            % show_cell(h,EIDORS.sim.iimg.calc_slices.levels,1)
            % disp('Generate model with cell: Done!')
        end


        function solve_fwd(obj)
            obj.gen_homogenious_image();
            obj.gen_inhomogenious_image();
            
            obj.data_h = fwd_solve(obj.img_h);
            obj.data_ih = fwd_solve(obj.img_ih);
        end

        function gen_homogenious_image(obj)
            obj.img_h = mk_image(obj.fmdl, obj.mediumConduct);
            obj.img_h.fwd_solve.get_all_nodes=0;
        end

        function gen_inhomogenious_image(obj)

            for o=1:size(obj.objects,2)
                conduct(:,:,o) = obj.objects(o).get_conduct_data(obj.fmdl)
            end

            % handling the cell overlapping by taking only the max value of
            % the conductivity on each layers
            conduct_data= zeros(size(conduct(:,1,1))); % init to 0

            for layer=1:size(conduct,2)
                l_conducts= conduct(:,layer,:)
                l_total_conduct= sum(l_conducts, 3) % sum all the columns to init the layer conduct
                overlapping_indx = find(sum(l_conducts~=0 , 3) >= 2)
                if any(overlapping_indx)
                    l_total_conduct(overlapping_indx)= max(l_conducts(overlapping_indx,:),[],2);
                end
                elmt_set = find(l_total_conduct~=0);
                if any(elmt_set)
                    conduct_data(elmt_set)= l_total_conduct(elmt_set);
                end
            end
            
            elmt_set = find(conduct_data==0);
            if any(elmt_set)
                conduct_data(elmt_set)= obj.mediumConduct;
            end

            obj.img_ih = mk_image(obj.fmdl, conduct_data);


            % %% Set inhomogenious conductivity
            % for i=1:size(obj.objects,1)
            %     select_object_func=obj.objects(i).select_object_func();
            %     % switch EIDORS.flag.Object
            %     %     case 'Cell'
            %     %         select_cell = @(x,y,z) (x-c.PosX).^2 + (y-c.PosY).^2+(z-c.PosZ).^2 <= c.Radius^2;
                        
            %     %     case 'Cylinder'
            %     %         select_cell = @(x,y,z) (x-c.PosX).^2 + (y-c.PosY).^2 <= (ones(size(y))*c.Radius).^2 & z>=c.PosZ;
            %     % end
            %     cell_frac(:,i) = elem_select( obj.fmdl, select_object_func);
            % % select_rst = @(x,y,z) (x-c.PosX).^2 + (y-c.PosY).^2+(z-c.PosZ).^2 > c.Radius^2 ;
            % % layer_frac(:,i) = elem_select( EIDORS.sim.img_h.fwd_model, select_rst);%% do we really need this one???
            % end



            % if size(obj.objects,1)==0
            %     obj.img_ih=obj.img_h;
            % else
            %     c_is=sum(cell_frac>0,2);
            % %     l_is=sum(layer_frac>0,2);
            %     for i=1:size(cell_frac,1)
            %         if c_is(i)==0
            %             c_frac(i,1) =0;
            %         elseif c_is(i)==1
            %             c_frac(i,1) = sum(cell_frac(i,:));
            %         elseif c_is(i)>1
            %             c_frac(i,1) = 1;
            %         end
            % %         if sum(layer_frac(i,:),2)==size(layer_frac,2)
            % %             l_frac(i,1) =1;
            % %         else
            % %             l_frac(i,1) = 0;
            % %         end
            %     end
                
            % %     EIDORS.sim.img_ih = mk_image(EIDORS.sim.img_h, EIDORS.sim.bufferConduct + c_frac*(EIDORS.sim.cellConduct) + l_frac*(EIDORS.sim.layerConduct));
            %     obj.img_ih = mk_image(obj.fmdl, obj.mediumConduct + c_frac*(EIDORS.sim.cellConduct-obj.mediumConduct));
            % end


        end
        
    end
end
