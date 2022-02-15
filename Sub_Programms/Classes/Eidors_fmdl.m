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
        type                  
        mat_idx               
        normalize_measurements
        misc                  
        get_all_meas          
        stimulation           
        meas_select           

    end

    % properties (Access = private)
    %     type = 'fwd_model'
    % end
    
    methods
        function obj = Eidors_fmdl()
            %Constructor
            obj.nodes =0;                
            obj.elems  =0;               
            obj.boundary  =0;            
            obj.boundary_numbers  =0;    
            obj.gnd_node      =0;        
            obj.np_fwd_solve =0;         
            obj.name       =0;           
            obj.electrode  =0;           
            obj.solve       =0;          
            obj.jacobian     =0;         
            obj.system_mat    =0;        
            obj.type       =0;           
            obj.mat_idx   =0;            
            obj.normalize_measurements=0;
            obj.misc        =0;          
            obj.get_all_meas     =0;     
            obj.stimulation    =0;       
            obj.meas_select     =0;  

        end

        function fmdl4EIDORS = fmdl(obj) % to EIDORS
            %Returns the present object as a structure for use in EIDORS

            fmdl4EIDORS = struct(obj);
        end

        function obj = set_fmdl(obj, fmdl) % from EIDORS 
            %Set the present object using the fmdl structure from EIDORS
            % only the fields of fmdl also present in obj will be updated

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

        function fmdl = gen_fmdl_ng(obj, chamber, shape_str, elec_pos, elec_shape, elec_obj, add_text)
            %Generate the fmdl (meshing, etc) with EIDORS using 
            % "ng_mk_cyl_models" for 2D
            % "ng_mk_gen_models" for 3D
            % additional properties are added to the electrodes for further use
            % the solving part wil be left as it was and should be set if not 
            % already done!

            if strcmp(chamber.form,'2D_Circ')
                [fmdl,mat_idx] = ng_mk_cyl_models(shape_str, elec_pos, elec_shape(1,:));
            else
                fmdl = ng_mk_gen_models(shape_str, elec_pos, elec_shape, elec_obj,add_text);
                for i= 1:size(fmdl.electrode,2)
                    fmdl.electrode(i).pos =elec_pos(i,:);
                    fmdl.electrode(i).shape=elec_shape(i);
                    fmdl.electrode(i).obj=elec_obj(i);
                end
            end
            

            fmdl.get_all_meas = 1;

            obj.set_fmdl_except(fmdl, {'name', 'solve', 'jacobian', 'system_mat', 'misc'});

            fmdl=obj.fmdl();
        end





    end
    
end