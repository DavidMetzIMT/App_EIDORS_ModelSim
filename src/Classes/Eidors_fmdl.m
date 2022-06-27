classdef Eidors_fmdl < handle
    % EIDORS_FMDL Class version of the Eidors fwd_model object

    properties
        type  = 'fwd_model';  
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
            %EIDORS_IMDL Constructor set default values
            obj.nodes                   = 0;                
            obj.elems                   = 0;               
            obj.boundary                = 0;            
            obj.boundary_numbers        = 0;    
            obj.gnd_node                = 0;        
            obj.np_fwd_solve            = 0;         
            obj.name                    = 'fdml_default_name';           
            obj.electrode               = 0;           
            obj.solve                   = obj.SOLVER{1};          
            obj.jacobian                = obj.JACOBIAN{1};      
            obj.system_mat              = obj.SYS_MAT{1};       
            obj.type  = 'fwd_model';           
            obj.mat_idx                 = 0;            
            obj.normalize_measurements  = 0;
            misc.perm_sym = obj.PERM_SYM{1};
            obj.misc                    = misc;
            obj.get_all_meas            = 1;
            stim.stim_pattern = 0;
            stim.meas_pattern = 0;     
            obj.stimulation             = stim;       
            obj.meas_select             = 0;
            % obj.coarse2fine=0; 
            
            obj.initialized = 0;
        end


        function cellarray = supported_solvers(obj)
            %SUPPORTED_SOLVERS Return supported fmdl solvers
            cellarray = obj.SOLVER;
        end
        function cellarray = supported_jacobians(obj)
            %SUPPORTED_JACOBIANS Return supported fmdl jacobians
            cellarray = obj.JACOBIAN;
        end
        function cellarray = supported_sys_mats(obj)
            %SUPPORTED_SYS_MATS Return supported system matrices
            cellarray = obj.SYS_MAT;
        end
        function cellarray = supported_perm_sym(obj)
            %SUPPORTED_PERM_SYM Return supported perm sym
            cellarray = obj.PERM_SYM;
        end

        function fmdl4EIDORS = fmdl(obj)
            %FMDL Return itself as a structure for use in EIDORS Toolbox
            fmdl4EIDORS = struct(obj);
            fmdl4EIDORS = rmfield(fmdl4EIDORS,{'SOLVER', 'JACOBIAN', 'SYS_MAT', 'PERM_SYM'});
        end

        function obj = set_fmdl(obj, fmdl) 
            %SET_FMDL Set properties using a "fwd_model" object from EIDORS
            % only the fields of fmdl also present in obj will be updated

            obj.initialized=0;
            if isa(fmdl, 'Eidors_fmdl') 
                fmdl= fmdl.fmdl();
            end
            [pass errstr]=valid_fwd_model(fmdl);
            if ~pass
                disp('ERROR TYPE: fwd_model should be an EIDORS "fwd_model" object')
                disp(errstr)
                return;
            end
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
            %SET_PATTERN Set the stimulation and meas_select properties
            %
            obj.initialized=0;
            obj.stimulation = stimulation;
            obj.meas_select = meas_select;
            obj.initialized=2;
        end

        function set_fmdl_except(obj, fmdl, fields)
            %SET_FMDL Set properties using a "fwd_model" object from EIDORS 
            %       only the fields of fmdl also present in obj will be updated 
            %       with the EXCEPTION of fields passed eg. {'name', 'solve'}
            %       field should be a cell arrays with the name of the fields to
            %       ignore!

            props_f = fieldnames(fmdl);
            for i=1:length(fields)
                field= fields{i};
                if any(strcmp(props_f,field))
                    setfield(fmdl, field, getfield(obj, field)); %rmfield(fmdl,field);
                end
            end
            obj = obj.set_fmdl(fmdl);
        end

        function set_solver(obj, name, solve, jacobian, system_mat, perm_sym)
            %SET_INV_SOLVER Set the solver parameters of the fwd_model
            obj.name= name;
            obj.solve= solve;
            obj.jacobian=jacobian;
            obj.system_mat= system_mat;
            misc.perm_sym= perm_sym;
            obj.misc=misc;
        end

        function fmdl = gen_fmdl_ng(obj, chamber, shape_str, elec_pos, elec_shape, elec_obj, z_contact, add_text)
            %GEN_FMDL_NG Generate the fmdl (meshing, etc) with EIDORS using 
            % "ng_mk_gen_models" for 3D and 2D
            % additional properties are added to the electrodes for further use
            % the solving part wil be left as it was and should be set if not 
            % already done!
            obj.initialized=0;
            fmdl = ng_mk_gen_models(shape_str, elec_pos, elec_shape, elec_obj, add_text);

            if strcmp(chamber.form,'2D_Circ')
                fmdl = mdl2d_from3d(fmdl)
            end
            
            for i= 1:size(fmdl.electrode,2)
                fmdl.electrode(i).pos =elec_pos(i,:);
                fmdl.electrode(i).shape=elec_shape(i);
                fmdl.electrode(i).obj=elec_obj(i);
                fmdl.electrode(i).z_contact=z_contact(i);
            end
            
            fmdl.stimulation= obj.stimulation;    % take dummy struct          

            obj.set_fmdl_except(fmdl, {'name', 'solve', 'jacobian', 'system_mat', 'misc', 'stimulation', 'get_all_meas'});
            fmdl=obj.fmdl();
            obj.initialized=1;
        end

        function [inj, meas] = extract_pattern_for_display(obj)
            %EXTRACT_PATTERN_FOR_DISPLAY Convert the pattern matrices into more comprehensibles tables with electrodes numbers
            % inj(inj#,:)= [ElecNb for inj-, ElecNb for inj+]
            % meas(:,:, inj#)= [ElecNb for meas-, ElecNb for meas+]
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