%% Code for analysis of tracks - Switch and Time Matrix
%% ====================================================


% Get thresholded tracks
% ----------------------

Track_Densities = Total_Density;
Track_Densities = log10(Track_Densities);
Track_Densities(Track_Densities==-Inf)=0;
Track_Densities(Track_Densities>=3.5)=6;
Track_Densities(Track_Densities<=2.8 & Track_Densities~=0)=2;
Track_Densities(Track_Densities<=3.5 & Track_Densities>=2.8) = 4;


%% Step 1: Characterize the tracks
%% -------------------------------

% Does this track cycle?
% ----------------------

% Non-cyclers = 0
% Cyclers = 1

% Calculate the amount of switches - if empty matrix = non-cycler, if not
% empty = cyler
Total = [];
for k = 1:size(Track_Densities,1)
    % Isolate the track
    Track = nonzeros(Track_Densities(k,:))';
    % Get the switches
    Switches = diff(Track);
    % Define in which frame the switch happens
    Switches2 = find(Switches);
    
    % Calculate the amount of switches - if empty matrix = non-cycler, if not
    % empty = cyler
    
    if isempty(Switches2)
        Cycling=0;
        Density_Class = Track(1);
        Frame = 0;
        Length = size(Track,2);
        Cycle_before = 0;
        Cycle_after = 0;
    else
        Cycling=1;
        
        
        
        % Details about the cycling/non-cycling?
        % --------------------------------------
        
        % Density class(es) = Loner, Packs or Swarms
        Density_Class = [];
        
        for i = 1:size(Track,2)
            if i==1
                Density_Class = Track(1);
            else
                if Track(i)~=Density_Class(end)
                    Density_Class = [Density_Class; Track(i)];
                end
            end
        end
        
        % When the switch happens = Frame
        % NOTE: Each track starts at frame 1 (not mentioned int Frame Variable),
        % first switch happens at Frame(1) between frame Frame(1) and frame
        % Frame(1)+1
        Frame = [Switches2';size(Track,2)];
        
        % Length of path in specific density states
        Frame = [Switches2';size(Track,2)];
        Length = [];
        for p = 1:size(Frame,1)
            if p==1
                Length = Frame(p);
            else
                L = Frame(p)-Frame(p-1);
                Length = [Length; L];
            end
        end
        
        % Which cycling happens at beginning of density state path - S_L, L_P,...
        % NOTE:
        %   1 = Cycle Loner to Pack
        %   2 = Cycle Loner to Swarm
        %   3 = Cycle Pack to Loner
        %
        
%         For density_class(1) - Cycle_before does not exist so = 0
        
        Cycle_before = [0 Track(1)];
        for j = 1:size(Switches2,2)
            B1 = Track(Switches2(j));
            B2 = Track(Switches2(j)+1);
            
            Cycle_before = [Cycle_before; B1, B2];
            
        end
        % Which cycling happens at end of density state path - S_L, L_P,...
        
%         For density_class(end) - Cycle_after does not exist so =0
        
        Cycle_after = [];
        for j = 1:size(Switches2,2)
            A1 = Track(Switches2(j));
            A2 = Track(Switches2(j)+1);
            
            Cycle_after = [Cycle_after; A1, A2];
            
        end
        Cycle_after = [Cycle_after; Track(end),0];
        
        %% Step 2: Save for each track the line in a matfile
        %% -------------------------------------------------
        
        
    end
    Total_frame = {Cycling Density_Class Frame Length Cycle_before Cycle_after};
        Total = [Total;Total_frame];
end
    
    colHeadings = {'Cycling' 'DensityClass' 'CycleFrames' 'LengthInFrames' 'CycleBefore' 'CycleAfter'};
    Test = cell2struct(Total, colHeadings, 2);

%% Step 3: Construct the Switch and Time Matrix
%% --------------------------------------------
Switch_L_L = [];
Switch_P_P = [];
Switch_S_S = [];
Switch_L_P = [];
Switch_L_S = [];
Switch_P_L = [];
Switch_P_S = [];
Switch_S_P = [];
Switch_S_L = [];

Time_L_L = [];
Time_P_P = [];
Time_S_S = [];
Time_L_P = [];
Time_L_S = [];
Time_P_L = [];
Time_P_S = [];
Time_S_P = [];
Time_S_L = [];

C = [Test(:).Cycling]';
Cyclers = find(C);
NonCyclers = find(C==0);

TrackEnds = [];

for k = 1:size(Cyclers,1)
   K = Cyclers(k);
   
   for m = 1:size(Test(K).CycleAfter,1)-1
    A1 = Test(K).CycleAfter(m,1);
    A2 = Test(K).CycleAfter(m,2);
    
    deltaT = Test(K).LengthInFrames(m);
    
    if A1==2
        if A2==4
            % Cycler from Swarm to Pack
            % Switch_S_P - Time_S_P
            Switch_S_P = [Switch_S_P;K];
            Time_S_P = [Time_S_P;deltaT];
        elseif A2==6
            % Cycler from Swarm to Loners
            % Switch_S_L - Time_S_L
            Switch_S_L = [Switch_S_L;K];
            Time_S_L = [Time_S_L;deltaT];
        end
        
    elseif A1==4
        if A2==2
            % Cycler from Pack to Swarm
            % Switch_P_S - Time_P_S
            Switch_P_S = [Switch_P_S;K];
            Time_P_S = [Time_P_S;deltaT];            
        elseif A2==6
            % Cycler from Pack to Loner
            % Switch_P_L - Time_P_L
            Switch_P_L = [Switch_P_L;K];
            Time_P_L = [Time_P_L;deltaT];
        end
    elseif A1==6
        if A2==2
            % Cycler from Loner to Swarm
            % Switch_L_S - Time_L_S
            Switch_L_S = [Switch_L_S;K];
            Time_L_S = [Time_L_S;deltaT];
        elseif A2==4
            % Cycler from Loner to Pack
            % switch_L_P - Time_L_S
            Switch_L_P = [Switch_L_P;K];
            Time_L_P = [Time_L_P;deltaT];
        end
    end
       
   end
   
   % Get the track ends
   % ------------------
   TrackEnds = [TrackEnds;Test(K).DensityClass(end), Test(K).LengthInFrames(end)];
   
end

Tracks_NonCyclers = [];
for l = 1:size(NonCyclers,1)
   L = NonCyclers(l);
   
   Tracks_NonCyclers = [Tracks_NonCyclers; Test(L).DensityClass(end), Test(L).LengthInFrames(end)];
end


Total_Time = [Time_S_L, Time_P_L, Time_L_L; Time_S_P, Time_P_P, Time_L_P; Time_S_S, Time_P_S, Time_L_S];
Total_Time = [size(Time_S_L,1), size(Time_P_L,1), 0; size(Time_S_P,1), 0, size(Time_L_P,1); 0, size(Time_P_S,1), size(Time_L_S,1)];