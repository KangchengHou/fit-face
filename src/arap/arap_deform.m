function new_img = arap_deform(img, proj_verts1, proj_verts2)
% img: the initial image
% verts1: 2 x N vertices before the deformation
% verts2: 2 x N vertices after the deformation

constrain_pairs = [proj_verts1', ...
                   proj_verts2'];

% add control points on the edges of the image
img_width = size(img, 2); img_height = size(img, 1);
width_grid = (2 : (img_width - 3) / 10 : img_width)';
height_grid = (2 : (img_height - 3) / 10 : img_height)';

edge_constrain = [width_grid, 2 * ones(size(width_grid)); 
                  width_grid, (img_height - 1) * ones(size(width_grid));
                  2 * ones(size(height_grid)), height_grid;
                  (img_width - 1) * ones(size(height_grid)), height_grid];

constrain_pairs = [constrain_pairs; edge_constrain, edge_constrain];
% adjust because of the Matlab coordinate system
constrain_pairs = [size(img, 2) - constrain_pairs(:, 1), ...
                   size(img, 1) - constrain_pairs(:, 2), ...
                   size(img, 2) - constrain_pairs(:, 3), ...
                   size(img, 1) - constrain_pairs(:, 4)];
% triangulation of the whole image
M = 20; % rows
N = 20; % cols
[TR_x, TR_y] = ...
    meshgrid(1 : (size(img, 2) - 1) / N : size(img, 2), 0 : (size(img, 1) - 1) / M : size(img, 1));
TR_x = reshape(TR_x, [], 1);
TR_y = reshape(TR_y, [], 1);
TR = delaunayTriangulation(TR_x, TR_y);
addpath('../arap');
% the third parameter is constrain weight
tic;
TR_pp = arap_warp_image(TR, constrain_pairs, 2); 
toc;
D = get_displace_field(TR.Points, TR_pp.Points, img);
new_img = imwarp(img, D);
rmpath('../arap');

end