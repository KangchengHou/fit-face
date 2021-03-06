% fit a model to the image and display the textured image
%% read the data
data_root = 'C:\Users\david\Desktop\fit-face\src\data';
exp_root = fullfile(data_root, 'test1');
[img, lm2d] = get_img_info(fullfile(exp_root), 'png');
figure; imshow(img); hold on;
scatter(lm2d(1, :), lm2d(2, :), 10, 'filled', 'g');
%%
[id_coef, exp_coef, camera] = fit_model(basel_face, lm2d);
model.faces = basel_face.faces;
model.verts = get_combined_model(basel_face, id_coef, exp_coef)';
save_mesh(model, fullfile(exp_root, 'model.obj'));
figure; imshow(img); hold on;
proj_lm3d = transform_lm3d(model.verts', camera);
scatter(proj_lm3d(1, :), proj_lm3d(2, :), 'r.');
%% compute the uv coordinate for each vertex
uv = [proj_lm3d(1, :) / size(img, 2); proj_lm3d(2, :) / size(img, 1)];
tmp_img = flip(rot90(img), 1);
write_dmat(fullfile(exp_root, 'uv.txt'), uv');

write_dmat(fullfile(exp_root, 'R.txt'), tmp_img(:, :, 1));
write_dmat(fullfile(exp_root, 'G.txt'), tmp_img(:, :, 2));
write_dmat(fullfile(exp_root, 'B.txt'), tmp_img(:, :, 3));
%% setup viewer
viewer_path = ... 
'C:\Users\david\Desktop\fit-face\src\geometry-processing-deformation\build\viewer.exe';
system([viewer_path, ' ', exp_root, '\']);
%% save to the file
% TODO: save camera parameters

figure; show_mesh(model, 'model');