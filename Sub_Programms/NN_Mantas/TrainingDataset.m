classdef TrainingDataset
    properties ( Access = public )
        Cells GenerateCell
        %         buffer bufferClass
        %        user_entry user_entry
        
        maxNumCells
        bufferConduct
        
        %% debug variables
        img_h
        img_ih
        data_h
        data_ih
        data_hn
        data_ihn
        %         cell_frac
        %         tmp1
        %         tmp2
        %         tmp3
        %         indx
        conduct_element
        %         invSolver
        fmdl
    end
    
    methods (Access = public)
        function obj = TrainingDataset(user_entry)
            if user_entry.withcells ==1 
                obj = obj.generate_data_withcells(user_entry);
            else
                obj = obj.generate_data_random(user_entry);
            end
        end
        
        function obj = generate_data_random(obj, user_entry)
            %TODO...@Mantas we need to discuss about that!
        end
        
        function obj = generate_data_withcells(obj, user_entry)
            global EIDORS
            %% creates fmdl
            
%             if user_entry.load_fmdl ==0
%                 chamber_radius = user_entry.chamber_radius;
%                 chamber_height = user_entry.chamber_height;
%                 mesh_size = user_entry.mesh_size;
%                 user_entry.fmdl= ng_mk_cyl_models([chamber_height,chamber_radius, mesh_size],[16,1],0);
%                 % ng_mk_cyl_models(cyl_shape= {height, radius, max size of mesh elems}, elec_pos, elec_shape, extra_ng_code)
%                 user_entry.fmdl.stimulation = mk_stim_patterns(16,1,[0,1],[0,1],{},1);
%                 obj.fmdl = user_entry.fmdl;
%                 obj.fmdl.stimulation = user_entry.fmdl.stimulation;
%             else
%                 obj.fmdl=EIDORS.fmdl;
%             end
            obj.fmdl = user_entry.fmdl;

            
            
            %% creates random conductivity of the buffer and the random number of cells from defined ranges
            tmp = GenerateRange(user_entry);
            obj.bufferConduct = tmp.bufferConduct;
            obj.maxNumCells = tmp.maxNumCells;
            %% creating Eidors for homogeneous and fwd_solve
            obj.img_h = mk_image(obj.fmdl, obj.bufferConduct);
            obj.data_h = fwd_solve(obj.img_h);  % voltage are to found under Data.meas
            obj.data_hn = add_noise( user_entry.SNR, obj.data_h);
            
            %% create cells
            for j=1:obj.maxNumCells
                obj.Cells(j) = GenerateCell(user_entry); % the each cells
            end
            % generate additional cell to create a y-shape centered on each
            % cell generated before!
            if user_entry.mk_antibodies==1
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
                       obj.Cells(indx)= obj.Cells(j)
                       obj.Cells(indx).Pos = c + pos_y(n,:)
                   end    
                end
            end
            
            %% making random number from 1 to n of cells in inhomogeneous image
            %             if user_entry.cell_nucleus == 1
            %                 ratio_cond = 0.72;      % the conductivity ratio between the nucleus and the whole cell
            %                 ratio_r_nuc = 0.10;     % the radius ratio between the nucleus and the whole cell
            %             else
            %                 ratio_cond = 0;
            %                 ratio_r_nuc = 1;
            %             end
            
            for j=1:size(obj.Cells,2)
                pos=obj.Cells(j).Pos;
                
                for layer=1:length(obj.Cells(j).LayerConduct)
                    % generating the whole random cell (cytoplasm)
                    layer_conduct = obj.Cells(j).LayerConduct(layer);
                    layer_ratio = obj.Cells(j).LayerRatio(layer);
                    radius = obj.Cells(j).Radius*layer_ratio;
                    select_fcn = @(x,y,z) (x-pos(1)).^2 + (y-pos(2)).^2 + (z-pos(3)).^2<= radius.^2;
                    % to simplify
                    Layers(layer).conduct(:,j) = (elem_select(obj.fmdl, select_fcn)~=0)*layer_conduct;
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
            
            %                 % generating the cell nucleus. Since the nucleus
            %                 % conductivity is smaller than the whole cells, from the whole
            %                 % cell the part of conductivity is subtracted to get nucleus conductivity, where nucleus is.
            %                 select_fcn = @(x,y,z) (x-obj.Cells(j).pos(1)).^2 + (y-obj.Cells(j).pos(2)).^2 + (z-obj.Cells(j).pos(3)).^2<= (obj.Cells(j).radius.*ratio_r_nuc)^2;
            %                 obj.cell_frac(:,j) = obj.cell_frac(:,j) - elem_select(fmdl, select_fcn)*obj.Cells(j).conduct * (1-ratio_cond);
            %% removing the overlaping part of cell's with smaller conductivity
            %@mantas implementation with matrix is faster ... and not
            %so ugly
            %                 if j > 1
            %                     jj = j - 1;
            %                     for k=1:jj
            %                         for l=1:length(obj.cell_frac)
            %                             occupied_place = obj.cell_frac>0;
            %                             if (occupied_place(l,k) + occupied_place(l,j)) == 2
            %                                 obj.cell_frac(l,j) = 0;
            %                                 break
            %                             end
            %                         end
            %                     end
            %                 end
            %
            %             %% for debugging
            %             obj.conduct_element= sum(obj.cell_frac,2);
            %             obj.tmp1 = obj.cell_frac>0;
            %             obj.tmp2 = sum(obj.tmp1,2);
            %             obj.tmp3 = obj.tmp2 > 2;
            %             obj.indx = find(obj.tmp2);
            %             if ~isempty(obj.indx)
            %                 obj.conduct_element(obj.indx)= max(obj.cell_frac(obj.indx,:),[],2);
            %             end
            %% rewriting to randomly generated conductivity of the buffer
            %@mantas implementation with matrix is faster ...
            elmt_set = find(obj.conduct_element==0);
            if any(elmt_set)
                obj.conduct_element(elmt_set)= obj.bufferConduct;
            end
            %             for i=1:length(obj.conduct_element)
            %                 if ~obj.conduct_element(i) > 0
            %                     obj.conduct_element(i) = obj.bufferConduct;
            %                 end
            %             end
            
            
            %% creating inhomogeneous image objects and fwd_solve
            obj.img_ih = mk_image(obj.fmdl, obj.conduct_element);
            obj.data_ih = fwd_solve(obj.img_ih);
            obj.data_ihn = add_noise( user_entry.SNR, obj.data_ih);
       
            %% inverse model solver
            % @Mantas: do not do that hier... because you dont need it for
            % the training of the network, so you save time for large
            % datasets...
            %             if user_entry.invSolver == 1
            %                 obj.invSolver = invSolver(user_entry, obj);
            %             end
         
        end
        
        
    end
    
end
