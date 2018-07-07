function [imgs, lm2ds] = get_video_info(root, frames, postfix)
frame_num = length(frames);
imgs = cell(frame_num, 1);
lm2ds = cell(frame_num, 1);
% quite magic number, modified later
valid_2d_index = setdiff(1 : 79, [1 : 8, 17 : 24]);
for i = 1 : frame_num
   imgs{i} = imread(fullfile(root, [int2str(frames(i)), '.', postfix]));
   lm2d = read_lm2d(fullfile(root, [int2str(frames(i)), '.json']));
   lm2ds{i} = lm2d(valid_2d_index, :)';
end
end