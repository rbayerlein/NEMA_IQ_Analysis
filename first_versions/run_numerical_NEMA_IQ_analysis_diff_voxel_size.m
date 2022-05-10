% run script to go through a certain parameter space and create dummy
% images and analyze them with the CRC analysis tool

%% parameters
output_folder = '/home/rbayerlein/Documents/Projects/20210407_Img_Qty_Assessment/Results_IQ_Dummy_Image/';

activity_ratio = 4.05;

voxel_size=2.85;

subsample_size=100;

img_size = [239,239,200];

spheres_diam = [10,13,17,22,28,37];

sphere_offset_vector = [0.5 0.5 0]; 
% applying this shifts the center of every sphere to the corner point of the
% voxel grid i.e. where 8 voxels touch
% the shift will performed in negative direction in all 3 coordinates

%% for loops over parameters
% voxel_sizes= [0.8, 1, 1.2, 1.4, 1.8, 2.0, 2.2, 2.4, 2.6, 3.0];
voxel_sizes= [2.8];

for i = 1 : length(voxel_sizes)
    if voxel_sizes(i) < 1.5
        sss=25;
    else
        sss=subsample_size;
    end
    fprintf('voxel_size %d\n', voxel_sizes(i));
%% invokation of function to obtain computer-generated NEMA IQ phantom image
    % disp('starting image generation...');
    % tic
    NEMA_IQ_Ground_Truth_Creator_FCN(output_folder, activity_ratio, voxel_sizes(i), sss, img_size, spheres_diam, sphere_offset_vector);
    % toc
%% Invokation of analysis tool to calculate CRC
    Bkgr_Var_NEMA_IQ_UCD_optimized_values_FCN(output_folder, activity_ratio, voxel_sizes(i), img_size, spheres_diam, sphere_offset_vector);
end