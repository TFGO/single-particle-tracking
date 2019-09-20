function [center_R,center_C,spotNumber]=Segment(mask,size_limit)
% Author: Tian Fang
% Date: Sep 4, 2019
% Description: Thid function is used to obtain the mask from a binary image.
%     detected spots of which any dimension is larger than size_limit
%     pixels are deems as false detections

%% Find connected components in binary image;
CC = bwconncomp(mask);
%disp(CC.NumObjects);
%% filter out all connected components with dimension larger than size_limit
center_R=[];% row # of the center of spots
center_C=[];% column # of the center of spots
for i=1:CC.NumObjects
    [R,C]=ind2sub(CC.ImageSize,CC.PixelIdxList{i});
    if range(R)<=size_limit & range(C)<=size_limit %only accept spot of which the size is not larger than size_limit
        center_R=[center_R round(mean(R))];
        center_C=[center_C round(mean(C))];
    end
end
spotNumber=length(center_R);
end