% LOADCOLORMESH : load the mesh with OR without color
%
% Syntax: mesh = loadColorMesh(path)
%
% Inputs:
%    path - the path to the mesh
%
% Outputs:
%    mesh - the result mesh, if the mesh has color, then mesh.verts will
%    have (11510, 3) shape. If the mesh does not have color, then
%    mesh.verts will have (11510, 6) shape

function mesh = load_mesh(path)
% input : the path to the mesh
% output : #vertex x 3 array : each entry represent the color of the vertex
fid = fopen(path, 'r');
verts_num = 11510;
faces_num = 22800;

mesh.verts = cell(verts_num, 1);
mesh.faces = zeros(faces_num, 3);
verts_i = 0;
faces_i = 0;
if fid == -1
    error('File can not be opened');
end

line = fgetl(fid);

while ischar(line)
    if isempty(line)
        line = fgetl(fid);
        continue;
    elseif line(1) == 'v'
        verts_i = verts_i + 1;
        mesh.verts{verts_i} = sscanf(line, 'v %f %f %f %f %f %f')';
    elseif line(1) == 'f'
        faces_i = faces_i + 1;
        mesh.faces(faces_i, :) = sscanf(line, 'f %d %d %d')';
    end
    line = fgetl(fid);
end
mesh.verts = cell2mat(mesh.verts);
mesh.faces = mesh.faces(1 : faces_i, :);
fclose(fid);

end