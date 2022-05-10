function fill_factor = GetFillFactor(cx,cy,cz,x,y,z, radius, subsample_factor)
if subsample_factor == 0 % catch invalid value and prevent division by zero
    subsample_factor = 1;
end
num_subvoxels = power(subsample_factor,3);
ct_voxel_contribution = 0;
subvoxel_size_fraction = 1/subsample_factor; % factor describing the size of the subvoxel as fraction of the parant voxel

if rem(subsample_factor,2) == 0 % even
    start_pos_x = x - (subsample_factor/2-1)*subvoxel_size_fraction -1/2*subvoxel_size_fraction;
    start_pos_y = y - (subsample_factor/2-1)*subvoxel_size_fraction -1/2*subvoxel_size_fraction;
    start_pos_z = z - (subsample_factor/2-1)*subvoxel_size_fraction -1/2*subvoxel_size_fraction;
else
    start_pos_x = x - subsample_factor/2*subvoxel_size_fraction + 1/2*subvoxel_size_fraction;
    start_pos_y = y - subsample_factor/2*subvoxel_size_fraction + 1/2*subvoxel_size_fraction;
    start_pos_z = z - subsample_factor/2*subvoxel_size_fraction + 1/2*subvoxel_size_fraction;
end
    
for i = 1 : subsample_factor
    pos_x = start_pos_x + (i-1)*subvoxel_size_fraction;
    
    for j = 1 : subsample_factor
        pos_y = start_pos_y + (j-1)*subvoxel_size_fraction;
        
        for k = 1 : subsample_factor
            pos_z = start_pos_z + (k-1)*subvoxel_size_fraction;
%             if pos_x == 0.75 && pos_y == 0.75 && pos_z == 0.75
%                 pos_x
%                 pos_y
%                 pos_z
%                 sqrt(power(cx-pos_x,2) + power(cy-pos_y,2) + power(cz-pos_z,2))
%             end
            if sqrt(power(cx-pos_x,2) + power(cy-pos_y,2) + power(cz-pos_z,2)) < radius 
                ct_voxel_contribution = ct_voxel_contribution+1;
            end
        end
    end
end
fill_factor = ct_voxel_contribution/num_subvoxels;

end