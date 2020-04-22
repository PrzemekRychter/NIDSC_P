


d = Symulator();
z = d.simulate(); %31 26
X4 = z(1,1:size(z,2));
Y4 = z(2,1:size(z,2));
figure(10);

hold on

plot(X4,Y4);
