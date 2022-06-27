function [simData] = FitImpactMap(simData,fitTime,fitOrder)
time = simData.Time;
controlMode = simData.ControlMode;

%% Fit Data
dt = time(2) - time(1);
[modeActive, modeStart, ~] = unique(controlMode);

simData.Controller.ModeActive = modeActive;
simData.Controller.ModeStart = modeStart;

existPostImpact = ismember(modeActive,3);
impIndex = modeStart(existPostImpact);
anteFitIndex = impIndex + (-round(fitTime/dt):0);
postFitIndex = impIndex + (0:round(fitTime/dt));

impTime = time(impIndex);
anteFitTime = time(anteFitIndex);
postFitTime = time(postFitIndex);

robotNames = fieldnames(simData.Robots);
fitDir = ["x","y","z"];

for i = 1:length(robotNames)    % Loop over robots
    for j = 1:length(fitDir)       % Loop over x,y,z directions for each robot
        
        % Fit Ante-Impact Data
        anteImpPosition = simData.Robots.(robotNames{i}).realPos.(fitDir(j))(anteFitIndex);
        [polyCoef,~,polyMu] = polyfit(anteFitTime,anteImpPosition,fitOrder); % fit polynomial --> obtain coefficients pa
        polyDerCoef = polyder(polyCoef);
        fittedPosition = polyval(polyCoef,anteFitTime,[],polyMu);
        fittedVelocity = 1/polyMu(2) * polyval(polyDerCoef,anteFitTime,[],polyMu);
        
        simData.Robots.(robotNames{i}).fittedAntePos.(fitDir(j)) = fittedPosition;
        simData.Robots.(robotNames{i}).fittedAnteVel.(fitDir(j)) = fittedVelocity;

        simData.Robots.(robotNames{i}).fittedTime.anteTime = anteFitTime;
        simData.Robots.(robotNames{i}).fittedTime.anteIndex = anteFitIndex;

        % Fit Post-Impact Data
        postImpPosition = simData.Robots.(robotNames{i}).realPos.(fitDir(j))(postFitIndex);
        [polyCoef,~,polyMu] = polyfit(postFitTime,postImpPosition,fitOrder); % fit polynomial --> obtain coefficients pa
        polyDerCoef = polyder(polyCoef);
        fittedPosition = polyval(polyCoef,postFitTime,[],polyMu);
        fittedVelocity = 1/polyMu(2) * polyval(polyDerCoef,postFitTime,[],polyMu);
        
        simData.Robots.(robotNames{i}).fittedPostPos.(fitDir(j)) = fittedPosition;
        simData.Robots.(robotNames{i}).fittedPostVel.(fitDir(j)) = fittedVelocity;

        simData.Robots.(robotNames{i}).fittedTime.postTime = postFitTime;
        simData.Robots.(robotNames{i}).fittedTime.postIndex = postFitIndex;

    end

end   

end

