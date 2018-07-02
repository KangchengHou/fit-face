
function [id_coef, exp_coefs, cameras] = joint_fit_model(basel_face, lm2ds)
% fit using features
% we first use 2 points
img_num = length(lm2ds);
% assert(img_num == 2);

iter_num = 3;
% initialize 
id_coef = zeros(length(basel_face.id_val), 1);
exp_coefs = cell(img_num, 1);
for i = 1 : length(exp_coefs)
    exp_coefs{i} = zeros(length(basel_face.exp_val), 1);
end

cameras = cell(img_num, 1);
verts3ds = cell(img_num, 1);
proj_all_lm3ds = cell(img_num, 1);
lm3d_contour_indexes = cell(img_num, 1);
lm3d_all_indexes = cell(img_num, 1);
lm3d_inner_index = basel_face.inner_index;
% facial inner features numbers
inner_num = length(lm3d_inner_index);

for i = 1 : iter_num
    % get the current model
    for j = 1 : img_num
        verts3ds{j} = get_combined_model(basel_face, id_coef, exp_coefs{j});
        if i == 1
            % first iteration does not have correspondece
            camera = ...
                estimate_camera(lm2ds{j}(:, 1 : inner_num), ...
                verts3ds{j}(:, lm3d_inner_index));
        else
            camera = ...
                estimate_camera(lm2ds{j}, ...
                verts3ds{j}(:, [lm3d_inner_index; lm3d_contour_indexes{j}]));
        end
        proj_all_lm3ds{j} = transform_lm3d(verts3ds{j}, camera);
        cameras{j} = camera;
        lm3d_contour_indexes{j} = ...
            find_contour_index(lm2ds{j}(:, inner_num + 1 : end), proj_all_lm3ds{j});
        lm3d_all_indexes{j} = [lm3d_inner_index; lm3d_contour_indexes{j}];
    end
    % get correspondence 
    [id_coef, exp_coefs] = ...
        joint_estimate_shape_coef(basel_face, lm3d_all_indexes, cameras, lm2ds, 250);
end
end

function contour_index = find_contour_index(lm2d, proj_all_lm3d)
assert(length(lm2d) == 19);
hull_index = convhull(proj_all_lm3d(1, :), proj_all_lm3d(2, :));
idx = knnsearch(proj_all_lm3d(:, hull_index)', lm2d');
contour_index = hull_index(idx);

% figure; hold on;
% for i = 1 : length(lm2d)
%     line([lm2d(1, i), proj_all_lm3d(1, contour_index(i))], [lm2d(2, i), proj_all_lm3d(2, contour_index(i))], 'lineWidth', 5);
% end
% scatter(lm2d(1, :), lm2d(2, :), 'r.'); hold on;
% scatter(proj_all_lm3d(1, contour_index), proj_all_lm3d(2, contour_index), 'b.'); axis equal;
end

