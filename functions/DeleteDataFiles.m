function DeleteDataFiles(data_folder,varargin)

if varargin{1} == 'all'
    extensions = {''};
else
    extensions = compose('*.%s',cell2mat(varargin.'));
end

fprintf("The following files are deleted:\n");
fprintf("Folder: %s:\n",data_folder);

for i = 1:length(extensions)
    fprintf("\tType: %s\n",extensions{i});
    files = dir(fullfile(data_folder,extensions{i}));
    for j = 1:length(files)
        fprintf("\t\tFile: \t%s\n",files(j).name);
        delete(fullfile(files(j).folder,files(j).name)) 
    end
    fprintf("\n");
end

fprintf("Files were succesfully deleted...\n");






