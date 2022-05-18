% MACRO for running the CRC analysis of the computer generated images
close all;

%% input parameters
p=genpath('/home/rbayerlein/Documents/Projects/20220510_CRC_Investigation/code/NEMA_IQ_creator');
addpath(p);

subsample_factor = 50;   % factor for subsampling a voxel; applied per dimension;

activity_contrast=4.05;
desired_voxel_size = 2.85;              % in mm
voxel_size_scaling_factor = 2.85/desired_voxel_size;

img_size=[239,239,239];                 % shorter axial length than real images!
img_size = round(img_size*voxel_size_scaling_factor);       % in voxels
spheres_diam = [10,13,17,22,28,37];     % in mm
sphere_offset_vector=[0,0,0];           % for testing of different sphere 
                                        % placement on underlying image grid
ROI_dimension = 2;  % 2 means circular ROI, 3 means spherical ROI

%% main 
for x=0:0.1:0.5
    for y = 0:0.1:0.5
        sphere_offset_vector(1) = sphere_offset_vector(1) + x;
        sphere_offset_vector(2) = sphere_offset_vector(2) + y;
        sphere_offset_vector
        NEMA_IQ_Ground_Truth_Creator(activity_contrast, desired_voxel_size, subsample_factor, spheres_diam, sphere_offset_vector);
        CRC = Calculate_CRC_ComGenImg(activity_contrast, desired_voxel_size, img_size, spheres_diam, sphere_offset_vector, ROI_dimension);

        %% print results
        fprintf('Contrast recovery coefficient:\t');
        for i = 1:length(CRC)
            fprintf('%0.3f\t', CRC(i)*100);
        end
        fprintf('\n');
    end
end