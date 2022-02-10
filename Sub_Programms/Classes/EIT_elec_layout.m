classdef EIT_elec_layout

    properties (Access = public)
        elecNb % number of electrodes
        elecForm % Circular, Rectangular, Point
        elecSize % width, height
        elecPos % Wall, Top, Bottom
        arrangement % Ring, Grid, Polka Dot
        arrSize % X, Y, Z
    end

    properties (Access = protected)
        reset
    end


    methods
        
        function obj = EIT_elec_layout(varargin)
            % Set the prperties from the object
            if nargin==1
                var= varargin{1}
                obj.reset = 0;
                obj.elecNb=var.Number; % number of electrodes
                obj.elecForm=var.Form; % Circular, Rectangular, Point
                obj.elecSize=[var.Diameter_Width, var.Height]; % width, height
                obj.elecPos=var.Position; % Wall, Top, Bottom
                obj.arrangement=var.Design; % Ring, Grid, Polka Dot
                obj.arrSize=var.Diameter; % X, Y, Z
            else
                obj.reset = 1;
            end
        end

        function value = is_reset(obj)
            value = obj.reset;
        end
    end

    % properties (Access = private)
    %     type = 'elec_layout'
    % end

end