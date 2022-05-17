% test reading image and placing ROIs 
function CRC_result = Calculate_CRC_RealImg(fname_in, recon, activity_contrast)
%% read image
[img_in,img_size, voxel_size] = getImgData(fname_in, recon);
if voxel_size(1) ~= voxel_size(2)
    error('Voxel size in x and y direction are different. The current version of this program cannot work with this!');
end
% put function here that reads file and returns img_in

%% image parameters
% center_slice=round(img_size(3)/2);
% image_center = [round(img_size(1)/2), round(img_size(2)/2), center_slice];
ROI_circle_radius = 57.2;       % in mm
Bkgr_ROI_circle_radius = 110;   % in mm

Lung_insert_diam_mm = 45;          % mm
Lung_insert_diam = Lung_insert_diam_mm / voxel_size(1);

phantom_center = zeros(1,3);

%% scanning parameters
% scout
sct_slice_range = 2;    % slice range for scount +/- 1
sct_step_size = 0.1;    % step size for scout (in voxels)
sct_step_range = 20;     % number of steps in x and y direction 

% scan
scan_step_size = 0.01;   % step size for scout (in voxels)
scan_step_range = 50;    % number of steps in x and y direction

plot_intermediate = true;

%% define phantom center relative to image center
%chose slice in coronal view
coronal_slice = reshape(img_in(:,round(img_size(2)/2),:), [img_size(1), img_size(3)]);
f_cor = figure('Name','Select the center of a sphere and press enter.');
f_cor.Position = [100 100 1800 1200];
imshow(coronal_slice, [], 'InitialMag', 'fit');
[z_cor,~] = getpts(f_cor);
close(f_cor);
center_slice=round(z_cor(length(z_cor)));

%chose center with circular ROI in lung incert
transverse_slice = reshape(img_in(:,:,center_slice), [img_size(1),img_size(2)]);
transverse_slice = rot90(transverse_slice,1);
f_trans = figure('Name', 'Move ROI to center of the lung insert and press enter.');
f_trans.Position = [100 100 1200 1200];
imshow(transverse_slice, [0,max(max(transverse_slice))/4], 'InitialMag', 'fit');
roi_Lung = drawcircle('Center',[round(img_size(1)/2) round(img_size(2)/2)],'Radius',Lung_insert_diam/2,'Color', 'r');
pause;
phantom_center([2 1])=roi_Lung.Center;
phantom_center (3) = center_slice;
close(f_trans);

%% display image in transverse view
slice = reshape(img_in(:,:,center_slice), [img_size(1),img_size(2)]);
slice = rot90(slice,1);
f_slice = figure;
f_slice.Position = [100 100 1800 1800];
imshow(slice, [], 'InitialMag', 'fit');

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
% calculate background first, as it is calculated with fixed positions
avg_roi_bkgr = zeros(12,5,6);   % (spheres, slices, sphere size)
for k=1:5 % slices
    slice = reshape(img_in(:,:,center_slice), [img_size(1), img_size(2)]);
    slice = rot90(slice, 1);
    for i=1:12 % ROIs per slice
        for j=1:6   % spheres diameters
            [avg_roi_bkgr(i, k, j),~,~,~] = roi_circ_sub_2D (slice, bkgr_spheres_center(i,1), bkgr_spheres_center(i,2), spheres_diam(j), 1);
        end
    end
end
avg_roi_bkgr_flat =  reshape(avg_roi_bkgr, [12*5,6]);           % combine all slices for every sphere size
avg_roi_bkgr_mean = mean(avg_roi_bkgr_flat);                     % average bkgr per sphere size

%run first scout to get first estimate of best position
Highest_Activity = zeros(6,4);   % 1) best CRC, 2) x-coordinate, 3) y-coordinate 4) z-coordinate

for z = center_slice-sct_slice_range:1:center_slice+sct_slice_range
    fprintf('scouting slice number %d\n', z);
    slice = reshape(img_in(:,:,z), [img_size(1), img_size(2)]);
    slice = rot90(slice,1);
    for sph = 1:length(spheres_diam_1D)
        Highest_Activity_tmp = GetHighestActivity(slice, spheres_center(sph,:), spheres_diam(sph,1), sct_step_range, sct_step_size);
        if Highest_Activity_tmp(1) > Highest_Activity(sph,1)    % check if values is higher than in previous slices
            Highest_Activity(sph,:) = Highest_Activity_tmp;     % save values
            Highest_Activity(sph,4) = z;                         % save slice number
        end
    end
end

% select best slice. Must be same slice for ALL ROIs!
best_slice=0;
for sph = 1:length(spheres_diam_1D)
    best_slice=best_slice+Highest_Activity(sph,4);
end
best_slice= round(best_slice/length(spheres_diam_1D));

% calculate intermediate CRC
for sph = 1 : length(spheres_diam_1D)
    Highest_Activity(sph,1) = (Highest_Activity(sph,1)/avg_roi_bkgr_mean(sph)-1)/(activity_contrast-1);
end

%% plotting intermediate results after scout
if plot_intermediate
    figure;
    slice = reshape(img_in(:,:,best_slice), [img_size(1), img_size(2)]);
    slice = rot90(slice,1);
    imshow(slice, [0,max(max(slice))*0.8], 'InitialMag', 'fit');

    drawcircle('Center',Highest_Activity(1,[3 2]),'Radius',0.9*spheres_diam(1,1)/2,'Color', 'r');
    drawcircle('Center',Highest_Activity(2,[3 2]),'Radius',0.9*spheres_diam(2,1)/2, 'Color', 'r');
    drawcircle('Center',Highest_Activity(3,[3 2]),'Radius',0.9*spheres_diam(3,1)/2, 'Color', 'r');
    drawcircle('Center',Highest_Activity(4,[3 2]),'Radius',0.9*spheres_diam(4,1)/2, 'Color', 'r');
    drawcircle('Center',Highest_Activity(5,[3 2]),'Radius',0.9*spheres_diam(5,1)/2, 'Color', 'r');
    drawcircle('Center',Highest_Activity(6,[3 2]),'Radius',0.9*spheres_diam(6,1)/2, 'Color', 'r');

    pause;
    close all;
end
%% run high precision scanning for best position
best_CRC = zeros(6,4);  % 1) best CRC, 2) x-coordinate, 3) y-coordinate 4) z-coordinate

fprintf('scanning for best CRC on slice %d, \n', best_slice);
slice = reshape(img_in(:,:,best_slice), [img_size(1), img_size(2)]);
slice = rot90(slice,1);

for sph = 1:length(spheres_diam_1D)
    fprintf('sphere %d mm\n', spheres_diam_1D(sph));
    start_point = [Highest_Activity(sph,2), Highest_Activity(sph,3), best_slice];
    Highest_Activity_tmp = GetHighestActivity(slice, start_point, spheres_diam(sph,1), scan_step_range, scan_step_size);
    if Highest_Activity_tmp(1) > best_CRC(sph,1)
        best_CRC(sph,:) = Highest_Activity_tmp;
        best_CRC(sph,4) = best_slice;
    end
end

% calculate CRC
for sph = 1 : length(spheres_diam_1D)
    best_CRC(sph,1) = (best_CRC(sph,1)/avg_roi_bkgr_mean(sph)-1)/(activity_contrast-1);
end
CRC_result = best_CRC(:,1);

%% display final results

figure;
imshow(slice, [0,max(max(slice))*0.8], 'InitialMag', 'fit');

drawcircle('Center',best_CRC(1,[3 2]),'Radius',0.9*spheres_diam(1,1)/2,'Color', 'r');
drawcircle('Center',best_CRC(2,[3 2]),'Radius',0.9*spheres_diam(2,1)/2, 'Color', 'r');
drawcircle('Center',best_CRC(3,[3 2]),'Radius',0.9*spheres_diam(3,1)/2, 'Color', 'r');
drawcircle('Center',best_CRC(4,[3 2]),'Radius',0.9*spheres_diam(4,1)/2, 'Color', 'r');
drawcircle('Center',best_CRC(5,[3 2]),'Radius',0.9*spheres_diam(5,1)/2, 'Color', 'r');
drawcircle('Center',best_CRC(6,[3 2]),'Radius',0.9*spheres_diam(6,1)/2, 'Color', 'r');

end % function