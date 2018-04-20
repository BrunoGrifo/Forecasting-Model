b3=0.3;
b4 = -0.18;
a1 = -1.5;
a2 = 0.56;
a = [1 a1 a2 0 0];
b = [0 0 0 b3 b4];
syms z;
disp('Função de transferencia G(z):');
Gz= (b3*z^(-3) + b4*z^(-4))/(1+a1*z^(-1) + a2*z^(-2));
pretty(Gz);

%1.2
disp('zeros');
zGz = roots(b);
disp('polos');
pGz = roots(a);

figure(1);
zplane(b,a);
%É estavel de os polos estiverem dentro do circulo

%1.3
if all(abs(pGz) <1)
    disp('O sistema é estavel');
else
    disp('Instavel');
end