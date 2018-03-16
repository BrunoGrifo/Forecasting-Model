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
