% ==========================================
%   Remove tiny regions in raw ground plane  
%   by finding them and merging them. Refine. 
% ==========================================

function segments = MergeSeg_Ground(GroundRaw,GroundEdge_RefinePara,SegSizeMin)
    global fa
    SegmentMax = 100000;  % maximum number of segments
    [height, width] = size(GroundRaw);
           
    GroundRaw = GroundRaw + 1;
    seg0 = uint16(GroundRaw);
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
    
    % count size 
    SegSize = zeros(1,SegmentMax);
    for i = 1:height
        for j = 1:width
            SegLabel = seg(i,j);        
            SegSize(SegLabel) = SegSize(SegLabel) + 1;            
        end
    end

    % merge small connected componets       
    for i = 1:height
        for j = 1:width
            SegLabel = seg(i,j);           
            if (SegSize(SegLabel)<SegSizeMin) 
                seg(i,j) = 0;
            end
            if (SegSize(SegLabel)<SegSizeMin*30)  && (GroundRaw(i,j)==1) % is not ground
                seg(i,j) = 0;
            end            
        end
    end        
    
    seg = double(seg);
    while numel(find(seg==0))~=0
        seg(seg==0)=NaN;
        seg = fillHoles(seg, 'bwdist');
    end
    
    IsGround = zeros(1,SegmentMax);
    for i = 1:height
        for j = 1:width
            SegLabel = seg(i,j);         
            if GroundRaw(i,j)==2
                IsGround(SegLabel) = IsGround(SegLabel) + 1;       
            else
                IsGround(SegLabel) = IsGround(SegLabel) - 1;    
            end
        end
    end       
    for i = 1:height
        for j = 1:width
            SegLabel = seg(i,j);         
            if IsGround(SegLabel)>0
                seg(i,j) = 0;
            end
        end
    end        
    
    seg(seg~=0) = 1;
    segments = 1 - seg;
    
    segments(segments==0) = -1;    
    Smooth_para = GroundEdge_RefinePara;
    convM = ones(Smooth_para,Smooth_para);
    convM((Smooth_para+1)/2,(Smooth_para+1)/2) = 0;
    segments = conv2(segments,convM,'same');
    segments(segments<=0) = 0;
    segments(segments>0) = 1;

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