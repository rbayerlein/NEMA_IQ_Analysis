% create NEMA IQ ground truth map for debugging

%% parameters
activity_ratio = 4.05 / 1;
desired_voxel_size = 2.85;
voxel_size_scaling_factor=2.85/desired_voxel_size;

voxel_size = 2.85/voxel_size_scaling_factor     % in mm, iotropical

img_size = [239,239,679];
img_size = round(img_size*voxel_size_scaling_factor)

center_slice = round(img_size(3)/2);     % where the spheres will be located

subsample_factor = 50;   % factor for subsampling a voxel; applied per dimension;

spheres_diam = [10,13,17,22,28,37];     % in mm
spheres_diam = spheres_diam/voxel_size; % in voxel

phantom_center = [img_size(1)/2, img_size(2)/2, center_slice];

spheres_center = zeros (6,3);
spheres_center(4,:)= [ sin(pi/6)*57.2, -cos(pi/6)*57.2, 0 ];
spheres_center(5,:)= [-sin(pi/6)*57.2, -cos(pi/6)*57.2, 0 ];
spheres_center(6,:)= [-57.2, 0, 0 ];
spheres_center(1,:)= [-sin(pi/6)*57.2, cos(pi/6)*57.2, 0 ];
spheres_center(2,:)= [ sin(pi/6)*57.2, cos(pi/6)*57.2, 0 ];
spheres_center(3,:)= [ 57.2, 0, 0];

spheres_center = round(spheres_center/voxel_size) + phantom_center - [0.5 0.5 0.5] % - [0.5 0.5 0]

% warm background
BG_size_x = round(img_size(1)*0.5);
BG_size_y = round(img_size(2)*0.4);
BG_size_z = round(img_size(3)/2);

% defin image
grnd_trth_img = zeros(img_size);

%% place spheres
for ax = 1 : img_size(3)
    for x = 1 : img_size(1)
        for y = 1 : img_size(2)
            
            % check warm BG
            if ax > center_slice-BG_size_z/2 && ax < center_slice+BG_size_z/2
                if x > phantom_center(1)-BG_size_x/2 && x < phantom_center(1)+BG_size_x/2
                    if y > phantom_center(2)-BG_size_y/2 && y < phantom_center(2) + BG_size_y/2
                        grnd_trth_img(x,y,ax) = 1;
                        
                        % check all spheres
                        for s = 1 : 6   
                            if sqrt(power(x-spheres_center(s,1),2) + power(y-spheres_center(s,2),2) + power(ax-spheres_center(s,3),2)) <= spheres_diam(s)/2 + 0.5*sqrt(3)
                                fill_factor = GetFillFactor(spheres_center(s,1),spheres_center(s,2),spheres_center(s,3), x,y,ax,spheres_diam(s)/2, subsample_factor);
                                grnd_trth_img(x,y,ax) = grnd_trth_img(x,y,ax)+(activity_ratio-1)*fill_factor;
                                break;  % because a voxel can only contribute to one sphere. no need to check the rest.
                            end
                        end
                        
                    end
                end
            end

        end
    end
end

%% display result
slice = reshape(grnd_trth_img(:,:,center_slice), [img_size(2),img_size(1)]);
slice = rot90(slice,1);
imshow(slice, []);
colorbar

%     roi_hot_1 = drawcircle('Center',spheres_center(1,[2 1]),'Radius',0.9*spheres_diam(1)/2,'Color', 'r');
%     roi_hot_2 = drawcircle('Center',spheres_center(2,[2 1]),'Radius',0.9*spheres_diam(2)/2, 'Color', 'r');
%     roi_hot_3 = drawcircle('Center',spheres_center(3,[2 1]),'Radius',0.9*spheres_diam(3)/2, 'Color', 'r');
%     roi_hot_4 = drawcircle('Center',spheres_center(4,[2 1]),'Radius',0.9*spheres_diam(4)/2, 'Color', 'r');
%     roi_hot_5 = drawcircle('Center',spheres_center(5,[2 1]),'Radius',0.9*spheres_diam(5)/2, 'Color', 'r');
%     roi_hot_6 = drawcircle('Center',spheres_center(6,[2 1]),'Radius',0.9*spheres_diam(6)/2, 'Color', 'r');

%% save image

fname_out = ['/home/rbayerlein/Documents/Projects/20210407_Img_Qty_Assessment/Results_IQ_Dummy_Image/NEMA_IQ_Ground_Truth_', num2str(voxel_size), 'iso.1'];
fid_out = fopen(fname_out, 'wb');
fwrite(fid_out, grnd_trth_img, 'float');
fprintf('image saved as: %s\n', fname_out);
fclose(fid_out);
disp('done');

