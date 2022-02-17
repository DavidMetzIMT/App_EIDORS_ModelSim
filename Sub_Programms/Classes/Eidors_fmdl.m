classdef Eidors_fmdl < handle

    properties
        nodes                 
        elems                 
        boundary              
        boundary_numbers      
        gnd_node              
        np_fwd_solve          
        name                  
        electrode             
        solve                 
        jacobian              
        system_mat            
        type  = 'fwd_model';                
        mat_idx               
        normalize_measurements
        misc                  
        get_all_meas          
        stimulation           
        meas_select
        % coarse2fine           

    end
    properties (Access = protected)
        initialized
    end

    properties (Access = private)
        SOLVER = {'eidors_default', 'fwd_solve_1st_order', 'aa_fwd_solve'}
        JACOBIAN = {'eidors_default', 'jacobian_adjoint','aa_calc_jacobian'}
        SYS_MAT = {'eidors_default','system_mat_1st_order', 'aa_calc_system_mat'}
        PERM_SYM = {'n'}
    end
    
    methods
        function obj = Eidors_fmdl()
            %Constructor
            obj.nodes =0;                
            obj.elems  =0;               
            obj.boundary  =0;            
            obj.boundary_numbers  =0;    
            obj.gnd_node      =0;        
            obj.np_fwd_solve =0;         
            obj.name       ='fdml_default_name';           
            obj.electrode  =0;           
            obj.solve       =obj.SOLVER{1};          
            obj.jacobian     =obj.JACOBIAN{1};      
            obj.system_mat    =obj.SYS_MAT{1};       
            obj.type       =0;           
            obj.mat_idx   =0;            
            obj.normalize_measurements=0;
            a.perm_sym= obj.PERM_SYM{1};
            obj.misc=a;
                      
            obj.get_all_meas     =0;     
            obj.stimulation    =0;       
            obj.meas_select     =0;
            % obj.coarse2fine=0; 
            
            obj.initialized=0;

        end


        function cellarray = supported_solvers(obj)
            %Return Supported fmdl solver
            cellarray = obj.SOLVER;
        end
        function cellarray = supported_jacobians(obj)
            %Return Supported fmdl  jacobian
            cellarray = obj.JACOBIAN;
        end
        function cellarray = supported_sys_mats(obj)
            %Return Supported fmdl system mat
            cellarray = obj.SYS_MAT;
        end
        function cellarray = supported_perm_sym(obj)
            %Return Supported fmdl perm sym
            cellarray = obj.PERM_SYM;
        end


        function fmdl4EIDORS = fmdl(obj) % to EIDORS
            %Returns the present object as a structure for use in EIDORS

            fmdl4EIDORS = struct(obj);
        end

        function obj = set_fmdl(obj, fmdl) % from EIDORS 
            %Set the present object using the fmdl structure from EIDORS
            % only the fields of fmdl also present in obj will be updated
            obj.initialized=0;
            props_o = fieldnames(obj);
            props_f = fieldnames(fmdl);
            for i= 1:length(props_o)
                p= props_o{i};
                if any(strcmp(props_f,p))
                    setfield(obj, p , getfield(fmdl,p));
                else
                    % errordlg('The chamber form ist not correct');
                end
            end
            obj.initialized=2;
        end

        function set_pattern(obj, stimulation, meas_select)
            obj.initialized=0;
            obj.stimulation = stimulation;
            obj.meas_select = meas_select;
            obj.initialized=2;
        end

        function set_fmdl_except(obj, fmdl, fields)
            %Set the present object using the fmdl structure from EIDORS 
            % only the fields of fmdl also present in obj will be updated 
            % with the EXCEPTION of fields passed eg. {'name', 'solve'}
            % field should be a cell arrays with the name of the fields to
            % ignore!

            props_f = fieldnames(fmdl);
            for i=1:length(fields)
                field= fields{i};
                if any(strcmp(props_f,field))
                    fmdl = rmfield(fmdl,field);
                end
            end
            obj = obj.set_fmdl(fmdl);
        end

        function set_solver(obj, name, solve, jacobian, system_mat, perm_sym)
            %Set the solving part of the fwd_model
            obj.name= name;
            obj.solve= solve;
            obj.jacobian=jacobian;
            obj.system_mat= system_mat;
            a.perm_sym= perm_sym;
            obj.misc=a;
        end

        function fmdl = gen_fmdl_ng(obj, chamber, shape_str, elec_pos, elec_shape, elec_obj, z_contact, add_text)
            %Generate the fmdl (meshing, etc) with EIDORS using 
            % "ng_mk_cyl_models" for 2D
            % "ng_mk_gen_models" for 3D
            % additional properties are added to the electrodes for further use
            % the solving part wil be left as it was and should be set if not 
            % already done!
            obj.initialized=0;
            if strcmp(chamber.form,'2D_Circ')
                [fmdl,mat_idx] = ng_mk_cyl_models(shape_str, elec_pos, elec_shape(1,:));
            else
                fmdl = ng_mk_gen_models(shape_str, elec_pos, elec_shape, elec_obj,add_text);
                for i= 1:size(fmdl.electrode,2)
                    fmdl.electrode(i).pos =elec_pos(i,:);
                    fmdl.electrode(i).shape=elec_shape(i);
                    fmdl.electrode(i).obj=elec_obj(i);
                    fmdl.electrode(i).z_contact=z_contact(i);
                end
            end
            

            fmdl.get_all_meas = 1;

            obj.set_fmdl_except(fmdl, {'name', 'solve', 'jacobian', 'system_mat', 'misc'});

            fmdl=obj.fmdl();
            obj.initialized=1;
        end

        function [inj, meas] = extract_pattern_for_display(obj)
            % return the patren as elctodes numbers tables
            % inj= [inj-, inj+]
            % meas= [meas-, meas+, inj#]
            inj=[];
            meas=[];
            if obj.initialized<2;
                return;
            end
            for t = 1:size(obj.stimulation,2)
                p=obj.stimulation(t).stim_pattern;
                amplitude= sum(abs(p))/2;
                p= p/amplitude;
                p=sort(eye(size(p,1)).*[1:size(p,1)]*p);
                inj(t,:)=[abs(p(end)) abs(p(1))];
            end

            for inj_nr=1:size(obj.stimulation,2)
                for t = 1:size(obj.stimulation(inj_nr).meas_pattern,1)
                    p=obj.stimulation(inj_nr).meas_pattern(t,:)';
                    p=sort(eye(size(p,1)).*[1:size(p,1)]*p);
                    meas(t,:, inj_nr)=[abs(p(1)) abs(p(end))];
                end
            end

            
        end





    end
    
end