function [] = ConvertBin2Mat(bin_folder,csv_folder,mat_folder)

%% Load bin files and convert to csv
bin_files = dir(strcat(bin_folder,'/*.bin'));

for i = 1:length(bin_files)
    bin_file = bin_files(i);
    csv_name = strcat(bin_file.name(1:end-4),'.csv');
    if ~isfile(strcat(csv_folder,'/',csv_name))
        fprintf("Converting %d/%d: %s\n",i,length(bin_files),bin_file.name)
        command  = strcat("cd ", bin_folder,";","mc_bin_to_log ",bin_file.name);
        system(command);  
        movefile(strcat(bin_folder,'/',csv_name),strcat(csv_folder,'/',csv_name))
    end
end

%% Load csv files and convert to mat
csv_files = dir(strcat(csv_folder,'/*.csv'));

% specify log entry names + extensions (varext = how it is saved in MATLAB
% struct), (logext = how it is saved in log file and should be read)
varext{1} = ["x","y","z"];
logext{1} = ["_x","_y","_z"];

varext{2} = ["J1","J2","J3","J4","J5","J6","J7"];
logext{2} = ["_0","_1","_2","_3","_4","_5","_6"];

varnames = ["realPos","realVel","targetPos","targetVel","syncPos","syncVel","realTorques","contTorques"];
extypes  = [1        ,1        ,1          ,1          ,1        ,1        ,2            ,2            ];
RobotName = ["Panda1","Panda2","Box"];

% Specify which robot loads what data (box has no synchronization + torques
% for example)
RobotVars{1} = 1:length(varnames);
RobotVars{2} = RobotVars{1};
RobotVars{3} = 1:4;

% Specify all constant parameters that are loaded in
parsprefix = "pars_";
parsname = ["ImpVelMag","ImpAngle","GainVecFieldAnte","StartRadiusAnte","EndRadiusAnte",...
            "GainVecFieldPost","SwitchRadiusPost","MaxRadiusPost","UseImpMap","tSwitchPost","useTimeSwitch"];

% loop over all desired log entries for each robot
for f = 1:length(csv_files) 

    csv_file = csv_files(f);
    mat_name = strcat(csv_file.name(1:end-4),'.mat');

    if ~isfile(strcat(mat_folder,'/',mat_name))
        clear simData
        data = readtable(fullfile(csv_file.folder,csv_file.name));
        
        simData.Time = data.t;
        simData.ControlMode = data.controlMode;
    
        % Panda 1 + 2 + Box
        Robots = {struct(),struct(),struct()};
    
        for i = 1:length(Robots)
            for j = RobotVars{i}
                Robots{i} = loadVectorLog(data,Robots{i},varnames(j),strcat(varnames(j),RobotName(i)),varext{extypes(j)},logext{extypes(j)});
            end
        end
    
        simData.Robots.Panda1 = Robots{1};
        simData.Robots.Panda2 = Robots{2};
        simData.Robots.Box = Robots{3};

        % Save Motion generation parameters
        for p = 1:length(parsname)
            simData.Params.(parsname(p)) = data.(strcat(parsprefix,parsname(p)))(end);
        end

        simData.FileName = csv_file.name(1:end-4);


        % Save control modes
        [modeActive, modeStart, ~] = unique(simData.ControlMode); 
        simData.Controller.ModeActive = modeActive;
        simData.Controller.ModeStart = modeStart;

        % save simulation data object
        save(strcat(mat_folder,'/',mat_name),"simData")
     
    end
end


end

function [destination] = loadVectorLog(source,destination,varname,logname,varext,logext)

    for i = 1:length(varext)
        destination.(varname).(varext(i)) = source.(strcat(logname,logext(i)));
    end

end
