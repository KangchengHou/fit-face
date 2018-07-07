%% load an image and display the landmark
[img, lm2d] = get_img_info(fullfile(data_root, 'obama2'), 'png');
figure; imshow(img); hold on;
scatter(lm2d(1, :), lm2d(2, :), 10, 'filled', 'g');
%% demo 1: fit a model and display the model
[id_coef, exp_coef, camera] = fit_model(basel_face, lm2d);
m.faces = basel_face.faces;
m.verts = get_combined_model(basel_face, id_coef, exp_coef)';
figure; imshow(img); hold on;
proj_lm3d = transform_lm3d(m.verts', camera);
scatter(proj_lm3d(1, :), proj_lm3d(2, :), 'r.');
