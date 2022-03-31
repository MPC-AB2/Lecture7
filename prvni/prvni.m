function [segmentedImages] = prvni(path)
img_paths = dir([path, '\*.jpg']);
segmentedImages = cell(1,length(img_paths));
detector = maskrcnn("resnet50-coco");

for i = 1:length(img_paths)
   
    I = imread([img_paths(i).folder, '\', img_paths(i).name]);
    [masks,labels,scores,boxes] = segmentObjects(detector,I,Threshold=0.6);%, MinSize=[100 100], NumStrongestRegions=2);
    
    my_labels = labels(labels=='cat');
    my_masks = masks(:,:,labels=='cat');
    my_scores = scores(labels=='cat');

    if length(my_labels)==1 
        mask = my_masks;
    
        maskStack = mask;
        maskStack(:,:,2) = mask;
        mask = activecontour(I,mask,100, 'Chan-Vese', 'SmoothFactor', 1.5);
        maskStack(:,:,1) = mask;
    
        numMasks = size(maskStack,3);
        overlayedImage = insertObjectMask(I,maskStack,'Color',lines(numMasks));
    else
        %Prekryv
        indexy = [];
        for u = 1:size(my_masks,3)
            for y = 1:size(my_masks,3)
                if u==y
                    continue
                end
                sum1 = sum(sum((my_masks(:,:,u))));
                sum2 = sum(sum((my_masks(:,:,y))));
                sum_overlap = sum(sum(((my_masks(:,:,u)+my_masks(:,:,y))==2)))/2;
                disp((sum_overlap/(sum1 + sum2))*100)
                if (sum_overlap/(sum1 + sum2))*100 < 1.3
                    indexy = [indexy, u, y]; 
                end
    
            end
        end

        indexy = sort(indexy);
        indexy = unique(indexy);

        if length(indexy)~=0
            mask_thresh = my_masks(:,:,indexy);
        else
            [~,idx] = max(my_scores);
            mask_thresh = my_masks(:,:,idx);
        end

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

    figure
    imshow(overlayedImage)
end