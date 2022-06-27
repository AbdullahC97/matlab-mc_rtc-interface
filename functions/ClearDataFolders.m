function [] = ClearDataFolders(varargin)

fprintf("The following files will be deleted:\n");
for i = 1:length(varargin)
    folder = varargin{i};
    fprintf("\tFolder: %s:\n",folder);
    files = dir(folder);
    for j = 1:length(files)
        fprintf("\t\tFile: \t%s\n",files(j).name);
    end
    fprintf("\n");
end

ask_user = input("Are you sure? Enter YES to delete the files...\n","s");

if strcmp(ask_user,'YES') 
    for i = 1:length(varargin)
        folder = varargin{i};
        delete(strcat(folder,"/*")) 
    end
    fprintf("The files have been deleted!\n");
else
    fprintf("Deleting cancelled.\n");
end



% bin_folder,csv_folder,mat_folder,delete_options

% 
% if delete_options(1)
%     fprintf("\tFolder: %s:\n",bin_folder);
%     files = dir(strcat(bin_folder,"/*.bin"));
%     for i = 1:length(files)
%         file = files(i);
%         fprintf("\t\tFile: \t%s\n",file.name);
%     end
%     fprintf("\n");
% end
% 
% if delete_options(2)
%     fprintf("\tFolder: %s:\n",csv_folder);
%     files = dir(strcat(csv_folder,"/*.csv"));
%     for i = 1:length(files)
%         file = files(i);
%         fprintf("\t\tFile: \t%s\n",file.name);
%     end
%     fprintf("\n");
% end
% 
% if delete_options(3)
%     fprintf("\tFolder: %s:\n",mat_folder);
%     files = dir(strcat(mat_folder,"/*.mat"));
%     for i = 1:length(files)
%         file = files(i);
%         fprintf("\t\tFile: \t%s\n",file.name);
%     end
%     fprintf("\n");
% end
% 
% ask_user = input("Are you sure? Enter YES to delete the files...\n","s");
% 
% if strcmp(ask_user,'YES') 
%     delete(strcat(bin_folder,"/*.bin")) 
%     delete(strcat(csv_folder,"/*.csv")) 
%     delete(strcat(mat_folder,"/*.mat")) 
%     fprintf("The files have been deleted!\n");
% else
%     fprintf("Deleting cancelled.\n");
% end






