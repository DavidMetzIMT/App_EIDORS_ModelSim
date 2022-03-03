function indx = get_list(n,size)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

q= floor(n/(size));%quotien
r=mod(n, size); % rest

i_end = size*([1:q]');

if r==0
    rest=[];
else
    rest=r;
end

if ~isempty(i_end)
    rest= rest+i_end(end);
end

i_end= cat(1, i_end, rest);


i_begin= [0; i_end(1:end-1)]+1;

indx= [i_begin, i_end];





end

