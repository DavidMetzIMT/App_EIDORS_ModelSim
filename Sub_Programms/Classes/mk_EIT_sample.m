classdef mk_EIT_sample
    properties ( Access = public )
        Cells GenerateCell
        maxNumCells
        bufferConduct
        img_h
        img_ih
        data_h
        data_ih
        data_hn
        data_ihn
        conduct_element
        fmdl
    end

    methods (Access = public)
        function obj = mk_EIT_sample(user_entry)
            obj = obj.mk_homogeneous_fwd_solve(user_entry);
            if ~contains(user_entry.type_of_artefacts, 'Random')
                obj = obj.generate_data_withcells(user_entry);
            else
                obj = generate_data_random(obj, user_entry);
            end
            obj = obj.mk_inhomogeneous_fwd_solve(user_entry);
            % otimaization for less output weight
            obj.conduct_element=[]; % is to found in img.elem_data...
            obj.fmdl=[]; % is to found in user_entry 
            obj.img_h.fwd_model=[];
            obj.img_ih.fwd_model=[];
        end
        
        %% make the homogenous image and solve the fwd model to get data
        function obj = mk_homogeneous_fwd_solve(obj, user_entry)
            
            %obj.fmdl = user_entry.fmdl
            % creates random conductivity of the buffer and the random number of cells from defined ranges
            tmp = GenerateRange(user_entry);
            obj.bufferConduct = tmp.bufferConduct;
            obj.maxNumCells = tmp.maxNumCells;
            % creating Eidors for homogeneous and fwd_solve
            obj.img_h = mk_image( user_entry.fmdl, obj.bufferConduct);
            obj.data_h = fwd_solve(obj.img_h);  % voltage are to found under Data.meas
            obj.data_hn = add_noise(user_entry.SNR, obj.data_h);
            
        end
         %% make the inhomogenous image and solve the fwd model to get data
        function obj = mk_inhomogeneous_fwd_solve(obj, user_entry)
            % creating inhomogeneous image objects and fwd_solve
            obj.img_ih = mk_image( user_entry.fmdl, obj.conduct_element);
            obj.data_ih = fwd_solve(obj.img_ih);
            obj.data_ihn = add_noise( user_entry.SNR, obj.data_ih);
        end
        %% generate the datat correspoding to cells
        function obj = generate_data_withcells(obj, user_entry)
            % create cells
            for j=1:obj.maxNumCells
                obj.Cells(j) = GenerateCell(user_entry); % the each cells
            end
            
            % cell generated before!
            if contains(user_entry.type_of_artefacts, 'Antigens')
                obj = obj.mk_antigens(user_entry);
            end
            
            for j=1:size(obj.Cells,2)
                pos=obj.Cells(j).Pos;
                
                for layer=1:length(obj.Cells(j).LayerConduct)
                    % generating the whole random cell (cytoplasm)
                    layer_conduct = obj.Cells(j).LayerConduct(layer);
                    layer_ratio = obj.Cells(j).LayerRatio(layer);
                    radius = obj.Cells(j).Radius*layer_ratio;
                    select_fcn = @(x,y,z) (x-pos(1)).^2 + (y-pos(2)).^2 + (z-pos(3)).^2<= radius.^2;
                    % to simplify
                    Layers(layer).conduct(:,j) = (elem_select( user_entry.fmdl, select_fcn)~=0)*layer_conduct;
                end
            end
            % handling the cell overlapping by taking only the max value of
            % the conductivity on each layers
            obj.conduct_element= zeros(size(Layers(1).conduct(:,1),1),1);
            for layer=1:length(Layers)
                l_conducts= Layers(layer).conduct;
                l_total_conduct= sum(l_conducts, 2); % sum all the columns to init the layer conduct
                overlapping_indx = find(sum(l_conducts~=0 , 2) >= 2);
                if any(overlapping_indx)
                    l_total_conduct(overlapping_indx)= max(l_conducts(overlapping_indx,:),[],2);
                end
                elmt_set = find(l_total_conduct~=0);
                if any(elmt_set)
                    obj.conduct_element(elmt_set)= l_total_conduct(elmt_set);
                end
            end
            
            elmt_set = find(obj.conduct_element==0);
            if any(elmt_set)
                obj.conduct_element(elmt_set)= obj.bufferConduct;
            end
        end
        %% to create antigens additional cells positions are generates arround the cellposition already generated
        % generate additional cell to create a y-shape centered on each
        function obj = mk_antigens(obj, user_entry)
            r=user_entry.range_cell_radius(1);
            pos_y0=[0,-r,0;0,-2*r,0;0,-3*r,0;0,-4*r,0, ;0,-5*r,0;0,-6*r,0;0,-7*r,0];
            a =-135*2*pi()/360    ;
            R1=[cos(a) -sin(a) 0;
                sin(a) cos(a) 0;
                0 0 1];
            a =135*2*pi()/360;
            R2=[cos(a) -sin(a) 0;
                sin(a) cos(a) 0;
                0 0 1];
            pos_y= [pos_y0;pos_y0*R2;pos_y0*R1];
            for j=1:obj.maxNumCells
                c = obj.Cells(j).Pos;
                a =rand()*2*pi();
                R3=[cos(a) -sin(a) 0;
                    sin(a) cos(a) 0;
                    0 0 1];
                pos_y= pos_y*R3;
                for n=1:size(pos_y,1)
                    indx=size(obj.Cells,2)+1;
                    obj.Cells(indx)= obj.Cells(j);
                    obj.Cells(indx).Pos = c + pos_y(n,:);
                end
            end
        end
        %% generate a random conductivity by inverse solving data obtained from homogenous
        function obj = generate_data_random(obj, user_entry)
            inv.name = 'EIT obj.inverse';
            inv.hyperparameter.value = 3e-3;
            inv.RtR_prior= 'prior_laplace';
            inv.reconst_type= 'difference';
            inv.jacobian_bkgnd.value= 1;
            inv.fwd_model= user_entry.fmdl;
            inv.fwd_model.misc.perm_sym= '{y}';
            inv.parameters.max_iterations = 2;
            inv.parameters.term_tolerance= 1e-3;
            disp('Start: GN Inverse solver...')
            inv.solve = 'inv_solve_diff_GN_one_step';
            inv.R_prior =  @prior_laplace;
            imdl= eidors_obj('inv_model', inv);
            iimg = inv_solve(imdl, obj.data_h, obj.data_hn);
            obj.conduct_element= iimg.elem_data;
        end
        
    end
    
end
