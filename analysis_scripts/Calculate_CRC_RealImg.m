% test reading image and placing ROIs 
function CRC_result = Calculate_CRC_RealImg(fname_in, recon, activity_contrast)
%% read image
[img_in,img_size, voxel_size] = getImgData(fname_in, recon);
if voxel_size(1) ~= voxel_size(2)
    error('Voxel size in x and y direction are different. The current version of this program cannot work with this!');
end
% put function here that reads file and returns img_in

%% parameters
center_slice=round(img_size(3)/2);
image_center = [round(img_size(1)/2), round(img_size(2)/2), center_slice];
ROI_circle_radius = 57.2;       % in mm
Bkgr_ROI_circle_radius = 110;   % in mm

Lung_insert_diam_mm = 45;          % mm
Lung_insert_diam = Lung_insert_diam_mm / voxel_size(1);

phantom_center = zeros(1,3);

%% define phantom center relative to image center
%chose slice in coronal view
coronal_slice = reshape(img_in(:,round(img_size(2)/2),:), [img_size(1), img_size(3)]);
f_cor = figure('Name','Select the axial center of the phantom on the CT image and press enter.');
imshow(coronal_slice, [], 'InitialMag', 'fit');
[z_cor,~] = getpts(f_cor);
close(f_cor);
center_slice=round(z_cor(length(z_cor)));

%chose center with circular ROI in lung incert
transverse_slice = reshape(img_in(:,:,center_slice), [img_size(1),img_size(2)]);
transverse_slice = rot90(transverse_slice,1);
f_trans = figure('Name', 'Move ROI to center of the phantom');
imshow(transverse_slice, [0,max(max(transverse_slice))/4], 'InitialMag', 200);
roi_Lung = drawcircle('Center',[round(img_size(1)/2) round(img_size(2)/2)],'Radius',Lung_insert_diam/2,'Color', 'r');
pause;
phantom_center([2 1])=roi_Lung.Center;
phantom_center (3) = center_slice
close(f_trans);

%% display image in transverse view
slice = reshape(img_in(:,:,center_slice), [img_size(1),img_size(2)]);
slice = rot90(slice,1);
figure;
imshow(slice, []);

%% define ROIs on hot spheres
% diameter
spheres_diam_1D = [10,13,17,22,28,37];  % in mm in 1D
spheres_diam = zeros(6,3);              % in voxel in 3D
for i=1:length(spheres_diam_1D)
    spheres_diam(i,:) = spheres_diam_1D(i);
    spheres_diam(i,:) = spheres_diam(i,:) ./ voxel_size;
end

% centers
spheres_center = zeros (6,3);
spheres_center(1,:)= [-sin(pi/6)*ROI_circle_radius, cos(pi/6)*ROI_circle_radius, 0 ];
spheres_center(2,:)= [ sin(pi/6)*ROI_circle_radius, cos(pi/6)*ROI_circle_radius, 0 ];
spheres_center(3,:)= [ ROI_circle_radius, 0, 0];
spheres_center(4,:)= [ sin(pi/6)*ROI_circle_radius, -cos(pi/6)*ROI_circle_radius, 0 ];
spheres_center(5,:)= [-sin(pi/6)*ROI_circle_radius, -cos(pi/6)*ROI_circle_radius, 0 ];
spheres_center(6,:)= [-ROI_circle_radius, 0, 0 ];

% apply shift
spheres_center = spheres_center/voxel_size(1);

% rotate by 90 degrees
spheres_center = rotate_spheres_90(spheres_center);

% place on image grid
spheres_center = spheres_center + phantom_center;

%% define ROIs on warm background

% centers
bkgr_spheres_center = zeros (12,3);
bkgr_spheres_center(1,:)= [-sin(pi/6)*Bkgr_ROI_circle_radius*0.8, cos(pi/6)*Bkgr_ROI_circle_radius*0.8, 0 ];
bkgr_spheres_center(2,:)= [ sin(pi/6)*Bkgr_ROI_circle_radius*0.8, cos(pi/6)*Bkgr_ROI_circle_radius*0.8, 0 ];
bkgr_spheres_center(3,:)= [ Bkgr_ROI_circle_radius, 0, 0];
bkgr_spheres_center(4,:)= [ sin(pi/6)*Bkgr_ROI_circle_radius, -cos(pi/6)*Bkgr_ROI_circle_radius*0.85, 0 ];
bkgr_spheres_center(5,:)= [-sin(pi/6)*Bkgr_ROI_circle_radius, -cos(pi/6)*Bkgr_ROI_circle_radius*0.85, 0 ];
bkgr_spheres_center(6,:)= [-Bkgr_ROI_circle_radius, 0, 0 ];

bkgr_spheres_center(7,:)= [-sin(pi/3)*Bkgr_ROI_circle_radius*0.8, cos(pi/3)*Bkgr_ROI_circle_radius*0.8, 0 ];
bkgr_spheres_center(8,:)= [ sin(pi/3)*Bkgr_ROI_circle_radius*0.8, cos(pi/3)*Bkgr_ROI_circle_radius*0.8, 0 ];
bkgr_spheres_center(9,:)= [ 0, Bkgr_ROI_circle_radius*0.75, 0];
bkgr_spheres_center(10,:)= [ sin(pi/3)*Bkgr_ROI_circle_radius, -cos(pi/3)*Bkgr_ROI_circle_radius, 0 ];
bkgr_spheres_center(11,:)= [-sin(pi/3)*Bkgr_ROI_circle_radius, -cos(pi/3)*Bkgr_ROI_circle_radius, 0 ];
bkgr_spheres_center(12,:)= [0, -Bkgr_ROI_circle_radius*0.8, 0 ];

% apply shift
bkgr_spheres_center = bkgr_spheres_center/voxel_size(1);

% rotate by 90 degrees
bkgr_spheres_center = rotate_spheres_90(bkgr_spheres_center);

% place on grid
bkgr_spheres_center = bkgr_spheres_center + phantom_center;

%% place ROIs
roi_hot_1 = drawcircle('Center',spheres_center(1,[2 1]),'Radius',0.9*spheres_diam(1,1)/2,'Color', 'r');
roi_hot_2 = drawcircle('Center',spheres_center(2,[2 1]),'Radius',0.9*spheres_diam(2,1)/2, 'Color', 'r');
roi_hot_3 = drawcircle('Center',spheres_center(3,[2 1]),'Radius',0.9*spheres_diam(3,1)/2, 'Color', 'r');
roi_hot_4 = drawcircle('Center',spheres_center(4,[2 1]),'Radius',0.9*spheres_diam(4,1)/2, 'Color', 'r');
roi_hot_5 = drawcircle('Center',spheres_center(5,[2 1]),'Radius',0.9*spheres_diam(5,1)/2, 'Color', 'r');
roi_hot_6 = drawcircle('Center',spheres_center(6,[2 1]),'Radius',0.9*spheres_diam(6,1)/2, 'Color', 'r');

BG_roi_1 = drawcircle('Center',bkgr_spheres_center(1,[2 1]),'Radius',0.9*spheres_diam(6,1)/2);
BG_roi_2 = drawcircle('Center',bkgr_spheres_center(2,[2 1]),'Radius',0.9*spheres_diam(6,1)/2);
BG_roi_3 = drawcircle('Center',bkgr_spheres_center(3,[2 1]),'Radius',0.9*spheres_diam(6,1)/2);
BG_roi_4 = drawcircle('Center',bkgr_spheres_center(4,[2 1]),'Radius',0.9*spheres_diam(6,1)/2);
BG_roi_5 = drawcircle('Center',bkgr_spheres_center(5,[2 1]),'Radius',0.9*spheres_diam(6,1)/2);
BG_roi_6 = drawcircle('Center',bkgr_spheres_center(6,[2 1]),'Radius',0.9*spheres_diam(6,1)/2);
BG_roi_7 = drawcircle('Center',bkgr_spheres_center(7,[2 1]),'Radius',0.9*spheres_diam(6,1)/2);
BG_roi_8 = drawcircle('Center',bkgr_spheres_center(8,[2 1]),'Radius',0.9*spheres_diam(6,1)/2);
BG_roi_9 = drawcircle('Center',bkgr_spheres_center(9,[2 1]),'Radius',0.9*spheres_diam(6,1)/2);
BG_roi_10 = drawcircle('Center',bkgr_spheres_center(10,[2 1]),'Radius',0.9*spheres_diam(6,1)/2);
BG_roi_11 = drawcircle('Center',bkgr_spheres_center(11,[2 1]),'Radius',0.9*spheres_diam(6,1)/2);
BG_roi_12 = drawcircle('Center',bkgr_spheres_center(12,[2 1]),'Radius',0.9*spheres_diam(6,1)/2);

% adjust if necessary

pause
spheres_center(1,[2 1]) = roi_hot_1.Center;
spheres_center(2,[2 1]) = roi_hot_2.Center;
spheres_center(3,[2 1]) = roi_hot_3.Center;
spheres_center(4,[2 1]) = roi_hot_4.Center;
spheres_center(5,[2 1]) = roi_hot_5.Center;
spheres_center(6,[2 1]) = roi_hot_6.Center;

bkgr_spheres_center(1, [2 1]) = BG_roi_1.Center;
bkgr_spheres_center(2, [2 1]) = BG_roi_2.Center;
bkgr_spheres_center(3, [2 1]) = BG_roi_3.Center;
bkgr_spheres_center(4, [2 1]) = BG_roi_4.Center;
bkgr_spheres_center(5, [2 1]) = BG_roi_5.Center;
bkgr_spheres_center(6, [2 1]) = BG_roi_6.Center;
bkgr_spheres_center(7, [2 1]) = BG_roi_7.Center;
bkgr_spheres_center(8, [2 1]) = BG_roi_8.Center;
bkgr_spheres_center(9, [2 1]) = BG_roi_9.Center;
bkgr_spheres_center(10, [2 1]) = BG_roi_10.Center;
bkgr_spheres_center(11, [2 1]) = BG_roi_11.Center;
bkgr_spheres_center(12, [2 1]) = BG_roi_12.Center;

close all;

%% Perform iterative analysis

CRC_result = -1;
                
end % function