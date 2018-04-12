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
interpResultValues=interp1(valuesIndexNonNan,valuesNotNaN,valuesIndexNan,'splice');

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
             new_values(k) = media + 2.5*desvio;
         else
             new_values = media - 2.5*desvio;
         end
     end
end
figure(2)
subplot(1,2,1)
plot(values)
subplot(1,2,2)
plot(new_values)

%% Materia ficha tp4
figure(3)
Serie_Temporal_Sem_Tendencia=detrend(new_values,'constant');
Tendencia=new_values-Serie_Temporal_Sem_Tendencia;
plot((1:365),new_values,1:365,Tendencia);

figure(4);
%aproximaçõ linear de grau 2
Coeficientes_polinomio=polyfit((1:365)',new_values,2); 
Aproximacao_Linear_grau2=polyval(Coeficientes_polinomio,(1:365)');

sinal=new_values-Aproximacao_Linear_grau2;
plot((1:365),new_values,1:365,sinal,1:365,Aproximacao_Linear_grau2);


