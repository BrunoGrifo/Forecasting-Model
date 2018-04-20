%%1.1
n=[-50:50]; %vetor de indices de tempo para determinar a 
xn=x4tp(n); %funcao que fedine o sinal x[n]
yn=0.1*atrasa(xn,1)+0.7*atrasa(xn,2)+0.2*atrasa(xn,3);
figure;
plot(n,xn);
hold on
plot(n,yn);
xlabel('n');
title('Resposta do sistema ao sinal sem ruido');
legend('x[n]','y[n]');
%%
r=(rand(1,numel(xn)).*0.4)-0.2; %Gerar ruido
xnr=xn+r;
ynr=0.1*atrasa(xnr,1)+0.7*atrasa(xnr,2)+0.2*atrasa(xnr,3);
figure;
plot(n,xn,n,xnr);
hold on
plot(n,yn,n,ynr);
xlabel('n');
title('Resposta do sistema ao sinal com e sem tuido');
legend('x[n]','x[n] com ruido','y[n]','y[n] com ruido');


%% Exercicio 2

%y1[n]
figure;
subplot(4,1,1);plot(n,xn,n,yn);
xlabel('n');
title('y1');
legend('x[n]','y1[n]');

%y2[n]
y2n=0.5*(atrasa(xn,2)).^2;
subplot(4,1,2); plot(n,xn,n,y2n);
xlabel('n');
title('y2');
legend('x[n]','y2[n]');

%y3[n]
x2n3=x(2*n-3);
y3n=0.4.*x2n3; %atrasa(x2n,3)
subplot(4,1,3); plot(n,xn,n,y3n);
xlabel('n');
title('y3');
legend('x[n]','y3[n]');
%y4[n]
y4n=(n-1).*atrasa(xn,2);
subplot(4,1,4); plot(n,xn,n,y4n);
label('n');
title('y4');
legend('x[n]','y4[n]');

%% Testar linearidade

%y4

y4n1=(n-1).*atrasa(x1n,2);
y4n2=(n-1).*atrasa(x2n,2);

y4c=a*y4n1+b*y4n2; %Linear combination of the independen

xc = a*x1n+b*x2n; %Linear combination of the inputs

y4xc = (n-1).*atrasa(xc,2);
%output originated by the linear combination of the input
