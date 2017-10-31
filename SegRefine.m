%   This function makes every non-connected componets a single label(avoid 
%   the case that segments in VCCS algorithm are not connected in 2D image
%   but have same label). Then secondly merges very small and noise
%   componets in to their near big ones.


function [segments,small] = SegRefine(SegGRID,skyIndices,worldZ,Edges,GroundPlane, p3 )

    % ------------- Parameters for Segments Refine(fine) ----------------------  
    SegSizeMin                  = p3.SegSizeMin;   
    SegRelativeSizeMin          = p3.SegRelativeSizeMin;
    Gradient_Thr                = p3.Gradient_Thr;
    % -------------------------------------------------------------------------
    
    global fa
    SegmentMax = 100000;    

    [height, width] = size(SegGRID);

    LabelMax = max(SegGRID(:));

%     SPLIT SKY LABEL SEGMENTS 
    SegGRID(skyIndices) = LabelMax*2;    
           
    seg0 = uint16(SegGRID);
    seg = uint16(zeros(height,width));
    dfn = 0;    
    fa = uint16(1:SegmentMax);     
    
    % Relabel all connected components   fa:father  anc:ancestor
    for i = 1:height
        for j = 1:width
            up = false;
            left = false;
            if (i>1) && (seg0(i,j)==seg0(i-1,j))
                up = true;
            end
            if (j>1) && (seg0(i,j)==seg0(i,j-1))    
                left = true;
            end
            if ((~up) && (~left))
                dfn = dfn + 1;
                seg(i,j) = dfn;
            else      
                if (up) && (left) % both up and right
%                     leftLabel = anc(seg(i,j-1));
                    % reduce calling anc funtion
                    father = fa(seg(i,j-1));
                    if father~=fa(father)
                        leftLabel = anc(seg(i,j-1));
                    else 
                        leftLabel = father;
                    end          
                    
%                     upLabel = anc(seg(i-1,j));
                    % reduce calling anc funtion
                    father = fa(seg(i-1,j));
                    if father~=fa(father)
                        upLabel = anc(seg(i-1,j));
                    else 
                        upLabel = father;
                    end                          
                    seg(i,j) = min(leftLabel,upLabel);                    
                    if leftLabel>upLabel
                        fa(leftLabel) = upLabel;
                    else
                        fa(upLabel) = leftLabel;
                    end
                else
                    if (up) % only up
%                         upLabel = anc(seg(i-1,j));
                        % reduce calling anc funtion
                        father = fa(seg(i-1,j));
                        if father~=fa(father)
                            upLabel = anc(seg(i-1,j));
                        else 
                            upLabel = father;
                        end                                                
                        seg(i,j) = upLabel;
                    else % only left
%                         leftLabel = anc(seg(i,j-1));
                        % reduce calling anc funtion
                        father = fa(seg(i,j-1));
                        if father~=fa(father)
                            leftLabel = anc(seg(i,j-1));
                        else 
                            leftLabel = father;
                        end                                                     
                        seg(i,j) = leftLabel;
                    end
                end
            end          
        end
    end
    
    worldZ = worldZ - min(worldZ(:));
    worldZ = worldZ/max(worldZ(:));

    for i = 1:height
        for j = 1:width
            father = fa(seg(i,j));
            if father~=fa(father)
                seg(i,j) = anc(seg(i,j));
            else 
                seg(i,j) = father;
            end            
        end
    end             
    
    Edges = 1 - Edges;
    % count size and mean z and gradient
    SegMeanZ = zeros(1,SegmentMax);
    SegSize = zeros(1,SegmentMax);
    SegGradient = zeros(1,SegmentMax);
    for i = 1:height
        for j = 1:width
            SegLabel = seg(i,j);          
            SegMeanZ(SegLabel) = SegMeanZ(SegLabel) + worldZ(i,j);
            SegSize(SegLabel) = SegSize(SegLabel) + 1;     
            if Edges(i,j)>Gradient_Thr/10
                SegGradient(SegLabel) = SegGradient(SegLabel) + Edges(i,j);
            end
        end
    end

    small = false(height,width);
    % merge small connected componets       
    for i = 2:height-1
        for j = 2:width-1
            SegLabel = seg(i,j);  
            
            % RELATIVE SIZE WITH RESPECT TO Z : PixelRegionSize/MeanZ
%             SegSize(SegLabel)*SegSize(SegLabel)/SegMeanZ(SegLabel)
            if (SegMeanZ(SegLabel)<SegRelativeSizeMin)
                if SegGradient(SegLabel)>Gradient_Thr
                    small(i,j) = true;
                else
                    seg(i,j) = 0;
                end
            end            
%             if (SegSize(SegLabel)<SegSizeMin)
%                 if SegGradient(SegLabel)>Gradient_Thr
%                     small(i,j) = true;
%                 else
%                     seg(i,j) = 0;
%                 end
%             end
        end
    end                  
    
    %% Small Region Refine
    
    seg = double(seg);
    while numel(find(seg==0))~=0
        seg(seg==0)=NaN;
        seg = fillHoles(seg, 'bwdist');
    end
    
    SegBound = edge(seg,'Sobel');
    se = strel('square',3);    
    SegBound = imdilate(SegBound,se);   
    
    GBound=bwperim(GroundPlane); 
    se = strel('square',5);    
    GBound = imdilate(GBound,se);       
    
    small = small | SegBound | GBound;    
    small(:,1) = false;
    small(1,:) = false;
    small(:,width) = false;
    small(height,:) = false;        

    seg = BoundRefine( small, seg, Edges );     
    
    SegSize = zeros(1,SegmentMax);
    for i = 1:height
        for j = 1:width
            SegLabel = seg(i,j);          
            SegSize(SegLabel) = SegSize(SegLabel) + 1;     
        end
    end         
    
    for i = 1:height
        for j = 1:width
            SegLabel = seg(i,j);  
            if (SegSize(SegLabel)<SegSizeMin)
                seg(i,j) = 0;
            end
        end
    end    
    
    seg = double(seg);
    while numel(find(seg==0))~=0
        seg(seg==0)=NaN;
        seg = fillHoles(seg, 'bwdist');
    end    
    
    % relabel to full label
    segments = uint16(zeros(height,width));
    visited = uint16(zeros(1,SegmentMax));
    dfn = 0;
    for i = 1:height
        for j = 1:width    
            SegLabel = seg(i,j);     
            if ~visited(SegLabel)
                dfn = dfn + 1;
                visited(SegLabel) = dfn;
            end
            segments(i,j) = visited(SegLabel);            
        end
    end 
    
    % make label start from 0
    segments = segments - 1;
    
%     segments(small==1) = 7999;
end

function ancestor = anc(i)
    global fa
    x = i;
    while (fa(x)~=x)
        x = fa(x);
    end
    ancestor = x;
    x = i;
    while (fa(x)~=x)
        xx = fa(x);
        fa(x) = ancestor;
        x = xx;
    end
end