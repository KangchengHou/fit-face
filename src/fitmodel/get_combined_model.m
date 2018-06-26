function lm3d = get_combined_model(basel, id_coef, exp_coef)
% get the linear combination of basel model
data_mean = basel.id_mean + basel.exp_mean;
data_vec = cat(3, basel.id_vec, basel.exp_vec);
lm3d = data_mean;
coef = [id_coef; exp_coef];
for i = 1 : length(coef)
   lm3d = lm3d + data_vec(:, :, i) * coef(i); 
end
end