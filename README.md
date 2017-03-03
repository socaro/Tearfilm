# jandj


align_video.m	                Align videos to correct for eye movement

## denoising using learned dictionary ##
   | filter_video.m         | Filter video using learned dictionary |
   | createdict.m	          | Creates dictionary using traindata and either approxksvd.m or dictlearn.m |
   | approxksvd.m	          | Function to learn dictionary using createdict.m (approximate KSVD algorithm)|
   | dictlearn.m            | Function to train dictionary using createdict.m (KSVD algorithm) |
   | usedict.m              | Function for dictionary denoising (to be used with blockproc in filter_video) |
   | matching_pursuit.m	    | Matching pursuit algorithm to be used in dictlearn, approxksvd and usedict |
   | traineddict.mat	       | Example for trained dictionary |
   
|   |   |   |   |   |
|---|---|---|---|---|
|   |   |   |   |   |
|   |   |   |   |   |
|   |   |   |   |   |

  * func_denoise_sw2d.m           Function for wavelet denoising exported from toolbox (doesn't work well with constant parameters) 

## Attempts for automatic correlation ##
  * auto_correlation_gradient.m	  Testing automatic correlation of pixels to colormap (thickness) using gradients -- doesn't work well
  * auto_t.m	                    Automatic correlation using blocks in RGB space
  * auto_tlab.m	                  Automatic correlation using blocks in LAB space
  * calibrate_cm.m	              Attempts to create colormap using parameter optimixation (requires calibration.mat)
  * calibration.mat	              Calibration data handpicked from image color values and corresponding thickness
  * fringe_grad.m                 Attempt to correlate colors from fringe peaks to peaks in colormap

## generating colormap ##
* ccolormap.m	                  Function to compute colormap using Fresnel equations
* optics.csv	                  CSV data on hardware for colormap generation
* colormap.mat	                Saved result of ccolormap for later use

## general image functions ##
* findlim.m	                    Find color intensity range in image to use for contrast adjustment (imadjust)
* imagecrop.m	                  Function to crop image from previous imgroi (to be used in video)
* imgroi.m                      Function to remove background from image of eye


