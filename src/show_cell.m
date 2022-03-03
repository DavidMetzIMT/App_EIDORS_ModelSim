function show_cell(fig,levels,fem)
global EIDORS
%get actual Axis Size
if fem
    for i= 1:size(EIDORS.sim.cell,1)
        x=[];
        x(1)=0;
        j=0;
        r=EIDORS.sim.cell(i).Radius;
        x(1)=EIDORS.sim.cell(i).PosX;
        x(end+1)=EIDORS.sim.cell(i).PosY;
        x(end+1)=EIDORS.sim.cell(i).PosZ;
        dimCell= 2*r;
        posCell_downleft= [(x(1)), (x(2))]-[dimCell, dimCell]/2;
        rectangle('Position',[posCell_downleft(1),posCell_downleft(2),dimCell,dimCell],'Curvature',[1,1],'linewidth',2,...
            'EdgeColor','blue')
    end
else
    figSize=axis;
    %middle of figure
    xm=[(figSize(2)+figSize(1)) (figSize(4)+figSize(3))]./2;
    %size ratio of current figure and body diamenter or length
    ra=(figSize(2)+figSize(1))/EIDORS.chamber.body.diameter_length;
    for i= 1:size(EIDORS.sim.cell,1)
        x=[];
        x(1)=0;
        j=0;
        r=EIDORS.sim.cell(i).Radius;
        if levels(1)==Inf
            x(end+1)=EIDORS.sim.cell(i).PosX;
            j=j+1;
        end
        if levels(2)==Inf
            x(end+1)=EIDORS.sim.cell(i).PosY;
            j=j+1;
        end
        if levels(3)==Inf
            x(end+1)=EIDORS.sim.cell(i).PosZ;
            j=j+1;
        end
        x= x(2:3);
        if j==2
            dimCell= 2*r*ra
            posCell_downleft= xm + [(x(1)), -(x(2))].*ra-[dimCell, dimCell]/2
            rectangle('Position',[posCell_downleft(1),posCell_downleft(2),dimCell,dimCell],'Curvature',[1,1],'linewidth',2,...
                'EdgeColor','blue')
        else
            error('Wrong levels')
        end
    end
end
end