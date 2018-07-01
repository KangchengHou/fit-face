function show_2dmesh(TR, color)
% show 2d mesh
% verts: the 2d verts
if nargin <= 1
    color = 'blue';
end
TR_edges = edges(TR);
verts = TR.Points;
hold on;
for i = 1 : length(TR_edges)
   v1 = verts(TR_edges(i, 1), :);
   v2 = verts(TR_edges(i, 2), :);
   line([v1(1), v2(1)], [v1(2), v2(2)], 'Color', color);
end
hold off
end