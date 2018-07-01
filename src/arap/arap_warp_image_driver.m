%% input
% input_mesh = load_mesh('./data/man.obj');
% figure; show_mesh(input_mesh, 'mesh'); hold on;
% TR = triangulation(input_mesh.faces, input_mesh.verts(:, 1), input_mesh.verts(:, 2));
% constrain_pairs = [
%     -0.8, 0.6, -0.8, 0.2; % left hand
%     0, 0.5, 0, 0.5; % center
%     0.8, 0.6, 0.8, 0.9; % right hand
%     ];
% constrain_pairs = [
%     -0.8, 0.6, -0.8, 0.6; % left hand
%     0, 0.5, 0, 0.5; % center
%     0.8, 0.6, 0.8, 0.6; % right hand
%     ];

% load obama2 input
% load('./data/obama2_arap_input.mat');
load('./data/obama2_contour_input.mat');
figure;
scatter(constrain_pairs(:, 1), constrain_pairs(:, 2), 'ro');
figure;
scatter(constrain_pairs(:, 3), constrain_pairs(:, 4), 'bx');
figure;
hold on;
imshow(img);
show_2dmesh(TR);
hold off;
%% deform
TR_pp = arap_warp_image(TR, constrain_pairs, 50); % the third parameter is constrain weight
%% visualize
figure; show_2dmesh(TR_pp);

%% 
% estimate D
D = get_displace_field(TR.Points, TR_pp.Points, img);
warped_img = imwarp(img, D);
figure; imshow(img);
figure; imshow(warped_img);