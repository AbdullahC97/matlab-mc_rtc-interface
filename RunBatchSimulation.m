clear all; close all; clc
addpath("functions/");
getArray = @(id,r) mat2cell(reshape([id*ones(size(r));r],1,[]),1,2*ones(size(r)));
%% Batch settings
simSettings.verbose = true;
simSettings.logController = false;
simSettings.FileName = "/home/abdullah/devel/time-invariant-dual-arm-panda-controller/etc/DualPandaGrab.in.yaml";
simSettings.ExtractData = true;
simSettings.SaveFolder = fullfile(pwd,"TuneReferenceFollowing");
simSettings.SavePreFix = "Experiment";

% A = 0.4:0.1:0.8;
% B = round(deg2rad(0:20:60),2);
% C = ["true","false"];
% D = {[1,2,3],[2,3,4],[5,3,1]};
% E = {[1,10],[1,20]};
% F = getArray(1,10:10:50);
% parName = ["ImpactVelocity","ImpactAngle", "AlignWithBox", "PosPanda1", "kVectorField","TaskWeight"];

%% Add Parameter Sweep Range
% the added parameters are swept in as a nested loop, so every
% combination is tested. You can add as many layers as desired, the
% recursive loop takes care of the nesting
A1 = getArray(3,[10:10:40]);
A2 = getArray(1,10:10:50);

parName = ["TaskWeight", "LinearTaskDamping"];
parValue = {A1,A2};

%% Add Additional Synchronized Parameters
% the following parameters are optional and serve to match with the swept
% parameters instead of looping seperately (matching layer should be specified). Leave blank if not used.
B1 = getArray(3,2*[5,6,7,8]);
syncName = [];
syncValue = {B1};
syncLayer = [2];

%% Start Parameter Sweep
tic
if (size(parName) == size(parValue))
    if isempty(syncName)
        RecursiveLoop(parName,parValue,ones(size(parValue)),1,simSettings,[],[],[]);
    else
        RecursiveLoop(parName,parValue,ones(size(parValue)),1,simSettings,syncName,syncValue,syncLayer);
    end
else
    error("Error: size of parName ~= parValue!");
end
fprintf("Finished batch simulation in %.2f [s]\n",toc)

%% Process Data
% Specify folder and settings
dataFolder = simSettings.SaveFolder;
deleteAfter = false;        % delete data folder after processing (specify what to delete below)
deleteTypes = {'mat','csv'}; % specify {'bin','csv','mat'} or {'all'} for everything
dataBaseName = "VecRefDataBase";

% Process Files
tic
DataBase = ConvertBins2DataBase(dataFolder,dataBaseName);
fprintf("Processed %d Files in %.2f [s]\n",length(DataBase),toc)
