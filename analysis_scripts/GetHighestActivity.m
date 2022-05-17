function highestActivity = GetHighestActivity(slice, sphere_center, sphere_diam, step_range, step_size)
% description: scans the ROI over the sphere
% calculates best possible CRC on a given slice for 1 sphere
% diameter at given position
 
% sphere_center
% sphere_diam
% step_range
% step_size

highestActivity = zeros(1,4);

for x = -step_range:1:+step_range
    for y = -step_range:1:+step_range
        [avg_act_hot,~,~,~] = roi_circ_sub_2D (slice, sphere_center(1,1)+x*step_size, sphere_center(1,2)+y*step_size, sphere_diam, 1);
        if avg_act_hot > highestActivity(1,1)
            highestActivity(1,1)=avg_act_hot;
            highestActivity(1,2)=sphere_center(1,1)+x*step_size;
            highestActivity(1,3)=sphere_center(1,2)+y*step_size;
        end
    end
end
%highestActivity
end % function