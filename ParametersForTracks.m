%% Couple the tracks to the parameters of the segments
%% ===================================================


% Load in the matfile of the tracks
% ---------------------------------

% Define the folder where the Analyzed data is saved
Dir_data = uigetdir('/mnt/grey/','Select the folder where the analyzed data is saved.');

% Define where the data is stored
Dir_tracks = strcat(Dir_data, '/Tracking');
cd(Dir_tracks)

Track = matfile('FullTrack.mat', 'Writable', false);
Track = Track.FullTrack;

% Get the path to the frames with the data
% ----------------------------------------
Dir_parameter = strcat(Dir_data, '/Tiling_Drift_PostProcess');
cd(Dir_parameter)
% Count the number of files
NFiles = size(dir('Frame*.mat'),1);

% Reconstruct the total tracks
% ----------------------------

Total_tracks = zeros(size(Track,1), NFiles);
Track_lengths = [];

for i = 1:size(Track,1)
% for i = 1:100
    Begin = cell2mat(Track(i).Timestamp_StartAndEnd(1));
    End = cell2mat(Track(i).Timestamp_StartAndEnd(2));
    
    T = Track(i).CompleteTrack(2,:);
%     Length = size(Track(i).CompleteTrack(2,:),2);
    
    Total_tracks(i,Begin:End) = T;
%     Track_lengths = [Track_lengths; Length];
end

% Filtering on size
% -----------------
% Size = 35;
% Total_tracks = Total_tracks(Track_lengths>=Size,:);


% Retrieve the data for each frame
% --------------------------------
cd(Dir_parameter)

Total_Density = zeros(size(Total_tracks,1), size(Total_tracks,2));
Total_Area = zeros(size(Total_tracks,1), size(Total_tracks,2));
Total_Backbone = zeros(size(Total_tracks,1), size(Total_tracks,2));
Total_Flag = zeros(size(Total_tracks,1), size(Total_tracks,2));
Total_Border = zeros(size(Total_tracks,1), size(Total_tracks,2));


for i = 1:size(Total_tracks,2)
%     for i = 101:size(Total_tracks,2)
    CellID = nonzeros(Total_tracks(:,i));
    Loc_CellID = find(Total_tracks(:,i));
    
    Name = strcat('Frame_', num2str(i, '%03d'));
    Frame = matfile(Name, 'Writable', true);
    
    % Voronoi densities
    Density = Frame.VoronoiTessellation(:,2);
    D = Density(CellID);
    
    % Flag
    Flag = Frame.OverlapRegionFlag;
    F = Flag(CellID);
    
    % Border Cells
    Border = Frame.BorderCells_10Pixels;
    Bo = Border(CellID);
    
    % Backbone
    Backbone = Frame.Backbone;
    B = Backbone(CellID);
    
    % Area
    Area = Frame.(Name);
    
    A = [];
    for j = 1:size(CellID,1)
        J = CellID(j);
        Area2 = size(cell2mat(Area.PixelIdxList(J)),1);
        A = [A; Area2];
    end
    
    Total_Density(Loc_CellID,i) = D;
    Total_Area(Loc_CellID,i) = A;
    Total_Backbone(Loc_CellID,i) = B;
    Total_Flag(Loc_CellID,i) = F;
    Total_Border(Loc_CellID,i) = Bo;
    
    disp(strcat('Frame #', num2str(i,'%03d'), ' was processed'))
    
end


Track_Densities = Total_Density;
Track_Densities = log10(Track_Densities);
Track_Densities(Track_Densities==-Inf)=0;
Track_Densities(Track_Densities>=3.5)=6;
Track_Densities(Track_Densities<=2.8 & Track_Densities~=0)=2;
Track_Densities(Track_Densities<=3.5 & Track_Densities>=2.8) = 4;




