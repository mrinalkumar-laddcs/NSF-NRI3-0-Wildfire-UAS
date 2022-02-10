% Generation of Map File
function genMapFile(obs,domain,mapfile)
% Write Data to file
fileID = fopen(mapfile,'w'); % Open or create new file. Discard contents.
fprintf(fileID, 'domain ');
fprintf(fileID, '%d ', domain);
fprintf(fileID, '\n');
for i = 1:size(obs,2)
    fprintf(fileID, 'polygon ');
    fprintf(fileID, '%.3f ', reshape(obs(i).polygon',[1, size(obs(i).polygon,1)*size(obs(i).polygon,2)]));
    fprintf(fileID, '\n');
end
fclose(fileID);
end