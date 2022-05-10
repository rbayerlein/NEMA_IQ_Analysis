% run script to go through a certain parameter space and create dummy
% images and analyze them with the CRC analysis tool

%% parameters
output_folder = '/home/rbayerlein/Documents/Projects/20210407_Img_Qty_Assessment/Results_IQ_Dummy_Image/';

activity_ratio = 4.05;

voxel_size=4;

subsample_size=100;

img_size = [239,239,200];

spheres_diam = [10,13,17,22,28,37];

sphere_offset_vector = [0.5 0.5 0]; 
% applying this shifts the center of every sphere to the corner point of the
% voxel grid i.e. where 8 voxels touch
% the shift will performed in negative direction in all 3 coordinates

%% for loops over parameters

if voxel_size < 1.5
    sss=25;
else
    sss=subsample_size;
end
for i = 0:9
    sphere_offset_vector = [0.5 0.5+i*0.1 0];
    fprintf('sphere_offset_vector [%d %d %d]\n', sphere_offset_vector(1), sphere_offset_vector(2), sphere_offset_vector(3));
    %% invokation of function to obtain computer-generated NEMA IQ phantom image
    % disp('starting image generation...');
    % tic
    NEMA_IQ_Ground_Truth_Creator_FCN(output_folder, activity_ratio, voxel_size, sss, img_size, spheres_diam, sphere_offset_vector);
    % toc
    %% Invokation of analysis tool to calculate CRC
    Bkgr_Var_NEMA_IQ_UCD_optimized_values_FCN(output_folder, activity_ratio, voxel_size, img_size, spheres_diam, sphere_offset_vector, 0.0);
end