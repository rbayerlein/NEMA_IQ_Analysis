% run script to go through a certain parameter space and create dummy
% images and analyze them with the CRC analysis tool

%% parameters
output_folder = '/home/rbayerlein/Documents/Projects/20210407_Img_Qty_Assessment/Results_IQ_Dummy_Image/';

activity_ratio = 4.05;

voxel_size=4;

subsample_size=100;

img_size = [239,239,200];

spheres_diam = [5,6,7,8,9,10];

sphere_offset_vector = [0.5 0.5 0]; 
% applying this shifts the center of every sphere to the corner point of the
% voxel grid i.e. where 8 voxels touch
% the shift will performed in negative direction in all 3 coordinates

%% for loops over parameters

for i = 0 : 5

    spheres_diam_this_run = spheres_diam+i*6;
    
    fprintf('diameter from %d to %d\n', spheres_diam_this_run(1), spheres_diam_this_run(6));
%% invokation of function to obtain computer-generated NEMA IQ phantom image
    % disp('starting image generation...');
    % tic
    NEMA_IQ_Ground_Truth_Creator_FCN(output_folder, activity_ratio, voxel_size, subsample_size, img_size, spheres_diam_this_run, sphere_offset_vector);
    % toc
%% Invokation of analysis tool to calculate CRC
    Bkgr_Var_NEMA_IQ_UCD_optimized_values_FCN(output_folder, activity_ratio, voxel_size, img_size, spheres_diam_this_run, sphere_offset_vector);
end