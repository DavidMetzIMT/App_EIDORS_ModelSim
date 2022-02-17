classdef EIT_object
    %EIT_object Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        type % cell, cylinder, sphere
        pos % X, Y, Z
        dim % depend on the type
        conduct
    end

    properties (Access = protected)
        reset
    end

    properties (Access = private)
        OBJ_TYPE ={'Cell', 'Sphere', 'Cylinder'};
    end
    
    methods
        function obj = EIT_object(varargin)
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
                obj.type=var.Type; % 'Cell', 'Sphere', 'Cylinder'
                obj.pos=str2num_array(var.Position); % position of the object
                obj.dim=str2num_array(var.Dimensions); % dimension of the objectr
                obj.conduct=str2num_array(var.Conductivity); % conductivity
            else
                obj.reset = 1;
                obj.type=obj.OBJ_TYPE{1};
                obj.pos=[0,0,0];
                obj.dim=[0.1]; 
                obj.conduct=[0.2]; 
            end
            
        end

        function var = get_struct_4_gui(obj)
            % attention here the order count
            var.Type        = obj.type; 
            var.Position    = [ '[' num2str(obj.pos) ']']; 
            var.Dimensions  = [ '[' num2str(obj.dim) ']']; 
            var.Conductivity= [ '[' num2str(obj.conduct) ']']; 
            
        end

        function obj=set.pos(obj, value)
            if length(value)~=3
                warndlg('Position of object has been set to [0,0,0]');
                obj.pos= [0,0,0];
            else
                obj.pos= value;

            end
            
        end

        function output = allowed_type(obj)
            output =obj.OBJ_TYPE;
        end

        function value = is_reset(obj)
            value = obj.reset;
        end

        function func = object_func(obj, ratio)
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
            % return the conductivity vector correspoding of the object for
            %the FEM elem defined in fmdl
            % depending on the object different conduct for each layers are returned
            % conduct = [elem_data for layer1, elem_data for layer2,...]

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

    end
end

