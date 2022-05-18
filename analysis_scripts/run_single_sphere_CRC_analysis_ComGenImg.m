% run single sphere CRC analysis

close all;

%% input parameters
activity_contrast=4.05;
voxel_size = 2.85;              % in mm

img_size=[239,239,239];                 % shorter axial length than real images!
spheres_diam = [10,13,17,22,28,37];     % in mm
sphere_offset_vector=[0,0,0];           % for testing of different sphere 
                                        % placement on underlying image grid
ROI_dimension = 2;  % 2 means circular ROI, 3 means spherical ROI


center_slice=round(img_size(3)/2);
phantom_center = [round(img_size(1)/2), round(img_size(2)/2), center_slice];
ROI_circle_radius = 57.2;       % in mm

%% open image
fname = ['../../Images/NEMA_IQ_Ground_Truth_', num2str(voxel_size), 'iso.1'];
img_in = fread(fopen(fname, 'rb'), inf, 'float');
img_in = reshape(img_in,img_size);

slice = reshape(img_in(:,:,center_slice), [img_size(1),img_size(2)]);
slice = rot90(slice,1);
figure;
imshow(slice, []);
pause

spheres_center = zeros (6,3);
spheres_center(1,:)= [-sin(pi/6)*ROI_circle_radius, cos(pi/6)*ROI_circle_radius, 0 ];


spheres_diam = spheres_diam/voxel_size;% in voxel
% apply shift
spheres_center = round(spheres_center/voxel_size) - sphere_offset_vector;

% rotate by 90 degrees
spheres_center = rotate_spheres_90(spheres_center);

% place on image grid
spheres_center = spheres_center + phantom_center;
roi_hot_1 = drawcircle('Center',spheres_center(1,[2 1]),'Radius',0.9*spheres_diam(1)/2,'Color', 'r');
close all

%% analysis
% 2D
[ave_roi_hot,sd_roi_hot,~,~] = roi_circ_sub_2D (slice, spheres_center(1,1), spheres_center(1,2), spheres_diam(1), 0)

%3D
% rotate each slice because imrotate3 changes number of elements
rotated_img = zeros(img_size);
for z=1:img_size(3)
    rotated_img(:,:,z) = rot90(reshape(img_in(:,:,z), [img_size(1), img_size(2)]));
end
img_in = rotated_img;
    
[ave_roi_hot_3d,sd_roi_hot_3d,~,~] = voi_sph_sub_3D (img_in, spheres_center(1,1), spheres_center(1,2), center_slice, spheres_diam(1), 0)
