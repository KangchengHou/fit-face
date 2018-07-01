function result = downsample3d(verts)
ptcloud = pointCloud(verts);
ptcloud2 = pcdownsample(ptcloud, 'gridAverage', 1);
result = ptcloud2.Location;
end