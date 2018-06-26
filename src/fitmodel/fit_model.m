
function [id_coef, exp_coef, camera] = fit_model(basel_face, lm2d)
% fit using features

iter_num = 3;
% initialize 
id_coef = zeros(length(basel_face.id_val), 1);
exp_coef = zeros(length(basel_face.exp_val), 1);
lm3d_inner_index = basel_face.inner_index;
% facial inner features numbers
inner_num = length(lm3d_inner_index);

for i = 1 : iter_num
    % get the current model
    verts3d = get_combined_model(basel_face, id_coef, exp_coef);
    if i == 1
        % first iteration does not have correspondece
        camera = estimate_camera(lm2d(:, 1 : inner_num), verts3d(:, lm3d_inner_index));
    else
        camera = estimate_camera(lm2d, verts3d(:, [lm3d_inner_index; lm3d_contour_index]));
    end
    % get correspondence 
    proj_all_lm3d = transform_lm3d(verts3d, camera);
    lm3d_contour_index = find_contour_index(lm2d(:, inner_num + 1 : end), proj_all_lm3d);
    [id_coef, exp_coef] = ...
        estimate_shape_coef(basel_face, [lm3d_inner_index; lm3d_contour_index], camera, lm2d, 5);
end
%%
% index = [lm3d_inner_index; lm3d_contour_index];
% figure; scatter(proj_all_lm3d(1, index), proj_all_lm3d(2, index), 'r'); hold on;
% scatter(lm2d(1, :), lm2d(2, :), 'b');
%%
% after `iter_num` iterations, get the final model
% model.verts = get_combined_model(basel_face, id_coef, exp_coef)';
% model.faces = basel_face.faces;

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

