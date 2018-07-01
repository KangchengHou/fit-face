function Gk = get_Gk(neighbors_k, TR)
% the original paper has a mistake here
this_edges = TR.Points(neighbors_k(2 : end), :) - TR.Points(neighbors_k(1), :);
Gk = zeros(size(this_edges, 1) * 2, 2);
for i = 1 : size(this_edges, 1)
   Gk(2 * i - 1 : 2 * i, :) = ...
       [this_edges(i, 1), this_edges(i, 2);
        this_edges(i, 2),-this_edges(i, 1)];
end
end