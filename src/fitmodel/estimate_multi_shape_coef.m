function [id_coef, multi_exp_coef] = ...
    estimate_multi_shape_coef(basel, multi_valid_index, multi_camera, multi_lm2d, reg_weight)
% estimate multiple shape coefficients at the same time
% NOTE that different shapes share the same identity coefficients
img_num = length(multi_lm2d);
data_mean = basel.id_mean + basel.exp_mean;
% the eigen values of the principal components
id_val = basel.id_val;
exp_val = basel.exp_val;
id_vec = basel.id_vec;
exp_vec = basel.exp_vec;

% use only valid index
multi_data_mean = cell(img_num, 1);
multi_data_vec = cell(img_num, 1);

for i = 1 : img_num
    multi_data_mean{i} = data_mean(:, multi_valid_index{i});
    multi_data_vec{i} = data_vec(:, multi_valid_index{i}, :);
end

% optimize the expression
id_coef = zeros(length(id_val), 1);
multi_exp_coef = cell(img_num, 1);

% for each image, only estimate the expression coefficients
for j = 1 : img_num
    R = multi_camera{j}.R(1 : 2, :);
    t = multi_camera{j}.t;
    s = multi_camera{j}.s;
    % data term

    A = zeros(numel(lm2d) + length(exp_val), length(exp_val));
    b = zeros(numel(lm2d) + length(exp_val), 1);

    % s: scalar, R: 2x3 mat, lm3d: 3xN, t: 2x1 
    % s(R * lm3d + t) = lm2d
    % s(R * A * x + t) = lm2d

    for k = 1 : length(lm2d)
        % every observable 2d feature points add to 2 equations: x,y
        A(2 * k - 1, :) = s * R(1, 1) * squeeze(data_vec(1, k, :)) + ...
                          s * R(1, 2) * squeeze(data_vec(2, k, :)) + ...
                          s * R(1, 3) * squeeze(data_vec(3, k, :));
        A(2 * k, :) = s * R(2, 1) * squeeze(data_vec(1, k, :)) + ...
                      s * R(2, 2) * squeeze(data_vec(2, k, :)) + ...
                      s * R(2, 3) * squeeze(data_vec(3, k, :));

        b(2 * k - 1) = lm2d(1, k) - s * ...
            (R(1,1) * data_mean(1, k) + R (1,2) * data_mean(2,k) + R(1,3) * data_mean(3,k) + t(1));
        b(2 * k) = lm2d(2, k)- s * ...
            (R(2,1) * data_mean(1, k) + R (2,2) * data_mean(2,k) + R(2,3) * data_mean(3,k) + t(2));
    end
    % add regularization term
    for i = 1 : length(data_val)
        A(2 * length(lm2d) + i, i) = reg_weight * (1 / sqrt(data_val(i)));
        b(2 * length(lm2d) + i) = 0;
    end
coef = A \ b;
id_coef = coef(1 : length(basel.id_val));
exp_coef = coef(length(basel.id_val) + 1 : end);
end