clear all; close all; clc
load("SyncDataBase")

cIdx = 1;
for i = 1:length(DataBase)
    if ismember(3,DataBase(i).Controller.ModeActive)
        FilteredDataBase(cIdx) = DataBase(i);
        cIdx = cIdx + 1;
    else
        fprintf("Experiment %d FAILED:\n",i);
        disp(DataBase(i).Params)
    end

end

% PlotComparison(FilteredDataBase)

%% Plot Data
% Plotting Options
plotOptions.Position        = false;
plotOptions.Velocity        = false;
plotOptions.Torque          = false;
plotOptions.Synchronization = false;
plotOptions.SyncVSVector    = false;
plotOptions.SyncError       = true;
plotOptions.PositionFit     = false;
plotOptions.VelocityFit     = false;
plotOptions.SavePlots       = false;
plotOptions.SaveFolder      = "exports/impact_map";
plotOptions.PreFix          = "MapOff_";

% Formatting Options
formatOptions.figWidth = 1; 
formatOptions.figHeight = 0.98;
formatOptions.zoomTime = 0.2;
formatOptions.zoomRatio = 0.5;
formatOptions.fontSize = 20;
formatOptions.xLineWidth = 2;
formatOptions.nCutTime = false;
formatOptions.nCutBegin = 2;
formatOptions.nCutEnd = 2;

for i = 1:length(FilteredDataBase)
%     close all;
%     PlotData(FilteredDataBase(i),plotOptions,formatOptions);
end







%% test
% simData = FilteredDataBase(1);
% robots = fieldnames(simData.Robots);
% ax = ["x","y","z"];
% var = "realVel";
%
% figure(1)
% for i = 1:length(robots)
%     for j = 1:length(ax)
%         subplot(length(ax),1,j)
%         hold on;
%         plot(simData.Time,simData.Robots.(robots{i}).(var).(ax(j)))
%     end
% end



