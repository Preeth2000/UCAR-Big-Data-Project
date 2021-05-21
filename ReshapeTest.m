a=zeros(10,5,3,2);
a(:) = 1:(10*5*3*2);

sz = 10*5*3;

b = reshape(a,[sz,2]);

parfor idxRow = 1:sz
    X(idxRow) = mean(b(idxRow,:));
end

c = reshape(Ans,[3,5,10]);

 parfor idxHour = 1:25
     comp(idxHour) = mean(c(:,:,idxHour));
 end
 
 parfor idxHour = 1:25
     comp2(idxHour) = mean(t(:,:,idxHour));
 end
 