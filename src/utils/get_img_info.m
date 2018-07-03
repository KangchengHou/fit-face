function [img, lm2d] = get_img_info(root, post_fix)
img = imread(fullfile(root, ['img.', post_fix]));
% quite magic number, modified later
valid_2d_index = setdiff(1 : 79, [1 : 8, 17 : 24]);
lm2d = read_lm2d(fullfile(root, 'lm.json'));
lm2d = lm2d(valid_2d_index, :)';
end