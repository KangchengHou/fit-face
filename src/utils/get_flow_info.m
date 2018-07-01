function [img1, lm2d1, img2, lm2d2] = get_flow_info(root)
img1 = imread(fullfile(root, 'img1.png'));
img2 = imread(fullfile(root, 'img2.png'));

% quite magic number, modified later
valid_2d_index = setdiff(1 : 79, [1 : 8, 17 : 24]);
lm2d1 = read_lm2d(fullfile(root, 'lm1.json'));
lm2d1 = lm2d1(valid_2d_index, :)';
lm2d2 = read_lm2d(fullfile(root, 'lm2.json'));
lm2d2 = lm2d2(valid_2d_index, :)';

end