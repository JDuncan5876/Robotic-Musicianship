X = [zeros(25, 1), zeros(25, 1);
     zeros(25, 1), ones(25, 1);
     ones(25, 1), zeros(25, 1);
     ones(25, 1), ones(25, 1)];
y = [ones(25, 1);
     ones(25, 1)*2;
     ones(25, 1)*2;
     ones(25, 1)];

[Theta1, Theta2] = driveNetwork(X, y, 2, 2, 2, 0);

fid = fopen('XORThetas.txt', 'w');
Thetas = [Theta1(:); Theta2(:)];

for ind = 1:length(Thetas)
    fprintf(fid, '%d, %1.4f;\r\n', ind - 1, Thetas(ind));
end

prediction = predict(Theta1, Theta2, X) - 1;
disp([X, prediction]);