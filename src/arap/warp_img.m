function result = warp_img(img, TR1, TR2)
% warp the image according to the TR

% for every pixel in the result, first find its coordinate in TR1, and get
% its position in TR2, simple and easy
TR1 = triangulation(TR1.ConnectivityList, ...
    [size(img, 2) - TR1.Points(:, 1), size(img, 1) - TR1.Points(:, 2)]);
TR2 = triangulation(TR2.ConnectivityList, ...
    [size(img, 2) - TR2.Points(:, 1), size(img, 1) - TR2.Points(:, 2)]);
result = zeros(size(img, 1) * size(img, 2), 3);
[qy, qx] = meshgrid(1 : size(img, 1), 1 : size(img, 2));
qx = reshape(qx, [], 1);
qy = reshape(qy, [], 1);
ti = pointLocation(TR2, qx, qy);
empty_index = isnan(ti);
ti(isnan(ti)) = 1;
B = cartesianToBarycentric(TR2, ti, [qx, qy]);
PC = barycentricToCartesian(TR1, ti, B);
for i = 1 : size(img, 1)
    for j = 1 : size(img, 2)
        k = (i - 1) * size(img, 2) + j;
        ck = [round(PC(k, 2)), round(PC(k, 1))];
        if ck(1) < 1, ck(1) = 1; elseif ck(1) > size(img, 1), ck(1) = size(img, 1); end
        if ck(2) < 1, ck(2) = 1; elseif ck(2) > size(img, 2), ck(2) = size(img, 2); end
        result(k, :) = img(ck(1), ck(2), :);
    end
end
result(empty_index, :) = 0;
result = reshape(result, size(img, 2), size(img, 1), 3);
result = permute(result, [2 1 3]);
result = uint8(result);
end