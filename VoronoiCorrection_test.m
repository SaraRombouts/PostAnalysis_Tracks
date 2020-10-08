%% Find cells that have a Voronoi value >=5
%% ========================================



for k = 100
   Name = strcat('Frame_', num2str(k, '%03d')); 
   Frame = matfile(Name, 'Writable', false);
   
    Frame_Voronoi = Frame.VoronoiTessellation;
    Voronoi = Frame_Voronoi(:,2);
    Voronoi = log10(Voronoi);
    Loners = find(Voronoi>=3.5);
    
    Frame_Image = Frame.(Name);
    Image = labelmatrix(Frame_Image);
    
    for t = 1:size(Loners,1)
        T = Loners(t);
        
        Image(Image==T)=100000;
    end
    
    figure, imagesc(Image)
end



Total_V = [];
for J = 1:size(Centroid_list,1)
    dist = sum((Centroid_list-Centroid_list(J,:)).^2,2);
    %     dist = sum((Total-Total(J,:)).^2,2);
    [~,r] = mink(dist,sum(dist==0)+3);
    R = Voronoi(r);
    Voronoi_test = (R(1)+(sum(R(2:4))/3))/2;
    
    Total_V = [Total_V; Voronoi_test];
end