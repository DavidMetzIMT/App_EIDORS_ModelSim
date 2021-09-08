
s=[0 0];
n= 50;
for i= 1:n

    s(1)= s(1)+tr{1, i}.best_perf ; 
    f(i,1)=tr{1, i}.best_perf;
    s(2)= s(2)+tr100{1, i}.best_perf ; 
    f(i,2)=tr100{1, i}.best_perf;
end
s=s/n
