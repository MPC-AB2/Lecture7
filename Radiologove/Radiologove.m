function [segmentedImages] = Radiologove(pathToImages)
%% Load images
addpath(pathToImages)
files = dir([pathToImages '\*.jpg']);
nfiles = size(files,1);
segmentedImages = cell(1,nfiles);

%% Define RCNN
detector = maskrcnn("resnet50-coco");

% figure
% i = 5;
for i = 1:nfiles
    pic = imread(files(i).name);
    I = pic;
    r = round(size(I,1)*0.25);
    c = round(size(I,2)*0.25);
    I = padarray(I, [r c], 0, 'both');
    mask = [];
    [masks,labels,scores,boxes] = segmentObjects(detector,I,Threshold=0.55);
    idx = labels=='cat';
    mask = masks(:,:,idx);        
    box = boxes(idx,:);
    label = labels(idx);
    score = scores(idx);
    overlayedImage = insertObjectMask(I,mask);
%     imshow(overlayedImage);
%     subplot(1,nfiles,i)
%     imshow(overlayedImage)
    suma = sum(mask,3);
    mask2 = false(size(suma));
    mask2(suma==2) = 1;
    if sum(mask2(:))==0
        mask2(suma==1) = 1;
    end
%     imshow(mask2)
    mask2 = mask2(r+1:size(mask2,1)-r, c+1:size(mask2,2)-c);
    segmentedImages{1,i} = mask2;
end
end