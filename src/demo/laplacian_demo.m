% this is a demo of laplacian surface editing
% first fit a face, then edit the face, and apply arap to the image to get
% a modified image.
%% read the data
exp_root = fullfile(data_root, 'obama3');
[img, lm2d] = get_img_info(fullfile(data_root, 'obama3'));
figure; imshow(img); hold on;
scatter(lm2d(1, :), lm2d(2, :), 10, 'filled', 'g');
%%
[id_ceof, exp_coef, camera] = fit_model(basel_face, lm2d);
model.faces = basel_face.faces;
model.verts = get_combined_model(basel_face, id_coef, exp_coef)';
figure; imshow(img); hold on;
proj_lm3d = transform_lm3d(model.verts', camera);
scatter(proj_lm3d(1, :), proj_lm3d(2, :), 'r.');

%% save to the file
save_mesh(model, fullfile(exp_root, 'model.obj'));
% perform the laplacian surface editing
%% load deformed model
deform_model = load_mesh(fullfile(exp_root, 'deform_model.obj'));
%% now edit the model
sub_ratio = 5;
sub_index = randperm(length(model.verts), round(length(model.verts) / sub_ratio));
model_lm2d = transform_lm3d(model.verts', camera);
deform_model_lm2d = transform_lm3d(deform_model.verts', camera);
%%
deform_exe_path = ...
    'C:\Users\david\Desktop\swapface\geometry-processing-deformation\build\deformation.exe';
deform_data_path = 'C:\Users\david\Desktop\fit-face\src\data\';
system([deform_exe_path, ' ', fullfile(deform_data_path, 'obama3\')]);
%%
deform_img = arap_deform(img, model_lm2d(:, sub_index), deform_model_lm2d(:, sub_index));
%%
figure; imshow(deform_img);