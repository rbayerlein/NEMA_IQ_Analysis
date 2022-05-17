% MACRO for running the CRC analysis of the computer generated images
close all;

%% input parameters
% file_name = '/media/rbayerlein/data/recon_data/20210827/Multi-Bed_Phantom_Multi-Bed_Phantom_154523/Phant_tb_SCon_PSFon_360s_4it_scale_by_number/lmrecon_explorer_OSEM_f0.intermediate.4';
% file_name = '/media/rbayerlein/data/recon_data/20220414/TripleIQ_SC_PSF_1800s_4it/lmrecon_explorer_OSEM_f0.intermediate.4';
% file_name = '../../Images/NEMA_IQ_Ground_Truth_2.85iso.1';
file_name = '/media/rbayerlein/SSD_09_Reimund/20210827/Multi-Bed_Phantom_Multi-Bed_Phantom_154523/Image/6minReconMatch_RB_2.344IT_5it10s_404/00000001.dcm';

activity_contrast=4.05;
recon="UIH";    % alternative; 'UIH', but not implemented yet!

%% main 

CRC = Calculate_CRC_RealImg(file_name, recon, activity_contrast);

%% print results
fprintf('Contrast recovery coefficient:\n');
for i = 1:length(CRC)
    fprintf('%0.3f\t', CRC(i)*100);
end
fprintf('\n');