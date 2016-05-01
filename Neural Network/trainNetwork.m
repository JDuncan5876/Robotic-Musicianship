%% Neural Network Training
% Author: Jared Duncan

%% File Read
% Read in data from text files
clear;
fid1 = fopen('trainingDataType1.txt');
line = fgets(fid1);
i = 1;
j = 1;
while ischar(line)
    for ind = 1:4
        [word, line] = strtok(line);
    end
    
    while ~isempty(word)
        if any(word ~= '-' & word ~= '.' & (word < '0' | word > '9'))
            word = word(1:end-1);
        end
        X(i, j) = str2double(word);
        j = j + 1;
        [word, line] = strtok(line);
    end
    
    i = i + 1;
    j = 1;
    line = fgets(fid1);
end
y = ones(i, 1);
oldI = i;
fclose(fid1);

fid2 = fopen('trainingDataType2.txt');
line = fgets(fid2);
while ischar(line)
    for ind = 1:4
        [word, line] = strtok(line);
    end
    
    while ~isempty(word)
        if any(word ~= '-' & word ~= '.' & (word < '0' | word > '9'))
            word = word(1:end-1);
        end
        X(i, j) = str2double(word);
        j = j + 1;
        [word, line] = strtok(line);
    end
    
    i = i + 1;
    j = 1;
    line = fgets(fid2);
end
y = [y; ones(i - oldI - 1, 1) * 2];
fclose(fid2);

%% Train Neural Network
input_layer_size = size(X, 2);
hidden_layer_size = 5;
num_labels = 2;
lambda = 0;
[Theta1, Theta2] = driveNetwork(X, y, input_layer_size, hidden_layer_size, num_labels, lambda);

%% Make Predictions/Check Accuracy
prediction = predict(Theta1, Theta2, X);
accuracy = length(find(y == prediction)) / length(y);
fprintf('Training Accuracy: %1.2f%%\n', accuracy * 100);

%% Write Data to File
thetas = [Theta1(:); Theta2(:)];
fid = fopen('Thetas.txt', 'w');
for ind = 1:length(thetas);
    fprintf(fid, '%d, %1.4f;\r\n', ind - 1, thetas(ind));
end
fclose(fid);