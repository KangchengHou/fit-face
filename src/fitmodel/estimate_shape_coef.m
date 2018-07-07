function [id_coef, exp_coef] = ...
    estimate_shape_coef(basel, valid_index, camera, lm2d, reg_weight)
% formulate it as a least square problem

data_mean = basel.id_mean + basel.exp_mean;
data_val = [basel.id_val, basel.exp_val];
data_vec = cat(3, basel.id_vec, basel.exp_vec);

% use only valid index
data_mean = data_mean(:, valid_index);
data_vec = data_vec(:, valid_index, :);

R = camera.R(1 : 2, :);
t = camera.t;
s = camera.s;
% data term

A = zeros(numel(lm2d) + length(data_val), length(data_val));
b = zeros(numel(lm2d) + length(data_val), 1);

% s: scalar, R: 2x3 mat, lm3d: 3xN, t: 2x1 
% s(R * lm3d + t) = lm2d
% s(R * A * x + t) = lm2d

for i = 1 : length(lm2d)
    % every observable 2d feature points add to 2 equations: x,y
    A(2 * i - 1, :) = s * R(1, 1) * squeeze(data_vec(1, i, :)) + ...
                      s * R(1, 2) * squeeze(data_vec(2, i, :)) + ...
                      s * R(1, 3) * squeeze(data_vec(3, i, :));
    A(2 * i, :) = s * R(2, 1) * squeeze(data_vec(1, i, :)) + ...
                  s * R(2, 2) * squeeze(data_vec(2, i, :)) + ...
                  s * R(2, 3) * squeeze(data_vec(3, i, :));
    
    b(2 * i - 1) = lm2d(1, i) - s * ...
        (R(1,1) * data_mean(1, i) + R (1,2) * data_mean(2,i) + R(1,3) * data_mean(3,i) + t(1));
    b(2 * i) = lm2d(2, i)- s * ...
        (R(2,1) * data_mean(1, i) + R (2,2) * data_mean(2,i) + R(2,3) * data_mean(3,i) + t(2));
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