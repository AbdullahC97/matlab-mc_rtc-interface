function RecursiveLoop(parName,parValue,parIndex,parLayer,simSettings,syncName,syncValue,syncLayer)

if parLayer > length(parName)
    nPars = 2*length(parName);
    % add parameters that are swept to varargins
    for j = 1:2:nPars
        idx = floor(j/2) + 1;
        varargin{j} = parName{idx};
        varargin{j+1} = parValue{idx}(parIndex(idx));
    end

    % add additional parameters (if they exist) that change synchronously with a swept
    % parameter to varargins
    for j = 1:2:2*length(syncName)
        idx = floor(j/2) + 1;
        varargin{nPars + j} = syncName{idx};
        varargin{nPars + j + 1} = syncValue{idx}(parIndex(syncLayer(idx)));
    end

    ModifyControllerConfig(simSettings.FileName,simSettings.verbose,varargin{:});

    RunSimulation(simSettings);

    if simSettings.ExtractData
        ExtractSweepData(simSettings,parName,parValue,parIndex,syncName,syncValue,syncLayer);
    end

else
    for i = 1:length(parValue{parLayer})
        parIndex(parLayer) = i;
        RecursiveLoop(parName,parValue,parIndex,parLayer+1,simSettings,syncName,syncValue,syncLayer);
    end
end

end




