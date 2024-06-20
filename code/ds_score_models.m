% DS(c1) = ((A+B)/2 - C(c1))/((A+B)/2 + C(c1));

%%
close all
A = 5; B = 7;
C = 4:.1:20;
for c1 = 1:size(C,2)
    DS(c1) = (C(c1) - (A+B)/2 )/((A+B)/2 + C(c1));
end

plot(C,DS)

%%
close all
A = 5; B = 7;
C = 4:.1:8;
for c1 = 1:size(C,2)
    DS(c1) = (C(c1) - max(A,B))/(max(A,B) + C(c1));
end

plot(C,DS)