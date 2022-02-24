classdef EIT_object
    %EIT_OBJECT Define an object placed in the chamber
    %   object has the properties
    %       - type : type of the object "allowed_type" return valid types
    %       - pos : position of the object
    %       - dim : dimension of the object
    %       - conduct :  layer conductivity of the object (for ex [0.1,1; 0.2,0.60] for a cell with 60% nucleus)
    %                    conduct(i,1): conduct layer i
    %                    conduct(i,2): is size ratio of layer i

    properties
        type % type of the object "allowed_type"-method return valid types
        pos  % position of the object
        dim  % dimension of the object
        conduct % layer conductivity of the object (for ex [0.1,1; 0.2,0.60] for a cell with 60% nucleus)
                % conduct(i,1): conduct layer i
                % conduct(i,2): is size ratio of layer i
    end

    properties (Access = protected)
        reset
    end

    properties (Access = private)
        OBJ_TYPE ={'Cell', 'Sphere', 'Cylinder'}; %Object types implemented
    end
    
    methods
        function obj = EIT_object(varargin)
            %EIT_OBJECT Constructor Set object properties using varargin
            % 
            % if varargin is not passed default values will be set
            % varargin{1} >> has to have the following struct (given by the "get_struct_4_gui"-method):
            %    - Type % type of the objectsee "allowed_type"-method. Default = 'Cell'
            %    - Position % Position of the object. Default = [0,0,0]
            %    - Dimensions % Dimension of object . Default = [0.1]
            %    - Conductivity %layer conductivity of the object (for ex [0.1,1; 0.2,0.60] for a cell with 60% nucleus)
            %                        conduct(i,1): conduct layer i
            %                        conduct(i,2): is size ratio of layer i
            %                   Default = [0.2] (equivalent to [0.2,1])
            if nargin==1
                var= varargin{1};
                obj.reset = 0;
                obj.type=var.Type; 
                obj.pos=str2num_array(var.Position); 
                obj.dim=str2num_array(var.Dimensions); 
                obj.conduct=str2num_array(var.Conductivity);
            else
                obj.reset = 1;
                obj.type=obj.OBJ_TYPE{1}; % 'Cell'
                obj.pos=[0,0,0]; 
                obj.dim=[0.1]; 
                obj.conduct=[0.2]; 
            end
            
        end

        function var = get_struct_4_gui(obj)
            %GET_STRUCT_4_GUI Return the object as a struct (this struct should be used to create an EIT_object)
            
            % attention here the order count
            var.Type        = obj.type; 
            var.Position    = num_array2str(obj.pos); 
            var.Dimensions  = num_array2str(obj.dim); 
            var.Conductivity= num_array2str(obj.conduct); 
        end

        function format = get_format_4_gui(obj)
            %GET_FORMAT_4_GUI Return format of each field of the returned struct from "get_struct_4_gui"-method 

            % attention here the order count
            format={obj.OBJ_TYPE, 'char', 'char', 'char' };
        end

        function obj=set.type(obj, value)
            %SET.TYPE Set type of the object

            % check if a valid object type has been passed
            if isempty(find(strcmp(obj.OBJ_TYPE, value)))
                errordlg('wrong type value for the object');
                obj.type= obj.OBJ_TYPE{1}; % set default value
            else
                obj.type= value;
            end
        end

        function obj=set.pos(obj, value)
            %SET.POS Set position of the object

            % check if the passed postion has 3 elements
            val= reshape(value,1,[]); %flatten the input array/vector
            if length(val)~=3 % if the length is different 
                warndlg('Position of object has been set to [0,0,0]');
                obj.pos= [0,0,0]; % set default value
            else
                obj.pos= val;
            end
        end

        function output = allowed_type(obj)
            %ALLOWED_TYPE Return the implemented object types
            output =obj.OBJ_TYPE;
        end

        function value = is_reset(obj)
            %IS_RESET Return if the present object has been resetted to default values
            value = obj.reset;
        end

        function func = object_func(obj, ratio)
            %OBJECT_FUNC Return a 3D function f(x,y,z) which assert if the pt (xyz) is contained in the object
            % the func return logical array of size (nb_points, 1)
            % artion can be used to select a defined pourcentage of the object

            p = obj.pos;
            d = obj.dim*ratio; % d(1) is radius
            type =obj.type;
            switch type
                case obj.OBJ_TYPE{1}%'Cell'
                    func = @(x,y,z) (x-p(1)).^2 + (y-p(2)).^2+(z-p(3)).^2 <= d(1)^2;

                case obj.OBJ_TYPE{2}%'Sphere'
                    func = @(x,y,z) (x-p(1)).^2 + (y-p(2)).^2+(z-p(3)).^2 <= 5^2;
                    
                case obj.OBJ_TYPE{3}%'Cylinder'
                    func = @(x,y,z) (x-p(1)).^2 + (y-p(2)).^2 <= (ones(size(y))*d(1)).^2 & z>=p(3);
            end
        end
        
        function conduct = get_conduct_data(obj, fmdl)
            %GET_CONDUCT_DATA Return a conductivity vector/array correspoding to the object for the passed fmdl (from EIDORS)
            %   the length of thh vector correxpond to the nb of FEM elems contained
            %   in that fmdl
            %   conductivity array is : 
            %             conduct(1:nb_elems, i) = conduct of layer i

            layer_conduct=obj.conduct;
            for layer=1:size(layer_conduct,1)
                % generating the whole random cell (cytoplasm)
                layer_conduct = layer_conduct(layer,1);
                if size(layer_conduct,2)>1
                    layer_ratio = layer_conduct(layer,2);
                else
                    layer_ratio = 1;
                end

                select_fcn = obj.object_func(layer_ratio);
                % to simplify
                conduct(:,layer) = (elem_select(fmdl, select_fcn)~=0)*layer_conduct;
            end
            
        end

        function obj = generate_random(obj, user_entry, chamber)
            %GENERATE_RANDOM Generate a random object out of user entry and chamber object
            %   type is set from the user entry
            %   pos is randomly generate out of the passed chamber
            %   dim is randomly genrateed out of the range from user entry
            %   conduct is randomly generated out of the range from user entry

            arguments
                obj
                user_entry UserEntry
                chamber EIT_chamber
            end

            obj.type=user_entry.objectType; % set type
            obj.pos= chamber.get_random_pt(); % generate a position in chamber

            % generate a dimension (radius)
            obj.dim=random_val_from_range(user_entry.objectDimRange(1,:));
            
            % generate conductivity
            range_conduct = user_entry.objectConductRange; % should be ok to used
            for layer =1:size(range_conduct,1) % we have a multiple layer cell
                obj.conduct(layer,1)=random_val_from_range(range_conduct(layer,1:2));
                obj.conduct(layer,2)= range_conduct(layer,3); % ratio
            end
            
        end




    end
end


