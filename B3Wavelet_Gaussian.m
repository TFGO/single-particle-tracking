%% info
% Author: Tian Fang
% E-mail: ftian@connect.ust.hk
% Date: Sep 16, 2019
% Description: This script is used to find the center of fluorescent spots
% in a single ROI
% by using B3 wavelet method for particle finding and Gaussian fitting for
% center localization.

% function name: B3Wavelet_Gaussian
% input: image: Region of interest, 2D matrix
% output: center_R_fitting: fitted row coordinates of all detected spots
%         center_C_fitting: fitted column coordinates of all detected spots

function [center_R_fitting,center_C_fitting,gaussian_amp,gaussian_width]=B3Wavelet_Gaussian(image)

%% Suppress noise by using 3x3 average convolution filter
% creates a square average filter whose width is 3 pixels
avf=[1/16 1/16 1/16;1/16 1/2 1/16;1/16 1/16 1/16];
%perform average filter
img_av=conv2(image,avf,'same');
low_av=min(img_av,[],'all');
high_av=max(img_av,[],'all');
% figure
% imshow(img_av,[low_av,high_av]);

%% 3-scale wavelet method to identify spots
% scale-1
u0=[1/16,1/4,3/8,1/4,1/16];
img_1=conv2(u0,u0,img_av','same');
W_1=img_1'-double(img_av);

% scale-2
u1=[1/16,0,1/4,0,3/8,0,1/4,0,1/16];
img_2=conv2(u1,u1,img_1,'same');
W_2=img_2'-img_1';
W_2_thresh=W_2>3*std2(W_2);
% figure
% imshow(W_2_thresh);

% scale-3
u2=[1/16,0,0,0,1/4,0,0,0,3/8,0,0,0,1/4,0,0,0,1/16];
img_3=conv2(u2,u2,img_2,'same');
W_3=img_3'-img_2';
W_3_thresh=W_3>2*std2(W_3);
% figure
% imshow(W_3_thresh);

% sum W_2_thresh and W_3_thresh to get the mask
mask=W_2_thresh|W_3_thresh;
% figure
% imshow(mask);

%% delete spot with any dimension larger than 3 pixels
size_limit=6;
[center_R,center_C,spotNumber]=Segment(mask,size_limit);

%% Use Gaussian Fitting to find the center positions of each spots
center_R_fitting=[];
center_C_fitting=[];
gaussian_width=[];
gaussian_amp=[];

for i=1:spotNumber
    %imcrop: imcrop has a inverted coordinates so swap x_index and y_index
    rect=[center_C(i)-floor(size_limit/2),center_R(i)-floor(size_limit/2),size_limit,size_limit];
    spot_i=imcrop(image,rect);%crop the suspected spot out of the raw image
    [xc_i ,yc_i, amp_i, gaussian_width_i]=center_finding(spot_i);%find the center by using Gaussian fitting
    %quality control
    if xc_i>0&&xc_i<size_limit&&yc_i>0&&yc_i<size_limit&&isreal(gaussian_width_i)&&gaussian_width_i<=2*size_limit&&amp_i<=5*max(spot_i,[],'all')
        center_R_fitting=[center_R_fitting center_R(i)-floor(size_limit/2)+xc_i];
        center_C_fitting=[center_C_fitting center_C(i)-floor(size_limit/2)+yc_i];
        gaussian_width=[gaussian_width gaussian_width_i];
        gaussian_amp=[gaussian_amp amp_i];
    end
end

end