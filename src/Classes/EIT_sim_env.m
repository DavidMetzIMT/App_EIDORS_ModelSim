classdef EIT_sim_env < matlab.mixin.Copyable % a hanlde with copy methods
    %EIT_SIM_ENV Simulation environement of EIT Measurements using EIDORS Toolbox
    %      
    properties
        type  = 'eit_sim_env';  
        name ='Simulation default'
        fmdl % "fwd_model" object from EIDORS
        objects EIT_object % objects put in the chamber
        mediumConduct % conductivity of the medium
        img_h % homogenious image only medium from EIDORS
        img_ih % inhomogenious image with the objects from EIDORS
        data_h % meas data for img_h from EIDORS (solving the fmdl)
        data_ih % meas data for img_ih from EIDORS (solving the fmdl)
        data_hn % meas data for img_h from EIDORS (solving the fmdl)
        data_ihn % meas data for img_ih from EIDORS (solving the fmdl)
        noise_SNR
    end

    properties (Access = private)
        SOLVER = {'eidors_default', 'fwd_solve_1st_order', 'aa_fwd_solve'}
        JACOBIAN = {'eidors_default', 'jacobian_adjoint','aa_calc_jacobian'}
        SYS_MAT = {'eidors_default','system_mat_1st_order', 'aa_calc_system_mat'}
        PERM_SYM = {'n'}
        reset_object= false
    end
    
    methods
        function obj = EIT_sim_env()
            %EIT_SIM_ENV Constructor create a default object (see "EIT_object") in a medium with a condutivity of 1
            obj.objects= EIT_object();
            obj.mediumConduct=1;
            obj.noise_SNR=20;
        end
        
        function reset_objects(obj)
            %RESET_OBJECTS Reset the objects to one default EIT_object
            %     in that case obj.objects(1).is_reset()==true
            obj.objects=EIT_object();
            obj.reset_object= true;
        end
        
        function add_object(obj, object)
            %ADD_OBJECT Append an EIT_object to obj.objetcs
            %   
            if ~isa(object, 'EIT_object')
                errordlg('object has to be an EIT_object cls')
                return;
            end
            if obj.reset_object==true
                obj.objects(1)= object;
                obj.reset_object= false;
            else
                obj.objects(length(obj.objects) + 1 ) = object;
            end

        end

        function struct4gui = get_objects_4_gui(obj)
            %GET_OBJECTS_4_GUI Returns the objects as a struct array for the display in gui
            for i=1:length(obj.objects)
                struct4gui(i)=obj.objects(i).get_struct_4_gui();
            end
        end

        function add_text= get_add_text(obj, chamber)
            % GET_ADD_TEXT return the additional text for fem construction of the objects
            add_text= '';
            for i=1:length(obj.objects)
                add_text=strcat(add_text, obj.objects(i).get_add_text(chamber, i));
            end
        end
        
        function solve_fwd(obj)
            %SOLVE_FWD Solve the fwd problem of the homogenious and inhomogenious image to get the corresponding measurements 
            obj.gen_homogenious_image();
            obj.gen_inhomogenious_image();
            
            obj.data_h = fwd_solve(obj.img_h);
            obj.data_ih = fwd_solve(obj.img_ih);

            noise_ratio= noise_dB_ratio(obj.noise_SNR);
            
            obj.data_hn = add_noise(noise_ratio, obj.data_h);
            obj.data_ihn = add_noise(noise_ratio, obj.data_ih);
        end


        function gen_homogenious_image(obj)
            %GEN_HOMOGENIOUS_IMAGE Generate the homogenious image "img_h" 
            %      by setting the conductivity of the chamber using the 
            %      conductivity of the medium
            obj.img_h = mk_image(obj.fmdl, obj.mediumConduct);
            obj.img_h.fwd_solve.get_all_nodes=0;
        end

        function gen_inhomogenious_image(obj)
            %GEN_INHOMOGENIOUS_IMAGE Generate the inhomogenious image "img_ih" 
            %      by setting the conductivity of the chamber using the
            %      conductivity of the medium and those of the objects

            for o=1:size(obj.objects,2)
                conduct(:,:,o) = obj.objects(o).get_conduct_data(obj.fmdl);
            end

            % handling the cell overlapping by taking only the max value of
            % the conductivity on each layers
            conduct_data= zeros(size(conduct(:,1,1))); % init to 0

            for layer=1:size(conduct,2)
                l_conducts= conduct(:,layer,:);
                l_total_conduct= sum(l_conducts, 3); % sum all the columns to init the layer conduct
                overlapping_indx = find(sum(l_conducts~=0 , 3) >= 2);
                if any(overlapping_indx)
                    l_total_conduct(overlapping_indx)= max(l_conducts(overlapping_indx,:),[],2);
                end
                elmt_set = find(l_total_conduct~=0);
                if any(elmt_set)
                    conduct_data(elmt_set)= l_total_conduct(elmt_set);
                end
            end
            
            elmt_set = find(conduct_data==0);
            if any(elmt_set)
                conduct_data(elmt_set)= obj.mediumConduct;
            end

            obj.img_ih = mk_image(obj.fmdl, conduct_data);

        end

        function set.fmdl(obj, fwd_model)
            %SETTER of fmdl
            %   if fwd_model can be an obj from the class "Eidors_fmdl" or 
            %   an fwd_model object from EIDORS toolbox 
            if isempty(fwd_model)
                obj.fmdl=fwd_model;
                return;
            end
            if  isequal(class(fwd_model),'Eidors_fmdl')
                fwd_model=fwd_model.fmdl();
            end
            if valid_fwd_model(fwd_model)
                obj.fmdl=fwd_model;
            else
                disp('ERROR TYPE: fwd_model could not be set')
            end
        end

        function clean_fmdl(obj)
            obj.fmdl=[];
            obj.img_h.fwd_model=[];
            obj.img_ih.fwd_model=[];
            
        end

        function output = reset_fmdl(obj, fmdl)
            obj.fmdl=fmdl;
            obj.img_h.fwd_model=fmdl;
            obj.img_ih.fwd_model=fmdl;
            
        end


    end
    methods (Access = protected)
        function copy = copyElement(obj)
            copy = copyElement@matlab.mixin.Copyable(obj); %shallow copy of all elements
            % copy.PipeVault = copy(this.PipeVault); %Deep copy of pipevault which is handle...
        end
    end
end

function ratio_val = noise_dB_ratio(dB_val)
    ratio_val= exp(dB_val / 10);
   
end