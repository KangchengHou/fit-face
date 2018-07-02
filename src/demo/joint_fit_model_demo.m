% this is a demo for joint model fitting which fits two face models to two
% images respectively.
% the two models share the same identity vectors and has different
% expression vectors
%% read the data
exp_root = fullfile(data_root, 'flow1');
[img1, lm2d1, img2, lm2d2] = get_flow_info(exp_root);
%% show scattered points
figure; imshow(img1); hold on;
scatter(lm2d1(1, :), lm2d1(2, :), 10, 'filled', 'g');
figure; imshow(img2); hold on;
scatter(lm2d2(1, :), lm2d2(2, :), 10, 'filled', 'g');
%% estimating seperatly
[id_coef1, exp_coef1, camera1] = fit_model(basel_face, lm2d1);
[id_coef2, exp_coef2, camera2] = fit_model(basel_face, lm2d2);
model1.faces = basel_face.faces;
model1.verts = get_combined_model(basel_face, id_coef1, exp_coef1)';
model2.faces = basel_face.faces;
model2.verts = get_combined_model(basel_face, id_coef2, exp_coef2)';
figure; imshow(img1); hold on;
proj_lm3d1 = transform_lm3d(model1.verts', camera1);
scatter(proj_lm3d1(1, :), proj_lm3d1(2, :), 'r.');
figure; imshow(img2); hold on;
proj_lm3d2 = transform_lm3d(model2.verts', camera2);
scatter(proj_lm3d2(1, :), proj_lm3d2(2, :), 'r.');
%% joint fitting
lm2ds = {lm2d1, lm2d2};
[id_coef, exp_coefs, cameras] = joint_fit_model(basel_face, lm2ds);
model1.faces = basel_face.faces;
model1.verts = get_combined_model(basel_face, id_coef, exp_coefs{1})';
model2.faces = basel_face.faces;
model2.verts = get_combined_model(basel_face, id_coef, exp_coefs{2})';
%% visualize fitting
figure; imshow(img1); hold on;
proj_lm3d1 = transform_lm3d(model1.verts', cameras{1});
scatter(proj_lm3d1(1, :), proj_lm3d1(2, :), 'r.');
figure; imshow(img2); hold on;
proj_lm3d2 = transform_lm3d(model2.verts', cameras{2});
scatter(proj_lm3d2(1, :), proj_lm3d2(2, :), 'r.');
