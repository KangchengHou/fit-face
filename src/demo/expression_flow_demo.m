%% demo for expression flow
exp_root = fullfile(data_root, 'flow1');
[img1, lm2d1, img2, lm2d2] = get_flow_info(exp_root);

%% show scattered points
figure; imshow(img1); hold on;
scatter(lm2d1(1, :), lm2d1(2, :), 10, 'filled', 'g');
figure; imshow(img2); hold on;
scatter(lm2d2(1, :), lm2d2(2, :), 10, 'filled', 'g');
%% single model fitting
[id_coef1, exp_coef1, camera1] = fit_model(basel_face, lm2d1);
[id_coef2, exp_coef2, camera2] = fit_model(basel_face, lm2d2);
model1.faces = basel_face.faces;
model1.verts = get_combined_model(basel_face, id_coef1, exp_coef1)';
model2.faces = basel_face.faces;
model2.verts = get_combined_model(basel_face, id_coef2, exp_coef2)';
%% TODO: joint model fitting, should be done
% lm2ds = {lm2d1, lm2d2};
% [models, cameras] = joint_fit_model(basel_face, lm3d_inner_index, lm2ds);
%% visualize fitting
figure; imshow(img1); hold on;
proj_lm3d1 = transform_lm3d(model1.verts', camera1);
scatter(proj_lm3d1(1, :), proj_lm3d1(2, :), 'r.');
figure; imshow(img2); hold on;
proj_lm3d2 = transform_lm3d(model2.verts', camera2);
scatter(proj_lm3d2(1, :), proj_lm3d2(2, :), 'r.');
%% sub_index
sub_ratio = 5;
sub_index = randperm(length(proj_lm3d1), round(length(proj_lm3d1) / sub_ratio));
%% expression flow
% apply the expression in image1 to image2
expr1_lm2d = transform_lm3d(model1.verts', camera2);
expr2_lm2d = transform_lm3d(model2.verts', camera2);
% from expression2 to expression1
expression_img2 = arap_deform(img2, expr2_lm2d(:, sub_index), expr1_lm2d(:, sub_index));
%% alignment flow
% move the face of img1 to img2

align_lm1 = transform_lm3d(model1.verts', camera1); % 
align_lm2 = transform_lm3d(model1.verts', camera2);
% figure; imshow(img1); hold on; scatter(align1_lm2d(1, :), align1_lm2d(2, :));
% figure; imshow(expression_img2); hold on; scatter(align2_lm2d(1, :), align2_lm2d(2, :));
align_tform = fitgeotrans(align_lm1', align_lm2', 'projective');
align_img1 = imwarp(img1, align_tform, 'OutputView', imref2d(size(expression_img2)));

%%
figure; 
subtightplot(1, 2, 1); imshow(align_img1); title('align img1');
subtightplot(1, 2, 2); imshow(expression_img2); title('expression img2');

%%
% Given two images
% TODO: modify the optimal mask
optimal_mask = seamless_composite(align_img1, expression_img2, align_lm2, exp_root);
%%
rep_optimal_mask = repmat(optimal_mask, 1, 1, 3);
naive_img = expression_img2;
naive_img(rep_optimal_mask) = align_img1(rep_optimal_mask);
figure; imshow(naive_img);

%% now perform poisson image blending
addpath('../poisson_blend/');
blend_img = PIE(expression_img2, align_img1, optimal_mask);
figure; imshow(blend_img);