function [h,legendPos] = CreateCustomCanvas(fig, options)
yExtra = options.yExtra;
nX = options.numPlots(1);
nY = options.numPlots(2);

xSpace = (1-2*options.padding.out(1)-(nX-1)*options.padding.in(1));
ySpace = (1-2*options.padding.out(2)-(nY-1)*options.padding.in(2)) - (options.yRatioLegend+0.5*options.padding.in(2))*options.showLegend - (options.yRatioControlBar+0.5*options.padding.in(2) + yExtra)*options.showControlBar;

dP.x = (options.ratioSize.x(1:nX))/max(sum(abs(options.ratioSize.x(1:nX))))*xSpace;
dP.y = (options.ratioSize.y(1:nY))/max(sum(abs(options.ratioSize.y(1:nY))))*ySpace;

x0 = options.padding.out(1);
y0 = options.padding.out(2)+yExtra*options.showControlBar; 

if options.showControlBar
    nY = nY + 1;
    dP.y = [options.yRatioControlBar dP.y ];
end

p0.x = zeros(nY,nX);
p0.y = zeros(nY,nX);

for i = 1:nX
    p0.x(:,i) = x0*ones([nY, 1]); 
    x0 = x0 + dP.x(i) + options.padding.in(1);
end

for j = nY:-1:1
    p0.y(j,:) = y0*ones([1, nX]);
    if j ~= nY || ~options.showControlBar
        y0 = y0 + dP.y(end - j + 1) + options.padding.in(2);
    else
        y0 = y0 + dP.y(end - j + 1) + 0.5*options.padding.in(2);
    end
end



figure(fig)
for i = 1:nX
    for j = 1:nY
        h(j,i) = subplot(nY,nX,(i-1)*nY + j);
    end
end

for i = 1:nX
    for j = 1:nY
        curAxis = h(j,i);
        set(curAxis,'Position',[p0.x(j,i) p0.y(j,i) dP.x(i) dP.y(end - j + 1)]);
    end
end

id1 = options.showControlBar;
id2 = id1 + options.showLegend;

if nargout > 1
    if options.showControlBar 
        %legendPos{id1}.Position = [p0.x(1,1), p0.y(nY,1) - 1.2*options.padding.out(2), sum(dP.x) + (nX-1)*options.padding.in(1), 0.4*options.padding.out(2)];
        legendPos{id1}.Position = [p0.x(1,1), options.padding.out(2), sum(dP.x) + (nX-1)*options.padding.in(1), options.yRatioControlLegend*yExtra];

    end
    
    if options.showLegend 
        legendPos{id2}.Position = [p0.x(1,1), p0.y(1,1) + dP.y(end) + 0.5*options.padding.in(2), dP.x(1), options.yRatioLegend];
    end

    if ~options.showControlBar && ~options.showLegend 
        legendPos = [];
    end

end


end

