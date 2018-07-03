function write_dmat(path, mat)
% <#columns> <#rows>
% the matrix
dlmwrite(path, [size(mat, 2), size(mat, 1)], ' ');
dlmwrite(path, mat', 'delimiter', ' ', '-append');
end