function lm = read_lm2d(path)
metadata_root = 'C:\Users\david\Desktop\swapface\metadata\';
fid = fopen(path);
raw = fread(fid,inf);
fclose(fid);
str = char(raw');
json = jsondecode(str);
landmark = json.faces.landmark;
% now rearange the lm using the pp_name
fid = fopen(fullfile(metadata_root, 'pp_name.txt'));
pp_name = textscan(fid,'%s');
pp_name = pp_name{1};
lm = zeros(length(pp_name), 2);
for i = 1 : length(pp_name)
   name = pp_name{i};
   lm(i, :) = [landmark.(name).x, landmark.(name).y];
end
fclose(fid);
end