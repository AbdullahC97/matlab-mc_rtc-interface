clear all; close all; clc
%% Load Data
addpath("functions/");
load("DataBase");

%% PLot Data
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

for i = 1:length(DataBase)
%     close all;
    PlotData(DataBase(i),plotOptions,formatOptions);
end