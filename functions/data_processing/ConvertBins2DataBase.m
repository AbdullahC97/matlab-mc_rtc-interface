function DataBase = ConvertBins2DataBase(data_folder,database_name)
warning('off')
%% Load bin files and convert to csv
% list all bin files and convert them to csv using the mc_rtc command
bin_files = dir(strcat(data_folder,'/*.bin'));
fprintf("Converting bin files to csv files:\n")
for i = 1:length(bin_files)
    bin_file = bin_files(i);
    csv_name = strcat(bin_file.name(1:end-4),'.csv');
    if ~isfile(strcat(data_folder,'/',csv_name))
        try
            fprintf("\tConverting %d/%d: %s\n",i,length(bin_files),bin_file.name)
            command  = strcat("cd ", data_folder," && ","mc_bin_to_log ",bin_file.name);
            [~,~] = system(command);
        catch
            fprintf("\b --> FAILED!\n")
        end
    end
end

%% Load csv files and convert to mat
csv_files = dir(strcat(data_folder,'/*.csv'));

% specify log entry names + extensions (varext = how it is saved in MATLAB
% struct), (logext = how it is saved in log file and should be read)
varext{1} = ["x","y","z"];
logext{1} = ["_x","_y","_z"];

varext{2} = ["J1","J2","J3","J4","J5","J6","J7"];
logext{2} = ["_0","_1","_2","_3","_4","_5","_6"];

varnames = ["realPos","realVel","targetPos","targetVel","syncPos","syncVel","realTorques","contTorques"];
extypes  = [1        ,1        ,1          ,1          ,1        ,1        ,2            ,2            ];

RobotNames = ["Panda1","Panda2","Box"];  % robots that will be loaded

% Specify which robot loads what data (box has no synchronization + torques
% for example)
RobotVars{1} = 1:length(varnames);
RobotVars{2} = RobotVars{1};
RobotVars{3} = 1:4; % the box only loads realPos till targetVel

% Specify the prefix that contains all the constant parameters
parsprefix = "pars_";

% loop over all desired log entries for each robot
fprintf("Converting csv files to mat files:\n")
for f = 1:length(csv_files)
    csv_file = csv_files(f);
    mat_name = strcat(csv_file.name(1:end-4),'.mat');
    if ~isfile(strcat(data_folder,'/',mat_name))
        try
            fprintf("\tConverting %d/%d: %s\n",f,length(csv_files),csv_file.name)
            clear simData
            data = readtable(fullfile(csv_file.folder,csv_file.name));

            simData.Time = data.t;
            simData.ControlMode = data.controlMode;

            % Panda 1 + 2 + Box
            Robots = repmat({struct()}, 1, length(RobotNames));
            for i = 1:length(Robots)
                for j = RobotVars{i}
                    Robots{i} = loadVectorLog(data,Robots{i},varnames(j),strcat(varnames(j),RobotNames(i)),varext{extypes(j)},logext{extypes(j)});
                end
                simData.Robots.(RobotNames(i)) = Robots{i};
            end

            % Save Motion generation parameters
            % find all log entries that start with "pars_"
            matched_columns = find(startsWith(data.Properties.VariableNames,parsprefix));
            % loop over entries, remove prefix "pars_" and save data
            for p = 1:length(matched_columns)
                idx = matched_columns(p);
                new_parname = erase(data.Properties.VariableNames(idx),parsprefix);
                simData.Params.(new_parname{:}) = data.(idx)(end);
            end

            % Save controller data
            [modeActive, modeStart, ~] = unique(simData.ControlMode);
            simData.Controller.ModeActive = modeActive;
            simData.Controller.ModeStart = modeStart;
            simData.Controller.TimeStep = simData.Time(2) - simData.Time(1);

            % save simulation data object
            simData.FileName = csv_file.name(1:end-4);
            save(strcat(data_folder,'/',mat_name),"simData")

        catch
            fprintf("\b --> FAILED!\n")
        end

    end
end

%% Save all matfiles into DataBase
fprintf("Saving into Database: %s.mat\n",database_name)
mat_files = dir(strcat(data_folder,'/*.mat'));
if ~isempty(mat_files)
    for i = 1:length(mat_files)
        DataBase(i) = load(fullfile(mat_files(i).folder,mat_files(i).name)).simData;
    end

    % only relevant if you run parameter sweeps (can remove otherwise)
    if isfolder(fullfile(data_folder,"Parameter Sweep"))
        for i = 1:length(DataBase)
            DataBase(i).Sweep  = load(fullfile(data_folder,"Parameter Sweep",[DataBase(i).FileName,'.mat'])).parConfig;
        end
    end

    if exist("DataBase","var")
        save(database_name,"DataBase");
    end

elseif nargout > 0
    DataBase = struct([]);
end

fprintf("Files were succesfully processed...\n\n")

end

function [destination] = loadVectorLog(source,destination,varname,logname,varext,logext)

for i = 1:length(varext)
    destination.(varname).(varext(i)) = source.(strcat(logname,logext(i)));
end

end
