function [xc_i ,yc_i, Amp, gaussian_width]=center_finding(spot_i)%find the center by using Gaussian fitting
% Author: Tian Fang
% Date: Sep 4, 2019
% Description: This function is used to obtain the center position by using
% Gaussian fitting of a 2D fluorescence spot matrix

[height, width]=size(spot_i);

thresh=median(reshape(spot_i,width*height,1));
mmin=min(spot_i,[],'all');
x=double(zeros(height,width));
y=double(zeros(height,width));
noise=double(spot_i(spot_i<thresh));
[x,y]=meshgrid(1:width,1:height);

z=double(spot_i-mmin);
[xc_i,yc_i,Amp,gaussian_width]=gauss2dcirc(z,x,y,std(noise));

end