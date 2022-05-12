% run the NEMA IQ image generator

%% input parameters
activity_ratio = 4.05 / 1;

desired_voxel_size = 2.85;

subsample_factor = 50;   % factor for subsampling a voxel; applied per dimension;

spheres_diam = [10,13,17,22,28,37];     % in mm

sphere_offset_vector = [0 0 0];


%% main
NEMA_IQ_Ground_Truth_Creator(activity_ratio, desired_voxel_size, subsample_factor, spheres_diam, sphere_offset_vector);