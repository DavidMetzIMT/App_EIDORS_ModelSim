classdef EIT_chamber < handle
    properties
        name % User specific name
        boxSize % X, Y, Z
        femRefinement
        form % Cylinder, Cube, Circle, Rectangular
    end

    properties (Access=private)
        FORMS ={'Cylinder', 'Cubic', '2D_Circ'};
        %ELEC_PLACE ={'Wall', 'Top', 'Bottom'};
        ALLOW_ELEC_PLACEMENT = [ % 'Wall', 'Top', 'Bottom'
            1,   1,   1 ; % 'Cylinder' 
            0,   1,   1 ; % 'Cubic'
            1,   0,   0 ; % '2D_Circ'
        ];      
    end
    methods
        function obj = EIT_chamber(varargin)
            % Set the properties of an object chamber
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
            %Return the size of the chamber in x direction defined as length

            value = obj.boxSize(1);
        end

        function value = width(obj)
            %Return the size of the chamber in y direction defined as width

            value = obj.boxSize(2);            
        end

        function value = height(obj)
            %Return the size of the chamber in Z direction defined as height

            value = obj.boxSize(3);
        end
        
        function l = box_limits(obj)
            %Returns the limits of the chamber in the 3 xyz directions
            % l= [minX, maxX; minY, maxY; minZ, maxZ]

            l=[
                -obj.length()/2,obj.length()/2;
                -obj.width()/2,obj.width()/2;
                -obj.height()/2,obj.height()/2];
        end

        function r = min_radius(obj)
            % return the radius of the comprised circle
            % radius in the xy_plane

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


        function obj = set.form(obj, val)
            %Setter for "form"

            % check if correct form has been transmitted
            if ~any(strcmp(obj.FORMS,val))
                return;
            end

            % set the value
            obj.form=val;

            % and operate some automatic changes depending the form selected  
            switch val
                case obj.FORMS{1} % 'Cylinder'
                    % set box size in x and y identical
                    if obj.boxSize(1)>0 
                        obj.boxSize(2)=obj.boxSize(1);
                    elseif obj.boxSize(2)>0
                        obj.boxSize(1)=obj.boxSize(2);
                    else 
                        errordlg('Negative X Y dimensions not suported' );
                    end
                case obj.FORMS{2} % 'Cubic'

                case obj.FORMS{3} % '2D_Circ'
                    % set z size to 0 as it is 2D!
                    obj.boxSize(3)=0; 
                    % set box size in x and y identical
                    if obj.boxSize(1)>0 
                        obj.boxSize(2)=obj.boxSize(1);
                    elseif obj.boxSize(2)>0
                        obj.boxSize(1)=obj.boxSize(2);
                    else 
                        errordlg('Negative X Y dimensions not suported' );
                    end
            end
            
        end

        function val = supported_forms(obj)
            %Returns the supported chamber forms

            val = obj.FORMS;
        end
        function val = allowed_placement(obj)
            %Returns the supported chamber forms

            index_actual_form = find(strcmp(obj.FORMS,obj.form));
            val = obj.ALLOW_ELEC_PLACEMENT(index_actual_form, :);
        end

        function shape = shape_for_ng(obj)
            %Returns the shape string used to generate a fmdl with EIDORS 
            % using "ng_mk_gen_models"

            radius    = num2str(obj.min_radius());
            length    = num2str(obj.length()/2); % centered
            depth     = num2str(obj.width()/2); % centered
            height    = num2str(obj.height()/2); % centered 
            maxh      = num2str(obj.femRefinement);
            type= obj.form;
            switch type
                case obj.FORMS{1} % 'Cylinder'
                    shape = [
                        'solid wall    = cylinder (0,0,0; 0,0,1;' radius '); \n', ...
                        'solid top    = plane(0,0,' height ';0,0,1);\n' ...
                        'solid bottom = plane(0,0,-' height ';0,0,-1);\n' ...
                        'solid mainobj= top and bottom and wall -maxh=' maxh ';\n'];

                case obj.FORMS{2} % 'Cubic'
                    shape = [
                        'solid wall    =     plane (-' length ',-' depth ',-' height '; 0,-1,0)' ...
                        'and plane (-' length ',-' depth ',-' height '; -1,0,0)'...
                        'and plane (' length ',' depth ',' height '; 0,1,0)'...
                        'and plane (' length ',' depth ',' height '; 1,0,0); \n', ...
                        'solid top    = plane(' length ',' depth ',' height ';0,0,1);\n' ...
                        'solid bottom = plane(-' length ',-' depth ',-' height ';0,0,-1);\n' ...
                        'solid mainobj= top and bottom and wall -maxh=' maxh ';\n'];

                case obj.FORMS{3}% '2D_Circ'
                    shape = [0, obj.length()/2, obj.femRefinement];
                otherwise
                    errordlg('wrong form of the chamber')
            end 
        end

    end
 
end