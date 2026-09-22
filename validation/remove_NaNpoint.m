function cell_data_new = remove_NaNpoint(cell_data)
[m,n] = size(cell_data);
cell_data_new = cell(m,n);
indx = m;
j = 1;
for i=1:m
    if isstring(cell_data{i,3})
        if cell_data{i,3} == ""
            indx = indx-1;
        else
            cell_data_new(j,:) = cell_data(i,:);
            j = j+1;
        end
    else
        cell_data_new(j,:) = cell_data(i,:);
        j = j+1;
    end
end
cell_data_new(indx+1:end,:)=[];
end
