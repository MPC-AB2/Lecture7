function [masks_merged] = kafickari(path_directory)
%%
 % Pls note the format of files,change it as required
 original_files=dir([path_directory '/*.jpg']); 


detector = maskrcnn("resnet50-coco");

 obr = {};
 masks = {};
 masks_new = {};
 labels = {};
 scores = {};
 boxes = {};
 for k=1:length(original_files)
    filename=[path_directory '\' original_files(k).name];
    obr{k}= imread(filename);
    [masks{k},labels{k},scores{k},boxes{k}] = segmentObjects(detector,obr{k},Threshold=0.60);
    tmp = labels{1,k};
    tmp=cellstr(tmp);
    idx = find(strcmp(tmp,'cat' ));   
    mask_tmp = [];

    for i=1:length(idx)
        mask_tmp(:,:,i) = masks{k}(:,:,idx(i));
    end
    masks_new{k} = mask_tmp;

%     overlayedImage = insertObjectMask(obr{k},logical(mask_tmp));
%     figure
%     imshow(overlayedImage)


 end




masks_merged = {};
for i = 1:length(masks_new)
    mask = zeros(size(masks_new{i},1,2));
    for k = 1:size(masks_new{i},3)
        mask(masks_new{i}(:,:,k)==1) = 1;
    end
    masks_merged{i} = logical(mask);


end


end

