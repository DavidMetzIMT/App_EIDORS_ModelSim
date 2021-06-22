function h = getCurrentFigure_with_figName(figName)
%get the figure this "Name" == FigName as Current
%if it not exists it creates this figure and return current figure handle h

figHandles = findobj('Type', 'figure');
figure_already_created=0;

for i=1:size(figHandles,1)
    if strcmp(figHandles(i).Name, figName)
        figure(figHandles(i));
        figure_already_created=1;
        h= figHandles(i);
        return
    end
end

if figure_already_created==0
    h=figure('Name', figName);
end

end

