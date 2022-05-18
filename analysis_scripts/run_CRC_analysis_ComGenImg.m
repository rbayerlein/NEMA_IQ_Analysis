% MACRO for running the CRC analysis of the computer generated images
close all;

%% input parameters
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

CRC = Calculate_CRC_ComGenImg(activity_contrast, desired_voxel_size, img_size, spheres_diam, sphere_offset_vector, ROI_dimension);

%% print results
fprintf('Contrast recovery coefficient:\n');
for i = 1:length(CRC)
    fprintf('%0.3f\t', CRC(i)*100);
end
fprintf('\n');
