function segmentedImage = ToNebudeFungovat(cesta) 

    cesta_pom = cesta + "\*.jpg";
    detector = maskrcnn("resnet50-coco");

    files = dir(cesta_pom);
    n = length(files);  
    for i=1:n
       soubor = [cesta '\' files(i).name];
       obr = imread(soubor);
       kocky{i} = obr;
    end


    segmentedImage = {};
    
    for i=1:n
%         for qw =1:2
            
            I = kocky{i};
        
            %% Algoritmus
    %         I = rgb2gray(I);
        
        
        %     imshow(I)
        %     roi = images.roi.AssistedFreehand;
        %     draw(roi);
        %     mask = createMask(roi);
            [m,n,~] = size(I);
            [object,labels,~,~] = segmentObjects(detector,I,Threshold=0.95);
           if(length(labels)>1)
                if(sum(labels=="cat")>1)
                    idx = find(labels=="cat");
                    if (length(idx)>1)
                        object = object(:,:,idx) ;
                        object = sum(object,3); object(object>1) = 1;
                    else
                        object = object(:,:,idx);
                    end
                else
                    R = round(m/2);
                    S = round(n/2);
                    px = 100;
               
                    object = zeros(size(I,1),size(I,2));
                    object(R-px:R+px,S-px:S+px)= 1; 
                end
            end



        
            if isempty(object)
          
            R = round(m/2);
            S = round(n/2);
            px = 80;
           
                object = zeros(size(I,1),size(I,2));
                object(R-px:R+px,S-px:S+px)= 1; 
            else
               object = double(imerode(object,strel("disk",80)));
            end
        
        
            % % Combine 2 masks
            % combinedMask = imbinarize(imadd(mask, mask2));
            % % Apply the filter
            % J = regionfill(I, combinedMask);
        
        
            o = 0.12;
            backgr = ones(size(I,1),size(I,2));
            backgr(round(o*m):round((1-o)*m),round(o*n):round((1-o)*n))= 0;
        %     
        %     backgr(1:50,10:90)= 1;
            
        %     imshow(backgr)
            
        %     object = zeros(size(I,1),size(I,2));
        %     object(120:300,150:350)= 1; 
        %     imshow(object)
            
            L = superpixels(I,500);
            BW = lazysnapping(I,L,object,backgr);
    
    
    %         figure
            %imshow(BW)
            
        
            %% Ulozeni
            segmentedImage{i} = BW;
%         end
    end
    
%     [segmResults] = Eval_Segmentation(segmentedImage)

end
% detector = maskrcnn("resnet50-coco");
% 
% 
%


% I = imread("Cats\cat1.jpg");
% 
% 
% 
% 
% [masks,labels,scores,boxes] = segmentObjects(detector,I,Threshold=0.80);
% 
% 
% overlayedImage = insertObjectMask(I,masks);
% imshow(overlayedImage)
% showShape("rectangle",boxes,Label=labels,LineColor=[1 0 0])



