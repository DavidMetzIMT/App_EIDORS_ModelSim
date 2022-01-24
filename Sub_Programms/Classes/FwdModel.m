classdef FwdModel

    properties
        name
        solve
        jacobian
        system_mat
        nodes
        elems
        boundary
        gnd_node
        misc
        meas_select
        electrode
        stimulation
    end

    properties (Access = private)
        type = 'fwd_model'
    end
    
    
end