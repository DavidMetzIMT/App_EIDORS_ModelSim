classdef EIT_rec_env < handle
    %EIT_REC_ENV EIT reconstruction environement  (EIDORS based)
    %   from here an eit image 'iimg' can be reconstructed based on 
    %   the 'data_h' and 'data_ih' and using the inverse model 'imdl'
    
    properties
        type= 'eit_rec_env'
        imdl % the inverse model from EIDORS
        data_h % meas data for homogenious meas
        data_ih % meas data for inhomogenious meas
        iimg  % inverse image from EIDORS (solving the imdl)
        greit % metrics for evaluation the iimg
    end

    properties (Access = private)
        REC_TYPE ={'difference'}; % Reconstruction type supported
    end
    
    methods
        function solve_inv(obj)
            %SOLVE_INV Solve the eit inverse problem (Reconstruction) to compute the inverse eit image 'iimg'
            
            %Check rec env is ready to solve inv problem
            if ~obj.is_rec_valid() return; end

            normalize = false;

            disp('Reconstruction: Start')
            disp('please wait ...')
            data_h = obj.data_h;
            data_ih =obj.data_ih;

            if normalize
                disp('normalized')
                data_h.meas = obj.data_h.meas./obj.data_h.meas;
                data_ih.meas =obj.data_ih.meas./obj.data_h.meas;
            end

            if contains(obj.imdl.reconst_type, obj.REC_TYPE{1}) % 'difference'
                obj.iimg = inv_solve(obj.imdl, data_h, data_ih);
            else
                errordlg('Recontruction typ not implemented')
                % obj.imdl.reconst_type= 'absolute'
                % %    tmp=obj.data_ih;
                % %    tmp.meas= zeros(size(obj.data_ih.meas));
                % obj.iimg = inv_solve(obj.imdl, obj.data_ih); 
            end
            disp('Reconstruction: Done!')
        end

        function set_data_meas(obj, data_ih, data_h)
            %SET_DATA_MEAS Set the measurement data

            pass_h = valid_data(data_h);
            pass_ih = valid_data(data_ih);
            if (pass_h && pass_ih)
                obj.data_ih=data_ih;
                obj.data_h=data_h;
            else if isnumeric(data_h) && isnumeric(data_ih)
                obj.data_ih.meas=data_ih;
                obj.data_h.meas=data_h;
                else
                    errordlg('data_ih, data_h soudl be eidorr data type or numeric')
                end
            end
            
        end

        function obj=load_measurements(obj, path)
            %LOAD_MEASUREMENTS Load measurements out of a mat-file containing a variable 'X_ih' and 'X_h'
            
            meas=load(uigetfile('.mat', path));
            f=fieldnames(meas)
            if isempty(find(strcmp(f, 'X_ih'))) || isempty(find(strcmp(f, 'X_h')))
                errordlg('Loaded file should contain a variable X_ih and X_h')
                return;
            end

            % % verify if data has same length as expected!!
            % if length(meas.X_ih) ~= length(obj.data_ih.meas)
            %     errordlg(['X_ih should have a size of ' num2str(size(obj.data_ih.meas)) ] )
            %     return;
            % end
            % if length(meas.X_h)~= length(obj.data_h.meas)
            %     errordlg(['X_h should have a size of ' num2str(size(obj.data_ih.meas)) ])
            %     return;
            % end
            
            obj.data_ih.meas=reshape(meas.X_ih,[length(meas.X_ih),1]);
            obj.data_h.meas=reshape(meas.X_h,[length(meas.X_h),1]);

            obj.set_data_meas(obj.data_ih,obj.data_h)
        end
    end

    methods (Access = private)


        function is = is_rec_valid(obj)
            %IS_DATA_VALID Return if the data are correspond to the imdl.
            is = 0;
            %Check imdl has been set
            pass = valid_inv_model(obj.imdl);
            if ~pass
                errordlg('Inverse model need to be set')
                return;
            end

            %Check data_h and data_ih are 'data'-type

            pass_h = valid_data(obj.data_h);
            pass_ih = valid_data(obj.data_ih);
            if ~(pass_h & pass_ih)
                errordlg('data_h and data_ih have to be "data"-type')
                return;
            end

            %Check data_h.meas and data_ih.meas have same length as imdl.fwd_model.meas_select 'data'-type
            n_h= length(obj.data_h.meas);
            n_ih= length(obj.data_ih.meas);
            n_meas= sum(obj.imdl.fwd_model.meas_select);
            if ~(n_h == n_meas & n_ih == n_meas)
                errordlg('data_h and data_ih have not compatible with the imdl/fwd_model: wrong amout of measurements')
                return;
            end

            is=1;            
        end









    end
end
