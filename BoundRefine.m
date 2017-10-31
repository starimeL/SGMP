function [ segments ] = BoundRefine( small, seg, Edges )
    global p GradientP heapTail

%   small: candidate small boundary regions

    pointsMax = 500000;
    [height,width] = size(seg);
    
    pointsTotal = numel(find(small==1));
    seg(small==1) = 0;
    
    se = strel('square',3);    
    MaskErode = imerode(small,se);
    ContourPoints = setdiff(find(small==1),find(MaskErode==1));
    
    GradientP = zeros(1,pointsMax);
    p = zeros(1,pointsMax);     % heap indexed by ind in GradientP
    heapTail = 0;
    iPos = zeros(1,pointsMax);
    jPos = zeros(1,pointsMax);
    visited = false(height,width);    
    
    for k = 1:numel(ContourPoints)
        [i,j] = ind2sub([height,width],ContourPoints(k));
        NeighborGradient = Edges(i-1:i+1,j-1:j+1);        
        iPos(k) = i;
        jPos(k) = j;
        visited(i,j) = true;
        GradientP(k) = sum(NeighborGradient(:));
        
        % Push in        
        heapTail = heapTail + 1;
        p(heapTail) = k;
        up(heapTail);        
        
    end        
    pointsTail = numel(ContourPoints);
    
    mi = [1,-1,0,0];
    mj = [0,0,1,-1];    
    while heapTail~=0        
        k = p(1);
        % pop out
        p(1) = p(heapTail);
        heapTail = heapTail - 1;
        down(1);
        
        i = iPos(k);
        j = jPos(k);
        NeighborLabels = seg(i-1:i+1,j-1:j+1);
        NeighborLabels = NeighborLabels(NeighborLabels~=0);

        mostf = 0;
        most = 0;
        for o = 1:numel(NeighborLabels)
            fre = numel(find(NeighborLabels==NeighborLabels(o)));
            if fre>mostf
                mostf = fre;
                most = NeighborLabels(o);
            end
        end
        seg(i,j) = most;        

        % push in 
        for o = 1:4
            ii = i + mi(o);
            jj = j + mj(o);
            if (seg(ii,jj)==0) && (~visited(ii,jj))
                pointsTail = pointsTail + 1;
                iPos(pointsTail) = ii;
                jPos(pointsTail) = jj;
                NeighborGradient = Edges(ii-1:ii+1,jj-1:jj+1);                
                visited(ii,jj) = true;
                GradientP(pointsTail) = sum(NeighborGradient(:));
                
                heapTail = heapTail + 1;
                p(heapTail) = pointsTail;
                up(heapTail);
                
            end
        end
        
        pointsTotal = pointsTotal - 1;
    end
    
    segments = seg;
    
end

function up(i)
global p GradientP
    while (i~=1) && (GradientP(p(i))<GradientP(p(floor(i/2))))
        j = floor(i/2);
        swap = p(i);
        p(i) = p(j);
        p(j) = swap;
        i = j;
    end
end

function down(i)
global p GradientP heapTail
    while (i*2<=heapTail)
        j = i*2;
        if (j+1<=heapTail) && (GradientP(p(j+1))<GradientP(p(j)))
            j = j + 1;
        end
        if GradientP(p(i))>GradientP(p(j))
            swap = p(i);
            p(i) = p(j);
            p(j) = swap;
            i = j;            
        else
            break;
        end
    end
end

