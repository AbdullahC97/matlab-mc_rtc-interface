function status = ModifyControllerConfig(fileName,verbose,varargin)

%% Read YAML file
txt = fileread(fileName);
txt = regexp(txt,'\r\n','split');

%% Find indices of passed keys
for i = 1:2:length(varargin) % work for a list of name-value pairs
    if ischar(varargin{i}) % check if is character
        find_str = varargin{i};
        idx = strfind(txt, find_str);

        k = floor(i/2) + 1;
        parameter{k} = find_str;
        value{k} = varargin{i+1};

        if isa(value{k},'cell') && size(value{k}{:},2) == 2
            index{k} = idx{:}(round(value{k}{:}(1)));
        else
            index{k} = idx{:}(1);
        end
    end
end


%% Modify YAML file
if verbose
    fprintf("\nFollowing changes were written:\n")
end

for i = 1:length(parameter)
    if isa(value{i},'double')
        new_str = sprintf("%s: %g #",parameter{i},value{i});   
    elseif isa(value{i},'string')
        new_str = sprintf("%s: %s #",parameter{i},value{i});   
    elseif isa(value{i},'cell')
        if size(value{i}{:},2) == 2
            new_str = sprintf("%s: %g #",parameter{i},value{i}{:}(2)); 
        elseif size(value{i}{:},2) == 3
            new_str = sprintf("%s: [%g,%g,%g] #",parameter{i},value{i}{:}); 
        elseif size(value{i}{:},2) == 7
            new_str = sprintf("%s: [%g,%g,%g,%g,%g,%g,%g] #",parameter{i},value{i}{:});     
        end
    else
        fprintf("\tPassed field + value is invalid --> Field: <%s>, Value: <%g>\n",parameter{i},value{i});
    end

    vloc = index{i} + (0:strlength(new_str)-1);
    txt{1}(vloc) = new_str;
    
    if verbose
        fprintf("\tModified --> %s\b\n",new_str);
    end
end

% fprintf(txt{:})

%% Write and replace YAML        
fid = fopen(fileName,'wt');
fprintf(fid,'%s\n',txt{:});
fclose(fid);

end