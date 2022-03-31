function [segmentedImages] = prvni(path)
img_paths = dir([path, '\*.jpg']);
segmentedImages = cell(1,length(img_paths));
detector = maskrcnn("resnet50-coco");

for i = 1:length(img_paths)
   
    I = imread([img_paths(i).folder, '\', img_paths(i).name]);
    [masks,labels,scores,boxes] = segmentObjects(detector,I,Threshold=0.60);%, MinSize=[100 100], NumStrongestRegions=2);
    
    my_labels = labels(labels=='cat');
    my_masks = masks(:,:,labels=='cat');
    my_scores = scores(labels=='cat');
    if length(my_labels)==1 
        mask = my_masks;
    
        maskStack = mask;
        maskStack(:,:,2) = mask;
        mask = activecontour(I,mask,110, 'Chan-Vese', 'SmoothFactor', 1.5);
        maskStack(:,:,1) = mask;
    
        numMasks = size(maskStack,3);
        overlayedImage = insertObjectMask(I,maskStack,'Color',lines(numMasks));
    else   
        mask_thresh = my_masks(:,:,my_scores>=0.92);
        mask = sum(mask_thresh,3);
        mask(mask>1) = 1;
        mask = logical(mask);
        maskStack = mask;
        maskStack(:,:,2) = mask;
        mask = activecontour(I,mask,110, 'Chan-Vese', 'SmoothFactor', 1.5);
        maskStack(:,:,1) = mask;
    
        numMasks = size(maskStack,3);
        overlayedImage = insertObjectMask(I,maskStack,'Color',lines(numMasks));

    end
    segmentedImages{i} = mask;

%     figure
%     imshow(overlayedImage)
end