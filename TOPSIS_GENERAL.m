function [Cplus,Cplus_ranked] = TOPSIS_GENERAL(r)

r(:,isnan(r(1,:)))=[];
[L C] = size(r);

j=1;
i=1;
while j<=C
    while i<=L
        rij(i,j) = r(i,j)/sqrt(sumsqr(r(:,j)));
        i=i+1;
    end
    i=1;
    j=j+1;
end

rij(isnan(rij))=0;
vij = rij;

for i=1:C
    Aplus(i)  = max(vij(:,i));
    Aminus(i) = min(vij(:,i));
end

for j=1:L
    for i =1:C
        a(j,i) = (vij(j,i) -  Aplus(i))^2;
        b(j,i) = (vij(j,i) -  Aminus(i))^2;
    end
end

for j=1:L
    Splus(j)  = sqrt(sum(a(j,:)));
    Sminus(j) = sqrt(sum(b(j,:)));
end
clear a b
for j=1:L
    Cplus(j) = Sminus(j)/(Splus(j)+Sminus(j));
end
% for j=1:L
%     Cplus(j) = Splus(j)/(Splus(j)+Sminus(j));
% end

[temp,Cplus_ranked]  = ismember(Cplus,unique(Cplus));
Cplus_ranked = abs(Cplus_ranked - length(Cplus_ranked)-1);
end

