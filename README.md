# AERC
## Automatic Extracton of Respiratory signal in CMR
AERC is an image based method of automatic extraction and sign determination of respiratory signal in multi-slice real-time cardiac MRI.
The respiraotry signal is extracted from RT cine images using PCA. Then, we use a two-step procedure to determine the sign of the signal. First, the signal polarity of all slices is made consistent with a reference slice. Second, a global sign correction is performed by maximizing the correlation of the respiratory signal with the zeroth-moment center curve. 

The proposed method, where no ROI and tuning parameters are induced, is fully automatic and more robust than the previous sign determination algorithms.

The test data (12 slices, SAX stack RT cine images, ~130 Mb) is available here: https://osu.box.com/s/24sn8cs717nhgynjrmqzc1awmc08jf9l

### Contact: 
Chong Chen, the Ohio State University (Chong.Chen@osumc.edu)

### Reference:
1. Automatic extraction and sign determination of respiratory signal in real-time cardiac MRI, C.Chen, et al. (submitted to MRM)
