function PlotData(simData, plotOptions, formatOptions, formatPlots)
 
fprintf("Plotting File: %s\n",simData.FileName);

time = simData.Time;


controlMode = simData.ControlMode;
modeActive = simData.Controller.ModeActive;
modeStart = simData.Controller.ModeStart;
impTime = time(modeStart(3)); %simData.Robots.Panda1.fittedTime.postTime(1);

spacer = @(n) strcat('$',repmat('\quad',1,n),'$');

%% Plotting Parameters
robotNames = fieldnames(simData.Robots);
modeIndex = [modeStart; length(time)];
shownModes = modeIndex;
fitDir = ["x","y","z"];
modeColors = ["y","b","r","g"];
yFill = [0 0 1 1];

if isfield(formatOptions,"onlyShowControlModes") && ~isempty(formatOptions.onlyShowControlModes)
    shownModes = modeIndex([formatOptions.onlyShowControlModes,formatOptions.onlyShowControlModes(end)+1]);
    plotTimeRange = time([shownModes(1) shownModes(end)]);
else
    plotTimeRange = time([1 end]);
end

if isfield(formatOptions,"nCutTime") && formatOptions.nCutTime 
    iStart = shownModes(1) + round((shownModes(2)-shownModes(1))*formatOptions.nCutBegin);
    iEnd = round(shownModes(end-1) + (shownModes(end)-shownModes(end-1))*formatOptions.nCutEnd);
    plotTimeRange = time([iStart,iEnd]); 
end

%% Save Parameters as Text File
if isfield(plotOptions,"SaveParams") && plotOptions.SaveParams
    table = rows2vars(struct2table(simData.Params));
    table.Properties.VariableNames = ["Parameter", "Value"];
    writetable(table,fullfile(plotOptions.SaveFolder,"params.txt"),"Delimiter","\t");
end

%% Plot Position (+ Around Impact)
options1.numPlots = [2,3];
options1.ratioSize.x = [0.75, 0.25];
options1.ratioSize.y = [1,1,1];
options1.padding.in = [0.05,0.025];
options1.padding.out = [0.05,0.05];
options1.showControlBar = true;
options1.yRatioControlBar = 0.01;
options1.yRatioControlLegend = 0.3;
options1.yExtra = 0.15;
options1.showLegend = true;
options1.yRatioLegend = 0.1;
options1.hideXLabels = true;
options1.hideYLabels = false;
options1.linkAxes = 'x';

lineWidth = [6 4.5 3];

if isfield(plotOptions,"Position") && plotOptions.Position
    % Default Format Plot
    formatDefault.name = "Position";
    formatDefault.figWidth = formatOptions.figWidth;
    formatDefault.figHeight = formatOptions.figHeight;
    formatDefault.fontSize = formatOptions.fontSize;
    formatDefault.xLineWidth = formatOptions.xLineWidth;
    formatDefault.lineWidth = [6 4.5 3; 5 3.5 3];
    formatDefault.yLabels = ["$\mathbf{p}_x$ [m]","$\mathbf{p}_y$ [m]","$\mathbf{p}_z$ [m]"];
    formatDefault.xLabels = "$t$ [s]";

    if nargin > 3 && isfield(formatPlots,"Position")
        formatUser = formatPlots.Position;
        formatDefault = overwriteFormat(formatDefault, formatUser);
    end

    fig = figure('Name',formatDefault.name);
    set(fig,'units','normalized','outerposition',[0 0 formatDefault.figWidth formatDefault.figHeight]);
    [h,legendPos] = CreateCustomCanvas(fig,options1);
    numPlotsX = options1.numPlots(1);
    numPlotsY = options1.numPlots(2)+options1.showControlBar;
    refIndex = {modeIndex(2)+1:modeIndex(4)-1,modeIndex(2)+1:modeIndex(4)-1,modeIndex(4)+1:modeIndex(end)};

    % Plot Data
    for i = 1:numPlotsX
        for j = 1:numPlotsY
            curAxis = h(j,i);
            hold(curAxis,"on");
            if options1.showControlBar &&  j == numPlotsY
                % Plot Control Modes (small bars below plots)
                for m = 1:length(modeStart)
                    mode(m) = fill(curAxis,[time(modeIndex(m:m+1)).' flip(time(modeIndex(m:m+1))).'],yFill,modeColors(m));
                end
            else
                % Plot vertical dashed lines to indicate control modes
                for m = 1:length(modeStart)
                    modePlot(m) = xline(curAxis,time(modeStart(m)),'--','LineWidth',formatDefault.xLineWidth,'Color',modeColors(m));
                end

                % Plot actual data
                for k = 1:length(robotNames)
                    curRobot = simData.Robots.(robotNames{k});
                    pos(k) = plot(curAxis,time,curRobot.realPos.(fitDir(j)),'LineWidth',formatDefault.lineWidth(k));
                end

                for k = 1:length(robotNames)-1
                    curRobot = simData.Robots.(robotNames{k});
                    ref(k) = plot(curAxis,time(refIndex{k}),curRobot.targetPos.(fitDir(j))(refIndex{k}),'--','LineWidth',formatDefault.lineWidth(2,k));
                end
            end
    
        end
    end
    
    FormatCustomPlot(h,options1);
    set(h(:,:),'FontSize',formatDefault.fontSize)
    set(h(1,1),"XLim",[plotTimeRange(1) plotTimeRange(end)])
    set(h(1,2),"XLim",impTime + [-formatOptions.zoomTime,formatOptions.zoomTime])
    text = sprintf('Enlarged between \n$t = %.3f$ [s] and $t = %.3f$ [s]',impTime + [-formatOptions.zoomTime,formatOptions.zoomTime]);
    title(h(1,2),text,'interpreter','latex')
    xlabel(h(end,:),formatDefault.xLabels,'interpreter','latex')
    for i = 1:3
        ylabel(h(i,1),formatDefault.yLabels(i),'interpreter','latex')
    end
    
    ns = 1; % 2
    modeLegend = legend([transpose(mode)],{['Initial Mode',spacer(ns)],['Ante-impact Mode',spacer(ns)],['Intermediate Mode',spacer(ns)],['Post-impact Mode',spacer(ns)]}.','interpreter','latex','NumColumns',4,'box','off');
    ns = 1; %35
    % plotLegend = legend([transpose(pos)],{['Cartesian Position: Panda 1 ',spacer(ns)],['Cartesian Position: Panda 2 ',spacer(ns)],['Cartesian Position: Box ',spacer(ns)]}.','interpreter','latex','box','off');
    plotLegend = legend([transpose([pos ref])],{['Cartesian Position: Panda 1',spacer(ns)],['Cartesian Position: Panda 2',spacer(ns)],['Cartesian Position: Box',spacer(ns)] ...
                                                ['Reference Position: Panda 1',spacer(ns)],['Reference Position: Panda 2',spacer(ns)],['Reference Position: Box',spacer(ns)]}.','interpreter','latex','NumColumns',2);

    
    modeLegend.Position(1:2) = [0.5 legendPos{1}.Position(2)]+[-modeLegend.Position(3)/2 0];
    plotLegend.Position(1:2) = legendPos{2}.Position(1:2);

    if plotOptions.SavePlots
        saveas(gcf,fullfile(plotOptions.SaveFolder,strcat(plotOptions.PreFix,formatDefault.name,'.png')))
        saveas(gcf,fullfile(plotOptions.SaveFolder,strcat(plotOptions.PreFix,formatDefault.name)),'epsc')
    end 

end


%% Plot Velocity + Reference + Around Impact
options2 = options1;
if isfield(plotOptions,"Velocity") && plotOptions.Velocity
    name = "Velocity";
    fig = figure('Name',name);
    set(fig,'units','normalized','outerposition',[0 0 formatOptions.figWidth formatOptions.figHeight]);
    [h,legendPos] = CreateCustomCanvas(fig,options2);
    lineWidth = [6 4.5 3; 5 3.5 3];
    numPlotsX = options2.numPlots(1);
    numPlotsY = options2.numPlots(2)+options2.showControlBar;
    refIndex = {modeIndex(2)+1:modeIndex(3)-1,modeIndex(2)+1:modeIndex(3)-1,modeIndex(4)+1:modeIndex(end)};
    % Plot Data
    for i = 1:numPlotsX
        for j = 1:numPlotsY
            curAxis = h(j,i);
            hold(curAxis,"on");
            if options2.showControlBar &&  j == numPlotsY
                % Plot Control Modes (small bars below plots)
                for m = 1:length(modeStart)
                    mode(m) = fill(curAxis,[time(modeIndex(m:m+1)).' flip(time(modeIndex(m:m+1))).'],yFill,modeColors(m));
                end

            else 
                % Plot vertical dashed lines to indicate control modes
                for m = 1:length(modeStart)
                    modePlot(m) = xline(curAxis,time(modeStart(m)),'--','LineWidth',formatOptions.xLineWidth,'Color',modeColors(m));
                end
                
                % Plot actual data
                for k = 1:length(robotNames)
                    curRobot = simData.Robots.(robotNames{k});
                    vel(k) = plot(curAxis,time,curRobot.realVel.(fitDir(j)),'LineWidth',lineWidth(1,k));
                end

                for k = 1:length(robotNames)-1
                    curRobot = simData.Robots.(robotNames{k});
                    ref(k) = plot(curAxis,time(refIndex{k}),curRobot.targetVel.(fitDir(j))(refIndex{k}),'--','LineWidth',lineWidth(2,k));
                end

            end
    
        end
    end
    
    % Format Plot
    yLabels = ["$\dot{\mathbf{p}}_x$ [m/s]","$\dot{\mathbf{p}}_y$ [m/s]","$\dot{\mathbf{p}}_z$ [m/s]"];
    xLabels = ["$t$ [s]"];
    
    FormatCustomPlot(h,options2);
    set(h(:,:),'FontSize',formatOptions.fontSize)
    set(h(1,1),"XLim",[plotTimeRange(1) plotTimeRange(end)])
    set(h(1,2),"XLim",impTime + [-formatOptions.zoomTime,formatOptions.zoomTime])
    text = sprintf('Enlarged between \n$t = %.3f$ [s] and $t = %.3f$ [s]',impTime + [-formatOptions.zoomTime,formatOptions.zoomTime]);
    title(h(1,2),text,'interpreter','latex','FontSize',formatOptions.fontSize)
    xlabel(h(end,:),xLabels,'interpreter','latex','FontSize',formatOptions.fontSize)
    for i = 1:length(yLabels)
        ylabel(h(i,1),yLabels(i),'interpreter','latex','FontSize',formatOptions.fontSize)
    end
    
    
    ns = 2;
    modeLegend = legend([transpose(mode)],{['Initial Mode',spacer(ns)],['Ante-impact Mode',spacer(ns)],['Intermediate Mode',spacer(ns)],['Post-impact Mode',spacer(ns)]}.','interpreter','latex','NumColumns',4,'box','off');
    ns = 10;
    plotLegend = legend([transpose([vel ref])],{['Cartesian Velocity: Panda 1',spacer(ns)],['Cartesian Velocity: Panda 2',spacer(ns)],['Cartesian Velocity: Box',spacer(ns)] ...
        ['Reference Velocity: Panda 1',spacer(ns)],['Reference Velocity: Panda 2',spacer(ns)],['Reference Velocity: Box',spacer(ns)]}.','interpreter','latex','NumColumns',2);
    modeLegend.Position = legendPos{1}.Position;
    plotLegend.Position = legendPos{2}.Position;

    if plotOptions.SavePlots
        saveas(gcf,fullfile(plotOptions.SaveFolder,strcat(plotOptions.PreFix,name,'.png')))
        saveas(gcf,fullfile(plotOptions.SaveFolder,strcat(plotOptions.PreFix,name)),'epsc')
    end  

end


%% Plot Torques
options3.numPlots = [2,7];
options3.ratioSize.x = [0.75, 0.25];
options3.ratioSize.y = [1,1,1,1,1,1,1];
options3.padding.in = [0.05,0.025];
options3.padding.out = [0.075,0.05];
options3.showControlBar = true;
options3.yRatioControlBar = 0.01;
options3.yRatioControlLegend = 0.3;
options3.yExtra = 0.15;
options3.showLegend = true;
options3.yRatioLegend = 0.05;
options3.hideXLabels = true;
options3.hideYLabels = false;
options3.linkAxes = 'x';

lineWidth = [6 4.5 3];

if isfield(plotOptions,"Torque") &&  plotOptions.Torque
    name = "Torques";
    fig = figure('Name',name);
    set(fig,'units','normalized','outerposition',[0 0 formatOptions.figWidth formatOptions.figHeight]);
    [h,legendPos] = CreateCustomCanvas(fig,options3);
    numPlotsX = options3.numPlots(1);
    numPlotsY = options3.numPlots(2)+options3.showControlBar;
    % Plot Data
    for i = 1:numPlotsX
        for j = 1:numPlotsY
            curAxis = h(j,i);
            hold(curAxis,"on");
            if options3.showControlBar &&  j == numPlotsY
                % Plot Control Modes (small bars below plots)
                for m = 1:length(modeStart)
                    mode(m) = fill(curAxis,[time(modeIndex(m:m+1)).' flip(time(modeIndex(m:m+1))).'],yFill,modeColors(m));
                end
            else
                % Plot vertical dashed lines to indicate control modes
                for m = 1:length(modeStart)
                    modePlot(m) = xline(curAxis,time(modeStart(m)),'--','LineWidth',formatOptions.xLineWidth,'Color',modeColors(m));
                end
    
                % Plot actual data
                for k = 1:2
                    curRobot = simData.Robots.(robotNames{k});
                    torq(k) = plot(curAxis,time,curRobot.realTorques.(strcat('J',num2str(j))),'LineWidth',lineWidth(k));
                end
            end
    
        end
    end
    
    % Format Plot
    yLabels = compose("$\\mathbf{\\tau}_{%d}$",1:options3.numPlots(2)); 
    yLabels(1) = strcat(yLabels(1)," [Nm]");
    xLabels = ["$t$ [s]"];
    

    FormatCustomPlot(h,options3);
    set(h(:,:),'FontSize',formatOptions.fontSize)
    set(h(1,1),"XLim",[plotTimeRange(1) plotTimeRange(end)])
    set(h(1,2),"XLim",impTime + [-formatOptions.zoomTime,formatOptions.zoomTime])
    text = sprintf('Enlarged between \n$t = %.3f$ [s] and $t = %.3f$ [s]',impTime + [-formatOptions.zoomTime,formatOptions.zoomTime]);
    title(h(1,2),text,'interpreter','latex','FontSize',formatOptions.fontSize)
    xlabel(h(end,:),xLabels,'interpreter','latex','FontSize',formatOptions.fontSize)
    for i = 1:length(yLabels)
        ylabel(h(i,1),yLabels(i),'interpreter','latex','FontSize',formatOptions.fontSize)
    end
    
    
    ns = 2;
    modeLegend = legend([transpose(mode)],{['Initial Mode',spacer(ns)],['Ante-impact Mode',spacer(ns)],['Intermediate Mode',spacer(ns)],['Post-impact Mode',spacer(ns)]}.','interpreter','latex','NumColumns',4,'box','off');
    ns = 35;
    plotLegend = legend([transpose(torq)],{['Joint Torques: Panda 1 ',spacer(ns)],['Joint Torques: Panda 2 ',spacer(ns)]}.','interpreter','latex');
    modeLegend.Position = legendPos{1}.Position;
    plotLegend.Position = legendPos{2}.Position;

    if plotOptions.SavePlots
        saveas(gcf,fullfile(plotOptions.SaveFolder,strcat(plotOptions.PreFix,name,'.png')))
        saveas(gcf,fullfile(plotOptions.SaveFolder,strcat(plotOptions.PreFix,name)),'epsc')
    end 

end

%% Plot Synchronization
lineWidth = [6 4.5; 5 3.5];
options4.numPlots = [1,3];
options4.ratioSize.x = [1];
options4.ratioSize.y = [1,1,1];
options4.padding.in = [0.05,0.025];
options4.padding.out = [0.1,0.1];
options4.showControlBar = false;
options4.yRatioControlBar = 0.01;
options4.yRatioControlLegend = 0.3;
options4.yExtra = 0.15;
options4.showLegend = true;
options4.yRatioLegend = 0.05;
options4.hideXLabels = true;
options4.hideYLabels = false;
options4.linkAxes = 'x';

options5 = options4;

if isfield(plotOptions,"Synchronization") && plotOptions.Synchronization
    %%%%%%%%%%%%%%%%%% Plot Synchronization Position 
    name = "SynchronizationPosition";
    fig = figure('Name',name);
    set(fig,'units','normalized','outerposition',[0 0 formatOptions.figWidth/2 formatOptions.figHeight]);
    [h,legendPos] = CreateCustomCanvas(fig,options4);
    numPlotsX = options4.numPlots(1);
    numPlotsY = options4.numPlots(2)+options4.showControlBar;
    % Plot Synchronization Position Data
    for i = 1:numPlotsX
        for j = 1:numPlotsY
            curAxis = h(j,i);
            hold(curAxis,"on");
            if options4.showControlBar &&  j == numPlotsY
                % Plot Control Modes (small bars below plots)
                for m = 1:length(modeStart)
                    mode(m) = fill(curAxis,[time(modeIndex(m:m+1)).' flip(time(modeIndex(m:m+1))).'],yFill,modeColors(m));
                end

                % Plot vertical dashed lines to indicate control modes
                for m = 1:length(modeStart)
                    modePlot(m) = xline(curAxis,time(modeStart(m)),'--','LineWidth',formatOptions.xLineWidth,'Color',modeColors(m));
                end

            else
                % Plot actual data
                for k = 1:length(robotNames)-1
                    curRobot = simData.Robots.(robotNames{k});
                    carpos(k) = plot(curAxis,time,curRobot.realPos.(fitDir(j)),'LineWidth',lineWidth(1,k));
                end

                for k = 1:length(robotNames)-1
                    curRobot = simData.Robots.(robotNames{k});
                    syncpos(k) = plot(curAxis,time,curRobot.syncPos.(fitDir(j)),'--','LineWidth',lineWidth(2,k));
                end

           end
    
        end
    end
    

    % Format Plot
    yLabels = ["$\mathbf{p}_x$ [m]","$\mathbf{p}_y$ [m]","$\mathbf{p}_z$ [m]"];
    xLabels = ["$t$ [s]"];
    
    FormatCustomPlot(h,options4);
    set(h(:,:),'FontSize',formatOptions.fontSize)
    set(h(1,1),"XLim",[time(modeStart(2)+1) time(modeStart(3)-1)])
    xlabel(h(end,:),xLabels,'interpreter','latex','FontSize',formatOptions.fontSize)
    for i = 1:3
        ylabel(h(i,1),yLabels(i),'interpreter','latex','FontSize',formatOptions.fontSize)
    end
    
    ns = 5;
    plotLegend = legend([transpose([carpos syncpos])],{['Panda 1: Position',spacer(ns)],['Panda 2: Position',spacer(ns)],...
                                                    ['Panda 1: Reference',spacer(ns)],['Panda 2: Reference',spacer(ns)]}.','interpreter','latex','NumColumns',2);
    plotLegend.Position = legendPos{1}.Position;

    if plotOptions.SavePlots
        saveas(gcf,fullfile(plotOptions.SaveFolder,strcat(plotOptions.PreFix,name,'.png')))
        saveas(gcf,fullfile(plotOptions.SaveFolder,strcat(plotOptions.PreFix,name)),'epsc')
    end 

    %%%%%%%%%%%%%%%%%% Plot Synchronization Velocity 
    name = "SynchronizationVelocity";
    fig = figure('Name',name);
    set(fig,'units','normalized','outerposition',[0.5 0 formatOptions.figWidth/2 formatOptions.figHeight]);
    [h,legendPos] = CreateCustomCanvas(fig,options5);
    numPlotsX = options5.numPlots(1);
    numPlotsY = options5.numPlots(2)+options5.showControlBar;
    % Plot Synchronization Position Data
    for i = 1:numPlotsX
        for j = 1:numPlotsY
            curAxis = h(j,i);
            hold(curAxis,"on");
            if options5.showControlBar &&  j == numPlotsY
                % Plot Control Modes (small bars below plots)
                for m = 1:length(modeStart)
                    mode(m) = fill(curAxis,[time(modeIndex(m:m+1)).' flip(time(modeIndex(m:m+1))).'],yFill,modeColors(m));
                end

                % Plot vertical dashed lines to indicate control modes
                for m = 1:length(modeStart)
                    modePlot(m) = xline(curAxis,time(modeStart(m)),'--','LineWidth',formatOptions.xLineWidth,'Color',modeColors(m));
                end

            else
                % Plot actual data
                for k = 1:length(robotNames)-1
                    curRobot = simData.Robots.(robotNames{k});
                    carvel(k) = plot(curAxis,time,curRobot.realVel.(fitDir(j)),'LineWidth',lineWidth(1,k));
                end

                for k = 1:length(robotNames)-1
                    curRobot = simData.Robots.(robotNames{k});
                    syncvel(k) = plot(curAxis,time,curRobot.syncVel.(fitDir(j)),'--','LineWidth',lineWidth(2,k));
                end

           end
    
        end
    end
    

    % Format Plot
    yLabels = ["$\dot{\mathbf{p}}_x$ [m/s]","$\dot{\mathbf{p}}_y$ [m/s]","$\dot{\mathbf{p}}_z$ [m/s]"];
    xLabels = ["$t$ [s]"];
    
    FormatCustomPlot(h,options5);
    set(h(:,:),'FontSize',formatOptions.fontSize)
    set(h(1,1),"XLim",[time(modeStart(2)+1) time(modeStart(3)-1)])
    xlabel(h(end,:),xLabels,'interpreter','latex','FontSize',formatOptions.fontSize)
    for i = 1:3
        ylabel(h(i,1),yLabels(i),'interpreter','latex','FontSize',formatOptions.fontSize)
    end
    
    ns = 5;
    plotLegend = legend([transpose([carvel syncvel])],{['Panda 1: Velocity',spacer(ns)],['Panda 2: Velocity',spacer(ns)],...
                                                    ['Panda 1: Reference',spacer(ns)],['Panda 2: Reference',spacer(ns)]}.','interpreter','latex','NumColumns',2);
    plotLegend.Position = legendPos{1}.Position;

    if plotOptions.SavePlots        
        saveas(gcf,fullfile(plotOptions.SaveFolder,strcat(plotOptions.PreFix,name,'.png')))
        saveas(gcf,fullfile(plotOptions.SaveFolder,strcat(plotOptions.PreFix,name)),'epsc')
    end 

end

%% Plot Synchronization Error
if isfield(plotOptions,"SyncError") &&  plotOptions.SyncError
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

    for k = 1:size(relPos1,2)
        syncError(:,k) = -(syncMat1*(relPos1(:,k)) - syncMat2*(relPos2(:,k)));
        syncErrorDot(:,k) = -(syncMat2*(relVel1(:,k)) - syncMat1*(relVel2(:,k)));
    end

    %%%%%%%%%%%%%%%%%% Plot Synchronization Position 
    options4.showLegend = false;
    options4.numPlots = [2, 3];
    options4.ratioSize.x = [1 1];
    options4.padding.in = [0.15,0.025];
    options4.padding.out = [0.15,0.1];
    name = "SynchronizationError";
    fig = figure('Name',name);
    set(fig,'units','normalized','outerposition',[0 0 formatOptions.figWidth/2 formatOptions.figHeight]);
    [h,legendPos] = CreateCustomCanvas(fig,options4);
    numPlotsX = options4.numPlots(1);
    numPlotsY = options4.numPlots(2)+options4.showControlBar;
    % Plot Synchronization Position Data
    for i = 1:numPlotsX
        for j = 1:numPlotsY
            curAxis = h(j,i);
            hold(curAxis,"on");
            if i == 1
                error = plot(curAxis,time,syncError(j,:),'LineWidth',lineWidth(1,1));
            else
                derror = plot(curAxis,time,syncErrorDot(j,:),'LineWidth',lineWidth(1,1));
            end
        end
    end
    

    % Format Plot
    yLabels = {["$\mathbf{\epsilon}_x$ [m]","$\mathbf{\epsilon}_y$ [m]","$\mathbf{\epsilon}_z$ [m]"],...
               ["$\dot{\mathbf{\epsilon}}_x$ [m/s]","$\dot{\mathbf{\epsilon}_y}$ [m/s]","$\dot{\mathbf{\epsilon}_z}$ [m/s]"]};
    xLabels = ["$t$ [s]"];
    
    FormatCustomPlot(h,options4);
    set(h(:,:),'FontSize',formatOptions.fontSize)
    set(h(1,:),"XLim",[time(modeStart(2)+1) time(modeStart(3)-1)])
    xlabel(h(end,:),xLabels,'interpreter','latex','FontSize',formatOptions.fontSize)
    for i = 1:3
        for j = 1:2
            ylabel(h(i,j),yLabels{j}(i),'interpreter','latex','FontSize',formatOptions.fontSize)
        end
    end
    
%     ns = 16;
%     plotLegend = legend([transpose([error derror])],{['Synchronization Position Error',spacer(ns)],['Synchronization Velocity Error',spacer(ns)]},...
%                                                       'interpreter','latex','NumColumns',1);
%     plotLegend.Position = legendPos{1}.Position;

    if plotOptions.SavePlots
        saveas(gcf,fullfile(plotOptions.SaveFolder,strcat(plotOptions.PreFix,name,'.png')))
        saveas(gcf,fullfile(plotOptions.SaveFolder,strcat(plotOptions.PreFix,name)),'epsc')
    end 


end


%% Plot Synchronization vs. Vector Field Component of Reference Velocity
options6.numPlots = [2,3];
options6.ratioSize.x = [1, 1];
options6.ratioSize.y = [1,1,1];
options6.padding.in = [0.05,0.025];
options6.padding.out = [0.1,0.1];
options6.showControlBar = false;
options6.yRatioControlBar = 0.01;
options6.yRatioControlLegend = 0.2;
options6.yExtra = 0.15;
options6.showLegend = true;
options6.yRatioLegend = 0.05;
options6.hideXLabels = true;
options6.hideYLabels = true;
options6.linkAxes = 'y';

if isfield(plotOptions,"SyncVSVector") && plotOptions.SyncVSVector
    name = "SynchronizationAndVectorField";
    fig = figure('Name',name);
    set(fig,'units','normalized','outerposition',[0.5 0 formatOptions.figWidth formatOptions.figHeight]);
    [h,legendPos] = CreateCustomCanvas(fig,options6);
    numPlotsX = options6.numPlots(1);
    numPlotsY = options6.numPlots(2)+options6.showControlBar;
    % Plot Synchronization Position Data
    for i = 1:numPlotsX
        for j = 1:numPlotsY
            curAxis = h(j,i);
            hold(curAxis,"on");

            % Plot actual data
            curRobot = simData.Robots.(robotNames{i});
            carvel(i) = plot(curAxis,time,curRobot.realVel.(fitDir(j)),'LineWidth',lineWidth(1,i));
            syncvel(i) = plot(curAxis,time,curRobot.syncVel.(fitDir(j)),'--','LineWidth',lineWidth(2,i));
            targetvel(i) = plot(curAxis,time,curRobot.targetVel.(fitDir(j)),':','LineWidth',lineWidth(2,i));         
    
        end
    end
    

    % Format Plot
    yLabels = ["$\dot{\mathbf{p}}_x$ [m/s]","$\dot{\mathbf{p}}_y$ [m/s]","$\dot{\mathbf{p}}_z$ [m/s]"];
    xLabels = ["$t$ [s]"];
    
    FormatCustomPlot(h,options6);
    set(h(:,:),'FontSize',formatOptions.fontSize)
    set(h(:,:),"XLim",[time(modeStart(2)+1) time(modeStart(3)-1)])
    xlabel(h(end,:),xLabels,'interpreter','latex','FontSize',formatOptions.fontSize)
    for i = 1:3
        ylabel(h(i,1),yLabels(i),'interpreter','latex','FontSize',formatOptions.fontSize)
    end
    
    comp = [carvel;syncvel;targetvel];
    ns = 2;

    preFix = ["Panda 1", "Panda 2"];

    for i = 1:2
        title(h(1,i),preFix(i),'interpreter','latex','FontSize',formatOptions.fontSize)
    end

    plotLegend = legend([transpose([carvel(i); syncvel(i); targetvel(i)])],{'Real Velocity','Synchronization Reference','Vector Field Reference'},...
                                                                               'interpreter','latex','NumColumns',1);  
    
    hPos = h(1,1).Position;
    
    plotLegend.Position = [0.5,hPos(2) + hPos(4) + 0.05,0,0];

%     preFix = ["Panda 1", "Panda 2"];
%     for i = 1:2
%     plotLegend(i) = legend([transpose([carvel(i); syncvel(i); targetvel(i)])],{join([preFix(i),'Velocity',spacer(ns)]),join([preFix(i),'Synchronization',spacer(ns)]),join([preFix(i),'Vector Field',spacer(ns)])},...
%                                                                             'interpreter','latex','NumColumns',1);    
%     end   

    if plotOptions.SavePlots
        saveas(gcf,fullfile(plotOptions.SaveFolder,strcat(plotOptions.PreFix,name,'.png')))
        saveas(gcf,fullfile(plotOptions.SaveFolder,strcat(plotOptions.PreFix,name)),'epsc')
    end 




end

%% Plot Position + Fit
lineWidth = [7 4 4];
formatOptions.xLineWidth = 2;
markerSize = 200;
numPlotsX = 3;
numPlotsY = 3;
% fitTime =   simData.Fitting.fitTime;
% fitOrder =   simData.Fitting.fitOrder;


if isfield(plotOptions,"PositionFit") &&  plotOptions.PositionFit
    name = "PolynomialFit";
    fig = figure('Name',name);
    set(gcf,'Units','Normalized','Position',[0 0 formatOptions.figWidth formatOptions.figHeight])
    posPlot = tiledlayout(numPlotsX,numPlotsY);
    posPlot.TileSpacing = 'compact';
    posPlot.Padding = 'compact';

    % Plot Data
    for i = 1:numPlotsX    % Loop over robots
        for j = 1:numPlotsY      % Loop over x,y,z directions for each robot
            curRobot = simData.Robots.(robotNames{i});
            posTile(j,i) = nexttile((j-1)*numPlotsX + i);
            hold on;
            impstart = xline(curRobot.fittedTime.postTime(1),'k--','LineWidth',formatOptions.xLineWidth);
            pos = plot(time,curRobot.realPos.(fitDir(j)),'LineWidth',lineWidth(1));
            afit = plot(curRobot.fittedTime.anteTime,curRobot.fittedAntePos.(fitDir(j)),'LineWidth',lineWidth(2));
            pfit = plot(curRobot.fittedTime.postTime,curRobot.fittedPostPos.(fitDir(j)),'LineWidth',lineWidth(3));
            astart = xline(curRobot.fittedTime.anteTime(1),'--','LineWidth',formatOptions.xLineWidth,'Color',afit.Color);
            pstart = xline(curRobot.fittedTime.postTime(end),'--','LineWidth',formatOptions.xLineWidth,'Color',pfit.Color);
            xlim(([curRobot.fittedTime.anteTime(1) - formatOptions.zoomRatio*fitTime, curRobot.fittedTime.postTime(end) + formatOptions.zoomRatio*fitTime]))
    
        end
    
    end
    
    
    % Format Plot
    lg = legend([pos;afit;pfit;impstart],["$\mathbf{p}_{\mathrm{real}}$","$\mathbf{p}_{\mathrm{fit}}^{\mathrm{ante}}$","$\mathbf{p}_{\mathrm{fit}}^{\mathrm{post}}$","$t_{\mathrm{imp}}$"],'interpreter','latex');
    lg.Layout.Tile = 'east';
    
    yLabels = ["$\mathbf{p}_x$ [m]","$\mathbf{p}_y$ [m]","$\mathbf{p}_z$ [m]"];
    titlePlots = ["Panda 1","Panda 2","Box"];
    for i = 1:numPlotsX
        for j = 1:numPlotsY      % Loop over x,y,z directions for each robot
    
            posTile(j,i).FontSize = formatOptions.fontSize;
    
            if j < 2
                title(posTile(j,i),titlePlots(i),'interpreter','latex');
            end
    
            if j < numPlotsY
                posTile(j,i).XTickLabel = '';
            else
                xlabel(posTile(j,i),'$t$ [s]','interpreter','latex');
            end
    
            if i > 1
                posTile(j,i).YTickLabel = '';
            else
                ylabel(posTile(j,i),yLabels(j),'interpreter','latex');
            end
        end
    
        linkaxes([posTile(i,:)],'xy')
    end
    
    posTitle = sprintf("Position Data + Polynomial Fit\nPolynomial Order $n = %d$, Fitting Duration: $t_{\\mathrm{fit}} = %d$ [ms]",fitOrder,fitTime * 1e3);
    title(posPlot,posTitle,'interpreter','latex','FontSize',formatOptions.fontSize+2);

    if plotOptions.SavePlots
        saveas(gcf,fullfile(plotOptions.SaveFolder,strcat(plotOptions.PreFix,name,'.png')))
        saveas(gcf,fullfile(plotOptions.SaveFolder,strcat(plotOptions.PreFix,name)),'epsc')
    end  

end
%% Plot Velocity + Prediction
numPlotsX = 3;
numPlotsY = 3;

if isfield(plotOptions,"VelocityFit") && plotOptions.VelocityFit
    name = "PredictedVelocity";
    fig = figure('Name',name);
    set(gcf,'Units','Normalized','Position',[0 0 formatOptions.figWidth formatOptions.figHeight])
    velPlot = tiledlayout(numPlotsX,numPlotsY);
    velPlot.TileSpacing = 'compact';
    velPlot.Padding = 'compact';

    % Plot Data
    for i = 1:numPlotsX    % Loop over robots
        for j = 1:numPlotsY      % Loop over x,y,z directions for each robot
            curRobot    = simData.Robots.(robotNames{i});
            velTile(j,i) = nexttile((j-1)*numPlotsX + i);
            hold on;
            impstart    = xline(curRobot.fittedTime.postTime(1),'k--','LineWidth',formatOptions.xLineWidth);
            vel         = plot(time,curRobot.realVel.(fitDir(j)),'LineWidth',lineWidth(1));
            afit        = plot(curRobot.fittedTime.anteTime,curRobot.fittedAnteVel.(fitDir(j)),'LineWidth',lineWidth(2));
            pfit        = plot(curRobot.fittedTime.postTime,curRobot.fittedPostVel.(fitDir(j)),'LineWidth',lineWidth(3));
            astart      = xline(curRobot.fittedTime.anteTime(1),'--','LineWidth',formatOptions.xLineWidth,'Color',afit.Color);
            pstart      = xline(curRobot.fittedTime.postTime(end),'--','LineWidth',formatOptions.xLineWidth,'Color',pfit.Color);
            aval        = scatter(curRobot.fittedTime.anteTime(end),curRobot.fittedAnteVel.(fitDir(j))(end),markerSize,'filled','s','MarkerEdgeColor',afit.Color,'MarkerFaceColor',afit.Color);
            pval        = scatter(curRobot.fittedTime.postTime(1),curRobot.fittedPostVel.(fitDir(j))(1),markerSize,'filled','s','MarkerEdgeColor',pfit.Color,'MarkerFaceColor',pfit.Color);
            xlim(([curRobot.fittedTime.anteTime(1) - formatOptions.zoomRatio*fitTime, curRobot.fittedTime.postTime(end) + formatOptions.zoomRatio*fitTime]))
    
        end
    
    end
    
    % Format Plot
    lg = legend([vel;afit;pfit;aval;pval;impstart],["$\dot{\mathbf{p}}_{\mathrm{real}}$","$\dot{\mathbf{p}}_{\mathrm{fit}}^{\mathrm{ante}}$","$\dot{\mathbf{p}}_{\mathrm{fit}}^{\mathrm{post}}$","$\dot{\mathbf{p}}_{\mathrm{fit}}^{-}$","$\dot{\mathbf{p}}_{\mathrm{fit}}^{\mathrm{+}}$","$t_{\mathrm{imp}}$"],'interpreter','latex');
    lg.Layout.Tile = 'east';
    
    yLabels = ["$\dot{\mathbf{p}}_x$ [m/s]","$\dot{\mathbf{p}}_y$ [m/s]","$\dot{\mathbf{p}}_z$ [m/s]"];
    titlePlots = ["Panda 1","Panda 2","Box"];
    for i = 1:numPlotsX
        for j = 1:numPlotsY      % Loop over x,y,z directions for each robot
    
            velTile(j,i).FontSize = formatOptions.fontSize;
    
            if j < 2
                title(velTile(j,i),titlePlots(i),'interpreter','latex');
            end
    
            if j < numPlotsY
                velTile(j,i).XTickLabel = '';
            else
                xlabel(velTile(j,i),'$t$ [s]','interpreter','latex');
            end
    
            if i > 1
                velTile(j,i).YTickLabel = '';
            else
                ylabel(velTile(j,i),yLabels(j),'interpreter','latex');
            end
        end
    
        linkaxes([velTile(i,:)],'xy')
    end
    
    velTitle = sprintf("Velocity Data + Prediction\nPolynomial Order $n = %d$, Fitting Duration: $t_{\\mathrm{fit}} = %d$ [ms]",fitOrder,fitTime * 1e3);
    
    title(velPlot,velTitle,'interpreter','latex','FontSize',formatOptions.fontSize+2);

    if plotOptions.SavePlots
        saveas(gcf,fullfile(plotOptions.SaveFolder,strcat(plotOptions.PreFix,name,'.png')))
        saveas(gcf,fullfile(plotOptions.SaveFolder,strcat(plotOptions.PreFix,name)),'epsc')
    end 
end



%% Function END
end


function formatPlot = overwriteFormat(formatPlot, formatUser)
    vars = formatUser;
    varFields = fieldnames(vars);
    for i = 1:numel(varFields)
        fld = varFields{i};
        if isfield(formatPlot, fld)
            formatPlot.(fld) = vars.(fld);
        else
            throw(MException('overwriteFormat:invalidVar', 'variable: "%s" is not a valid variable to set', fld));
        end
    end
end