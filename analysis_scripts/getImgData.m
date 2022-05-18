function [img_in, img_size, voxel_size]  = getImgData(fname, recon)

%% standard parameters
stnd_img_size=[239,239,679];
img_size = zeros(1,3);
voxel_size = zeros(1,3);
stnd_voxel_size = [2.85,2.85,2.85];

fprintf('Reading data from file %s\n recon type: %s\n', fname, recon);

%% get image dimensions and voxel size
switch recon
    case 'UCD'              %% %% %% %% %% %% UCD %% %% %% %% %% %%
        % check image size
        flag_img_size = false;
        dlg_title = 'Image size';
        dlg_question='use standard image size (239, 239, 679)?';
        answer = questdlg(dlg_question, dlg_title, 'yes', 'no', 'yes'); % last entry is default value
        switch answer
            case 'yes'
                flag_img_size=true;
            case 'no'
                flag_img_size=false;
        end
        if flag_img_size == true
            img_size = stnd_img_size;
        else
            while ~flag_img_size
                dlg_prompt='Please enter correct image dimensions!';
                answer = inputdlg({'x dimension', 'y dimensions', 'z dimensions'}, dlg_prompt, [1 50]);
                if isempty(answer)
                    error('Program interrupted by user!')
                end
                img_size = [str2num(answer{1}), str2num(answer{2}), str2num(answer{3})]; %#ok<ST2NM>
                if length(img_size) ~= 3 || img_size(1) <= 0 || img_size(2) <= 0 || img_size(3) <= 0
                    disp('you must enter three values greater 0!');
                else
                    flag_img_size = true;
                end
                
            end % while
        end % flag check
        
        % check voxel size
        flag_voxel_size = false;
        dlg_title = 'Voxel size';
        dlg_question='use standard voxel size (2.85, 2.85, 2.85)?';
        answer = questdlg(dlg_question, dlg_title, 'yes', 'no', 'yes');
        switch answer
            case 'yes'
                flag_voxel_size=true;
            case 'no'
                flag_voxel_size=false;
        end
        if flag_voxel_size == true
            voxel_size = stnd_voxel_size;
        else
            while ~flag_voxel_size
                dlg_prompt='Please enter correct voxel values!';
                answer = inputdlg({'x dimension', 'y dimensions', 'z dimensions'}, dlg_prompt, [1 50]);
                if isempty(answer)
                    error('Program interrupted by user!')
                end
                voxel_size = [str2num(answer{1}), str2num(answer{2}), str2num(answer{3})]; %#ok<ST2NM>
                if length(voxel_size) ~= 3 || voxel_size(1) <= 0 || voxel_size(2) <= 0 || voxel_size(3) <= 0
                    disp('you must enter three values greater 0!');
                else
                    flag_voxel_size = true;
                end
                
            end % while
        end % flag check
        
    case 'UIH'              %% %% %% %% %% %% UIH %% %% %% %% %% %%        
        % get info from dicom header
        folder = fileparts(fname);
        dir_contents=dir(fullfile(folder, '*.dcm'));
        first_slice_fname = [folder,'/',dir_contents(1).name];
        dcm_info = dicominfo(first_slice_fname);
        third_slice_fname = [folder,'/',dir_contents(3).name];
        dcm_info_third = dicominfo(third_slice_fname);
        
        img_size(1) = dcm_info.Rows;
        img_size(2) = dcm_info.Columns;
        img_size(3) = dcm_info.NumberOfSlices;
        
        voxel_size(1) = double(dcm_info.PixelSpacing(1));
        voxel_size(2) = double(dcm_info.PixelSpacing(2));
        voxel_size(3) = double(abs(dcm_info.SliceLocation - dcm_info_third.SliceLocation)/2);
        
        fprintf('Image size: %dx%dx%d\n', img_size(1), img_size(2), img_size(3));
        fprintf('Voxel size: %dx%dx%d\n', voxel_size(1), voxel_size(2), voxel_size(3));
    otherwise
        error('unknown recon type. abort');
end % switch

%% open and read in image
switch recon
    case 'UCD'              %% %% %% %% %% %% UCD %% %% %% %% %% %%
        fid = fopen(fname, 'rb');
        img_in = fread(fid, inf, 'float');
        img_in = reshape(img_in, img_size);
        fclose(fid);
    case 'UIH'              %% %% %% %% %% %% UIH %% %% %% %% %% %%
        fprintf('reading in %d dicom slices\n', img_size(3));
        img_in = zeros(img_size(1), img_size(2), img_size(3));
        for s = 1 : img_size(3)
            if rem(s,100) == 0
                fprintf('%d slices read.\n', s);
            end
            fname_slice = [folder,'/',dir_contents(s).name];
            dcm_info = dicominfo(fname_slice);
            img_in(:,:,s) = dicomread(fname_slice);
            img_in = double(img_in);
            r_slope = double(dcm_info.RescaleSlope);
            r_intercept = double(dcm_info.RescaleIntercept);
            img_in(:,:,s) = double(img_in(:,:,s)*r_slope + r_intercept);
        end
        fprintf('%d slices read.\n', img_size(3));
        disp('rotate and mirror image to match in-house recon');
        % rotate to match orientation of in-house recon data
        numel(img_in)
        img_in = imrotate3(img_in, 90, [0 0 1]);
        numel(img_in)
        % mirror image to match view of in-house recon data
        img_in = flip(img_in,2);
        
end % switch


end % function