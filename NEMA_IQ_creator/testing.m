% test reading image and placing ROIs 

%% parameters
voxel_size=2.85;
img_size = [239,239,679];
center_slice=round(img_size(3)/2);
spheres_diam = [10,13,17,22,28,37];     % in mm
sphere_offset_vector = [0.5 0 0];
phantom_center = [round(img_size(1)/2), round(img_size(2)/2), center_slice]

fname = ['../../Images/NEMA_IQ_Ground_Truth_', num2str(voxel_size), 'iso.1'];

%% read image
img_in = fread(fopen(fname, 'rb'), inf, 'float');
img_in = reshape(img_in,img_size);

%% display image
slice = reshape(img_in(:,:,center_slice), [img_size(1),img_size(2)]);
slice = rot90(slice,1);
figure;
imshow(slice, []);

%% define hot spheres
spheres_diam = spheres_diam/voxel_size; % in voxel

spheres_center = zeros (6,3);

spheres_center(1,:)= [-sin(pi/6)*57.2, cos(pi/6)*57.2, 0 ];
spheres_center(2,:)= [ sin(pi/6)*57.2, cos(pi/6)*57.2, 0 ];
spheres_center(3,:)= [ 57.2, 0, 0];
spheres_center(4,:)= [ sin(pi/6)*57.2, -cos(pi/6)*57.2, 0 ];
spheres_center(5,:)= [-sin(pi/6)*57.2, -cos(pi/6)*57.2, 0 ];
spheres_center(6,:)= [-57.2, 0, 0 ];

spheres_center = round(spheres_center/voxel_size) - sphere_offset_vector

%% rotate by 90 degrees
cos_90=0;
sin_90=1;
for i = 1:length(spheres_diam)
    x_prior=spheres_center(i,1);
    y_prior=spheres_center(i,2);
    spheres_center(i, 1) = cos_90*x_prior - y_prior*sin_90;
    spheres_center(i, 2) = sin_90*x_prior + y_prior*cos_90;
end

spheres_center = spheres_center + phantom_center;

%% place spheres
roi_hot_1 = drawcircle('Center',spheres_center(1,[2 1]),'Radius',0.9*spheres_diam(1)/2,'Color', 'r');
roi_hot_2 = drawcircle('Center',spheres_center(2,[2 1]),'Radius',0.9*spheres_diam(2)/2, 'Color', 'r');
roi_hot_3 = drawcircle('Center',spheres_center(3,[2 1]),'Radius',0.9*spheres_diam(3)/2, 'Color', 'r');
roi_hot_4 = drawcircle('Center',spheres_center(4,[2 1]),'Radius',0.9*spheres_diam(4)/2, 'Color', 'r');
roi_hot_5 = drawcircle('Center',spheres_center(5,[2 1]),'Radius',0.9*spheres_diam(5)/2, 'Color', 'r');
roi_hot_6 = drawcircle('Center',spheres_center(6,[2 1]),'Radius',0.9*spheres_diam(6)/2, 'Color', 'r');
% roi_hot_1 = drawcircle('Center', [1,239], 'Radius', 5)

