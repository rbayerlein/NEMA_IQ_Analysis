% test reading image and placing ROIs 
function CRC_result = Calculate_CRC_ComGenImg(activity_contrast, voxel_size, img_size, spheres_diam, sphere_offset_vector)
%% parameters

center_slice=round(img_size(3)/2);
phantom_center = [round(img_size(1)/2), round(img_size(2)/2), center_slice];
ROI_circle_radius = 57.2;       % in mm
Bkgr_ROI_circle_radius = 115;   % in mm

%% read image
fname = ['../../Images/NEMA_IQ_Ground_Truth_', num2str(voxel_size), 'iso.1'];
img_in = fread(fopen(fname, 'rb'), inf, 'float');
img_in = reshape(img_in,img_size);

%% display image
slice = reshape(img_in(:,:,center_slice), [img_size(1),img_size(2)]);
slice = rot90(slice,1);
figure;
imshow(slice, []);

%% define ROIs on hot spheres
% diameter
spheres_diam = spheres_diam/voxel_size;% in voxel

% centers
spheres_center = zeros (6,3);
spheres_center(1,:)= [-sin(pi/6)*ROI_circle_radius, cos(pi/6)*ROI_circle_radius, 0 ];
spheres_center(2,:)= [ sin(pi/6)*ROI_circle_radius, cos(pi/6)*ROI_circle_radius, 0 ];
spheres_center(3,:)= [ ROI_circle_radius, 0, 0];
spheres_center(4,:)= [ sin(pi/6)*ROI_circle_radius, -cos(pi/6)*ROI_circle_radius, 0 ];
spheres_center(5,:)= [-sin(pi/6)*ROI_circle_radius, -cos(pi/6)*ROI_circle_radius, 0 ];
spheres_center(6,:)= [-ROI_circle_radius, 0, 0 ];

% apply shift
spheres_center = round(spheres_center/voxel_size) - sphere_offset_vector;

% rotate by 90 degrees
spheres_center = rotate_spheres_90(spheres_center);

% place on image grid
spheres_center = spheres_center + phantom_center;

%% define ROIs on warm background

% centers
bkgr_spheres_center = zeros (12,3);
bkgr_spheres_center(1,:)= [-sin(pi/6)*Bkgr_ROI_circle_radius, cos(pi/6)*Bkgr_ROI_circle_radius, 0 ];
bkgr_spheres_center(2,:)= [ sin(pi/6)*Bkgr_ROI_circle_radius, cos(pi/6)*Bkgr_ROI_circle_radius, 0 ];
bkgr_spheres_center(3,:)= [ Bkgr_ROI_circle_radius, 0, 0];
bkgr_spheres_center(4,:)= [ sin(pi/6)*Bkgr_ROI_circle_radius, -cos(pi/6)*Bkgr_ROI_circle_radius, 0 ];
bkgr_spheres_center(5,:)= [-sin(pi/6)*Bkgr_ROI_circle_radius, -cos(pi/6)*Bkgr_ROI_circle_radius, 0 ];
bkgr_spheres_center(6,:)= [-Bkgr_ROI_circle_radius, 0, 0 ];
bkgr_spheres_center(7,:)= [-sin(pi/3)*Bkgr_ROI_circle_radius, cos(pi/3)*Bkgr_ROI_circle_radius, 0 ];
bkgr_spheres_center(8,:)= [ sin(pi/3)*Bkgr_ROI_circle_radius, cos(pi/3)*Bkgr_ROI_circle_radius, 0 ];
bkgr_spheres_center(9,:)= [ 0, Bkgr_ROI_circle_radius*0.75, 0];
bkgr_spheres_center(10,:)= [ sin(pi/3)*Bkgr_ROI_circle_radius, -cos(pi/3)*Bkgr_ROI_circle_radius, 0 ];
bkgr_spheres_center(11,:)= [-sin(pi/3)*Bkgr_ROI_circle_radius, -cos(pi/3)*Bkgr_ROI_circle_radius, 0 ];
bkgr_spheres_center(12,:)= [0, -Bkgr_ROI_circle_radius*0.75, 0 ];

% apply shift
bkgr_spheres_center = round(bkgr_spheres_center/voxel_size) - sphere_offset_vector;

% rotate by 90 degrees
bkgr_spheres_center = rotate_spheres_90(bkgr_spheres_center);

% place on grid
bkgr_spheres_center = bkgr_spheres_center + phantom_center;

%% place ROIs
roi_hot_1 = drawcircle('Center',spheres_center(1,[2 1]),'Radius',0.9*spheres_diam(1)/2,'Color', 'r');
roi_hot_2 = drawcircle('Center',spheres_center(2,[2 1]),'Radius',0.9*spheres_diam(2)/2, 'Color', 'r');
roi_hot_3 = drawcircle('Center',spheres_center(3,[2 1]),'Radius',0.9*spheres_diam(3)/2, 'Color', 'r');
roi_hot_4 = drawcircle('Center',spheres_center(4,[2 1]),'Radius',0.9*spheres_diam(4)/2, 'Color', 'r');
roi_hot_5 = drawcircle('Center',spheres_center(5,[2 1]),'Radius',0.9*spheres_diam(5)/2, 'Color', 'r');
roi_hot_6 = drawcircle('Center',spheres_center(6,[2 1]),'Radius',0.9*spheres_diam(6)/2, 'Color', 'r');

BG_roi_1 = drawcircle('Center',bkgr_spheres_center(1,[2 1]),'Radius',0.9*spheres_diam(6)/2);
BG_roi_2 = drawcircle('Center',bkgr_spheres_center(2,[2 1]),'Radius',0.9*spheres_diam(6)/2);
BG_roi_3 = drawcircle('Center',bkgr_spheres_center(3,[2 1]),'Radius',0.9*spheres_diam(6)/2);
BG_roi_4 = drawcircle('Center',bkgr_spheres_center(4,[2 1]),'Radius',0.9*spheres_diam(6)/2);
BG_roi_5 = drawcircle('Center',bkgr_spheres_center(5,[2 1]),'Radius',0.9*spheres_diam(6)/2);
BG_roi_6 = drawcircle('Center',bkgr_spheres_center(6,[2 1]),'Radius',0.9*spheres_diam(6)/2);
BG_roi_7 = drawcircle('Center',bkgr_spheres_center(7,[2 1]),'Radius',0.9*spheres_diam(6)/2);
BG_roi_8 = drawcircle('Center',bkgr_spheres_center(8,[2 1]),'Radius',0.9*spheres_diam(6)/2);
BG_roi_9 = drawcircle('Center',bkgr_spheres_center(9,[2 1]),'Radius',0.9*spheres_diam(6)/2);
BG_roi_10 = drawcircle('Center',bkgr_spheres_center(10,[2 1]),'Radius',0.9*spheres_diam(6)/2);
BG_roi_11 = drawcircle('Center',bkgr_spheres_center(11,[2 1]),'Radius',0.9*spheres_diam(6)/2);
BG_roi_12 = drawcircle('Center',bkgr_spheres_center(12,[2 1]),'Radius',0.9*spheres_diam(6)/2);

% adjust if necessary (SHOULD NOT BE THE CASE FOR COMPUTER GENERATED
% IMAGES!!)

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

%% Analyze the six ROIs on the hot spheres
ave_roi_hot = zeros (1,6);
sd_roi_hot = zeros (1,6);

% activity in hot spheres
for i=1:6
    [ave_roi_hot(i),sd_roi_hot(i),~,~] = roi_circ_sub_2D (slice, spheres_center(i,1), spheres_center(i,2), spheres_diam(i), 1);
end

% activity in background
ave_roi_bkgr = zeros(12,5,6); % spheres, slices, sphere sizes
for k=1:5 % slices
    slice = reshape(img_in(:,:,center_slice-3+k), [img_size(1), img_size(2)]);
    slice = rot90(slice, 1);
    for i=1:12 % ROIs per slice
        for j=1:6   % spheres diameters
            [ave_roi_bkgr(i, k, j),~,~,~] = roi_circ_sub_2D (slice, bkgr_spheres_center(i,1), bkgr_spheres_center(i,2), spheres_diam(j), 1);
        end
    end
end

% create bgkr mean values
ave_roi_bkgr_flat =  reshape(ave_roi_bkgr, [12*5,6]);               % combine all slices for every sphere size
ave_roi_bkgr_mean = mean(ave_roi_bkgr_flat);                        % average bkgr per sphere size

% calculate CRC
contrast_spheres = ave_roi_hot./ave_roi_bkgr_mean;                  % measured activity ratio
CRC_result = (contrast_spheres - 1)/(activity_contrast -1);         % calculate CRC
                
end % function