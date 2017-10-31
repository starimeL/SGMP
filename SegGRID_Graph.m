function [SegRAW, SegGRID] = SegGRID_MST(imgRgb,dispar,focal,basel,x0,sx,PosHeight,GroundPlane)    

    global fa2

    height_histdim = 100;
    color_histdim = 16;
    MinSize = 20;
    EdgeMax = 100000;
    BaseNum = 4;
    
    [height, width] = size(dispar);

    dispar = double(dispar);
%     dispar = dispar / Disparity_Max;
%     imgg = double(imgRgb);
%     imgg = imgg / 255;
%     dispar = guidedfilter_color( imgg, dispar, 7, 0.001);
%     dispar = uint16(dispar * Disparity_Max);    
    
    worldZ = (focal * basel) ./ (dispar + 10000);   
        
%     minZ = min(worldZ(:));
%     maxZ = max(worldZ(:));
%     worldZ = worldZ - min(worldZ(:));
%     worldZ = worldZ/max(worldZ(:));        
%     imgg = double(imgRgb);
%     imgg = imgg / 255;    
%     worldZ = guidedfilter_color( imgg, worldZ, 9, 0.001);     
%     worldZ = worldZ*maxZ;
%     worldZ = worldZ + minZ;
    
    worldX = (repmat(1:width,height,1)-x0).*worldZ/(focal/sx);
    
    worldZ = worldZ - min(worldZ(:));
    worldZ = worldZ/max(worldZ(:));
    worldX = worldX - min(worldX(:));
    worldX = worldX/max(worldX(:));      
    
    stepZ = 0.04;
    stepX = 0.02;

%     stepZ = 0.08;
%     stepX = 0.08;    

    indMax = max(ceil(1/stepZ),ceil(1/stepX)) + 1;
    
    imgRgb1 = imgRgb(:,:,1);
    imgRgb2 = imgRgb(:,:,2);
    imgRgb3 = imgRgb(:,:,3);
    
    [ SegRAW,indListNum,RegionHeightHist,RegionColorHist,RegionPNum,GridFlag ] = InitGRID_mex...
        ( indMax,height_histdim,color_histdim,MinSize,stepZ,stepX,GroundPlane,worldZ,worldX,PosHeight,imgRgb1,imgRgb2,imgRgb3 );        
    
    %% Construct Graph
    
    edgeU = zeros(1,EdgeMax);
    edgeV = zeros(1,EdgeMax);
    edgeWeight = zeros(1,EdgeMax);
    EdgeNum = 0;      
    
    for zz = 1:indMax
        for xx = 1:indMax
            
            if GridFlag(zz,xx)==0
                continue;
            end   
            
            % BACK DIRECTION ON Z
            if (zz<indMax) && (GridFlag(zz+1,xx)==1)         
                EdgeNum = EdgeNum + 1;               
                edgeU(EdgeNum) =sub2ind([indMax,indMax],zz,xx); 
                edgeV(EdgeNum) =sub2ind([indMax,indMax],zz+1,xx);            
            end
            
            % RIGHT DIRECITON ON X
            if (xx<indMax) && (GridFlag(zz,xx+1)==1)         
                EdgeNum = EdgeNum + 1;
                edgeU(EdgeNum) =sub2ind([indMax,indMax],zz,xx); 
                edgeV(EdgeNum) =sub2ind([indMax,indMax],zz,xx+1);                                                          
            end                                    
        end
    end    
    
    %% Connect        
    
    fa2 = 1:indMax*indMax;      

    SegNum = sum(GridFlag(:));
    Lastvv = 0;
    
    for iter = 1:SegNum-250
        Maxuu = 0;
        Maxvv = 0;
        MaxWeight = 0;
        for k = 1:EdgeNum      
        
            if fa2(edgeU(k))~=fa2(fa2(edgeU(k)))
                uu = anc(edgeU(k));
            else 
                uu = fa2(edgeU(k));
            end    
    
            if fa2(edgeV(k))~=fa2(fa2(edgeV(k)))
                vv = anc(edgeV(k));
            else 
                vv = fa2(edgeV(k));
            end    
        
            if (uu==vv) || (RegionPNum(vv) + RegionPNum(uu)>10000 )
                continue;
            end 
        
            if (iter==1) || (Lastvv == uu) || (Lastvv == vv)
        
                HistU = RegionHeightHist(uu,:) / norm(RegionHeightHist(uu,:));         
                HistV = RegionHeightHist(vv,:) / norm(RegionHeightHist(vv,:));
                EdgeWeightH = HistU * HistV';
        
                HistU = RegionColorHist(uu,:) / norm(RegionColorHist(uu,:));
                HistV = RegionColorHist(vv,:) / norm(RegionColorHist(vv,:));
                EdgeWeightC = HistU * HistV';
    
                edgeWeight(k) = (BaseNum^EdgeWeightH)*(BaseNum^EdgeWeightC);
            end
        
            if edgeWeight(k)>MaxWeight
                MaxWeight = edgeWeight(k);
                Maxuu = uu;
                Maxvv = vv;
            end
        
%         if (EdgeWeightH>Hist_Similarity_Threshold_Height) || (EdgeWeightC>Hist_Similarity_Threshold_Color) || ((EdgeWeightH>Hist_Similarity_Threshold_Height-0.2) && (EdgeWeightC>Hist_Similarity_Threshold_Color-0.1))       
%             fa(uu) = vv;    
%             RegionHeightHist(vv,:) = RegionHeightHist(vv,:) + RegionHeightHist(uu,:);
%             RegionColorHist(vv,:) = RegionColorHist(vv,:) + RegionColorHist(uu,:);
% %             RegionPNum(vv) = RegionPNum(vv) + RegionPNum(uu);
%         end       
        
        end
    
        if MaxWeight==0
            break;
        end
    
        uu = Maxuu;
        vv = Maxvv;
        fa2(uu) = vv;    
        RegionHeightHist(vv,:) = RegionHeightHist(vv,:) + RegionHeightHist(uu,:);
        RegionColorHist(vv,:) = RegionColorHist(vv,:) + RegionColorHist(uu,:);
        RegionPNum(vv) = RegionPNum(vv) + RegionPNum(uu);
        Lastvv = vv;
    
    end  
    
    cnt = 0;
    for i = 1:indMax*indMax
        if fa2(i)~=i
            cnt = cnt + 1;
        end
    end
    
%     [iter,SegNum-200]
 
    for zz = 1:indMax
        for xx = 1:indMax         
            if indListNum(zz,xx)~=0
                fa2(sub2ind([indMax,indMax],zz,xx)) = anc(sub2ind([indMax,indMax],zz,xx));
            end
        end
    end
    
    SegGRID = zeros(height,width);
    for i = 1:height
        for j = 1:width
            if GroundPlane(i,j)
                continue;
            end                       
            SegGRID(i,j) = fa2(SegRAW(i,j));
        end
    end        
    
    SegGRID(GroundPlane==1) = 8000;     
    SegRAW(GroundPlane==1) = 8000; 
%     [numel(unique(SegGRID(:))),numel(unique(SegRAW(:)))]    
    
end

function ancestor = anc(i)
    global fa2
    x = i;
    while (fa2(x)~=x)
        x = fa2(x);
    end
    ancestor = x;
    x = i;
    while (fa2(x)~=x)
        xx = fa2(x);
        fa2(x) = ancestor;
        x = xx;
    end
end