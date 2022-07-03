function PerformanceData = computePerformance(DataBase)

robotNames = ["Panda1","Panda2"];
ax = ["x","y","z"];

for i = 1:length(DataBase)
    idx = [DataBase(i).Controller.ModeStart(2):DataBase(i).Controller.ModeStart(3)-1];
    for r = 1:length(robotNames)
        robot = DataBase(i).Robots.(robotNames(r));

        % Follow Reference Error: position and velocity
        for j = 1:3
            PerformanceData(i).(robotNames(r)).errorPos(j,:) = [robot.targetPos.(ax(j))(idx) - robot.realPos.(ax(j))(idx)].';
            PerformanceData(i).(robotNames(r)).errorVel(j,:) = [robot.targetVel.(ax(j))(idx) - robot.realVel.(ax(j))(idx)].';
        end

%         PerformanceData(i).(robotNames(r)).errorPos = errorPos;
%         PerformanceData(i).(robotNames(r)).errorVel = errorVel;
        errorPos = PerformanceData(i).(robotNames(r)).errorPos;
        errorVel = PerformanceData(i).(robotNames(r)).errorVel;

        for j = 1:size(errorPos,2)
            PerformanceData(i).trackingError.normPos.(robotNames(r))(j) = norm(errorPos(:,j),2);
            PerformanceData(i).trackingError.normVel.(robotNames(r))(j) = norm(errorVel(:,j),2);
        end
    end

    PerformanceData(i).meanPosTrackError = ...
        mean([mean(PerformanceData(i).trackingError.normPos.Panda1),...
              mean(PerformanceData(i).trackingError.normPos.Panda2)]);

    PerformanceData(i).meanVelTrackError = ...
        mean([mean(PerformanceData(i).trackingError.normVel.Panda1),...
              mean(PerformanceData(i).trackingError.normVel.Panda2)]);    

    PerformanceData(i).anteTime = DataBase(i).Time(idx(end)) - DataBase(i).Time(idx(1));

    % Synchronization Error
    simData = DataBase(i);

    syncMat1 = eye(3);
    syncMat2 = [1,0,0;0,-1,0;0,0,1];

    relPos1 = [ simData.Robots.Panda1.realPos.x.'- simData.Robots.Box.realPos.x.';
        simData.Robots.Panda1.realPos.y.'- simData.Robots.Box.realPos.y.';
        simData.Robots.Panda1.realPos.z.'- simData.Robots.Box.realPos.z.'];

    relPos2 = [ simData.Robots.Panda2.realPos.x.'- simData.Robots.Box.realPos.x.';
        simData.Robots.Panda2.realPos.y.'- simData.Robots.Box.realPos.y.';
        simData.Robots.Panda2.realPos.z.'- simData.Robots.Box.realPos.z.'];

    relVel1 = [ simData.Robots.Panda1.realVel.x.'- simData.Robots.Box.realVel.x.';
        simData.Robots.Panda1.realVel.y.'- simData.Robots.Box.realVel.y.';
        simData.Robots.Panda1.realVel.z.'- simData.Robots.Box.realVel.z.'];

    relVel2 = [ simData.Robots.Panda2.realVel.x.'- simData.Robots.Box.realVel.x.';
        simData.Robots.Panda2.realVel.y.'- simData.Robots.Box.realVel.y.';
        simData.Robots.Panda2.realVel.z.'- simData.Robots.Box.realVel.z.'];

    for k = 1:length(idx)
        ki = idx(k);
        syncErrorPos(:,k) = -(syncMat1*(relPos1(:,ki)) - syncMat2*(relPos2(:,ki)));
        syncErrorVel(:,k) = -(syncMat2*(relVel1(:,ki)) - syncMat1*(relVel2(:,ki)));
        syncPosNorm(k) = norm(syncErrorPos(:,k),2);
        syncVelNorm(k) = norm(syncErrorVel(:,k),2);
    end

    PerformanceData(i).syncError.normPos = syncPosNorm;
    PerformanceData(i).syncError.normVel = syncVelNorm;

    PerformanceData(i).meanPosSyncError = mean(syncPosNorm);
    PerformanceData(i).meanVelSyncError = mean(syncVelNorm);

end


end