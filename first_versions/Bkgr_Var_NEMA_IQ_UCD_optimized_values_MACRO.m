% background variability 
% script written by Reimund Bayerlein, 2021

close all;
clear all;

%% input parameters and files
% img_name_folder = '/media/rbayerlein/data/recon_data/20210827/Multi-Bed_Phantom_Multi-Bed_Phantom_154523/';
% img_name_folder = [img_name_folder, 'Phant_tb_SC_PSFoff_360s_4it/'];
% img_name_folder = [img_name_folder, 'Phant_tb_SCoff_PSFon_360s_4it/'];
% img_name_folder = [img_name_folder, 'Phant_tb_SCoff_PSFoff_360s_4it/'];
% img_name_folder = [img_name_folder, 'Phant_tb_scat_corr_1920s_4it/'];
% img_name_folder = [img_name_folder, 'Phant_tb_scat_corr_360s_4it_lm2blocksino5d_DEBUG/'];
% img_name_folder = [img_name_folder, 'Phant_tb_SCon_PSFon_360s_4it_scale_by_number/'];

img_name_folder ='/home/rbayerlein/Documents/Projects/20210407_Img_Qty_Assessment/Results_IQ_Dummy_Image/';
% img_name_raw = [img_name_folder, 'lmrecon_explorer_OSEM_f0.intermediate.'];
% img_name_raw = [img_name_folder, 'NEMA_IQ_Ground_Truth_1.425iso_subsampled.'];
img_name_raw = [img_name_folder, 'NEMA_IQ_Ground_Truth_2.85iso.'];

num_iter=1; % total number of iterations

voxel_size_scaling_factor=2.85/2.85;

img_size = [239,239,679];
img_size = round(img_size*voxel_size_scaling_factor);
% img_size = [478,478,1358];

%slice to show
center_slice = 340;
% center_slice = round(img_size(3)/2);

% range of slices in which to repeat the scanning process
slice_range=0;

%stepping size and range for x-y-direction
xy_range=5;         % given as number of steps of size xy_stepsize
xy_stepsize=0.5;   % measured in pixels

artif_shift = 1.0;  % to compensate for weird matlab alignment issue in y-direction
misalignment = 0.0; % misalgnment on purpose (for testing)

% activity contrast
act_contrast = 4.05;

% set flag for double-checking ROI placement on PET image
control_ROIs = true;

% spheres diameter
voxel_size = 2.85/voxel_size_scaling_factor;
spheres_diam = [10,13,17,22,28,37];     % in mm
spheres_diam = spheres_diam/voxel_size;

%% sphere positions 
% Ideal sphere center positions relative to the center
spheres_center = zeros (6,2);

radius_sphere_positions=57.2;   %spheres are placed on a ring with that radius
spheres_center(4,:)= [ sin(pi/6)*radius_sphere_positions, cos(pi/6)*radius_sphere_positions ];
spheres_center(5,:)= [-sin(pi/6)*radius_sphere_positions, cos(pi/6)*radius_sphere_positions];
spheres_center(6,:)= [-radius_sphere_positions, 0 ];
spheres_center(1,:)= [-sin(pi/6)*radius_sphere_positions, -cos(pi/6)*radius_sphere_positions ];
spheres_center(2,:)= [ sin(pi/6)*radius_sphere_positions, -cos(pi/6)*radius_sphere_positions ];
spheres_center(3,:)= [ radius_sphere_positions, 0];

% background spheres
bkgr_spheres_center =   [159.9788,  126.7678;
  121.5417,  150.7041;
   98.4917,  148.5402;
   85.4886,  140.2519;
   80.4643,  126.8862;
   84.1442,  113.1578;
   96.1654,  100.1548;
  120.3627,   92.0744;
  143.1093,   99.9423;
  155.3384,  139.7436;
  153.6753, 112.2731;
  142.2777,  149.2261];
 bkgr_spheres_center = bkgr_spheres_center*voxel_size_scaling_factor;
phantom_center = [119.5,119.5];
% phantom_center = [img_size(1)/2, img_size(2)/2 + artif_shift + misalignment];
% phantom_center = phantom_center*2;

spheres_center = round(spheres_center/voxel_size) + phantom_center - [0.5 -1.5]

slices = zeros(1,2*slice_range+1);

for i = -slice_range : 1 : slice_range
    slices(1,i+slice_range+1) = center_slice + i;
end

best_xy_values = zeros(2,num_iter, 6); %first coordinate holds x and y coordinate respectively
% output arrays for results

bkgr_var_per = zeros(num_iter,6)+100;      % 4 iterations and 6 sphere sizes
contrast_spheres_per = zeros(num_iter,6);  % 4 iterations and 6 sphere sizes

%% positioning of the ROIs with visual display
img_to_show_name = [img_name_raw, num2str(num_iter)]
img_to_show_fid = fopen(img_to_show_name, 'rb');
img_to_show = fread(img_to_show_fid, inf, 'float');
img_to_show = reshape(img_to_show, img_size);
slice = reshape(img_to_show(:,:,center_slice), [img_size(1), img_size(2)]);
slice = rot90(slice, 1);
imshow(slice, [0,max(max(slice))]);

roi_hot_1 = drawcircle('Center',spheres_center(1,:),'Radius',0.9*spheres_diam(1)/2,'Color', 'r');
roi_hot_2 = drawcircle('Center',spheres_center(2,:),'Radius',0.9*spheres_diam(2)/2, 'Color', 'r');
roi_hot_3 = drawcircle('Center',spheres_center(3,:),'Radius',0.9*spheres_diam(3)/2, 'Color', 'r');
roi_hot_4 = drawcircle('Center',spheres_center(4,:),'Radius',0.9*spheres_diam(4)/2, 'Color', 'r');
roi_hot_5 = drawcircle('Center',spheres_center(5,:),'Radius',0.9*spheres_diam(5)/2, 'Color', 'r');
roi_hot_6 = drawcircle('Center',spheres_center(6,:),'Radius',0.9*spheres_diam(6)/2, 'Color', 'r');

if control_ROIs
    pause;
end
spheres_center(1,:) = roi_hot_1.Center;
spheres_center(2,:) = roi_hot_2.Center;
spheres_center(3,:) = roi_hot_3.Center;
spheres_center(4,:) = roi_hot_4.Center;
spheres_center(5,:) = roi_hot_5.Center;
spheres_center(6,:) = roi_hot_6.Center;

        % adjust them if neccessary
roi_1 = drawcircle('Center',bkgr_spheres_center(1,:),'Radius',0.9*spheres_diam(6)/2);
roi_2 = drawcircle('Center',bkgr_spheres_center(2,:),'Radius',0.9*spheres_diam(6)/2);
roi_3 = drawcircle('Center',bkgr_spheres_center(3,:),'Radius',0.9*spheres_diam(6)/2);
roi_4 = drawcircle('Center',bkgr_spheres_center(4,:),'Radius',0.9*spheres_diam(6)/2);
roi_5 = drawcircle('Center',bkgr_spheres_center(5,:),'Radius',0.9*spheres_diam(6)/2);
roi_6 = drawcircle('Center',bkgr_spheres_center(6,:),'Radius',0.9*spheres_diam(6)/2);
roi_7 = drawcircle('Center',bkgr_spheres_center(7,:),'Radius',0.9*spheres_diam(6)/2);
roi_8 = drawcircle('Center',bkgr_spheres_center(8,:),'Radius',0.9*spheres_diam(6)/2);
roi_9 = drawcircle('Center',bkgr_spheres_center(9,:),'Radius',0.9*spheres_diam(6)/2);
roi_10 = drawcircle('Center',bkgr_spheres_center(10,:),'Radius',0.9*spheres_diam(6)/2);
roi_11 = drawcircle('Center',bkgr_spheres_center(11,:),'Radius',0.9*spheres_diam(6)/2);
roi_12 = drawcircle('Center',bkgr_spheres_center(12,:),'Radius',0.9*spheres_diam(6)/2);

if control_ROIs
    pause;
    control_ROIs = false; % no need to check again at this point
end

% Calculate the sphere ROI centers (x,y)
bkgr_spheres_center (12,:) = roi_12.Center;
bkgr_spheres_center (11,:) = roi_11.Center;
bkgr_spheres_center (10,:) = roi_10.Center;
bkgr_spheres_center (9,:) = roi_9.Center;
bkgr_spheres_center (8,:) = roi_8.Center;
bkgr_spheres_center (7,:) = roi_7.Center;
bkgr_spheres_center (6,:) = roi_6.Center;
bkgr_spheres_center (5,:) = roi_5.Center;
bkgr_spheres_center (4,:) = roi_4.Center;
bkgr_spheres_center (3,:) = roi_3.Center;
bkgr_spheres_center (2,:) = roi_2.Center;
bkgr_spheres_center (1,:) = roi_1.Center;

close all;
        
        
%% main program
% go through all slices around the center slice to find best position for
% optimal CRC results
for sl = 1 : 2*slice_range+1    % loop over slices
    current_slice = slices(1,sl);
    fprintf('now running slice offset %d\n',slices(1,sl)-center_slice); 
    fprintf('(takes up to %d seconds per slice)\n', power((2*xy_range+1),2)*(2*slice_range+1));
    
    for f_num = 1 : num_iter    %% running over iterations
    % define temp data
    contrast_tmp = zeros(num_iter,6);
    bkgr_tmp = zeros(num_iter,6)+100;

    % open file
    img_name = [img_name_raw, num2str(f_num)];

    img_fid = fopen(img_name, 'rb');
    img = fread(img_fid, inf, 'float');
    img = reshape(img, img_size);
    slice = reshape(img(:,:,current_slice), [img_size(1), img_size(2)]);
    slice = rot90(slice, 1);
                
        for x_shift = -xy_range : 1 : xy_range     
           for y_shift = -xy_range : 1 : xy_range 
            %fprintf('current shift:\tx=%d\ty=%d\n', x_shift, y_shift);


                %% get ROI statistics
                    %% Analyze the six ROIs on the hot spheres
                    ave_roi_hot = zeros (1,6);
                    sd_roi_hot = zeros (1,6);

                for i=1:6
                    [ave_roi_hot(i),sd_roi_hot(i),~,~] = roi_circ_sub_2D (slice, spheres_center(i,2) + y_shift*xy_stepsize, spheres_center(i,1) + x_shift*xy_stepsize, spheres_diam(i), 1);
                end

                ave_roi_bkgr = zeros(12,5,6);
                for k=1:5 % slices
                    slice = reshape(img(:,:,current_slice-3+k), [img_size(1), img_size(2)]);
                    slice = rot90(slice, 1);
                    for i=1:12 % ROIs per slice
                        for j=1:6   % spheres diameters
                            [ave_roi_bkgr(i, k, j),~,~,~] = roi_circ_sub_2D (slice, bkgr_spheres_center(i,2), bkgr_spheres_center(i,1), spheres_diam(j), 1);
                        end
                    end
                end

                ave_roi_bkgr_flat =  reshape(ave_roi_bkgr, [12*5,6]);
                ave_roi_bkgr_mean = mean(ave_roi_bkgr_flat);

                %% Contrast of six hot spheres

                %NOMIDVARI METHOD
                contrast_spheres = ave_roi_hot./ave_roi_bkgr_mean;
                contrast_tmp(f_num,:) = (contrast_spheres - 1)/(act_contrast -1);

                %% Background variability
                sd_bkgr =  sqrt (sum((ave_roi_bkgr_flat - ave_roi_bkgr_mean).^2)/(12*5-1));
                bkgr_tmp(f_num,:) = sd_bkgr ./ ave_roi_bkgr_mean;
                
                %check for best value
                %save coordinate if better
                for n=1:num_iter
                    for s=1:6
                        if contrast_tmp(n,s) > contrast_spheres_per(n,s) 
                            best_xy_values(1,n,s)=x_shift;
                            best_xy_values(2,n,s)=y_shift;
                        end
                    end
                end
                % save results if temp value is better than stored one
                contrast_spheres_per(contrast_tmp>contrast_spheres_per) = contrast_tmp(contrast_tmp>contrast_spheres_per);
                bkgr_var_per(bkgr_tmp<bkgr_var_per) = bkgr_tmp(bkgr_tmp<bkgr_var_per);
            end
        end
    end % loop over recon iterations
    
    % display results in terminal
% contrast_spheres_per %#ok<NOPTS>
% bkgr_var_per %#ok<NOPTS>
for k=1:6
    fprintf('%d ',contrast_spheres_per(k)); 
end
% reset values
fprintf('\n');
for k=1:6
    fprintf('%d ', bkgr_var_per(k));
end
fprintf('\n');

% reset values for next slice
bkgr_var_per = zeros(num_iter,6)+100;      % 4 iterations and 6 sphere sizes
contrast_spheres_per = zeros(num_iter,6);  % 4 iterations and 6 sphere sizes
disp('======================================================');
end % loop over slices

%% display all best spheres of iteration 4
img_to_show_name = [img_name_raw, num2str(num_iter)];
img_to_show_fid = fopen(img_to_show_name, 'rb');
img_to_show = fread(img_to_show_fid, inf, 'float');
img_to_show = reshape(img_to_show, img_size);
slice = reshape(img_to_show(:,:,center_slice), [img_size(1), img_size(2)]);
slice = rot90(slice, 1);
imshow(slice, [0,max(max(slice))]);
fclose(img_to_show_fid);

for s = 1 : 6
    spheres_center(s,2) =spheres_center(s,2) + xy_stepsize * best_xy_values(1,num_iter,s);
    spheres_center(s,1) =spheres_center(s,1) + xy_stepsize * best_xy_values(2,num_iter,s);
end

roi_hot_1 = drawcircle('Center',spheres_center(1,:),'Radius',0.9*spheres_diam(1)/2,'Color', 'r');
roi_hot_2 = drawcircle('Center',spheres_center(2,:),'Radius',0.9*spheres_diam(2)/2, 'Color', 'r');
roi_hot_3 = drawcircle('Center',spheres_center(3,:),'Radius',0.9*spheres_diam(3)/2, 'Color', 'r');
roi_hot_4 = drawcircle('Center',spheres_center(4,:),'Radius',0.9*spheres_diam(4)/2, 'Color', 'r');
roi_hot_5 = drawcircle('Center',spheres_center(5,:),'Radius',0.9*spheres_diam(5)/2, 'Color', 'r');
roi_hot_6 = drawcircle('Center',spheres_center(6,:),'Radius',0.9*spheres_diam(6)/2, 'Color', 'r');

fclose ('all');
disp('done');