b0=0.1*(mod(6,2)+1);
b1=0.4*mod(6,2);
b2=0.4*mod(1+6,2);
b3=0.3*(mod(6,3)+1);
b4=-0.1*(mod(6,4)+1);

b=[b0 b1 b2 b3 b4];

n=-50:49;

y=zeros(size(n));
x=zeros(size(n));

for i=1:length(y)
    ruido=-0.2 + 0.4*rand();
    x(i)=entrada_novo(n(i));% + ruido;
    y(i)=b0*(entrada_novo(n(i))+ruido) + b1*(entrada_novo(n(i)-1)+ruido) + b2*(entrada_novo(n(i)-2)+ruido) + b3*(entrada_novo(n(i)-3)+ruido) + b4*(entrada_novo(n(i)-4)+ruido);
end

figure(1);
plot(n,x,n,y);
xlabel('n');
ylabel('Entrada/Resposta do sistema');
title('Resposta do sistema ao sinal sem ruído');
legend('Entrada x[n]','Saída y[n]');


%2.5 e 2.6
yh1 = conv(b,x);
yh1=yh1(1:end-length(b)+1);

figure(2);
plot(n,y,n,yh1,'o');
title('Resposta ao sistema y1 com base em h[n]*x[n]');
xlabel('n');