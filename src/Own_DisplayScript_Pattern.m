function Own_DisplayScript_Pattern(fwd_model, display_all,wait,display_meas_pattern)
global EIDORS
close all

fmdl=fwd_model.fmdl();

for i= 1:size(fmdl.electrode,2)
    e_xyz(i,:)=fmdl.electrode(i).pos(1:3);
end
time= 0.15;
% display_all=EIDORS.flag.injPatteralldisplay;
% wait=EIDORS.flag.injPatterAnimated;
% display_meas_pattern =EIDORS.flag.injPatterWithMeasPattern;

getCurrentFigure_with_figName('Wire Mesh Current Injections');


[inj, meas]=fwd_model.extract_pattern_for_display();

for i=1:size(inj,1)
    plot3(e_xyz(:,1),e_xyz(:,2),e_xyz(:,3),'r*');
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    hold on
    indx_inj= inj(i,:);
    xyz_inj=e_xyz(indx_inj,1:3);
    plot3(xyz_inj(:,1),xyz_inj(:,2),xyz_inj(:,3),'b-');

    title(sprintf('Stim #=%d', i))
    
    hold on
    if display_meas_pattern ==1
        for j=1:size(meas(:,:,i),1)
            indx_meas= meas(j,:,i);
            xyz_meas=e_xyz(indx_meas,1:3);
            plot3(xyz_meas(:,1),xyz_meas(:,2),xyz_meas(:,3),'y-');
            hold on
            if wait==1
                pause(time);
            else
                pause
            end
            plot3(xyz_meas(:,1),xyz_meas(:,2),xyz_meas(:,3),'g-');
            hold on
            if isequal(xyz_inj, xyz_meas) || isequal(xyz_inj(end:-1:1,:), xyz_meas)
                plot3(xyz_inj(:,1),xyz_inj(:,2),xyz_inj(:,3),'b-');
            end
            title(sprintf('Stim #=%d, Meas #=%d', i, j))
        end        
    end
    if display_all==0
        hold off
    end

    if wait==1
        pause(time);
    else
        pause
    end
end
end

