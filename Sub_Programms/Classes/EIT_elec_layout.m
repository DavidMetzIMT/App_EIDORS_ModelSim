classdef EIT_elec_layout

    properties (Access = public)
        elecNb % number of electrodes
        elecForm % Circular, Rectangular, Point
        elecSize % width, height
        elecPlace % Wall, Top, Bottom
        layoutDesign % Ring, Grid, Polka Dot
        layoutSize % X, Y, Z
    end

    properties (Access = protected)
        reset
    end
    properties (Access=private)
        ELEC_FORMS ={'Circular', 'Rectangular', 'Point'};
        LAYOUT_DESIGN = {'Ring', 'Array_Grid 0', 'Array_Grid 45', 'Array_PolkaDot 0', 'Array_PolkaDot 45'};
        ELEC_PLACE ={'Wall', 'Top', 'Bottom'};
        ALLOW_ELEC_PLACEMENT = [ % 'Wall', 'Top', 'Bottom'
                                    1,   1,   1 ; % 'Ring'
                                    0,   1,   1 ; % 'Array_Grid 0'
                                    0,   1,   1 ; % 'Array_Grid 45'
                                    0,   1,   1 ; % 'Array_PolkaDot 0'
                                    0,   1,   1 ; % 'Array_PolkaDot 45'
        ];  
    end
    methods
        
        function obj = EIT_elec_layout(varargin)
            % Set the prperties from the object electrodes layout
            % varargin{1} >> struct :
            %                           --Number % of electrode
            %                           --Form % of the electrode: Circular, Rectangular, Point
            %                           --Diameter_Width % electrode width
            %                           --Height % electrode height
            %                           --Position % position in the chamber Wall, Top, Bottom
            %                           --Design % Ring, Grid, Polka Dot
            %                           --Diameter % Diameter design

            if nargin==1
                var= varargin{1};
                obj.reset = 0;
                obj.elecNb=var.Number; % number of electrodes
                obj.elecForm=var.Form; % Circular, Rectangular, Point
                obj.elecSize=[var.Diameter_Width, var.Height]; % width, height
                obj.elecPlace=var.Position; % Wall, Top, Bottom
                obj.layoutDesign=var.Design; % Ring, Grid, Polka Dot
                obj.layoutSize=var.Diameter; % X, Y, Z
            else
                obj.reset = 1;
                obj.elecNb=16; % number of electrodes
                obj.elecForm='Circular'; % Circular, Rectangular, Point
                obj.elecSize=[0.5, 0]; % width, height
                obj.elecPlace='Wall'; % Wall, Top, Bottom
                obj.layoutDesign='Ring'; % Ring, Grid, Polka Dot
                obj.layoutSize=4; % X, Y, Z
            end
        end

        function value = is_reset(obj)
            value = obj.reset;
        end

        function var = get_struct_4_gui(obj)
            % attention here the order count
            var.Design          = obj.layoutDesign; 
            var.Diameter        = obj.layoutSize; 
            var.Number          = obj.elecNb; 
            var.Position        = obj.elecPlace; 
            var.Form            = obj.elecForm; 
            var.Diameter_Width  = obj.elecSize(1);
            var.Height          = obj.elecSize(2);
        end

        function cellarray = supported_elec_forms(obj)
            %Return Supported electrode forms
            cellarray = obj.ELEC_FORMS;
        end
        function cellarray = supported_layouts(obj)
            %Return Supported arrDesign designs
            cellarray = obj.LAYOUT_DESIGN;
        end
        function cellarray = supported_elec_pos(obj)
            %Return Supported electrode position
            cellarray = obj.ELEC_PLACE;
        end

        function val = allowed_placement(obj)
            % returns the supported chamber forms
            index_actual_layout = find(strcmp(obj.LAYOUT_DESIGN, obj.layoutDesign));
            val = obj.ALLOW_ELEC_PLACEMENT(index_actual_layout, :);
        end

        function r = elec_radius(obj)
            % TODO change that with the forms....
            r= obj.elecSize(1)/2;
        end

        function [elec_pos, elec_shape, elec_obj, error] = data_for_ng(obj, chamber)

            arguments % argument validator
                obj
                chamber EIT_chamber
            end
            
            elec_pos=[];
            elec_shape=[]; 
            elec_obj={};

            error.msg='';
            error.code=0; % 0 noerror > 0 error

            % DoNotGenerate=0;
            %% Chamber
            % chamber radius
            ch_r=chamber.radius();
            % ch_limits = [minX, maxX; minY, maxY; minZ, maxZ] centered chamber 
            ch_limits = chamber.box_limits();
            %% Electrodes
            % electrodes radius
            elec_r= obj.elec_radius();
            
            % is the number of electrodes a float -> elec_nX, elec_nY for arrays 
            elec_n= obj.elecNb;
            elec_n = [
                round(elec_n-mod(elec_n,1))
                round(mod(elec_n,1)*100)];
            
                
                % check if electrode placement is compatible with layout design 
                allow_place_for_actual_layout = obj.allowed_placement();
                actual_elec_place_indx= find(strcmp(obj.ELEC_PLACE, obj.elecPlace));
                if ~allow_place_for_actual_layout(actual_elec_place_indx)
                % msgbox('Chamber_typ and Design electrode incompatible');
                error.msg='Electrode place and layout are incompatible';
                error.code= 1; % 0 noerror > 0 error
                return; % ??
            end

            % check if electrode placement is compatible with chamber design 
            allow_place_for_actual_chamber = chamber.allowed_placement();
            if ~allow_place_for_actual_chamber(actual_elec_place_indx)
                % msgbox('Chamber_typ and Design electrode incompatible');
                error.msg= 'Electrode place and chamber are incompatible';
                error.code= 1; % 0 noerror > 0 error
                return; % ??
            end

            
            elec_place= obj.elecPlace;
            specific_length = obj.layoutSize/2;
            
            switch elec_place
                case obj.ELEC_PLACE{1} %'Wall'
                    specific_length = ch_r;
                    f= [specific_length,specific_length, 1];
                    c_pos= [0, 0 , 0 ];
                    n_vec= [1,1,0];
    
                case obj.ELEC_PLACE{2} %'Top'
                    f= [specific_length,specific_length, 1];
                    c_pos= [0, 0 , ch_limits(3,2) ];
                    n_vec= [0,0,-1];

                case obj.ELEC_PLACE{3}%'Bottom'
                    f= [specific_length,specific_length, 1];
                    c_pos= [0, 0 , ch_limits(3,1)];
                    n_vec= [0,0,1];
                otherwise
                    error.msg= 'Electrode position/design combination not implemented/incompatible';
                    error.code= 1; % 0 noerror > 0 error
                    return; % ??
                    % msgbox('Electrode position/design combination not implemented/incompatible')
                    % DoNotGenerate=1;
                end
                
            % rotation of the layoutDesign
            rot_angle = [0, 0, 0];
            if contains(obj.layoutDesign,'45')
                rot_angle = [0, 0, pi/4];
            end
                    
            layoutDesign= obj.layoutDesign;
                
            switch layoutDesign
                case obj.LAYOUT_DESIGN{1} % 'Ring'

                    elec_n= elec_n(1); % only one number

                    theta = linspace(0, 2*pi, elec_n + 1)';
                    theta(end) = []; % 0 <= theta < 2*pi 
                    
                    xyz = [cos(theta), sin(theta), zeros(elec_n,1)] .*f + c_pos; 
                    n = [cos(theta), sin(theta), ones(elec_n,1)] .* n_vec;
                    
                    % check if electrodes are contained in chamber 
                    
                    
                    if (ch_r)<(elec_r+specific_length) & ~strcmp(obj.elecPlace,obj.ELEC_PLACE{1}) %'Wall'
                        % msgbox('Too big electrode diame te... incompatible with Chamber diameter and ring diameter')
                        error.msg= 'Too big electrode diame te... incompatible with Chamber diameter and ring diameter';
                        error.code= 1; % 0 noerror > 0 error
                        return; % ??
                    end
                    % check if ring electrodes
                    if (2*pi*specific_length)<=(2*asin(elec_r/specific_length)*specific_length*elec_n)
                        % msgbox('Too big or too much electrode... incompatible with Chamber diameter')
                        % DoNotGenerate=1;
                        error.msg= 'Too big or too much electrode... incompatible with Chamber diameter';
                        error.code= 1; % 0 noerror > 0 error
                        return; % ??
                    end
                

                % case {'Array_PolkaDot 0', 'Array_PolkaDot 45'}
                %     % only 13 electrodes....
                %     if size(elec_n,2)==2
                %         if (sum(mod(elec_n,2))==0)
                %             errordlg('please give only uneven number of electrodes for Array_PolkaDot ')
                %         else
                %             d = EIDORS.chamber.electrode(i).Diameter;
                %             ratio=elec_n(1)/elec_n(2);
                %             Width_grid = [sqrt(d^2/(1+1/ratio^2)) sqrt(d^2/(1+ratio^2))];
                %             for xy=1:2
                %                 switch elec_n(xy)
                %                     case 1
                %                         vector(xy).v= 0;
                %                     case 2
                %                         vector(xy).v=[-Width_grid(xy)/2 Width_grid(xy)/2];
                %                     otherwise
                %                         vector(xy).v=linspace(-Width_grid(xy)/2,Width_grid(xy)/2,elec_n(xy));
                %                 end
                %             end
                %             [x,y] = meshgrid(vector(1).v,vector(2).v);
                %         end
                %     else
                %         if ~(elec_n==13)
                %             warndlg('number of electrodes set to 13 ')
                %             elec_n=13;
                %         end
                %         EIDORS.chamber.electrode(i).Number=elec_n;
                %         Width_grid = EIDORS.chamber.electrode(i).Diameter/sqrt(2);
                %         [x,y] = meshgrid(linspace( -Width_grid/2,Width_grid/2,5));
                %     end
                    
                %     x=x(1:2:end);
                %     y=y(1:2:end);
                %     elec_n= max(size(x(:)));
                    
                %     z=Z_height*ones(elec_n,1);
                %     nx=0*ones(elec_n,1);
                %     ny=0*ones(elec_n,1);
                %     nz=-ones(elec_n,1);
                %     switch EIDORS.chamber.electrode(i).Position
                %         case 'Top'
                %             % elec_set(i).obj = 'top';
                %         case 'Bottom'
                %             % only 13 electrodes....
                %             % elec_set(i).obj = 'bottom';
                %             z=-z;
                %             nz=-nz;
                %         otherwise
                %             msgbox('Electrode position/design combination not implemented/incompatible')
                %             DoNotGenerate=1;
                %     end
                %     if contains(EIDORS.chamber.electrode(i).Design,'45')
                %         alpha = pi/4;
                %     end
                    
                % case {'Array_Grid 0', 'Array_Grid 45'}
                %     if size(elec_n,2)==2
                %         d = EIDORS.chamber.electrode(i).Diameter;
                %         ratio=elec_n(1)/elec_n(2);
                %         Width_grid = [sqrt(d^2/(1+1/ratio^2)) sqrt(d^2/(1+ratio^2))];
                %         for xy=1:2
                %             switch elec_n(xy)
                %                 case 1
                %                     vector(xy).v= 0;
                %                 case 2
                %                     vector(xy).v=[-Width_grid(xy)/2 Width_grid(xy)/2];
                %                 otherwise
                %                     vector(xy).v=linspace(-Width_grid(xy)/2,Width_grid(xy)/2,elec_n(xy));
                %             end
                %         end
                %         [x,y] = meshgrid(vector(1).v,vector(2).v);
                %     else % square array
                %         if ~(round(sqrt(elec_n))^2==elec_n)
                %             warndlg('number of electrodes set to 16 (please give a a^2 number of electrodes for square Array_Grid) ')
                %             elec_n=16;
                %         end
                %         EIDORS.chamber.electrode(i).Number=elec_n;
                %         Width_grid = EIDORS.chamber.electrode(i).Diameter/sqrt(2);
                %         [x,y] = meshgrid(linspace( -Width_grid/2,Width_grid/2,sqrt(elec_n)));
                %     end
                %     elec_n= max(size(x(:)));
                    
                %     z=Z_height*ones(elec_n,1);
                %     nx=0*ones(elec_n,1);
                %     ny=0*ones(elec_n,1);
                %     nz=-ones(elec_n,1);
                %     switch EIDORS.chamber.electrode(i).Position
                %         case 'Top'
                %             % elec_set(i).obj = 'top';
                %         case 'Bottom'
                %             % only 13 electrodes....
                %             % elec_set(i).obj = 'bottom';
                %             z=-z;
                %             nz=-nz;
                %         otherwise
                %             msgbox('Electrode position/design combination not implemented/incompatible')
                %             DoNotGenerate=1;
                %     end
                %     if contains(EIDORS.chamber.electrode(i).Design,'45')
                %         alpha = pi/4;
                %     end

                otherwise
                    error.msg= 'Electrode Design not implemented';
                    error.code= 1; % 0 noerror > 0 error
                    return; % ??
                    % msgbox('Electrode Design not implemented')
                    % DoNotGenerate=1;
            end
            
            elec_pos_2D=[elec_n,1]; % if '2D_circ'

            % generate position of electrodes
            elec_pos = [xyz,n];

            % rotation in z only
            gamma= rot_angle(3);
            Rz = [
                cos(gamma), -sin(gamma), 0;
                sin(gamma), cos(gamma), 0;
                0, 0, 1
            ];
            Rz= [Rz,zeros(size(Rz));zeros(size(Rz)), Rz];
            elec_pos=(Rz*elec_pos')';

            % generate shape of electrodes
            elec_form= obj.elecForm;

            switch elec_form
                case obj.ELEC_FORMS{1} %'Circular'
                    tmp_shape=[elec_r,0,chamber.femRefinement];

                case obj.ELEC_FORMS{2} %'Rectangular'
                    tmp_shape=[obj.elecSize(1),obj.elecSize(2),chamber.femRefinement];

                case obj.ELEC_FORMS{3} %'Point'
                    tmp_shape=[0,0,chamber.femRefinement];

                otherwise
                    error.msg= 'Electrode form not implemented';
                    error.code= 1; % 0 noerror > 0 error
                    return; % ??
            end
            elec_shape = tmp_shape.*ones(elec_n,1);
        
            % generate shape of electrodes
            place = lower(obj.elecPlace); %for a
            
            for k=1:elec_n
                elec_obj{k}= place;
            end
                % if (i==1)
                %     elec_pos = elec_set(i).pos;
                %     elec_shape = elec_set(i).shape;
                %     elec_obj= tmp;
                % else
                %     elec_pos = [elec_pos ;elec_set(i).pos];
                %     elec_shape = [elec_shape;elec_set(i).shape];
                %     elec_obj= [elec_obj,tmp];
                % end
                
                % end
        end

    end


end


