function [id_coef, exp_coefs] = ...
    joint_estimate_shape_coef(basel, valid_indexes, cameras, lm2ds, reg_weight)
% valid_indexes: cell, contains the valid indexes for each image
% cameras: cell, contains the camera parameter for each image
% lm2ds: contain the 2d landmark position for each image
img_num = length(valid_indexes);
assert(length(cameras) == img_num);
assert(length(lm2ds) == img_num);

% formulate it as a least square problem

data_mean = basel.id_mean + basel.exp_mean;
data_vec = cat(3, basel.id_vec, basel.exp_vec);

% use only valid index
joint_R = cell(img_num, 1);
joint_t = cell(img_num, 1);
joint_s = cell(img_num, 1);
exp_coefs = cell(img_num, 1);
for i = 1 : img_num
    joint_R{i} = cameras{i}.R(1 : 2, :);
    joint_t{i} = cameras{i}.t;
    joint_s{i} = cameras{i}.s;
end
unknown_num = length(basel.id_val) + img_num * length(basel.exp_val);
normal_equ_num = numel(lm2ds{1}) * img_num;
% data term
A = zeros(normal_equ_num + unknown_num, unknown_num);
b = zeros(normal_equ_num + unknown_num, 1);

% s: scalar, R: 2x3 mat, lm3d: 3xN, t: 2x1 
% s(R * lm3d + t) = lm2d
% s(R * A * x + t) = lm2d

% for each image
for k = 1 : img_num
    cols = false(unknown_num, 1);
    cols(1 : length(basel.id_val)) = true;
    cols(length(basel.id_val) + (k - 1) * length(basel.exp_val) + 1 : ...
         length(basel.id_val) + k * length(basel.exp_val)) = true;
    for i = 1 : length(lm2ds{k})
        prev_row_num = (k - 1) * numel(lm2ds{1});
        % every observable 2d feature points add to 2 equations: x,y
        valid_pos = valid_indexes{k}(i);
        A(prev_row_num + 2 * i - 1, cols) = ...
            joint_s{k} * joint_R{k}(1, 1) * squeeze(data_vec(1, valid_pos, :)) + ...
            joint_s{k} * joint_R{k}(1, 2) * squeeze(data_vec(2, valid_pos, :)) + ...
            joint_s{k} * joint_R{k}(1, 3) * squeeze(data_vec(3, valid_pos,:));
        A(prev_row_num + 2 * i, cols) = ...
            joint_s{k} * joint_R{k}(2, 1) * squeeze(data_vec(1, valid_pos, :)) + ...
            joint_s{k} * joint_R{k}(2, 2) * squeeze(data_vec(2, valid_pos, :)) + ...
            joint_s{k} * joint_R{k}(2, 3) * squeeze(data_vec(3, valid_pos, :));
        b(prev_row_num + 2 * i - 1) = lm2ds{k}(1, i) - joint_s{k} * ...
            (joint_R{k}(1,1) * data_mean(1, valid_pos) + ...
             joint_R{k}(1,2) * data_mean(2, valid_pos) + ...
             joint_R{k}(1,3) * data_mean(3, valid_pos) + joint_t{k}(1));
        b(prev_row_num + 2 * i) = lm2ds{k}(2, i)- joint_s{k} * ...
            (joint_R{k}(2,1) * data_mean(1, valid_pos) + ...
             joint_R{k}(2,2) * data_mean(2, valid_pos) + ...
             joint_R{k}(2,3) * data_mean(3, valid_pos) + joint_t{k}(2));
    end
end

% add regularization term
% add regularization term for id_vec
for i = 1 : length(basel.id_val)
    A(normal_equ_num + i, i) = reg_weight * (1 / sqrt(basel.id_val(i)));
    b(normal_equ_num + i) = 0;
end
for k = 1 : img_num
    for i = 1 : length(basel.exp_val)
        col = length(basel.id_val) + (k - 1) * length(basel.exp_val) + i;
        A(normal_equ_num + col, col) = reg_weight * (1 / sqrt(basel.exp_val(i)));
        b(normal_equ_num + col) = 0;
    end
end

coef = A \ b;
id_coef = coef(1 : length(basel.id_val));
for k = 1 : img_num
    exp_coefs{k} = ...
        coef(length(basel.id_val) + (k - 1) * length(basel.exp_val) + 1 : ...
             length(basel.id_val) + k * length(basel.exp_val));
end

end