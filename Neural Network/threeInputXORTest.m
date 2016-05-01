X = [zeros(25, 1), zeros(25, 1), zeros(25, 1);
     zeros(25, 1), zeros(25, 1), ones(25, 1);
     zeros(25, 1), ones(25, 1), zeros(25, 1);
     zeros(25, 1), ones(25, 1), ones(25, 1);
     ones(25, 1), zeros(25, 1), zeros(25, 1);
     ones(25, 1), zeros(25, 1), ones(25, 1);
     ones(25, 1), ones(25, 1), zeros(25, 1);
     ones(25, 1), ones(25, 1), ones(25, 1)];

y = [ones(25, 1);
     ones(25, 1)*2;
     ones(25, 1)*2;
     ones(25, 1);
     ones(25, 1)*2;
     ones(25, 1);
     ones(25, 1);
     ones(25, 1)*2];

[Theta1, Theta2] = driver(X, y, 3, 4, 2, 0);

prediction = predict(Theta1, Theta2, X) - 1;
disp([X, prediction]);