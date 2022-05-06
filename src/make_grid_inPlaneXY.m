function [xyz, nxyz] = make_grid_inPlaneXY(n_XY)
    %MAKE_GRID_INPLANEXY Create a grid arragement of points in the xy plane 
    % and centered in (0,0,0) with a radius of 1
    % 
    % n_XY=[nb electrode in X, nb electrodes in Y]
    % if the nb electrodes in Y is zero than 
    % nb electrode in X

    radius=1;
    d= radius*2;% diameter of the grid (or diagonales)
    rat=n_XY(1)/n_XY(2);
    width_grid = [sqrt(1/(1+(1/rat)^2)) sqrt(1/(1+(rat)^2))]*d;
    for xy=1:2
        switch n_XY(xy)
            case 1 % case of 1 electrode 
                vector(xy).v= 0;
            otherwise % for mor thna 1 Electrodes
                vector(xy).v=linspace(-width_grid(xy)/2,width_grid(xy)/2,n_XY(xy));
        end
    end
    [x,y] = meshgrid(vector(1).v,vector(2).v);
    n_tot=n_XY(1)*n_XY(2);

    xyz = [x(1:end)', y(1:end)', zeros(n_tot,1)];
    nxyz = [zeros(n_tot,1), zeros(n_tot,1), ones(n_tot,1)];
end