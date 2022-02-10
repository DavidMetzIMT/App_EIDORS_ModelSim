classdef EIT_chamber

    properties (Access = public)
        name % User specific name
        boxSize % X, Y, Z
        femRefinement
        form % Cylinder, Cube, Circle, Rectangular
    end

    % properties (Access = private)
    %     type = 'chamber'
    % end

    methods (Access = public)
        function obj = EIT_chamber(varargin)
            % Set the prperties from the object
            if nargin==4
                obj.name= varargin{1}; % User specific name
                obj.boxSize=varargin{2}; % X, Y, Z
                obj.femRefinement=varargin{3};
                obj.form= varargin{4}; % Cylinder, Cube, Circle, Rectangular
            else
                obj.name= 'Chamber_name'; % User specific name
                obj.boxSize=[1, 1, 1]; % X, Y, Z
                obj.femRefinement= 0.5;
                obj.form= 'Cylinder'; % Cylinder, Cube, Circle, Rectangular
            end


        end

        
        function obj = set_chamber(obj, name, box, fem_refinement, form)
            % Set the prperties from the object
            obj.name= name; % User specific name
            obj.boxSize=box; % X, Y, Z
            obj.femRefinement= fem_refinement;
            obj.form= form; % Cylinder, Cube, Circle, Rectangular
            obj= obj;
        end
    end
 
end