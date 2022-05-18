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
ROI_dimension = 3;  % 2 means circular ROI, 3 means spherical ROI

best_CRC = zeros(1,6);
best_positions = zeros(6,3);

%% main
for z=0:0.1:0.5
    fprintf('====\nz=%d\n', z);
    for y = 0:0.1:0.5
        fprintf('scanning x along y=%0.1f\n', y);
        for x=0:0.1:0.5
        
        
            sphere_offset_vector = [x,y,z];

            NEMA_IQ_Ground_Truth_Creator(activity_contrast, desired_voxel_size, subsample_factor, spheres_diam, sphere_offset_vector);
            CRC = Calculate_CRC_ComGenImg(activity_contrast, desired_voxel_size, img_size, spheres_diam, sphere_offset_vector, ROI_dimension);

            for i = 1:6
                if CRC(i) > best_CRC(i)
%                     fprintf('%d: CRC %f > best_CRC %f \t at (%d,%d,%d)\n', i, CRC(i), best_CRC(i), x,y,z);
                    best_CRC(i) = CRC(i);
                    best_positions(i,1) =x;
                    best_positions(i,2) =y;
                    best_positions(i,3) =z;
                end
            end
        end
    end
end

%% print results
fprintf('Contrast recovery coefficient:\n');
for i = 1:length(CRC)
    fprintf('%0.3f\t%0.1f\t%0.1f\t%0.1f\n', best_CRC(i)*100, best_positions(i,1), best_positions(i,2), best_positions(i,3) );
end
disp('done');