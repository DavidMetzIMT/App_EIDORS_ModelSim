classdef EIT_chamber < handle
    properties
        type = 'eit_chamber'
        name % User specific name for the chamber
        boxSize %Dimension of the chamber in X, Y, Z
        femRefinement % Refinement value for FEM mesh generation
        form % Form of the Chamber "supported_forms"-method return the valid supported form types
    end

    properties (Access=private)
        FORMS ={'Cylinder', 'Cubic', '2D_Circ'};
        ALLOW_ELEC_PLACEMENT = [ % 'Wall', 'Top', 'Bottom'
            1,   1,   1 ; % 'Cylinder' 
            0,   1,   1 ; % 'Cubic'
            1,   1,   1 ; % '2D_Circ'
        ];
        height_2D = 0      
    end
    methods
        function obj = EIT_chamber(varargin)
            %EIT_CHAMBER Constructor Set chamber properties using varargin
            %
            % if varargin is not passed default values will be set 
            % varargin:
            %     name= varargin{1}; % User specific name; Default:'NameDesignOfChamber'
            %     boxSize=varargin{2}; % X, Y, Z; Default: [1,1,1]
            %     femRefinement=varargin{3}; Default: 0.5
            %     form= varargin{4}; % Cylinder, Cube, Circle, Rectangular; Default:'Cylinder'

            if nargin==4
                obj.name= varargin{1}; % User specific name
                obj.boxSize=varargin{2}; % X, Y, Z
                obj.femRefinement=varargin{3};
                obj.form= varargin{4}; % Cylinder, Cube, Circle, Rectangular
            else
                obj.name= 'NameDesignOfChamber'; % User specific name
                obj.boxSize=[5, 5, 2]; % X, Y, Z
                obj.femRefinement= 0.5;
                obj.form= obj.FORMS{1}; % Default:'Cylinder'
            end
        end

        function value = length(obj)
            %LENGTH Return the length of the chamber (size in X direction)
            value = obj.boxSize(1);
        end

        function value = width(obj)
            %WIDTH Return the width of the chamber (size in Y direction)
            value = obj.boxSize(2);            
        end

        function value = height(obj)
            %HEIGHT Return the height of the chamber (size in Z direction)
            value = obj.boxSize(3);
        end
        
        function l = box_limits(obj)
            %BOX_LIMITS Return the overall box size of the chamber in XYZ
            %
            % limits = [minX, maxX; minY, maxY; minZ, maxZ]
            l=[
                -obj.length()/2,obj.length()/2;
                -obj.width()/2,obj.width()/2;
                -obj.height()/2,obj.height()/2];
        end

        function r = min_radius(obj)
            %MIN_RADIUS Return the radius of a comprised circle in XY plane
            val= obj.form;
            switch val
                case obj.FORMS{1} % 'Cylinder'
                    r= obj.length()/2;        

                case obj.FORMS{2} % 'Cubic'
                    r= min([obj.length(),obj.width()])/2;
                    
                case obj.FORMS{3} % '2D_Circ'
                    r= obj.length()/2;
            end
        end

        function height_2D = get_height_2D(obj)
            height_2D= obj.height_2D
        end

        function obj = set.form(obj, val)
            %SET.FORM Set form of the chamber  7 

            % check if a valid form type has been passed
            if ~any(strcmp(obj.FORMS,val))
                return;
            end

            % set the value
            obj.form=val;
            sign_size= sum(double(obj.boxSize>0) .* [1,2,5]);
            % 1 (x>0), 2 (y>0) , 3(x,y>0), 5(z>0), 6(x, z>0), 7(y, z>0), 8(x, y, z>0)

            % and operate some automatic changes depending the form selected  
            switch val
                case obj.FORMS{1} % 'Cylinder'
                    if sign_size < 6 % x, z or y, z or x,y,z have to be >0
                        errordlg('Negative or zero XY dimensions are not supported' );
                        return;
                    end

                    % set box size in x and y identical
                    max_xy=max(obj.boxSize(1:2));
                    obj.boxSize(1:2)= [1,1] .*max_xy;

                case obj.FORMS{2} % 'Cubic'
                    if sign_size < 8 % all size have to be >0
                        errordlg('Negative or zero XYZ dimensions are not supported' );
                        return;
                    end

                case obj.FORMS{3} % '2D_Circ'
                    if sign_size < 1 % x or y or x,y have to be >0
                        errordlg('Negative or zero XY dimensions are not supported' );
                        return;
                    end

                    obj.boxSize(3)=0; % set z size to 0 as it is 2D!
                    % set box size in x and y identical
                    max_xy=max(obj.boxSize(1:2));
                    obj.boxSize(1:2)= [1,1] .*max_xy;
            end
        end

        function val = supported_forms(obj)
            %SUPPORTED_FORMS Returns the supported forms of chamber
            val = obj.FORMS;
        end

        function val = allowed_placement(obj)
            %ALLOWED_PLACEMENT Returns the allowed electrode position placements in the chamber
            index_actual_form = find(strcmp(obj.FORMS,obj.form));
            val = obj.ALLOW_ELEC_PLACEMENT(index_actual_form, :);
        end

        function shape = shape_for_ng(obj, index, ratio)
            %SHAPE_FOR_NG Returns the shape string used to generate a fmdl with EIDORS 
            % for more detail see "ng_mk_gen_models"
            % ['mainobj', index]
            radius    = num2str(obj.min_radius()*ratio);
            length    = num2str(obj.length()/2*ratio); % centered
            depth     = num2str(obj.width()/2*ratio); % centered
            height    = num2str(obj.height()/2*ratio); % centered 
            maxh      = num2str(obj.femRefinement*ratio);
            type= obj.form;
            switch type
                case obj.FORMS{1} % 'Cylinder'
                    shape = [
                        'solid wall', index ,'    = cylinder (0,0,0; 0,0,1;' radius '); \n', ...
                        'solid top', index ,'    = plane(0,0,' height ';0,0,1);\n' ...
                        'solid bottom', index ,' = plane(0,0,-' height ';0,0,-1);\n' ...
                        'solid mainobj', index ,' = top', index ,' and bottom', index ,' and wall', index ,' -maxh=' maxh ';\n'];

                case obj.FORMS{2} % 'Cubic'
                    shape = [
                        'solid wall', index ,'    =     plane (-' length ',-' depth ',-' height '; 0,-1,0)' ...
                        'and plane (-' length ',-' depth ',-' height '; -1,0,0)'...
                        'and plane (' length ',' depth ',' height '; 0,1,0)'...
                        'and plane (' length ',' depth ',' height '; 1,0,0); \n', ...
                        'solid top', index ,'    = plane(' length ',' depth ',' height ';0,0,1);\n' ...
                        'solid bottom', index ,' = plane(-' length ',-' depth ',-' height ';0,0,-1);\n' ...
                        'solid mainobj', index ,' = top', index ,' and bottom', index ,' and wall', index ,' -maxh=' maxh ';\n'];

                case obj.FORMS{3}% '2D_Circ'
                
                    %Need some width to let netgen work, but not too much so
                    % that it meshes the entire region
                    obj.height_2D = obj.min_radius()/5; % initial extimate
                    if obj.femRefinement>0
                        obj.height_2D = min(obj.height_2D,2*obj.femRefinement);
                    end

                    % obj.height_2D = height      
                    height = num2str(obj.height_2D)  
                    shape = [
                        'solid wall', index ,'   = cylinder (0,0,0; 0,0, ' height ';' radius '); \n', ...
                        'solid top', index ,'   = plane(0,0,' height ';0,0,1);\n' ...
                        'solid bottom', index ,' = plane(0,0,0;0,0,-1);\n' ...
                        'solid mainobj', index ,' = top', index ,' and bottom', index ,' and wall', index ,' -maxh=' maxh ';\n']

                otherwise
                    errordlg('wrong form of the chamber')
            end 
        end

        function pt = get_random_pt(obj)
            %GET_RANDOM_PT Return a random point in the the chamber
            z= obj.height()*(-1/2+rand());
            type= obj.form;
            switch type
                case {obj.FORMS{1}, obj.FORMS{3}} % 'Cylinder' ||'2D_Circ'
                    r = obj.min_radius()*rand();
                    alpha = 2*pi()*rand();
                    pt = [r*cos(alpha) r*sin(alpha) z];

                case obj.FORMS{2} % 'Cubic'
                    pt = [obj.length()*(-1/2+rand()) obj.width()*(-1/2+rand()) z];
                    
                otherwise
                    errordlg('wrong form of the chamber')
            end 
            
        end
    end

end