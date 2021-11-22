% Tongge Wu
% Nov 14 2021

% update Nov 21 2021

clear
clc
close all 

% load video file
seqName = 'Walking.54138969';
vName = strcat(seqName, '.video.mp4');
v = VideoReader(vName);

% logger
fprintf('FileName is %s\n', vName);
fprintf('Video Numframes is %d\n', v.NumFrames);
fprintf('Video Width is %d pixel\n', v.Width);
fprintf('Video Height is %d pixel\n', v.Height);

% load background box 
% var name Masks
bbName = strcat(seqName, '.bb.mat');
load(bbName);
bbMask = Masks;
clear Masks

% logger
fprintf('Background Box Masks Numframes is %d\n', length(bbMask));

% load background subtract 
% var name Masks
bsName = strcat(seqName, '.bs.mat');
load(bsName);
bsMask = Masks;
clear Masks

% logger
fprintf('Background Subtract Masks Numframes is %d\n', length(bsMask));

% load part label
% var name Feat
plName = strcat(seqName, '.pl.mat');
load(plName);

% logger
fprintf('Part Label Numframes is %d\n', length(Feat));

% create color map for part label
partList = unique(Feat{1});
partMap = rand(max(partList), 3);
% background set black
partMap(1,:) = [0,0,0];

% init video writter
outputVideo = VideoWriter('tempDemo.mp4','MPEG-4');
outputVideo.FrameRate = 2;
open(outputVideo)

% for idx = 1:v.NumFrames
for idx = 1:10:100
%     raw frame
    currFrame = read(v, idx);

%     background remove box
    currbbMask = bbMask{idx};
    currbbMask = cat(3, currbbMask, currbbMask, currbbMask);
    tempFrambb = currFrame;
    tempFrambb(~currbbMask) = 0;
    
%     background substract
    currbsMask = bsMask{idx};
    currbsMask = cat(3, currbsMask, currbsMask, currbsMask);
    tempFrambs = currFrame;
    tempFrambs(~currbsMask) = 0;

%     plot raw, bb, bs, partLabel in array
    subplot(2,2,1), imshow(currFrame)
    subplot(2,2,2), imshow(tempFrambb)
    subplot(2,2,3), imshow(tempFrambs)
    subplot(2,2,4), imshow(Feat{idx}, partMap)

%     save frame
    writeVideo(outputVideo, getframe(gcf))
end

close all

%  save video
close(outputVideo)

% load depth  
% var name Feat
rdName = strcat(seqName, '.rd.mat');
load(rdName);
rawDeep = Feat;
clear Feat

% logger
fprintf('Depth Numframes is %d\n', length(rawDeep));

% load depth (sc =? subtract clothes)
% var name Feat
scdName = strcat(seqName, '.scd.mat');
load(scdName);
scDeep = Feat;
clear Feat

% logger
fprintf('SC Depth Numframes is %d\n', length(scDeep));

% init video writter
outputVideo = VideoWriter('tempDemp2.mp4','MPEG-4');
outputVideo.FrameRate = 2;
open(outputVideo)

% for idx = 1:v.NumFrames
for idx = 1:10:100

%     read current frame depth image
    currDeep = rawDeep{idx};
    currDeepSc = scDeep{idx};

%     set contour plot range
    low = min(min(currDeep(currDeep > 0)));
    high = max(max(currDeep(currDeep > 0)));
%     set range -> colormap
    cmap = low: 50: high;
    contourf(currDeep, cmap)

%     cosmeic setting
    ax = gca;
    set(ax, 'YDir','reverse')
    axis equal

    colorbar
%     save frame
    writeVideo(outputVideo, getframe(gcf))
   
end

close all

%  save video
close(outputVideo)

