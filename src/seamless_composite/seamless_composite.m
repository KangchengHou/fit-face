function optimal_mask = seamless_composite(img1, img2, verts2d, exp_root)
% img1: foreground image
% img2: background image
% verts2d: the vertices of the image2
% will put img1(mask) to img2(mask), i.e. img2(mask) = img1(mask)

% use graph cut to find the best seam
% label0: foreground, label1: background
% for every pixel, compute the probability of being in the foreground
% for every neigbor, compute the neighborhood penalty

% should use a site map
hull_index = convhull(verts2d(1, :), verts2d(2, :));
mask = poly2mask(verts2d(1, hull_index), verts2d(2, hull_index), size(img1, 1), size(img2, 2));
assert(all(size(img1) == size(img2)));
height = size(img1, 1);
width = size(img1, 2);
% hyper parameters

figure; imshow(img2);
[user_pts(:, 2), user_pts(:, 1)] = getpts;

grad1 = get_gradient(img1);
grad2 = get_gradient(img2);

% convert to a more compact format
[site_map, edges, grad1_mat, grad2_mat, data_cost] = ...
    to_compact_format(grad1, grad2, mask, user_pts);
figure; histogram(data_cost);
% post processing because gco support integers better
data_cost = (data_cost - min(data_cost)) / (max(data_cost) - min(data_cost));
viz_data_cost(data_cost, site_map, exp_root);
% output to gco
gco_input_root = 'C:\Users\david\Desktop\fit-face\src\seamless_composite\graph_cut\data';

write_mat(fullfile(gco_input_root, 'grad1.txt'), grad1_mat);
write_mat(fullfile(gco_input_root, 'grad2.txt'), grad2_mat);
write_mat(fullfile(gco_input_root, 'data_cost.txt'), data_cost);
write_mat(fullfile(gco_input_root, 'edges.txt'), edges);

% run gco
gco_exe_path = 'C:\Users\david\Desktop\fit-face\src\seamless_composite\graph_cut\x64\Release\graph_cut.exe';
system(gco_exe_path);

% get the output of gco
result = importdata(fullfile(gco_input_root, 'result.txt'));
optimal_mask = false(size(mask));
for i = 1 : size(mask, 1)
    for j = 1 : size(mask, 2)
       if mask(i, j) && ~result(site_map(i, j))
           optimal_mask(i, j) = 1;
       else
           optimal_mask(i, j) = 0;
       end
    end
end
figure; imshow(optimal_mask);


end

function viz_data_cost(data_cost, site_map, exp_root)
cost = zeros(size(site_map));
for i = 1 : size(site_map, 1)
    for j = 1 : size(site_map, 2)
       if site_map(i, j) ~= 0
           cost(i, j) = data_cost(site_map(i, j));
       end
    end
end
figure; imshow(cost);
imwrite(cost, fullfile(exp_root, 'data_cost.png'));
end

function grad = get_gradient(img)
% output: M x N x 6 RGB
[grad(:, :, 1), grad(:, :, 2)] = imgradientxy(img(:, :, 1));
[grad(:, :, 3), grad(:, :, 4)] = imgradientxy(img(:, : ,2));
[grad(:, :, 5), grad(:, :, 6)] = imgradientxy(img(:, :, 3));
end


function [site_map, edges, grad1_mat, grad2_mat, data_cost] = ...
    to_compact_format(grad1, grad2, mask, user_pts)
% hyper parameters of the data cost
sigma_d = 250;
sigma_s = 300;
alpha = 0.8;
% get site map
site_map = zeros(size(mask));
edges = zeros(sum(sum(mask)) * 2, 2);

site_num = 0;
edge_num = 0;
for i = 1 : size(mask, 1)
    for j = 1 : size(mask, 2)
        if mask(i, j) == 1
            site_num = site_num + 1;
            site_map(i, j) = site_num;
            if i ~= 1
                if mask(i - 1, j)
                    edge_num = edge_num + 1;
                    edges(edge_num, :) = [site_map(i - 1, j), site_map(i, j)];
                end
            end
            if j ~= 1
                if mask(i, j - 1) 
                    edge_num = edge_num + 1; 
                    edges(edge_num, :) = [site_map(i, j - 1), site_map(i, j)];
                end
            end
        end
    end
end
edges = edges(1 : edge_num, :);
edges = edges - 1; % c++ use 0 starting base
% convert the gradient map and get the data cost
grad1_mat = zeros(site_num, 6);
grad2_mat = zeros(site_num, 6);
data_cost = zeros(site_num, 1);
% spatial_dist_set = [];
% grad_mag_set = [];
for i = 1 : size(site_map, 1)
    for j = 1 : size(site_map, 2)
        if site_map(i, j) == 0
            continue;
        end
        grad1_mat(site_map(i, j), :) = grad1(i, j, :);
        grad2_mat(site_map(i, j), :) = grad2(i, j, :);
        % get the data cost
        cur_pt = [i, j];
        % nearest user point
        user_dist = sum((user_pts - cur_pt) .^ 2, 2);
        [~, nearest_index] = min(user_dist); 
        nearest_pt = user_pts(nearest_index, :);
        % the closer to the user pts, the larger the gradient the larger
        spatial_dist = sqrt(sum((cur_pt - nearest_pt) .^ 2));
        grad_mag = sqrt(sum(grad1(i, j, :) .^ 2));
%         spatial_dist_set = [spatial_dist_set; spatial_dist];
%         grad_mag_set = [grad_mag_set; grad_mag];
        data_cost(site_map(i, j)) = ...
            alpha * exp(-spatial_dist / sigma_d) + ...
            (1 - alpha) * (1 - exp(-grad_mag / sigma_s));
    end
end
% figure; histogram(spatial_dist_set); title('spatial distance');
% figure; histogram(grad_mag_set); title('gradient magnitute');

end

function write_mat(path, mat)
rows = size(mat, 1);
cols = size(mat, 2);
dlmwrite(path, [rows, cols], 'delimiter', ' ', 'precision', '%d');
dlmwrite(path, mat, '-append', 'delimiter', ' ');
end
% -----------------------------------------

function out = to_gco_mat(mat)
% input: normal matrix M x N x P
% output: gco format matrix M*N x P
height = size(mat, 1);
width = size(mat, 2);
out = zeros(height * width, size(mat, 3));
for i = 1 : height
    for j = 1 : width
        out(i * width + j, :) = mat(i, j, :);
    end
end
end

function out = from_gco_mat(mat, height, width)
% input: gco format matrix M*N x P
% output: normal matrix M x N x P
out = zeros(height, width, size(mat, 2));
for i = 1 : height
    for j = 1 : width
        out(width, height, :) = mat(i * width + j, :);
    end
end
end


