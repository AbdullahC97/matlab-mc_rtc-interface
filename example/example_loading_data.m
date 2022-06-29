clear all; close all; clc
addpath("/home/abdullah/devel/matlab-programs/matlab-mc_rtc-interface/functions/data_processing/");

%% Specify folders
dataFolder = fullfile(pwd,"DataFolder");
deleteAfter = true;        % delete data folder contents after processing (specify what to delete below)
deleteTypes = {'csv','mat'};     % specify {'bin','csv','mat'} or {'all'} for everything
dataBaseName = "DataBase";

%% Process Files
tic
DataBase = ConvertBins2DataBase(dataFolder,dataBaseName);
fprintf("Processed %d Files in %.2f [s]\n",length(DataBase),toc)

%% Delete Data folder and save Database
if deleteAfter
    DeleteDataFiles(dataFolder,deleteTypes{:})
end

%% Plotting Data
robots = fieldnames(DataBase(1).Robots);
ax = ["x","y","z"];
var = "realPos";

for k = 1:length(DataBase)
    simData = DataBase(k);
    figure(k)
    for i = 1:length(robots)-1
        for j = 1:length(ax)
            subplot(length(ax),1,j)
            hold on;
            h(j) = plot(simData.Time,simData.Robots.(robots{i}).(var).(ax(j)));
       end
    end
   
end


