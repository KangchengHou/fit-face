function edge_neighbors = get_edge_neighbors(TR)

edges = TR.edges;
neighbors = edgeAttachments(TR, edges);
neighbors_size = cellfun(@(x) length(x), neighbors);
assert(all(neighbors_size <= 2 & neighbors_size >= 1));
edge_neighbors = cell(size(neighbors));
for i = 1 : length(neighbors)
    ni = neighbors{i};
    n = []; % neighbors
    for j = 1 : length(ni)
        this_v = TR.ConnectivityList(ni(j), :);
        n = union(n, this_v);
    end
    % push the two vertex of the edge to the front part
    n = setdiff(n, edges(i, :));
    edge_neighbors{i} = [edges(i, :)'; n];
end
end