% flush the buffer
clrdevice(obj1);
 
% Clean-up
% Disconnect all objects.
fclose(obj1);

% Clean up all objects.
delete(obj1);

fprintf(1, 'Disconnected from: %s\n', instrinfo);