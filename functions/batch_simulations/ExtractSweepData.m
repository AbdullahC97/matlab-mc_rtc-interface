function ExtractSweepData(simSettings,parName,parValue,parIndex,syncName,syncValue,syncLayer)

parFolderName = "Parameter Sweep";
parSweepName = "Sweep";

if ~isfolder(simSettings.SaveFolder)
    mkdir(simSettings.SaveFolder)
end

if ~isfolder(fullfile(simSettings.SaveFolder,parFolderName))
    mkdir(fullfile(simSettings.SaveFolder,parFolderName))
end

latestBinFile = strcat("/tmp/","mc-control-DualPandaGrab-latest.bin");
newName = strcat(simSettings.SavePreFix,sprintf("_%d",parIndex));
copiedBinFile = fullfile(simSettings.SaveFolder,strcat(newName,".bin"));
copyfile(latestBinFile,copiedBinFile)

for k = 1:length(parName)
    parConfig.(sprintf("%s_%d",parName(k),k)) = parValue{k}(parIndex(k));
end

for k = 1:length(syncName)
    parConfig.(sprintf("%s_%d",syncName(k),k)) = syncValue{k}(parIndex(syncLayer(k)));
end

save(fullfile(simSettings.SaveFolder,parFolderName,strcat(newName,".mat")),"parConfig");

if ~isfile(fullfile(simSettings.SaveFolder,parFolderName,strcat(parSweepName,".mat")))
    parSweepRange.Parameters = [parName syncName];
    parSweepRange.Range      = [parValue syncValue];
    parSweepRange.Sync       = [nan*zeros(size(parName)) syncLayer];
    save(fullfile(simSettings.SaveFolder,parFolderName,strcat(parSweepName,".mat")),"parSweepRange");
end

end

