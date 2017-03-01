% 0)initialize the dataset 
% after the prototype make it .mat file for
% speeding up the process
for i=1:26
    if(i<10)
        dataBase(i,:)=['Images/Database/' int2str(i) '.jpg ']; 
    end    
    if(i>9)
        dataBase(i,:)=['Images/Database/' int2str(i) '.jpg'];
    end    
end

save theHGRDatabase