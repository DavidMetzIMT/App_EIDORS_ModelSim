classdef ElectrodeLayout

    properties (Access = public)
        elecNb % number of electrodes
        elecForm % Circular, Rectangular, Point
        elecSize % width, height
        elecPos % Wall, Top, Bottom
        arrangement % Ring, Grid, Polka Dot
        size % X, Y, Z

    end

    properties (Access = private)
        type = 'electrodes_layout'
    end

end