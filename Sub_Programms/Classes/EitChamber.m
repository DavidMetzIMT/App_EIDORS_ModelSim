classdef EitChamber

    properties (Access = public)
        name % User specific name
        boxSize % X, Y, Z
        femRefinement
        form % Cylinder, Cube, Circle, Rectangular
        electrodeLayout ElectrodeLayout
    end

    properties (Access = private)
        type = 'Chamber'
    end

    methods (Access = public)
        function obj = EitChamber()
            
        end
    end

end