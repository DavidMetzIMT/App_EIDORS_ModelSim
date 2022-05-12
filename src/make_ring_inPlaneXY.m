function [xyz, nxyz] = make_ring_inPlaneXY(n)
    %MAKE_RING_INPLANEXY Create a ring arragement of n points in the xy plane 
    % and centered in (0,0,0) with a radius of 1
    % it returns the positions xyz, the direction vector
    % and the total number of electrodes

    theta = linspace(0, 2*pi, n + 1)';
    theta(end) = []; % 0 <= theta < 2*pi 
    p= ones(size(theta))*pi/2;
    clockwise=1;
    start_on_top= 1;

    if start_on_top==1
        p= 0;
    end
    
    theta= theta+p;

    if clockwise==1
        xyz = [sin(theta), cos(theta), zeros(n,1)]; 
        nxyz = [sin(theta), cos(theta), ones(n,1)]; %here ones because the electrode can also be oriented in Z
    else
        xyz = [cos(theta), sin(theta), zeros(n,1)]; 
        nxyz = [cos(theta), sin(theta), ones(n,1)]; %here ones because the electrode can also be oriented in Z

    end
end