function nstructure = get_structure_nested(object)
    if isobject(object)
        structure= struct(object);
        fields= fieldnames(structure,'-full');

        for i=1:length(fields)
            field= fields{i};
            nstructure.(field)=get_structure_nested(structure.(field));
        end
    else
%         disp(object)
        nstructure=object;
    end
    
end