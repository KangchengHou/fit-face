function TR_pp = arap_warp_image(TR, constrain_pairs, constrain_weight)
%% preprocess
TR_edges = edges(TR);
% find point location and barycentric coordinates
constrain_face_index = pointLocation(TR, constrain_pairs(:, 1:2));
notnan_index = ~isnan(constrain_face_index);
constrain_face_index = constrain_face_index(notnan_index);
constrain_pairs = constrain_pairs(notnan_index, :);
constrain_bary = zeros(length(constrain_face_index), 3);
for i = 1 : size(constrain_bary, 1)
    constrain_bary(i, :) = ...
        cartesianToBarycentric(TR, constrain_face_index(i), constrain_pairs(i, 1 : 2));
end


%% formulate the matrix in step 1
% 0. preprocessing, get all the edge, 
edge_neighbors = get_edge_neighbors(TR);
A1 = zeros((length(TR_edges) + size(constrain_pairs, 1)) * 2, length(TR.Points) * 2);
b1 = zeros(size(A1, 1), 1);
% 1. formualate and solve least square to estimate Tij for each edge
for k = 1 : length(edge_neighbors)
    neighbors_k = edge_neighbors{k};
%     neighbors_v = zeros(2 * length(neighbors_k), 1);
%     neighbors_v(1 : 2 : end) = TR.Points(neighbors_k, 1);
%     neighbors_v(2 : 2 : end) = TR.Points(neighbors_k, 2);
    Gk = get_Gk(neighbors_k, TR);
%     Gk = zeros(length(neighbors_k) * 2, 2);
%     for i = 1 : length(neighbors_k)
%        Gk(2 * i - 1 : 2 * i, :) = ...
%            [TR.Points(neighbors_k(i), 1), TR.Points(neighbors_k(i), 2);
%             TR.Points(neighbors_k(i), 2),-TR.Points(neighbors_k(i), 1)];
%     end
    Ak = zeros(2, length(neighbors_k)  * 2);
    Ak(1,1) = -1; Ak(1, 3) = 1; Ak(2, 2) = -1; Ak(2, 4) = 1;
    ek = TR.Points(TR_edges(k, 2), :) - TR.Points(TR_edges(k, 1), :);
    edge_mat = zeros((length(neighbors_k) - 1) * 2, length(neighbors_k) * 2);
    for i = 1 : length(neighbors_k) - 1
       edge_mat(2 * i - 1, 1) = -1; edge_mat(2 * i - 1, 2 * i + 1) = 1;
       edge_mat(2 * i, 2) = -1; edge_mat(2 * i, 2 * i + 2) = 1;
    end
    Ak = Ak - [ek(1), ek(2); ek(2), -ek(1)] * ((Gk' * Gk) \ Gk') * edge_mat;
    A1_cols = zeros(length(neighbors_k) * 2, 1);
    A1_cols(1 : 2 : end) = 2 * neighbors_k - 1;
    A1_cols(2 : 2 : end) = 2 * neighbors_k;
    % here modified
%     edge_weight = mean(rigid_weight(neighbors_k));
    edge_weight = 1;
    A1(2 * k - 1 : 2 * k, A1_cols) = Ak * edge_weight;
end
for k = 1 : size(constrain_pairs, 1)
   % convert to barycentric
   this_bary = constrain_bary(k, :);
   this_face = TR.ConnectivityList(constrain_face_index(k), :);
   A1(2 * length(edge_neighbors) + 2 * k - 1, 2 * this_face - 1) = constrain_weight * this_bary;
   A1(2 * length(edge_neighbors) + 2 * k, 2 * this_face) = constrain_weight * this_bary;
   b1(2 * length(edge_neighbors) + 2 * k - 1) = constrain_weight * constrain_pairs(k, 3);
   b1(2 * length(edge_neighbors) + 2 * k) = constrain_weight * constrain_pairs(k, 4); 
end

% solve step 1
verts_p = A1 \ b1;
verts_p = [verts_p(1 : 2 : end), verts_p(2 : 2 : end)];
% TR'
TR_p = triangulation(TR.ConnectivityList, verts_p(:, 1), verts_p(:, 2));
% figure; show_2dmesh(TR_p.Points, TR_edges); axis equal;
%% step 2 : solve separately for x and y component
% A2 is same of x/y
A2 = zeros(length(TR_edges) + size(constrain_pairs, 1), length(TR.Points));
% b2 is different for x/y
b2x = zeros(size(A2, 1), 1);
b2y = zeros(size(A2, 1), 1);
for k = 1 : length(TR.edges)
    % set constrain here
    
    neighbors_k = edge_neighbors{k};
    % neighbor vertex of TR'
    neighbors_v = zeros(2 * length(neighbors_k), 1);
    neighbors_v(1 : 2 : end) = TR_p.Points(neighbors_k, 1);
    neighbors_v(2 : 2 : end) = TR_p.Points(neighbors_k, 2);
    Gk = get_Gk(neighbors_k, TR);
    edge_mat = zeros((length(neighbors_k) - 1) * 2, length(neighbors_k) * 2);
    for i = 1 : length(neighbors_k) - 1
       edge_mat(2 * i - 1, 1) = -1; edge_mat(2 * i - 1, 2 * i + 1) = 1;
       edge_mat(2 * i, 2) = -1; edge_mat(2 * i, 2 * i + 2) = 1;
    end
    cksk = inv(Gk' * Gk) * Gk' * edge_mat * neighbors_v;
    Tk = [cksk(1), cksk(2); -cksk(2), cksk(1)] / sqrt(cksk(1) ^ 2 + cksk(2) ^ 2); % do not forget to normalize
    % v_j - v_i
    Tkek = Tk * (TR.Points(TR_edges(k, 2), :) - TR.Points(TR_edges(k, 1), :))';
    % modified here
%     edge_weight = mean(rigid_weight(neighbors_k));
    edge_weight = 1;
    A2(k, TR_edges(k, 2)) = 1 * edge_weight; A2(k, TR_edges(k, 1)) = -1 * edge_weight;
    b2x(k) = Tkek(1) * edge_weight; b2y(k) = Tkek(2) * edge_weight;
end
% constraint
for k = 1 : size(constrain_pairs, 1)
   % convert to barycentric
   this_bary = constrain_bary(k, :);
   this_face = TR.ConnectivityList(constrain_face_index(k), :);
   A2(length(TR_edges) + k, this_face) = constrain_weight * this_bary;
   b2x(length(TR_edges) + k) = constrain_weight * constrain_pairs(k, 3);
   b2y(length(TR_edges) + k) = constrain_weight * constrain_pairs(k, 4); 
end
% solve step 2
verts_pp = zeros(size(verts_p));
verts_pp(:, 1) = A2 \ b2x;
verts_pp(:, 2) = A2 \ b2y;
TR_pp = triangulation(TR.ConnectivityList, verts_pp(:, 1), verts_pp(:, 2));
fprintf('done!\n');
end
