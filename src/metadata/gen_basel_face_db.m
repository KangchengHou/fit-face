model_path = './model2017-1_face12_nomouth.h5';
basel_face.id_mean = hdf5read(model_path, '/shape/model/mean');
basel_face.id_val = hdf5read(model_path, '/shape/model/pcaVariance')';
basel_face.id_vec = hdf5read(model_path, '/shape/model/pcaBasis');
basel_face.exp_mean = hdf5read(model_path, '/expression/model/mean');
basel_face.exp_val = hdf5read(model_path, '/expression/model/pcaVariance')';
basel_face.exp_vec = hdf5read(model_path, '/expression/model/pcaBasis');
% notice the `+1` operation here
basel_face.faces = hdf5read(model_path, '/shape/representer/cells') + 1;
% post processing
num_vertices = length(basel_face.id_mean) / 3;
basel_face.id_mean = reshape(basel_face.id_mean, 3, num_vertices);
basel_face.id_vec = reshape(basel_face.id_vec', 3, num_vertices, []);
basel_face.exp_mean = reshape(basel_face.exp_mean, 3, num_vertices);
basel_face.exp_vec = reshape(basel_face.exp_vec', 3, num_vertices, []);
basel_face.inner_index = importdata('./inner_index.txt');

% save it to a file
save('basel_face_db.mat', 'basel_face');

