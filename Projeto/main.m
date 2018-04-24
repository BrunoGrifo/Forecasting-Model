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

%Preencher valores em falta com o resultado da interpola��o
values(valuesIndexNan)=interpResultValues;

%Representa��o
figure(1);
plot(values);
ylabel("Consumo de Energia total");
xlabel("Dia");
title("Consumo de energia diaria");

%Media
media=mean(values);
fprintf('Media: %d\n',media);

%Desvio Padr�o
desvio=std(values);
fprintf('Desvio Padr�o: %d\n',desvio);

%Verificar outliers
N=size(values,1);
MeanMat1=repmat(media,N,1); %repete media (mu) em N linhas
SigmaMat1=repmat(desvio,N,1); %repete desvio padr�o em N linhas
outliers = find(abs(values - MeanMat1)>3*SigmaMat1); % identifica os outliers
N_outliers=length(outliers);  %numero de outliers
outliers=[];
for i=1:N
    if (abs(values(i) - media) > 2.5*desvio)
        %� outlier
        outliers=[outliers, i]; %#ok<AGROW>
    end
end

new_values=values;%substitui��o do outlier

if N_outliers
     for k=outliers
         if new_values(k)> media
             new_values(k) = media + 2.2*desvio;
         else
             new_values(k) = media - 2.2*desvio;
         end
     end
end
figure(2)
subplot(1,2,1)
plot(values)
subplot(1,2,2)
plot(new_values)

% Materia ficha tp4
figure(3)
Serie_Temporal_Sem_Tendencia=detrend(new_values,'constant');
Tendencia=new_values-Serie_Temporal_Sem_Tendencia;
plot((1:365),new_values,1:365,Tendencia);

figure(4);
%aproxima�� linear de grau 3
Coeficientes_polinomio=polyfit((1:365)',new_values,3); 
Aproximacao_Linear_grau=polyval(Coeficientes_polinomio,(1:365)');

sinal=new_values-Aproximacao_Linear_grau;
plot((1:365),new_values,1:365,sinal,1:365,Aproximacao_Linear_grau);


%Factores de sazonalidade
FactoresSazonais=[];

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
%{
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
%}
Sinal_sem_FactoresSaz=new_values-FactoresSazonais';
figure(5);
plot(Sinal_sem_FactoresSaz);

figure(5);
Irregularidade=new_values-Aproximacao_Linear_grau-FactoresSazonais';
plot(Irregularidade);
Serie_SemIrregularidade=new_values-Irregularidade;
figure(6);
plot(Serie_SemIrregularidade);

% FICHA 5
%Tirando as tendencias(primeiro grau ou segundo ou terceiro...) a fun��o
%adftest diz-nos que a serie � estacionaria se o resultado for 1

%3.2
h = adftest(new_values); % teste de estacionaridade da s�rie regularizada

%3.3
figure(7);
autocorr(FactoresSazonais);
figure(8);
parcorr(FactoresSazonais);


%3.4
%%{
id_y1= iddata(FactoresSazonais',[],1, 'TimeUnit', 'Days');

 
opt1_AR = arOptions('Approach', 'ls');
na1_AR = 20;  %6
model1_AR = ar(id_y1, na1_AR, opt1_AR);
pcoef1_AR = polydata(model1_AR);
%%}

y1_AR = FactoresSazonais(1:na1_AR);
 
for k=na1_AR+1:21
    y1_AR(k) = sum(-pcoef1_AR(2:end)'.*flip(y1_AR(k-na1_AR:k-1)));
    %Tem que ir buscar os ultimos 6 valores, visto que queremos calcular o
    %setimo valor
end

y1_AR2 = repmat(y1_AR,2,1);
y1_ARf = forecast(model1_AR, FactoresSazonais(1:na1_AR), 24-na1_AR); %Esta funcao tem os novos 18 valores
%Mas vamos ter que juntar os 6 primeiros a estes 18 novos valores, logo
y1_ARf = repmat([y1(1:na1_AR);y1_ARf],2,1);
 
figure(12)
plot(t, x1ro_s, '-+', t, y1_AR2, '-o', t, y1_ARf, '-*')
xlabel('t[h]');
