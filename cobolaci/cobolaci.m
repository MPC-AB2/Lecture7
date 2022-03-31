function [segmentedImages] = cobolaci(pathToImages)
detector = maskrcnn("resnet50-coco");    
    cd(pathToImages);
    a = dir('*.jpg');
    n = numel(a);
    segmentedImages = cell(1,n);
    nonCat = 0;
    for i = 1:n
        nonCat = 0;
        I = imread(['cat' num2str(i) '.jpg']);
%         cat = imresize(I,[800 1200]);
        t = 0.55;
        [masks,labels,scores,boxes] = segmentObjects(detector,I,Threshold = t);
       
        f = find(labels == 'cat');
        while isempty(f) == 1
            t = t-0.5;
            [masks,labels,scores,boxes] = segmentObjects(detector,I,t);
            f = find(labels == 'cat');
                if t == 0.05
                    nonCat = 1;
                    break
                end
        end

        if nonCat == 1 && i >1
            segmentedImages{i} = segmentedImages{i-1};
        else nonCat == 1 && i == 1
            segmentedImages{i} = zeros(size(I,1),size(I,2));
        end
        segmentedIm = squeeze(sum(masks(:,:,f),3));
       
        if sum(sum(segmentedIm > 1))
            cats = length(f);
   
            overlap = bboxOverlapRatio(boxes(f(1),:),boxes(f(2),:));  
   
            if overlap > 0.15
                if sum(sum(masks(:,:,f(2)))) < sum(sum(masks(:,:,f(1))))
                    segmentedIm = masks(:,:,f(2));
                else
                    segmentedIm = masks(:,:,f(1));
                end
   
            end
        end
       
        segmentedImages{i} = logical(segmentedIm);

%         imshow(segmentedImages{i})

    end
end