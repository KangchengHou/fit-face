function lm2d = transform_lm3d(lm3d, camera)
% lm3d: 3 x N
R = camera.R; s = camera.s; t = camera.t;
lm2d = s * (R(1:2, :) * lm3d + t);

end