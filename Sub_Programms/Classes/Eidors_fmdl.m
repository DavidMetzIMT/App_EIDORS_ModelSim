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
            fmdl4EIDORS = struct(obj);
        end

        function obj = set_fmdl(obj, fmdl) % from EIDORS 
            
            props_o = fieldnames(obj);
            props_f = fieldnames(fmdl);
            for i= 1:length(props_o)
                p= props_o{i};
                if any(strcmp(props_f,p))
                    setfield(obj, p , getfield(fmdl,p))
                else
                    % errordlg('The chamber form ist not correct');
                end
            end
        end

        function set_solver(obj, name, solve, jacobian, system_mat, perm_sym)
            obj.name= name;
            obj.solve= solve;
            obj.jacobian=jacobian;
            obj.system_mat= system_mat;
            obj.misc.perm_sym=perm_sym;
        end

        



    end
    
end