classdef Visualization

% Visualization(user_entry, test_data, show_cells, n) the purpose of this
% function is to observe the n-th generated set.
% n = i;      % n - the index number of generated n-th object
% show_cells = 0; if show_cells = 1, draws circle where phantom should be


    properties ( Access = public )
        test_data
        
    end
    
    methods ( Access = public )
        function obj = Visualization(user_entry, test_data, show_cells, n)

            %% showing fwd_model
            figName= '2D Image of resolved inverse Problem';
            h= getCurrentFigure_with_figName(figName);
            set(gcf, 'Position', [50, 110, 1300, 650])    
          
            obj.test_data = test_data.singleTrainingDataSet(n);
            img = obj.test_data.img_ih;
            
            % if user_entry.invSolver is off, then only the fwd model is shown
             
            if user_entry.invSolver == 1
                h1 = subplot(1,3,1);
            else
                h1 = subplot(1,1,1);
            end
            title('fwd model');
            show_fem(img,[1,1,0]); 
            
            if show_cells == 1
               draw_circle()
            end

            %% showing inv_model
            if user_entry.invSolver == 1
                obj.test_data = test_data.singleTrainingDataSet(n).invSolver;
                
                iimg = obj.test_data.iimg;
                iimg_n = obj.test_data.iimg_n;

                switch user_entry.inv_solver_name %choosing specific solver
                    case 'GN'  % obj.inv_solve_diff_GN_one_step (prior_laplace)
                      
                        show_inv_model(user_entry, show_cells,iimg , iimg_n)

                    case 'TV'   %obj.inv_solve_TV_pdipm (prior_TV)
                       
                        show_inv_model(user_entry, show_cells,iimg , iimg_n)
                            
                    case 'NN'    
                    %Neural network invers solver
                        
                        show_inv_model(user_entry, show_cells,iimg , iimg_n)

                    otherwise
                        error('Wrong name of invers solver, try GN (for Gauss Newton one step) or TV (for Total Variation/PDIPM)')
                end  
            end  
            
            %function for showing inv solved image without noise and with noise

            function show_inv_model(user_entry, show_cells, iimg, iimg_n)
                h2 = subplot(1,3,2);
                title(['inv ', user_entry.inv_solver_name,' model without noise']);
                show_fem(iimg,[1,1,0]);

                if show_cells == 1
                   draw_circle()
                end

                h3 = subplot(1,3,3);
                title(['inv ', user_entry.inv_solver_name, ' model with noise, when SNR is ', num2str(user_entry.SNR)]);
                show_fem(iimg_n,[1,1,0]);   

                if show_cells == 1
                   draw_circle()
                end
            end
            
            function draw_circle()
                 %% Circle drawing
                for i = 1:length(obj.test_data.cell)
                    if sum(obj.test_data.cell_frac(:,i),1) > 0
                        x =[];
                        x(1)=0;
                        r=obj.test_data.cell(i).radius;
                        x=obj.test_data.cell(i).pos;
                        dimCell = 2*r;
                        posCell_downleft= [(x(1)), (x(2))]-[dimCell, dimCell]/2;
                        rectangle('Position',[posCell_downleft(1),posCell_downleft(2),dimCell,dimCell],'Curvature',[1,1],'linewidth',2,...
                            'EdgeColor','green')
                    end
                end
            end
            
        end
        
    end
end
