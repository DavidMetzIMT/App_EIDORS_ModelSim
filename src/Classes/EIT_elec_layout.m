classdef EIT_elec_layout < handle
    %EIT_ELEC_LAYOUT Class defining an electrode layout

    properties
        type = 'eit_elec_layout'
        elecNb % number of electrodes
        elecForm % form of the electrode Circular, Rectangular, Point
        elecSize % width, height of the electrode
        elecPlace % where in the chamber the electrode are placed e.g.Wall, Top, Bottom
        layoutDesign % Design of the electrode layout, e.g. Ring, Grid, Polka Dot
        layoutSize % Design size (X, Y, Z)
        zContact% Impedance contact of the electrodes
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
            %EIT_ELEC_LAYOUT Constructor set the prperties from the object electrodes layout
            %
            % if varargin is not passed default values will be set
            % varargin{1} >> has to have the following struct (given by the "get_struct_4_gui"-method):
            %       - Number 
            %       - Form 
            %       - Diameter_Width 
            %       - Height
            %       - Position
            %       - Design 
            %       - Diameter


            if nargin==1
                var= varargin{1};
                obj.reset = 0;
                obj.elecNb=var.Elec_Nb; 
                obj.elecForm=var.Elec_Form; 
                obj.elecSize=[var.Elec_Width, var.Elec_Height]; 
                obj.elecPlace=var.Position; 
                obj.layoutDesign=var.Design; 
                obj.layoutSize=var.Diameter;
                obj.zContact=var.Zcontact;
            else
                obj.reset = 1;
                obj.elecNb=16; 
                obj.elecForm=obj.ELEC_FORMS{1}; %'Circular'
                obj.elecSize=[0.5, 0]; 
                obj.elecPlace=obj.ELEC_PLACE{1}; % Wall
                obj.layoutDesign=obj.LAYOUT_DESIGN{1}; %'Ring'
                obj.layoutSize = 4;
                obj.zContact = 0.01;
            end
        end

        function value = is_reset(obj)
            %IS_RESET Return if the present object has been resetted to default values
            value = obj.reset;
        end

        function var = get_struct_4_gui(obj)
            %GET_STRUCT_4_GUI Return the layout as a struct (this struct should be used to create an EIT_elec_layout)
            % attention here the order count
            var.Design          = obj.layoutDesign; 
            var.Position        = obj.elecPlace; 
            var.Diameter        = obj.layoutSize; 
            var.Elec_Nb          = obj.elecNb; 
            var.Elec_Form            = obj.elecForm; 
            var.Elec_Width  = obj.elecSize(1);
            var.Elec_Height          = obj.elecSize(2);
            var.Zcontact =obj.zContact;
        end

        function format = get_format_4_gui(obj)
            %GET_FORMAT_4_GUI Return format of each field of the returned struct from "get_struct_4_gui"-method 
            % attention here the order count
            format={...
                obj.supported_layouts(),...
                obj.supported_elec_pos(),...
                'numeric',...
                'numeric',...
                obj.supported_elec_forms(),...
                'numeric',...
                'numeric',...
                'numeric'};
            ;
        end

        function cellarray = supported_elec_forms(obj)
            %SUPPORTED_ELEC_FORMS Return all supported electrode forms
            cellarray = obj.ELEC_FORMS;
        end
        function cellarray = supported_layouts(obj)
            %SUPPORTED_LAYOUTS Return all supported electrodes layouts
            cellarray = obj.LAYOUT_DESIGN;
        end
        function cellarray = supported_elec_pos(obj)
            %SUPPORTED_ELEC_POS Return all supported electrode placement
            cellarray = obj.ELEC_PLACE;
        end

        function val = allowed_placement(obj)
            %ALLOWED_PLACEMENT Return the allowed placement for the actual design
            index_actual_layout = find(strcmp(obj.LAYOUT_DESIGN, obj.layoutDesign));
            val = obj.ALLOW_ELEC_PLACEMENT(index_actual_layout, :);
        end

        function r = elec_radius(obj)
            %ELEC_RADIUS Return the actual radius of the electrode
            %       radius = elecSize(1)/2
            
            % TODO change that with the forms....
            r= obj.elecSize(1)/2;
        end

        function [elec_pos, elec_shape, elec_obj, z_contact, error] = data_for_ng(obj, chamber)
            %DATA_FOR_NG Returns data about the electrodes used to generate a fmdl with EIDORS 
            % for more detail see "ng_mk_gen_models"
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
            z_contact=[];
            % elec_pos_2d=[];

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

            %% Generate z-contact of electrodes
            z_contact= ones(n_tot,1)*obj.zContact;
            
            %% Test length of the ouput values
            if length(elec_obj)~= size(elec_pos, 1)
                error = build_error('elec_pos and elec_obj don''t have same size', 1);
                return;
            end
            if size(elec_shape, 1)~=size(elec_pos, 1)
                error = build_error('elec_pos and elec_shape don''t have same size', 1);
                return;
            end
            if length(z_contact)~= size(elec_pos, 1)
                error = build_error('elec_pos and z_contact don''t have same size', 1);
                return;
            end

        end

        function error = check_layout(obj,n_XY, n_tot, layout_r, chamber)
            %CHECK_LAYOUT  Check the electrode layout c
            %   it check:
            %       - the compatiblity between layout, electrode placement,
            %       chamber form 
            %       - if electrodes are contained in chamber
            %       - if electrodes are not overlapping

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
            %GET_NB_ELEC check and compute the electrodes numbers
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


% ******************************************************************************
% ******************************************************************************
% ******************************************************************************
% ******************************************************************************

function [xyz, nxyz, error] = get_normalized_layout(layout_design ,n_XY)
    %GET_NORMALIZED_LAYOUT Returns the position and normal vector of the electrodes for a normalized 
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
    %PARAM_FOR_ELEC_PLACE Return the parameters dependent for each electrodes placement
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
    %GEN_ELEC_SHAPE Generate the shape vector of the electrodes neede for ng fmdl generation
    % see "ng_mk_gen_models" for the definition of the shape depending on the form selected
    % the shape is defined for each electrode

    error = build_error('', 0);
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
    %GEN_ELEC_OBJ Generate the object vector of the electrodes needed for ng fmdl generation
    % see "ng_mk_gen_models" for the definition of the object
    % the object (wall, top, bottom) is defined for each electrode
    
    place = lower(elec_place);
    for k=1:elec_n_tot
        elec_obj{k}= place;
    end
end


function [X] = RotationZ(pos, rot_angle)
    %ROTATIONZ Rotate the electrode position vector arround Z 
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

function [xyz, nxyz] = make_polkaDot_inPlaneXY(n_XY)
    %MAKE_POLKADOT_INPLANEXY Create a polkadot arragement of points in the xy plane 

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





