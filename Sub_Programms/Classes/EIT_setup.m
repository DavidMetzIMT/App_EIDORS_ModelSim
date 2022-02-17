classdef EIT_setup < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        chamber EIT_chamber
        pattern EIT_pattern
        elec_layout EIT_elec_layout
    end
    
    methods
        function obj = EIT_setup()
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            obj.chamber= EIT_chamber();
            obj.pattern= EIT_pattern();
            obj.elec_layout= EIT_elec_layout();
        end

        function obj = set.chamber(obj, chamber)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            if isa(chamber, 'EIT_chamber')
                obj.chamber= chamber;
            else
                errordlg('Chamber has to be an EIT_Chamber cls');
            end
        end

        function reset_elec_layout(obj)
            %reset_elec_layout clear the electrode layouts
            obj.elec_layout=EIT_elec_layout();
        end

        function obj = add_elec_layout(obj, layout)
            %add_elec_layout append an electrode layout
            if isa(layout, 'EIT_elec_layout')
                if obj.elec_layout.is_reset()
                    obj.elec_layout(1)= layout;
                else
                    obj.elec_layout(length(obj.elec_layout) + 1 ) = layout;
                end
            else
                errordlg('Electrode Layout has to be an EIT_elec_layout cls')
            end
        end
        
        function obj = set.pattern(obj, pattern)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            if isa(pattern, 'EIT_pattern') 
                obj.pattern= pattern;
            else
                errordlg('Chamber has to be an EIT_Chamber cls');
            end
     
        end

        function ch = get.chamber(obj)
            %Returns the chamber object
            ch= obj.chamber;            
        end

        function struct4gui = get_elec_layout_4_gui(obj)
            %Returns the electrodes layout as a struct array for the display 
            %in gui

            for i=1:length(obj.elec_layout)
                struct4gui(i)=obj.elec_layout(i).get_struct_4_gui();
            end
        end


        function output = get_struct_4_gui(input)
            
        end


        function [shape, elec_pos, elec_shape, elec_obj, z_contact, error] = data_for_ng(obj)
            %Returns the data needed for the generation of a fmdel with EIDORS 
            % using "ng_mk_gen_models":
            % shape, elec_pos, elec_shape, elec_obj
            % also an error flag containing .code (>0 error)
            %                               .msg message of error 

            % shape string for eidors model generation function with ng
            shape= obj.chamber.shape_for_ng();

            % electrodes data for eidors model generation function with ng
            elec_pos = [];
            elec_shape = [];
            z_contact=[];
            elec_obj= {};
            for i=1:length(obj.elec_layout)
                [elec_pos_i, elec_shape_i, elec_obj_i, z_contact_i, error] = obj.elec_layout(i).data_for_ng(obj.chamber);
                if error.code
                    return;
                end
                elec_pos = cat(1,elec_pos, elec_pos_i);
                elec_shape = cat(1,elec_shape, elec_shape_i);
                elec_obj= cat(2, elec_obj, elec_obj_i); % on second axis...
                z_contact= cat(1, z_contact, z_contact_i);
            end
        end

        function [stimulation,meas_select, error] = generate_patterning(obj)
            n_tot=0;
            for i=1:length(obj.elec_layout)
                [n_XY, n, error] = obj.elec_layout(i).get_nb_elec();
                n_tot =n_tot+n;
            end
            [stimulation,meas_select, error]= obj.pattern.make(n_tot, length(obj.elec_layout));
            if error.code
                return;
            end
        end


    end
end

