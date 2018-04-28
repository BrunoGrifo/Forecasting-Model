%Carregar dados em memoria
filename='dataset_ATD_PL6.csv';
file=readtable(filename);

%Separar os valores da tabelas em arrays
dates=table2array(file(:,1));
values=table2array(file(:,2));

%Determinar os indexes dos values Nan e notNan para interpolar os valores
valuesNotNaN=values(~isnan(values));
valuesIndexNonNan=find(~isnan(values));
valuesIndexNan=find(isnan(values));
interpResultValues=interp1(valuesIndexNonNan,valuesNotNaN,valuesIndexNan,'spline');

%Preencher valores em falta com o resultado da interpolação
values(valuesIndexNan)=interpResultValues;

%Representação
figure(1);
plot(values);
ylabel("Consumo de Energia total");
xlabel("Dia");
title("Consumo de energia diaria");

%Media
media=mean(values);
fprintf('Media: %d\n',media);

%Desvio Padrão
desvio=std(values);
fprintf('Desvio Padrão: %d\n',desvio);

%Verificar outliers
N=size(values,1);
MeanMat1=repmat(media,N,1); %repete media (mu) em N linhas
SigmaMat1=repmat(desvio,N,1); %repete desvio padrão em N linhas
outliers = find(abs(values - MeanMat1)>3*SigmaMat1); % identifica os outliers
N_outliers=length(outliers);  %numero de outliers
outliers=[];
for i=1:N
    if (abs(values(i) - media) > 3*desvio)
        %é outlier
        outliers=[outliers, i]; %#ok<AGROW>
    end
end

new_values=values;%substituição do outlier

if N_outliers
     for k=outliers
         if new_values(k)> media
             new_values(k) = media + 2.6*desvio;
         else
             new_values(k) = media - 2.6*desvio;
         end
     end
end
figure(2)
subplot(1,2,1)
plot(values)
ylabel("Consumo de Energia total");
xlabel("Dia");
title("Serie temporal Sem outliers");
subplot(1,2,2)
plot(new_values)
ylabel("Consumo de Energia total");
xlabel("Dia");
title("Serie temporal com outliers");

% Materia ficha tp4
figure(3)
Serie_Temporal_Sem_Tendencia=detrend(new_values,'constant');
Tendencia=new_values-Serie_Temporal_Sem_Tendencia;
plot((1:365),new_values,1:365,Tendencia);
xlabel('t[n]');

figure(4);
%aproximaçõ linear de grau 3
Coeficientes_polinomio=polyfit((1:365)',new_values,3); 
Aproximacao_Linear_grau=polyval(Coeficientes_polinomio,(1:365)');

sinal=new_values-Aproximacao_Linear_grau;
plot((1:365),new_values,1:365,sinal,1:365,Aproximacao_Linear_grau);
xlabel('t[n]');
legend({'Sinal Original (sem outliers)','Sinal sem Tendencia (sem outliers)','Tendencia'},'Location','southwest');
legend('boxoff')

%Factores de sazonalidade
FactoresSazonais=[];

%{
for i=1:31
    if i<=28
        factor=(sinal(i)+sinal(i+31)+sinal(i+31+28)+sinal(i+31+28+31)+sinal(i+31+28+31+30)+sinal(i+31+28+31+30+31)+sinal(i+31+28+31+30+31+30)+sinal(i+31+28+31+30+31+30+31)+sinal(i+31+28+31+30+31+30+31+31)+sinal(i+31+28+31+30+31+30+31+31+30)+sinal(i+31+28+31+30+31+30+31+31+30+31)+sinal(i+31+28+31+30+31+30+31+31+30+31+30))/12;
    end
    if (i>28) && (i<=30)
        factor=(sinal(i)+sinal(i+31+28)+sinal(i+31+28+31)+sinal(i+31+28+31+30)+sinal(i+31+28+31+30+31)+sinal(i+31+28+31+30+31+30)+sinal(i+31+28+31+30+31+30+31)+sinal(i+31+28+31+30+31+30+31+31)+sinal(i+31+28+31+30+31+30+31+31+30)+sinal(i+31+28+31+30+31+30+31+31+30+31)+sinal(i+31+28+31+30+31+30+31+31+30+31+30))/11;
    end
    if i>30
       factor=(sinal(i)+sinal(i+31+28)+sinal(i+31+28+31+30)+sinal(i+31+28+31+30+31+30)+sinal(i+31+28+31+30+31+30+31+31+30)+sinal(i+31+28+31+30+31+30+31+31+30+31+30))/6;
    end
    
    FactoresSazonais=[FactoresSazonais factor];  %#ok<AGROW>
end
FactoresSazonais = [FactoresSazonais(1:31) FactoresSazonais(1:28) FactoresSazonais(1:31) FactoresSazonais(1:30) FactoresSazonais(1:31) FactoresSazonais(1:30) FactoresSazonais(1:31) FactoresSazonais(1:31) FactoresSazonais(1:30) FactoresSazonais(1:31) FactoresSazonais(1:30) FactoresSazonais(1:31)];
%}



for i=1:92
    if i<=90
        factor=(sinal(i)+sinal(i+90)+sinal(i+90+91)+sinal(i+90+91+92))/4;
    end
    if i==91
        factor=(sinal(i+90)+sinal(i+90+91)+sinal(i+90+91+92))/3;
    end
    if i==92
        factor=(sinal(i+90+91)+sinal(i+90+91+92))/3;
    end
    FactoresSazonais=[FactoresSazonais factor]; %#ok<AGROW>
end
FactoresSazonais = [FactoresSazonais(1:90) FactoresSazonais(1:91) FactoresSazonais(1:92) FactoresSazonais(1:92)];

Sinal_sem_FactoresSaz=new_values-FactoresSazonais';
figure(5);
plot(Sinal_sem_FactoresSaz);
xlabel("Dia");
legend({'Sinal sem componente de sazonal'},'Location','northwest');
legend('boxoff')
title("Serie temporal sem Factores de Sazonalidade (Trimestral)");


figure(6);
Irregularidade=new_values-Aproximacao_Linear_grau-FactoresSazonais';
plot(Irregularidade);
xlabel("Dia");
legend({'Irregularidade'},'Location','southwest');
legend('boxoff')
title("Irregularidade do Sinal");

Serie_SemIrregularidade=new_values-Irregularidade;
figure(7);
plot(Serie_SemIrregularidade);
xlabel("Dia");
legend({'Sinal sem componente de irregularidade'},'Location','northwest');
legend('boxoff')
title("Serie temporal sem Irregularidade");


% FICHA 5
%Tirando as tendencias(primeiro grau ou segundo ou terceiro...) a função
%adftest diz-nos que a serie é estacionaria se o resultado for 1

%3.2
h = adftest(new_values); % teste de estacionaridade da série regularizada

%3.3
figure(8);

autocorr(FactoresSazonais);
figure(9)
parcorr(FactoresSazonais);


%3.4

id_y1= iddata(FactoresSazonais',[],1, 'TimeUnit', 'Days');

 
opt1_AR = arOptions('Approach', 'ls');
na1_AR =20;  %6
model1_AR = ar(id_y1, na1_AR, opt1_AR);
pcoef1_AR = polydata(model1_AR);


y1_AR = FactoresSazonais(1:na1_AR)';
 
for k=na1_AR+1:30
    disp(y1_AR(k-na1_AR:k-1));
    y1_AR(k) = sum(-pcoef1_AR(2:end)'.*flip(y1_AR(k-na1_AR:k-1)));
    %Tem que ir buscar os ultimos 6 valores, visto que queremos calcular o
    %setimo valor
end

y1_AR2 = repmat(y1_AR,12,1);
y1_AR2= [y1_AR2; y1_AR2(1:5)];
y1_ARf = forecast(model1_AR, FactoresSazonais(1:na1_AR)', 30-na1_AR); %Esta funcao tem os novos 18 valores
%Mas vamos ter que juntar os 6 primeiros a estes 18 novos valores, logo
y1_ARf = repmat([FactoresSazonais(1:na1_AR)';y1_ARf],12,1);
y1_ARf= [y1_ARf; y1_ARf(1:5)];
y1_AR2=y1_AR2+Aproximacao_Linear_grau;
y1_ARf=y1_ARf+Aproximacao_Linear_grau;
 
figure(12)
plot(1:365, y1_AR2, '-o', 1:365, y1_ARf, '-*')
ylabel("Consumo de Energia total");
xlabel("Dia");
title("Modelo AR - Previsão do consumo de energia");
legend({'repmat','forecast'},'Location','northwest');
legend('boxoff')
y1_AR = FactoresSazonais(1:na1_AR)';

disp("Erros");
E1_AR = sum((FactoresSazonais - y1_AR2(1:365)').^2)
E1_AR1 = sum((new_values - (y1_AR2+Aproximacao_Linear_grau)).^2)
%E1_AR2 = sum((new_values - (y1_AR2+Aproximacao_Linear_grau+Irregularidade)).^2) 

%{
for k=na1_AR+1:91
    disp(y1_AR(k-na1_AR:k-1));
    y1_AR(k) = sum(-pcoef1_AR(2:end)'.*flip(y1_AR(k-na1_AR:k-1)));
    %Tem que ir buscar os ultimos 6 valores, visto que queremos calcular o
    %setimo valor
end

y1_AR2 = repmat(y1_AR,4,1);
y1_AR2= [y1_AR2; y1_AR2(1)];
y1_ARf = forecast(model1_AR, FactoresSazonais(1:na1_AR)', 91-na1_AR); %Esta funcao tem os novos 18 valores
%Mas vamos ter que juntar os 6 primeiros a estes 18 novos valores, logo
y1_ARf = repmat([FactoresSazonais(1:na1_AR)';y1_ARf],4,1);
y1_ARf= [y1_ARf; y1_ARf(1)];
y1_AR2=y1_AR2+Aproximacao_Linear_grau;
y1_ARf=y1_ARf+Tendencia;
 
figure(12)
plot(1:365, y1_AR2, '-o', 1:365, y1_ARf, '-*')
xlabel('t[h]');

%}
t=1:365;
opt1_ARMAX = armaxOptions('SearchMethod', 'auto');
na1_ARMA = 20;
nc1_ARMA = 10;
model1_ARMA = armax(id_y1,[na1_ARMA nc1_ARMA],opt1_ARMAX);
[pa1_ARMA, pb1_ARMA, pc1_ARMA] = polydata(model1_ARMA);
 
e = randn(30,1);
y1_ARMA = FactoresSazonais(1:na1_ARMA)';
 
for k=na1_ARMA+1:30
    y1_ARMA(k) = sum(-pa1_ARMA(2:end)'.*flip(y1_ARMA(k-na1_ARMA:k-1)))+sum(pc1_ARMA'.*flip(e(k-nc1_ARMA:k)));
end
 
y1_ARMA2 = repmat(y1_ARMA,12,1);
y1_ARMA2= [y1_ARMA2; y1_ARMA2(1:5)];
y1_ARMAf = forecast((model1_ARMA),FactoresSazonais(1:na1_ARMA)', 30-na1_ARMA);
y1_ARMAf2 = repmat([FactoresSazonais(1:na1_ARMA)';y1_ARMAf],12,1);
y1_ARMAf2= [y1_ARMAf2; y1_ARMAf2(1:5)];
y1_ARMA2=y1_ARMA2+Aproximacao_Linear_grau;
y1_ARMAf2=y1_ARMAf2+Aproximacao_Linear_grau;
 
figure(14)
plot(t, y1_ARMA2,'-o', t,y1_ARMAf2,'-*')
ylabel("Consumo de Energia total");
xlabel("Dia");
title("Modelo ARMA - Previsão do consumo de energia");
legend({'repmat','forecast'},'Location','northwest');
legend('boxoff')

disp("Erros AMRA");
E1_ARMA = sum((FactoresSazonais - y1_ARMA2(1:365)').^2)
E1_ARMA1 = sum((new_values - (y1_ARMA2+Aproximacao_Linear_grau)).^2)
%E1_ARMA2 = sum((new_values - (y1_ARMA2+Aproximacao_Linear_grau+Irregularidade)).^2)
disp("forecast");
E1_ARMAf = sum((FactoresSazonais - y1_ARMAf2(1:365)').^2)
E1_ARMAf1 = sum((new_values - (y1_ARMAf2+Aproximacao_Linear_grau)).^2)
%E1_ARMAf2 = sum((new_values - (y1_ARMAf2+Aproximacao_Linear_grau+Irregularidade)).^2)

%% 
%ARIMA
%y1_ARIMAFinal=zeros(1,365)';
p1_ARIMA = 20;
d1_ARIMA =1;
q1_ARIMA = 3;
    Md1 = arima(p1_ARIMA, d1_ARIMA, q1_ARIMA);
    EstMd1 = estimate(Md1, sinal,'Y0', sinal(1:p1_ARIMA+1));
    y1_ARIMA = + simulate(EstMd1,365); %faz integracao de modo a aproximar se com a serie original
for ciclo=1:9
    Md1 = arima(p1_ARIMA, d1_ARIMA, q1_ARIMA);
    EstMd1 = estimate(Md1, sinal,'Y0', sinal(1:p1_ARIMA+1));
    y1_ARIMA = y1_ARIMA + simulate(EstMd1,365); %faz integracao de modo a aproximar se com a serie original
    %y1_ARIMAFinal=y1_ARIMAFinal+y1_ARIMA;
end
y1_ARIMA=y1_ARIMA/10;
y1_ARIMA= y1_ARIMA+Aproximacao_Linear_grau;
arimaerror=0;
arimaerror = sum((new_values - (y1_ARIMA)).^2)


 
figure(15);
plot(t,new_values,'-+', t , y1_ARIMA, '-o');
ylabel("Consumo de Energia total");
xlabel("Dia");
title("Modelo ARIMA - Previsão do consumo de energia");
legend({'Sinal Original (sem outliers)','Previsão '},'Location','northwest');
legend('boxoff')