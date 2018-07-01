function save_mesh(mesh, path)
fid = fopen(path, 'w');
for i = 1 : size(mesh.verts, 1)

    fprintf(fid, 'v %f %f %f\n', ... 
        mesh.verts(i, 1), mesh.verts(i, 2), mesh.verts(i, 3));
    
end

for i = 1 : size(mesh.faces, 1)
    fprintf(fid, 'f %d %d %d\n', mesh.faces(i, 1), mesh.faces(i, 2), mesh.faces(i, 3));
end
fclose(fid);

end