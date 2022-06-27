%% Load Data
clear all; close all; clc
addpath("functions/");

%% Specify folder and settings
dataFolder = fullfile(pwd,"TuneReferenceFollowing");
deleteAfter = false;        % delete data folder after processing (specify what to delete below)
deleteTypes = {'mat','csv'}; % specify {'bin','csv','mat'} or {'all'} for everything
dataBaseName = "VecRefDataBase";

%% Process Files
tic
DataBase = ConvertBins2DataBase(dataFolder,dataBaseName);
fprintf("Processed %d Files in %.2f [s]\n",length(DataBase),toc)

%% Delete Data folder and save Database
if deleteAfter
    DeleteDataFiles(dataFolder,deleteTypes{:})
end

%% Save Parameter Sweep if it exists
% if isfolder(fullfile(dataFolder,"Parameter Sweep"))
%     for i = 1:length(DataBase)
%         DataBase(i).Sweep  = load(fullfile(dataFolder,"Parameter Sweep",[DataBase(i).FileName,'.mat'])).parConfig;
%     end
% end






