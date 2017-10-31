function  dispar = DisparityCalc_Libelas( imgl, imgr , param , imgRgb )

    Disparity_Max = 65535;

    param.disp_min    = 0;           % minimum disparity (positive integer)
    param.disp_max    = 4096;         % maximum disparity (positive integer)
    param.subsampling = 0; % process only each 2nd pixel (1=active)
    param.candidate_stepsize = 10;
    param.incon_window_size = 10;
    param.support_threshold = 0.70;    
    param.incon_min_support = 15;
    param.lr_threshold = 0.5;

    
    [D1,~] = elasMex(imgl',imgr',param);

    dispar = D1';

    dispar = double(dispar);
    dispar(dispar<0) = 0;        
    dispar = dispar / max(dispar(:));
    dispar = uint16(Disparity_Max*dispar);
    
%     dispar(dispar>0.9*Disparity_Max) = 0;    
    
%         dispar = double(dispar);
%         dispar = dispar / Disparity_Max;    
%         dispar(dispar==0) = 1;
%         dispar = FillDepth(imgl,dispar);
% %         return;
%         dispar = uint16(dispar * Disparity_Max);           
        
            % Fill Holes!!!!    
            dispar = double(dispar);
            dispar = dispar / Disparity_Max;    
            while find(dispar==0)                
                dispar(dispar==0)=NaN;
                dispar = fillHoles(dispar, 'bwdist');
            end
            dispar = uint16(dispar * Disparity_Max);                           
        

%     dispar = double(dispar);
%     dispar = dispar/Disparity_Max;    
% 
%     imgg = double(imgRgb);
%     imgg = imgg / 255;    
%     dispar = guidedfilter_color( imgg, dispar, 7, 0.001);          
%     
%     dispar = uint16(dispar * Disparity_Max);           
%     dispar(dispar<=0) = 1;     
    
%     imshow(dispar,[]);    
    
end

