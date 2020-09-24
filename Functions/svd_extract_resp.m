function Res_sig = svd_extract_resp( images_stack)
%Input:  images_stack         [L R FR SLC] (L:number of rows, R:number of columns, FR:number of phases, SLC:number of slices)
%Output: Resp_signal         [FR SLC]
%Last modified on 09/24/2020 by Chong Chen (chong.chen@osumc.edu)

L = size(images_stack,1);  R = size(images_stack,2);
FR = size(images_stack,3); SLC = size(images_stack,4);

Res_sig = zeros(FR,SLC);

eig_image = zeros(L, R, SLC); %eigen images
cov_en_image_all_slc = zeros(1,SLC); %correlation between eigen images of adjacent slices
cov_en_image_sign = zeros(1,SLC); % sign of the correlation

ZMC_all_slc = zeros(FR,SLC); %zeroth-moment center for all slices

for slc_num = 1:SLC
    %% Extract the signal
    image = (((squeeze(images_stack(:,:,:,slc_num)))));    
    % vectoreize each frame
    image_vec = reshape(image,[L*R FR]);
    % remove_mean, build covariance matrix (Eq.(1,2))
    image_vec = bsxfun(@minus, image_vec, mean(image_vec, 2));
    im_sigma = image_vec'*image_vec;
    % SVD
    [~, ~, V_im] = svd(im_sigma);
    resp_PC = 1;
    Res_sig(:,slc_num) = V_im(:,resp_PC);
    eig_image(:,:,slc_num) = reshape(image_vec*V_im(:,resp_PC), [L, R]);
    
    %% Sign correction (step 1, adjust the sign of all slices respect to the 1st slice) 
    % pair-wise correlations between the eigen images of two adjacent slices 
    %(shift eigen image, and find the amount of shift which leads to
    % the largest correaltion)
    tmp_idx = 0; shift_size = 5;
    shift_amout = zeros(2,(shift_size*2+1)^2);
    cov_eig_image = zeros(1,(shift_size*2+1)^2);
    
    for y_shift = (-1*shift_size):1:shift_size
        for x_shift = (-1*shift_size):1:shift_size
            tmp_idx = tmp_idx + 1;
            eig_image_slc = circshift(circshift(eig_image(:,:,slc_num),y_shift,2),x_shift,1); %shifted eigenimage of current slice
            eig_image_pre_slc = eig_image(:,:,max(1,slc_num-1)); %previous slice            
            % generate the mask (keep the top 10 percent of the pixels in eigen images)
            abs_eig_image = abs(eig_image_slc(:));
            abs_eig_image_descen = sort(abs_eig_image,'descend');
            thres_hold = abs_eig_image_descen(max(ceil(numel(abs_eig_image)/10),100));
            mask = find(abs_eig_image > thres_hold);
            % calculate the correlation 
            ZM_tmp = cov(eig_image_slc(mask),eig_image_pre_slc(mask))/std(eig_image_slc(mask))/std(eig_image_pre_slc(mask));
            cov_eig_image(tmp_idx) = ZM_tmp(1,2);
            shift_amout(1,tmp_idx) = x_shift; shift_amout(2,tmp_idx) = y_shift;
        end
    end
    % find the largest correaltion
    [~,max_cov_idx] = max(abs(cov_eig_image));
%     disp([ 'slice:' num2str(slc_num) '   cov:'   num2str(cov_eig_image(max_cov_idx)) '   shift:' num2str(shift_amout(1,max_cov_idx))  '  '  num2str(shift_amout(2,max_cov_idx)) ]);
    cov_en_image_all_slc(1,slc_num) = cov_eig_image(max_cov_idx);
    clear cov_en_image shift_amout;
    % correct the sign (Eq. (3) in Ref.)
    cov_en_image_sign(slc_num) = sign(cov_en_image_all_slc(1,slc_num));
    Res_sig(:,slc_num) = Res_sig(:,slc_num)*prod(cov_en_image_sign(1:slc_num)); %sign correction
    Res_sig(:,slc_num) = (Res_sig(:,slc_num) - mean(Res_sig(:,slc_num)))/std(Res_sig(:,slc_num)); % normalize the signal
    
    
    %% ZMC curve 
    SI_projection = sum(image,2); % SI projection
    % calculate the zeroth-momentum for all frames
    ZM_SI_projection = zeros(size(SI_projection));
    for i = 1:L
        ZM_SI_projection(i,:) = sum(abs(SI_projection(1:i,:)),1);
    end
    % find the location of zeroth-momentum center for each frame
    ZMC_curve = zeros(1,FR);
    for fr = 1:FR
        ZM_tmp = ZM_SI_projection(:,fr);
        d = ZM_tmp - max((ZM_tmp))/2; % displacement to the ZMC
        [~,m_star] = min(abs(d(:))); % Eq. (4) in Ref.
        if d(m_star) < 0; m_star = m_star + 1; end % d(m_star) >=0
        d_p = d(m_star); d_n = d(m_star - 1);
        ZMC_curve(fr) = m_star - d_p/(d_p - d_n); %interpolation, Eq. (5) in Ref.
    end
    %normalize ZMC curve
    ZMC_all_slc(:,slc_num) = (ZMC_curve - mean(ZMC_curve))/std(ZMC_curve);
    
end






%% Sign correction (step 2, overall sign correction)
cov_ZMC_Resp = zeros(1,SLC);
sign_tmp = 0;
cov_thresh = 0.7;
for slc_num = 1:SLC
    cov_tmp = cov(Res_sig(:,slc_num),ZMC_all_slc(:,slc_num));
    cov_ZMC_Resp(slc_num) = cov_tmp(1,2);
    sign_tmp = sign_tmp + sign(cov_ZMC_Resp(slc_num))*max(abs(cov_ZMC_Resp(slc_num)) - cov_thresh,0);
end

if sign_tmp ~= 0
    Res_sig = Res_sig*sign(sign_tmp);
else
    Res_sig = Res_sig*sign(sum(sign(cov_ZMC_Resp)));
    disp('correlation between SVD and LOM is too small for all slices!!!!!');
end

disp('correlation between eigen images of adjacent slices(slice_i, slice_i-1): '); disp(cov_en_image_all_slc);
disp('correlation between PCA curve and ZOM curve: '); disp(cov_ZMC_Resp);


end

