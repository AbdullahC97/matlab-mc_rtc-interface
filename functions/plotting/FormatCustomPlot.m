function [] = FormatCustomPlot(h, options)

nX = options.numPlots(1);
nY = options.numPlots(2) + options.showControlBar;

for i = 1:nX
    for j = 1:nY
        curAxis = h(j,i);

        if options.hideYLabels
            if i > 1
                set(curAxis, 'YTickLabel', '');
            end
        end

        if options.hideXLabels
            if j < nY
                set(curAxis, 'XTickLabel', '');
            end
        end

        if options.showControlBar
            if j == nY
                set(curAxis,'YColor','none')
            end
        end

        if options.linkAxes == 'x'
            linkaxes([h(:,i)],'x')
        end

        if options.linkAxes == 'y'
            linkaxes([h(j,:)],'y')
        end

    end
end


end

