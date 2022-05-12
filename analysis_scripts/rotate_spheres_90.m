function spheres_out = rotate_spheres_90(spheres_in)
% function to rotat the spheres around the center point
spheres_out = spheres_in;
cos_90=0;
sin_90=1;

for i = 1:length(spheres_out)
    x_prior=spheres_out(i,1);
    y_prior=spheres_out(i,2);
    spheres_out(i, 1) = cos_90*x_prior - y_prior*sin_90;
    spheres_out(i, 2) = sin_90*x_prior + y_prior*cos_90;
end
end