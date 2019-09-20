clear all;
warning('off','all'); %turn off all warnings
analysis_time=datestr(now,'yymmddHHMMSS');

%% select file
default_path='D:\Projects\A-Project 6 Tracking\papers\code';%replace the address of analysis folder here
[file,path] = uigetfile(strcat(default_path,'\*.tif'));
if isequal(file,0)
   disp('User selected Cancel');
else
   disp(['User selected ', fullfile(path,file)]);
end

file_selected=strcat(path,file);%filename of the data to be analyzed
img_info=imfinfo(file_selected);
movieLength=length(img_info);
movieSize=img_info(1).Width;

%% input the start and end frame of the selected file
prompt = {'Enter start frame number:','Enter end frame number:'};
title = 'ROI';
dims = [1 35];
definput = {'1','end'};
input = inputdlg(prompt,title,dims,definput);

frame_start=str2num(input{1});
if strcmp(input{2},'end')
    frame_end=movieLength;
else
    frame_end=str2num(input{2});
end
frame_num=frame_end-frame_start+1;

%% choose the subregion
list = {'Up','Down','Left','Right'};
[subregion_indx,tf] = listdlg('ListString',list,'Name','ROI','PromptString','Select a subregion', 'SelectionMode','single','ListSize',[200,100]);

%% initialize recording excel
%show progress
h = waitbar(0,sprintf('Initializing...'),'Name','Multi-bead Tracking Status'); 

analysis_time=datestr(now,'yymmddHHMMSS');
excelName=strcat(path,file(1:end-4),'_',analysis_time,'.xlsx');
mask_file=strcat(path,file(1:end-4),'_mask_',analysis_time,'.tif');

xlswrite(excelName,{'frame Index'},1,'A1');
xlswrite(excelName,{'X_center'},1,'B1');
xlswrite(excelName,{'Y_center'},1,'C1');
xlswrite(excelName,{'amplitude'},1,'D1');
xlswrite(excelName,{'width'},1,'E1');

%% calculate and record frame by frame
fitting_results=cell(frame_num,5);
tic;
for f=1:frame_num
    %show progress
    perc = ceil(100*f/frame_num);
    waitbar(perc/100,h,sprintf('Analyzing: frame #%d...%d%%',f,perc));
    
    image_f=imread(file_selected,f+frame_start-1);
    switch subregion_indx
        case 1
            image=image_f(1:movieSize/2,:);
        case 2
            image=image_f(movieSize/2:movieSize,:);
        case 3
            image=image_f(:,1:movieSize/2);
        otherwise
            image=image_f(:,movieSize/2:movieSize);
    end
    
    %detect spots in this frame
    [center_R_fitting,center_C_fitting,gaussian_amp,gaussian_width]=B3Wavelet_Gaussian(image);
    fitting_results(f,1:5)={f,num2str(center_R_fitting),num2str(center_C_fitting),num2str(gaussian_amp),num2str(gaussian_width)};
    
    %save into images
    image_size=size(image);
    mask=zeros(image_size);
    for i=1:size(center_R_fitting,2)
        mask(surrounding(center_R_fitting(i),center_C_fitting(i),gaussian_width(i),image_size))=1;
    end
    imwrite(mask,mask_file,'WriteMode','append');
end
fitting_time=toc;
disp(['Fitiing time: ',num2str(fitting_time),'s']);
xlswrite(excelName,fitting_results,1,'A2');
close(h);%close the waitbar
close all;