function [PE_hb,PI_hb, PE_fr_sel, PI_fr_sel] = beat_selection(Res_sig,trig_time, rej_thres)
%Input:  Res_sig    [FR SLC] (respiratory signal, FR:number of phases, SLC:number of slices)
%        trig_time  [FR SLC] (cardiac trigger time, unit 2.5 ms)
%        rej_thres  threshold to reject the arrhythmic heartbeats ('rej_thres' away from the mean R-R interval)
%Output: PE_hb      [SLC 1]   selected PE heartbeat
%        PI_hb      [SLC 1]   selected PI heartbeat
%        PE_fr_sel  [SLC 2]   phase index of selected PE heartbeat (begin and end frame)
%        PI_fr_sel  [SLC 2]   phase index of selected PI heartbeat (begin and end frame)
%Last modified on 09/24/2020 by Chong Chen (chong.chen@osumc.edu)

SLC = size(Res_sig,2);
PE_hb = zeros(SLC,1); PI_hb = zeros(SLC,1);
PE_fr_sel = zeros(SLC,2); PI_fr_sel = zeros(SLC,2);

% estimate the mean RR interval
RR_interval = [];
for slc_num = 1:SLC
    [tmp_peaks,~] = findpeaks(double(trig_time(:,slc_num)));
    RR_interval = cat(1,RR_interval, tmp_peaks);
end
mean_RR_interval = mean(RR_interval);
std_RR_interval = std(RR_interval);
disp(['Mean RR interval is: ' num2str(mean_RR_interval*2.5) ' ms']);
disp(['Std RR interval is: ' num2str(std_RR_interval*2.5) ' ms']);

for slc_num = 1:SLC
    tmp = Res_sig(:,slc_num);
    ECG_trig = trig_time(:,slc_num);
    [ecg_peaks, peak_loc] = findpeaks(single(ECG_trig));
    HB = numel(peak_loc);
    mean_resp_loc = zeros(HB,1);
    mean_resp_loc(1) = mean(tmp(1:peak_loc(1)));
    for hb_num = 2:HB
        mean_resp_loc(hb_num) = mean(tmp((peak_loc(hb_num-1)+1):peak_loc(hb_num)));
    end
    %%Peak expiration heartbeat (PE)
    mean_resp_loc(1) = inf;
    [~, beat_idx] = sort(mean_resp_loc);
    for i = 1:ceil(numel(beat_idx)/2)
        if abs( ecg_peaks( beat_idx(i) )  - mean_RR_interval ) < mean_RR_interval*rej_thres
            PE_hb(slc_num) = beat_idx(i);
            break
        end
    end 
    PE_fr_sel(slc_num,:) = [(peak_loc(PE_hb(slc_num)-1)+1),peak_loc(PE_hb(slc_num))];
    
    %%Peak inspiration heartbeat (PI)
    mean_resp_loc(1) = -inf;
    [~, beat_idx] = sort(-1*(mean_resp_loc));
    for i = 1:ceil(numel(beat_idx)/2)
        if abs( ecg_peaks( beat_idx(i) )  - mean_RR_interval ) < mean_RR_interval*rej_thres
            PI_hb(slc_num) = beat_idx(i);
            break
        end
    end    
    PI_fr_sel(slc_num,:) = [(peak_loc(PI_hb(slc_num)-1)+1),peak_loc(PI_hb(slc_num))];
    
end
end

