%% some setups
clear;
addpath('../fitmodel');
addpath('../utils');
data_root = '../data/';
load('../metadata/basel_face_db.mat');
%% load an image and display the landmark
[img, lm2d] = get_img_info(fullfile(data_root, 'obama2'));
figure; imshow(img); hold on;
scatter(lm2d(1, :), lm2d(2, :), 10, 'filled', 'g');
%% fit a model and display the model
[id_coef, exp_coef, camera] = fit_model(basel_face, lm2d);
m.faces = basel_face.faces;
m.verts = get_combined_model(basel_face, id_coef, exp_coef)';
figure; imshow(img); hold on;
proj_lm3d = transform_lm3d(m.verts', camera);
scatter(proj_lm3d(1, :), proj_lm3d(2, :), 'r.');
%%
figure; imshow(img); hold on;
scatter(lm2d(1, :), lm2d(2, :), 10, 'filled', 'g');
proj_lm3d = transform_lm3d(m.verts', camera); 
scatter(proj_lm3d(1, basel_face.inner_index), proj_lm3d(2, basel_face.inner_index), 10, 'filled', 'r');

