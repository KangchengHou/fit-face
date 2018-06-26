function write_mat(path, mat)
dlmwrite(path, size(mat), ' ');
dlmwrite(path, mat, 'delimiter', ' ', '-append');
end