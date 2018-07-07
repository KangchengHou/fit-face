% fit 3d model sequence to a video using joint model fitting
%% read the data
exp_root = fullfile(data_root, 'obama-video');
frame_indexes = [13, 49, 68]; % the three images needed to be fit
frame_num = length(frame_indexes);
[imgs, lm2ds] = get_video_info(exp_root, frame_indexes, 'jpg');

%% visualize input data
for i = 1 : frame_num
    figure; imshow(imgs{i}); hold on;
    scatter(lm2ds{i}(1, :), lm2ds{i}(2, :), 10, 'filled', 'g');
end
%% joint fitting
[id_coef, exp_coefs, cameras] = joint_fit_model(basel_face, lm2ds);
models = cell(frame_num, 1);
for i = 1 : frame_num
    models{i}.faces = basel_face.faces;
    models{i}.verts = get_combined_model(basel_face, id_coef, exp_coefs{i})';
end
%% visualize fitting
for i = 1 : frame_num
    figure; imshow(imgs{i}); hold on;
    proj_lm3d = transform_lm3d(models{i}.verts', cameras{i});
    scatter(proj_lm3d(1, :), proj_lm3d(2, :), 'r.');
end
