function listofFolders = dirFolders( folder )
files = dir(folder);
dirFlags = [files.isdir];
listofFolders = files(dirFlags);
end