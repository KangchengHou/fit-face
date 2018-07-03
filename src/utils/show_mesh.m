% DISPLAYMESH : display the mesh
%
% Syntax: displayMesh(mesh, name)
%
% Inputs:
%    mesh - the mesh WITH faces
%    name - the output name
%
% Outputs:
%    none

function displayMesh(mesh, name, f_index, color, saveit)
if nargin<5
    saveit = false;
end

FV.vertices = mesh.verts;
FV.faces = mesh.faces;
FV.FaceVertexCData = ones(size(mesh.faces, 1), 3) * 0.5;

if nargin > 3
    FV.FaceVertexCData(f_index, :) = repmat(color, length(f_index), 1);
end
patch(FV,'facecolor','flat', 'edgecolor', 'none', 'vertexnormalsmode', 'auto'); camlight;
lighting gouraud;
material dull;
axis vis3d;
axis equal;
title(name);

if saveit
    set(gcf,'units','normalized','outerposition',[0 0 1 1])    
    savefig([name, '.fig']);
    print('-dpng','-r300', name);    
end
end