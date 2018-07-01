function d_field = get_displace_field(pt1, pt2, img)
% pt1 
% NOTE : here has some transformation between spatial coordinate and image
% coordinate
d_field = zeros(size(img, 2), size(img, 1), 2);
step = 1;
[x_field, y_field] = meshgrid(1 : step : size(d_field, 1), 1 : step : size(d_field, 2));
delta = pt2 - pt1;
d_fieldx = griddata(pt1(:, 1), pt1(:, 2), ...
    delta(:, 1), x_field, y_field, 'linear');
d_fieldy = griddata(pt1(:, 1), pt1(:, 2), ...
    delta(:, 2), x_field, y_field, 'linear');
d_fieldx(isnan(d_fieldx)) = 0;
d_fieldy(isnan(d_fieldy)) = 0;
d_field = cat(3, d_fieldx, d_fieldy);
d_field = flip(d_field, 1);
d_field = flip(d_field, 2);

end