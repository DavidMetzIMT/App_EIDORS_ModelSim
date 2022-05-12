classdef EIT_setup < handle
    %EIT_SETUP Describe an EIT measurement setup
    %  it comprise the data about the measurement chamber 
    %  with the electrodes layout placed in the chamber  
    %  and the injections/measurement pattern
    
    properties
        type= 'eit_setup'
        chamber EIT_chamber
        elec_layout EIT_elec_layout
        pattern EIT_pattern
    end
    
    methods
        function obj = EIT_setup()
            %EIDORS_IMDL Constructor set default values
            obj.chamber= EIT_chamber();
            obj.elec_layout= EIT_elec_layout();
            obj.pattern= EIT_pattern();
        end

        function reset_elec_layout(obj)
            %RESET_ELEC_LAYOUT reset the electrode layout to one default "EIT_elec_layout"
            % in that case obj.elec_layout(1).is_reset()==true
            obj.elec_layout=EIT_elec_layout();
        end
        
        function obj = add_elec_layout(obj, layout)
            %ADD_ELEC_LAYOUT Append an EIT_elec_layout to obj.elec_layout
            if isa(layout, 'EIT_elec_layout')
                if obj.elec_layout(1).is_reset()
                    obj.elec_layout(1)= layout;
                else
                    obj.elec_layout(length(obj.elec_layout) + 1 ) = layout;
                end
            else
                errordlg('Electrode Layout has to be an EIT_elec_layout cls')
            end
        end
        
        function obj = set.chamber(obj, chamber)
            %SETTER of chamber
            %   chamber must be an "EIT_chamber"object
            if isa(chamber, 'EIT_chamber')
                obj.chamber= chamber;
            else
                errordlg('Chamber has to be an EIT_Chamber cls');
            end
        end
        
        function obj = set.pattern(obj, pattern)
            %SETTER of pattern
            %   chamber must be an "EIT_pattern"object
            if isa(pattern, 'EIT_pattern') 
                obj.pattern= pattern;
            else
                errordlg('Chamber has to be an EIT_Chamber cls');
            end
     
        end

        function struct4gui = get_elec_layout_4_gui(obj)
            %GET_ELEC_LAYOUT_4_GUI Returns the electrodes layout as a struct array for the display in gui
            for i=1:length(obj.elec_layout)
                struct4gui(i)=obj.elec_layout(i).get_struct_4_gui();
            end
        end

        function [shape, elec_pos, elec_shape, elec_obj, z_contact, error] = data_for_ng(obj)
            %DATA_FOR_NG Returns the data needed for the generation of a fmdl with EIDORS 
            % using "ng_mk_gen_models":
            % shape, elec_pos, elec_shape, elec_obj
            % also an error flag containing .code (>0 error)
            %                               .msg message of error 

            % shape string for eidors model generation function with ng
            shape= obj.chamber.shape_for_ng('', 1);

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
            %GENERATE_PATTERNING Return the patterning var for the fwd_model
            %  
            n_tot=0;
            n_XY=[];
            n_elec= [];
            for i=1:length(obj.elec_layout)
                [n_XY_i, n, error] = obj.elec_layout(i).get_nb_elec();
                n_XY(i, :)= n_XY_i;
                n_elec(i)= n;
                n_tot =n_tot+n;
            end

            [stimulation,meas_select, error]= obj.pattern.make(n_tot, length(obj.elec_layout), n_elec, n_XY);
            if error.code
                return;
            end
        end


    end
end

