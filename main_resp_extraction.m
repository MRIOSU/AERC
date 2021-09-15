close all;
restoredefaultpath
addpath(genpath('.\Functions'));

%% load multiple slices Images(M_image), DICOM header(dicom_info) and cardiac trigger time(cardic_trigger_time)
disp('Loading the data ...')
load('./vol_1_rt_cine_stack.mat');

%% reorient the image (based on dicom_info) such that the vertical axis has the larger component in the SI direction 
if (dicom_info.orientation(1:3) == 'Tra')
    M_image = rot90(M_image);
end

%% filter the image using a low pass filter (0,0.8] Hz
disp('Filtering the image ...')
RO = size(M_image,1);PE = size(M_image,2);
FR = size(M_image,3);SLC = size(M_image,4);
Ts = dicom_info.RepetitionTime*1e-3; % temporal resolution
time = Ts*(1:FR);
M_image_filt = permute(reshape(fft_filter(reshape(permute(M_image,[3 1 2 4]),[FR, RO*PE*SLC]),Ts,0,0.8),...
           [FR, RO, PE, SLC]),[2 3 1 4]);

%% extract respiratory signal and sign correction
disp('Extract respiratory signal and sign correction ...')
Res_sig = svd_extract_resp(M_image_filt);

%% heart beat selection
disp('Heatbeat selection ...')
rej_thres = 0.15; % threshold to reject the arrhythmic heartbeats (defult 15% away from the mean R-R interval)
[~,~, PE_phase_selected, PI_phase_selected] = beat_selection(Res_sig, cardic_trigger_time, rej_thres);

%% Display the results
disp('Display the results ...')
%%SI Projection image
Projection_im = zeros(RO,FR,SLC);
for slc_num = 1:SLC
    Projection_im(:,:,slc_num) = squeeze(sum(M_image(:,:,:,slc_num),2));
end

figure;
row_num = 2;
for slc_num = 1:SLC
    tmp = Res_sig(:,slc_num)*10; % scale the signal for better visulization
    fr_sel_PE = PE_phase_selected(slc_num,1):PE_phase_selected(slc_num,2);
    fr_sel_PI = PI_phase_selected(slc_num,1):PI_phase_selected(slc_num,2);
    
    [~, peak_loc] = findpeaks(single(cardic_trigger_time(:,slc_num)));
    subplot(row_num,floor(SLC/row_num) + logical(rem(SLC,row_num)),slc_num); imagesc(Projection_im(:,:,slc_num));
    axis image; axis off; colormap(gray);
    hold on; plot(tmp + RO/2, 'r'); % plot the respiratory signal (red)
    plot(peak_loc,tmp(peak_loc) + RO/2,'*'); % plot the ECG triggers
    plot(fr_sel_PE,tmp(fr_sel_PE) + RO/2,'y');% plot the selected PE heartbeat (yellow)
    plot(fr_sel_PI,tmp(fr_sel_PI) + RO/2,'b');% plot the selected PI heartbeat (blue)
    title(['slice' num2str(slc_num)]);
end




