classdef EIT_rec_env < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        imdl % the inverse model from EIDORS
        data_h % meas data for homogenious meas
        data_ih % meas data for inhomogenious meas
        iimg  % inverse image from EIDORS (solving the imdl)
        greit % metrics for evaluation the iimg
    end
    
    methods




        function solve_inv(obj)


        %     %% make inv_model
        %    disp('Simulation: create imdl')
        %    disp('please wait ...')
        %    create_imdl()
        %    disp('Simulation: imdl created!')
        %    %% make inv model for sim
        %    EIDORS.sim.imdl= EIDORS.imdl;
        %    EIDORS.sim.imdl.name = ['EIT inv_mdl for fwd_mdl: ' EIDORS.sim.fmdl.name];
        %    EIDORS.sim.imdl.fwd_model = EIDORS.sim.fmdl;


           
           disp('Reconstruction: Start')
           disp('please wait ...')
           
           if contains(obj.imdl.reconst_type, 'difference')
            obj.iimg = inv_solve(obj.imdl, obj.data_h,obj.data_ih);
           else
               obj.imdl.reconst_type= 'absolute'
               tmp=obj.data_ih;
               tmp.meas= zeros(size(obj.data_ih.meas));

               obj.iimg = inv_solve(obj.imdl, obj.data_ih);

           end
           
           disp('Reconstruction: Done!')

        end


        function set_data_meas(obj, data_ih, data_h)

            obj.data_ih=data_ih;
            obj.data_h=data_h;
        end



        function obj=load_measurements(obj, path)
            %verify that a fmdl has been cearted!


            meas=load(uigetfile('.m', path));

            % verify if data has same length as expected!!

            obj.set_data_meas(meas.Xih, meas.Xh);


            
        end

    end
end
