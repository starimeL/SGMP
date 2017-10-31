function [ dispar ] = FillDepth( dispar )

    % Simply fill the depth holes without rgb or grayscale reference
    % Can use other methods refer to rgb such as bf filter

    Disparity_Max = 65535;

    dispar(dispar==Disparity_Max) = 0;

    % Fill Holes!!!!    
    dispar = double(dispar);
    dispar = dispar / Disparity_Max;    
    while find(dispar==0)
        dispar(dispar==0)=NaN;
        dispar = fillHoles(dispar, 'bwdist');
    end
    dispar = uint16(dispar * Disparity_Max);    
    
end

