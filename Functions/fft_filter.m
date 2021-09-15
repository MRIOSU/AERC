function x = fft_filter(x,Ts,f_low,f_high)
%Input:      x             [N, C]  (N:signal length, C:number of channel)
%            Ts            temporal resolution in second
%            f_low,f_high  low/high frequency cut
%Output:     x             [N, C] (filtered image)
%Last modified on 09/15/2021 by Chong Chen (chong.chen@osumc.edu)

%length of the signal
N=size(x,1);                               
if 2*floor(N/2)==N
  f=(-N/2:N/2-1)/(Ts*N);                   %frequency vector
else
  f=(-(N-1)/2:(N-1)/2)/(Ts*N);
end
%DFT
x=fftshift(fft(x),1);                     
% rectangle window in the frequency domain
lowf_idx = find(abs(f) < f_low);
highf_idx = find(abs(f) > f_high);
x([lowf_idx,highf_idx],:) = 0;
% inverse DFT
x = ifft(ifftshift(x,1));





