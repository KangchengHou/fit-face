%%
addpath('../toolbox/export_fig');
[img, lm2d] = get_img_info(fullfile(data_root, 'obama2'));
figure; imshow(img); hold on;
scatter(lm2d(1, :), lm2d(2, :), 10, 'filled', 'g');
export_fig(fullfile(data_root, 'obama2', 'img_with_lm.png'), '-native');
%%
[id_coef, exp_coef, camera] = fit_model(basel_face, lm3d_inner_index, lm2d);
m.faces = basel_face.faces;
m.verts = get_combined_model(basel_face, id_coef, exp_coef)';
figure; imshow(img); hold on;
proj_lm3d = transform_lm3d(m.verts', camera);
scatter(proj_lm3d(1, :), proj_lm3d(2, :), 'r.');
