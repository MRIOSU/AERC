# AERC
## Automatic Extracton of Respiratory signal in CMR
AERC is an image based method of automatic extraction and directionality determination of respiratory signal in multi-slice real-time cardiac MRI.
The respiraotry signal is extracted from RT cine images using PCA. Then, we use a two-step procedure to determine the sign of the signal. First, the signal polarity of all slices is made consistent with a reference slice. Second, a global sign correction is performed by maximizing the correlation of the respiratory signal with the zeroth-moment center curve. 

The proposed method, where no ROI and tuning parameters are induced, is fully automatic and more robust than the previous sign determination algorithms.

The test data (12 slices, SAX stack RT cine images, ~130 Mb) is available here: https://buckeyemailosu-my.sharepoint.com/:u:/g/personal/chen_7211_osu_edu/Eb3NgLT2PXlPn0jhHMit7PMBWyhLHv9CvI-ehGeytqi48g?e=pO6Qg8
### Contact: 
Chong Chen, the Ohio State University (Chong.Chen@osumc.edu)

### Reference:
1. Automatic Extraction and Sign Determination of Respiratory Signal in Real-time Cardiac Magnetic Resonance imaging https://arxiv.org/pdf/2002.03216.pdf (ISBI 2020)
2. Ensuring Respiratory Phase Consistency to Improve Cardiac Function Quantification in Real-Time CMR, C.Chen, et al. (submitted to MRM)
