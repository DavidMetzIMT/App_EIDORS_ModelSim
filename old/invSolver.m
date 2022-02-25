classdef invSolver
% this class is used for solving the invere problem, using 1 of 3 possibilities:
% 'GN' (for Gauss Newton one step), 'TV' (for Total Variation/PDIPM)' 
%  or 'NN' (for Neural Network solver)
    
    properties (Access = public)
        inv
        iimg
        iimg_n
    end
    
    methods (Access = public)
        function obj = invSolver(user_entry, trainingDataset)
           
           clear obj.inv;
            
            obj.inv.name = 'EIT obj.inverse';
            obj.inv.hyperparameter.value = 3e-3;
            obj.inv.RtR_prior= 'prior_laplace';
            obj.inv.reconst_type= 'difference';
            obj.inv.jacobian_bkgnd.value= trainingDataset.bufferConduct;
            obj.inv.fwd_model= user_entry.fmdl;
            obj.inv.fwd_model.misc.perm_sym= '{y}';
            
            
            obj.inv.parameters.max_iterations = 1;
            obj.inv.parameters.term_tolerance= 1e-3;
            
            %obj.info_solving= ''
            
            switch user_entry.inv_solver_name
                case 'GN' % obj.inv_solve_diff_GN_one_step (prior_laplace)
                        disp('Start: GN Inverse solver...')
                        obj.inv.solve = 'inv_solve_diff_GN_one_step';
                        obj.inv.R_prior =  'prior_laplace'; 
                        imdl= eidors_obj('inv_model', obj.inv);
                        
                        obj.iimg = inv_solve(imdl, trainingDataset.data_h, trainingDataset.data_ih);  
                        obj.iimg_n = inv_solve(imdl, trainingDataset.data_hn, trainingDataset.data_ihn);
                        
                        
                case 'TV'    %obj.inv_solve_TV_pdipm (prior_TV)
                        disp('Start: TV Inverse solver...')
                        obj.inv.solve = 'inv_solve_TV_pdipm';
                        obj.inv.R_prior =  @prior_TV;
                        obj.inv.prior_TV.alpha2 = 1e-5;
                        imdl= eidors_obj('inv_model', obj.inv);
                        

                        obj.iimg = inv_solve(imdl, trainingDataset.data_h, trainingDataset.data_ih);  
                        obj.iimg_n = inv_solve(imdl, trainingDataset.data_hn, trainingDataset.data_ihn); 
                        
%                 case 'NN'    %Neural network inverse solver
%                     disp('Start: NN Inverse solver...')
%                         %% one solver is needed to make a background in which elem_data will be overwritten from NN solver
%                         %@mantas no we only need to get the right fmdl from
%                         %´the training data set  and use make image...
% %                         obj.inv.solve = 'inv_solve_diff_GN_one_step';
% %                         
% %                         imdl= eidors_obj('inv_model', obj.inv);
% %                         user_entry.imdl = imdl;
% %                         obj.iimg = inv_solve(user_entry.imdl, trainingDataset.data_h, trainingDataset.data_ih);
%                         
%                         %%
%                         x = trainingDataset.data_ih.meas;
%                     
%                         img_old= trainingDataset.img_h;
%                         [element_data, element_data_n]= Net_solver(user_entry, trainingDataset);
%                         
%                         obj.iimg= mk_image(img_old, element_data);
%                         obj.iimg_n= mk_image(img_old, element_data_n);
                        
                      
                        
                otherwise
                     error('Wrong name of invers solver, try GN (for Gauss Newton one step), TV (for Total Variation/PDIPM) or NN (for Neural Network)');
            end
            disp('Stop: Inverse solver...')
        end 

        

    end
    
end

