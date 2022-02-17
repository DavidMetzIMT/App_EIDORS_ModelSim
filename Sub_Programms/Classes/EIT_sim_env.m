classdef EIT_sim_env < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name ='Simulation default'
        fmdl % the forward model from EIDORS
        objects EIT_object % objects put in the chamber
        mediumConduct % conductivity of the medium
        img_h % homogenious image only medium from EIDORS
        img_ih % inhomogenious image with the objects from EIDORS
        data_h % meas data for img_h from EIDORS (solving the fmdl)
        data_ih % meas data for img_ih from EIDORS (solving the fmdl)
    end
    
    methods
        function obj = EIT_sim_env()

            obj.objects= EIT_object();
            obj.mediumConduct=1;
            
        end
        function add_object(obj, object)
            %UNTITLED3 Construct an instance of this class
            %   Detailed explanation goes here
            % obj.objects(length(obj.objects)+1)= EIT_object(struct_object);
            %add_elec_layout append an electrode layout
            if isa(object, 'EIT_object')
                if obj.objects.is_reset()
                    obj.objects(1)= object;
                else
                    obj.objects(length(obj.objects) + 1 ) = object;
                end
            else
                errordlg('object has to be an EIT_object cls')
            end
        end

        function reset_objects(obj)
            %reset_elec_layout clear the electrode layouts
            obj.objects=EIT_object();
        end

        function struct4gui = get_objects_4_gui(obj)
            %Returns the objects as a struct array for the display 
            %in gui

            for i=1:length(obj.objects)
                struct4gui(i)=obj.objects(i).get_struct_4_gui();
            end
        end
        
        function solve_fwd(obj)
            obj.gen_homogenious_image();
            obj.gen_inhomogenious_image();
            
            obj.data_h = fwd_solve(obj.img_h);
            obj.data_ih = fwd_solve(obj.img_ih);
        end

        


        function gen_homogenious_image(obj)
            obj.img_h = mk_image(obj.fmdl, obj.mediumConduct);
            obj.img_h.fwd_solve.get_all_nodes=0;
        end

        function gen_inhomogenious_image(obj)

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


        
        
    end
end
