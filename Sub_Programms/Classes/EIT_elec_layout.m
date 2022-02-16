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
        LAYOUT_DESIGN = {'Ring', 'Array_Grid 0', 'Array_Grid 45'};%, 'Array_PolkaDot 0', 'Array_PolkaDot 45'};
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
            % Returns data about the electrodes needed to generate a fmdl with EIDORS 
            % using "ng_mk_gen_models"
            % elec_pos = [position vector, normal vector (to the electrode surface)]
            %                  array size (eletrodes nb, 6)
            % elec_shape =  [elecsize1 elecsize2, fem_refinemet used for elec](see "ng_mk_gen_models")
            %                  array size (eletrodes nb, 3)
            % elec_obj = {object} (object is the place of the electrode wall, top, bottom)
            %                  cell array size (1, eletrodes nb)
            %
            arguments % argument validator
                obj
                chamber EIT_chamber
            end
            
            elec_pos=[];
            elec_shape=[]; 
            elec_obj={};

            error = build_error('', 0);

            %% Format the number of electrodes
            [n_XY, n_tot, error] = obj.get_nb_elec();
            if error.code>0 return; end
            
            %% Generate parameters for the selected electrode placement
            [layout_r, f_pos, c_pos, n_vec, error] = param_for_elec_place(obj.elecPlace, obj.layoutSize, chamber.min_radius(), chamber.box_limits());
            if error.code>0 return; end

            %% Check layout (if layout is compatible with electrode placement,
            % chamber form and if elctrodes are contained in cahmber and not overlapping)
            error = obj.check_layout(n_XY,n_tot, layout_r, chamber);
            if error.code>0 return; end

            %% Generate electrodes position depending the selected layout design
            [xyz, nxyz, error] = get_normalized_layout(obj.layoutDesign,n_XY);
            if error.code>0 return; end
            
            %% scale the normalized layout 
            elec_pos = [xyz .* f_pos + c_pos, nxyz .* n_vec];

            % Rotation of the layoutDesign in Z only
            rot_angle = [0, 0, 0];
            if contains(obj.layoutDesign,'45')
                rot_angle = [0, 0, pi/4];
                elec_pos = RotationZ(elec_pos, rot_angle);
            end
            
            %% Generate shape of electrodes
            [elec_shape, error] = gen_elec_shape(obj.elecForm, obj.elecSize, n_tot, chamber.femRefinement, obj.ELEC_FORMS);
            if error.code>0 return; end
            
            %% Generate object of electrodes
            elec_obj = gen_elec_obj(obj.elecPlace, n_tot);
            
            %% Test length of the ouput values
            if length(elec_obj)~= size(elec_pos, 1)
                error = build_error('elec_pos and elec_obj don''t have same size', 1);
                return;
            end
            if size(elec_shape, 1)~=size(elec_pos, 1)
                error = build_error('elec_pos and elec_shape don''t have same size', 1);
                return;
            end

            % 2d_Circ need an other type of elec_pos data
            if strcmp(chamber.form, '2D_Circ')
                elec_pos=[n_tot, 1];
            end
        end

        function error = check_layout(obj,n_XY, n_tot, layout_r, chamber)
            % Check layout (if layout is compatible with electrode placement,
            % chamber form and if elctrodes are contained in cahmber and not overlapping)

            error = build_error('', 0);
            %% Check if electrode placement is compatible with layout design 
            allow_place_for_actual_layout = obj.allowed_placement();
            actual_elec_place_indx= find(strcmp(obj.ELEC_PLACE, obj.elecPlace));
            if ~allow_place_for_actual_layout(actual_elec_place_indx)
                error = build_error('Electrode place and layout are incompatible', 1);
                return; % ??
            end

            %% Check if electrode placement is compatible with chamber design 
            allow_place_for_actual_chamber = chamber.allowed_placement();
            if ~allow_place_for_actual_chamber(actual_elec_place_indx)
                error = build_error('Electrode place and chamber are incompatible', 1);
                return; % ??
            end
            
            %% Check if electrodes size/ layout size is compatible with chamber

            ch_r=chamber.min_radius();% chamber radius
            elec_r= obj.elec_radius();% electrodes radius

            %% check if ring electrodes are not overlapping
            layout_design=obj.layoutDesign;
            switch layout_design
                case 'Ring'
                    if (2*pi*layout_r)<=(2*asin(elec_r/layout_r)*layout_r*n_tot) 
                        error = build_error('Ring Electrode are overlapping', 1);
                        return; 
                    end
                    min_layout_width= layout_r; % for electrodes contained in chamber
                case {'Array_Grid 0', 'Array_Grid 45'}
                    d=layout_r*2/sqrt(2);
                    space_btw_elec= min(d./(n_XY-1));
                    if  space_btw_elec<=elec_r*2
                        error = build_error('Array Electrode are overlapping', 1);
                        return; 
                    end
                    rat=n_XY(1)/n_XY(2); % for electrodes contained in chamber
                    min_layout_width = min([sqrt(1/(1+(1/rat)^2)) sqrt(1/(1+(rat)^2))]*layout_r);
                
                % case {'Array_PolkaDot 0', 'Array_PolkaDot 45'} 

                otherwise
                    error = build_error('Electrode Design not implemented', 1);
                    return;
            end
            %% check if electrodes are contained in chamber xy-section (top or bottom)
            if ~strcmp(obj.elecPlace,'Wall') & (ch_r)<=(elec_r+min_layout_width) 
                error = build_error('Electrodes not contained inchamber', 1);
                return; % ??
            end
        end

        function [n_XY, n_tot, error] = get_nb_elec(obj)
            % format the electrodes numbers
            % if elec_n = [integer part of elec_nb, 100*fractional part of elec_nb ]
            % return n_XY = 
        
            error = build_error('', 0);
            n_tot=0;
        
            % is the number of electrodes a float -> elec_nX, elec_nY for arrays 
            elec_n= obj.elecNb;
            elec_n = [
                round(elec_n-mod(elec_n,1))
                round(mod(elec_n,1)*100)];
        
            % check if electrode number > 0
            if ~elec_n(1)>0
                error = build_error('Electrode number should be > 0 ', 1);
                return;
            end
        
            n_XY= elec_n; 
            layout_design=obj.layoutDesign;
            switch layout_design
                case 'Ring'
        
                case {'Array_Grid 0', 'Array_Grid 45'}
                    if elec_n(2) == 0 
                        if ~(round(sqrt(elec_n(1)))^2==elec_n(1)) % verify if n is a^2
                            warndlg('number of electrodes set to 16 (please give a a^2 number of electrodes for square Array_Grid) ');
                            n_XY=[4, 4];
                        else
                            n_XY=[round(sqrt(elec_n(1))),round(sqrt(elec_n(1)))];
                        end
                    end
                    
                % case {'Array_PolkaDot 0', 'Array_PolkaDot 45'} 
        
                otherwise
                    error = build_error('Electrode Design not implemented', 1);
                    return;
            end
            if n_XY(2)>0
                n_tot= n_XY(1)*n_XY(2);
            else
                n_tot= n_XY(1);
            end
        
            
        end

    end
end

function [xyz, nxyz, error] = get_normalized_layout(layout_design ,n_XY)
    % Returns the position and normal vector of the electrodes for a normalized 
    % layout with a specific radius 1 (normalized) centered in (0,0,0)

    error = build_error('', 0);
    xyz=[0, 0, 0];
    nxyz=[0, 0, 0];

    switch layout_design
        case 'Ring'
            [xyz, nxyz] = make_ring_inPlaneXY(n_XY(1));
        
        case {'Array_Grid 0', 'Array_Grid 45'}
            [xyz, nxyz] = make_grid_inPlaneXY(n_XY);
            
        % case {'Array_PolkaDot 0', 'Array_PolkaDot 45'}
        %    [xyz, nxyz] = make_polkaDot_inPlaneXY(n_XY);

        otherwise
            error = build_error('Electrode Design not implemented', 1);
            return;
    end
    
end



function [layout_r, f_pos, c_pos, n_vec, error] = param_for_elec_place(elec_place, layout_size, chamber_radius, chamber_limits)
    % Returns the parameters dependent fro each electrodes placemenent
    % - layout_r: specifific lenght of the layout to use 
    % - f_pos : factor vector to scale the position of the electrodes
    % - c_pos : center of the electrodes layout
    % - n_vec : eigen vector of the normal vector

    error = build_error('', 0);
    switch elec_place
        case 'Wall'
            layout_r = chamber_radius; % chamber radius
            f_pos= [layout_r,layout_r, 1];
            c_pos= [0, 0 , 0 ];
            n_vec= [1,1,0];

        case 'Top'
            layout_r = layout_size/2; % layout radius
            f_pos= [layout_r,layout_r, 1];
            c_pos= [0, 0 , chamber_limits(3,2) ];
            n_vec= [0,0,-1];

        case 'Bottom'
            layout_r = layout_size/2; % layout radius
            f_pos= [layout_r,layout_r, 1];
            c_pos= [0, 0 , chamber_limits(3,1)];
            n_vec= [0,0,1];
        otherwise
            error = build_error('Electrode position/design combination not implemented/incompatible', 1);
        end
end


function [elec_shape, error] = gen_elec_shape(elec_form, elec_size,elec_n_tot, fem_refinement, ELEC_FORMS)
    % Generate the shape vector of the electrodes neede for ng fmdl generation
    % see "ng_mk_gen_models" for the definition of the shape depending on the form selected
    % the shape is defined for each electrode

    error = build_error('', 0)
    switch elec_form
        case ELEC_FORMS{1} %'Circular'
            shape=[elec_size(1)/2,0,fem_refinement];

        case ELEC_FORMS{2} %'Rectangular'
            shape=[elec_size(1),elec_size(2),fem_refinement];

        case ELEC_FORMS{3} %'Point'
            shape=[0,0,fem_refinement];

        otherwise
            shape=[0,0,fem_refinement];
            error = build_error('Electrode form not implemented', 1);
    end
    elec_shape = shape.*ones(elec_n_tot,1);
end

function elec_obj = gen_elec_obj(elec_place, elec_n_tot)
    % Generate the object vector of the electrodes needed for ng fmdl generation
    % see "ng_mk_gen_models" for the definition of the object
    % the object (wall, top, bottom) is defined for each electrode
    
    place = lower(elec_place);
    for k=1:elec_n_tot
        elec_obj{k}= place;
    end
end


function [X] = RotationZ(pos, rot_angle)
    % Rotate the position vector containing
    % pos= [x, y, z, nx, ny, nz]
    % rotation angle = [rotX, RotY, RotZ] 
    
    gamma= rot_angle(3);
    Rz = [
        cos(gamma), -sin(gamma), 0;
        sin(gamma), cos(gamma), 0;
        0, 0, 1];
    Rz= [Rz,zeros(size(Rz));zeros(size(Rz)), Rz];
    X=(Rz*pos')';
    
end

function [xyz, nxyz] = make_ring_inPlaneXY(n)
    % create a ring arragement of n points in the xy plane 
    % and centered in (0,0,0) with a radius of 1
    % it returns the positions xyz, the direction vector
    % and the total number of electrodes

    theta = linspace(0, 2*pi, n + 1)';
    theta(end) = []; % 0 <= theta < 2*pi 

    xyz = [cos(theta), sin(theta), zeros(n,1)]; 
    nxyz = [cos(theta), sin(theta), ones(n,1)]; %here ones because the electrode can also be oriented in Z
    
end

function [xyz, nxyz] = make_grid_inPlaneXY(n_XY)
    % create a grid arragement of points in the xy plane 
    % and centered in (0,0,0) with a radius of 1
    % 
    % n_XY=[nb electrode in X, nb electrodes in Y]
    % if the nb electrodes in Y is zero than 
    % nb electrode in X

    radius=1;
    d= radius*2;% diameter of the grid (or diagonales)
    rat=n_XY(1)/n_XY(2);
    width_grid = [sqrt(1/(1+(1/rat)^2)) sqrt(1/(1+(rat)^2))]*d;
    for xy=1:2
        switch n_XY(xy)
            case 1 % case of 1 electrode 
                vector(xy).v= 0;
            otherwise % for mor thna 1 Electrodes
                vector(xy).v=linspace(-width_grid(xy)/2,width_grid(xy)/2,n_XY(xy));
        end
    end
    [x,y] = meshgrid(vector(1).v,vector(2).v);
    n_tot=n_XY(1)*n_XY(2); 

    % else % square array
    %     if ~(round(sqrt(n_XY(1)))^2==n_XY(1)) % verify if n is a^2
    %         warndlg('number of electrodes set to 16 (please give a a^2 number of electrodes for square Array_Grid) ');
    %         elec_n=[16, 0];
    %     end
    %     width_grid = d/sqrt(2);
    %     [x,y] = meshgrid(linspace( -width_grid/2,width_grid/2,sqrt(n_XY(1))));
    %     elec_n_tot=n_XY(1);
    % end

    xyz = [x(1:end)', y(1:end)', zeros(n_tot,1)];
    nxyz = [zeros(n_tot,1), zeros(n_tot,1), ones(n_tot,1)];
    
end


function [xyz, nxyz] = make_polkaDot_inPlaneXY(n_XY)

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
    
end



