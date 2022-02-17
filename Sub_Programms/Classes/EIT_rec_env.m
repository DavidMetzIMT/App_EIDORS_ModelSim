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


            meas=load(uigetfile('.mat', path));

            f=fieldnames(meas)
            if isempty(find(strcmp(f, 'X_ih'))) | isempty(find(strcmp(f, 'X_h')))
                errordlg('Loaded file should contain a variable Xih and Xh')
                return;
            end

            % verify if data has same length as expected!!
            
            if length(meas.X_ih) ~= length(obj.data_ih.meas)
                errordlg(['X_ih should have a size of ' num2str(size(obj.data_ih.meas)) ] )
                return;
            end
            if length(meas.X_h)~= length(obj.data_h.meas)
                errordlg(['X_h should have a size of ' num2str(size(obj.data_ih.meas)) ])
                return;
            end
            
            obj.data_ih.meas=meas.X_ih;
            obj.data_h.meas=meas.X_h;
            
        end

    end
end
