% MACRO for running the CRC analysis of the computer generated images
close all;

%% input parameters
file_name = '/media/rbayerlein/data/recon_data/20210827/Multi-Bed_Phantom_Multi-Bed_Phantom_154523/Phant_tb_SCon_PSFon_360s_4it_scale_by_number/lmrecon_explorer_OSEM_f0.intermediate.4 ';
activity_contrast=4.05;
recon="UCD";    % alternative; 'UIH', but not implemented yet!

%% main 

CRC = Calculate_CRC_RealImg(file_name, recon, activity_contrast);

%% print results
fprintf('Contrast recovery coefficient:\n');
for i = 1:length(CRC)
    fprintf('%0.3f\t', CRC(i)*100);
end
fprintf('\n');
