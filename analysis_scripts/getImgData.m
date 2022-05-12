function [img_in,img_size, voxel_size]  = getImgData(fname, recon)

%% standard parameters
stnd_img_size=[239,239,679];
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
        error('UIH input is not available yet!');
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
        error('UIH input is not available yet!');
end % switch


end % function