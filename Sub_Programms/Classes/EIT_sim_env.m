classdef EIT_sim_env
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name ='Simulation default'
        fmdl % Eidors_fmdl % the forward model from EIDORS
        imdl % Eidors_imdl % the inverse model from EIDORS
        objects EIT_object % objects put in the chamber
        mediumConduct % conductivity of the medium
        img_h % homogenious image only medium from EIDORS
        img_ih % inhomogenious image with the objects from EIDORS
        data_h % meas data for img_h from EIDORS (solving the fmdl)
        data_ih % meas data for img_ih from EIDORS (solving the fmdl)
        iimg  % inverse image from EIDORS (solving the imdl)
        greit % metrics fro evaluation the iimg


    end
    
    methods
        function obj = untitled3(inputArg1,inputArg2)
            %UNTITLED3 Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end
