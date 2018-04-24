load('seriestemp.dat');
%%
nan1=find(isnan(seriestemp(:,1)));
notnan1=find(~isnan(seriestemp(:,1)));
nan2=find(isnan(seriestemp(:,2)));
notnan2=find(~isnan(seriestemp(:,2)));
first=interp1(find(~isnan(seriestemp(:,1))),seriestemp(notnan1,1),nan1);
second=interp1(find(~isnan(seriestemp(:,2))),seriestemp(notnan2,2),nan2);
seriestemp(nan1,1)=first;
seriestemp(nan2,2)=second;

mu1=mean(seriestemp(:,1));
sigma1=std(seriestemp(:,1));

mu2=mean(seriestemp(:,2));
sigma2=std(seriestemp(:,2));

x1r=seriestemp(:,1);
x2r=seriestemp(:,2);

N=size(seriestemp,1);

%Verifica outlines |X1 - Mu|>3*sigma
MeanMat1=repmat(mu1,N,1); %repete media (mu) em N linhas
SigmaMat1 = repmat(sigma1,N,1); %repete desvio padr�o (sigma) em N linhas
outliers1 = find(abs(x1r - MeanMat1)>3*SigmaMat1); % identifica os outliers
nout1=length(outliers1);  %numero de outliers
outliers1=[];
for i=1:N
    if (abs(x1r(i) - mu1) > 3*sigma1)
        %� outlier
        outliers1=[outliers1, i];
    end
end

MeanMat2=repmat(mu2,N,1); %repete media (mu) em N linhas
SigmaMat2 = repmat(sigma2,N,1); %repete desvio padr�o (sigma) em N linhas
outliers2 = find(abs(x2r - MeanMat2)>3*SigmaMat2); % identifica os outliers
nout2=length(outliers2);  %numero de outliers

x1ro=x1r;%substitui��o do outlier

if nout1
     for k=outliers1
         if x1ro(k)>mu1
             x1ro(k) = mu1 + 2.5*sigma1;
         else
             x1ro = mu1 - 2.5*sigma1;
         end
     end
end


x2ro=x2r;%substitui��o do outlier

if nout2
     for k=outliers2
         if x2ro(k)>mu2
             x2ro(k) = mu2 + 2.5*sigma2;
         else
             x2ro = mu2 - 2.5*sigma2;
         end
     end
end
%%
%1.2 & 1.3 & 1.4
figure(1);
Serie_Temporal_Sem_Tendencia=detrend(x1ro,'constant');
x1ro_nova=x1ro-Serie_Temporal_Sem_Tendencia;
plot((1:48),x1ro,1:48,x1ro_nova);

%%
%1.5 & 1.6 & 1.7
figure(2);
%aproxima�� linear de grau 2
Coeficientes_polinomio=polyfit((1:48)',x1ro,2); 
Aproximacao_Linear_grau2=polyval(Coeficientes_polinomio,1:48);


x2ro_nova1=x1ro-Aproximacao_Linear_grau2';
plot((1:48),x1ro,1:48,x2ro_nova1,1:48,Aproximacao_Linear_grau2);
legend('Serie temporal 1','ST sem tendencia de grau2','Aproximacao_Linear_grau2');
%%
%exercicio 1.8 & 1.9 & 1.10
%Calcular factores de sazonalidade
FactoresSazonais=[];
%figure(3);
for i=1:24
    factor=(x2ro_nova1(i)+x2ro_nova1(i+24))/2;
    FactoresSazonais=[FactoresSazonais factor];  %#ok<AGROW>
end
FactoresSazonais=[FactoresSazonais FactoresSazonais];
%plot(FactoresSazonais);
ST_SemFactoresSaz=x1ro-FactoresSazonais';
figure(4);
plot(ST_SemFactoresSaz);

%%
%Resto da ficha
figure(5);
Irregularidade=x1ro-Aproximacao_Linear_grau2'-FactoresSazonais';
plot(Irregularidade);
Serie_SemIrregularidade=x1ro-Irregularidade;
figure(6);
plot(Serie_SemIrregularidade);
%% FICHA 5
%Tirando as tendencias(primeiro grau ou segundo ou terceiro...) a fun��o
%adftest diz-nos que a serie � estacionaria se o resultado for 1
h = adftest(x1ro); % teste de estacionaridade da s�rie regularizada

%% 1.2
figure(7);
autocorr(FactoresSazonais');
figure(8);
parcorr(FactoresSazonais');

%% 1.3
y1=FactoresSazonais(1:24)';
data = iddata(y1,[],3600);

opt1_AR= arOptions('Approach','ls'); %op�oes modelo AR
nal_AR = 6; %historico da variavel
model1_AR=ar(data,nal_AR,opt1_AR); %modelo ar
pcoef1_AR= polydata(model1_AR); %parametros do modelo ar

%1.6
%simula��o do modelo ar (estimar componente sazonal)
%y(t) + a1*y(t-1) a a2*y(t-2) +...+ aN*y(t-N)
%Logo os primeiros N elementos N�o sao alterados

y1_AR = y1(1:nal_AR);
for k = nal_AR+1:24
    y1_AR(k)=sum(-pcoef1_AR(2:end)'.* flip(y1_AR(k-nal_AR:k-1)));
end

y1_AR2 = repmat (y1_AR,2,1);
%Componente sazonal - obter primeiros 24 valores e depois duplicar

%simula��o do Modelo AR vom forcast
y1_ARf= forecast(model1_AR,y1(1:nal_AR),24-nal_AR);
y1_ARf2=repmat([y1(1:nal_AR); y1_ARf],2,1); % repete a simula��o

%Metrica para analise: Comparar o sinal original com 'Modelo AR+tendencia'
%calculo do erro da simula��o
E1_AR = sum((y1 - y1_AR2(1:24)).^2)
E1_AR = sum((x1ro - (y1_AR2+Aproximacao_Linear_grau2')).^2)
E1_AR = sum((x1ro - (y1_AR2+Aproximacao_Linear_grau2'+Irregularidade)).^2)
%E1_AR=sum((x1ro - (y1_AR2 + tr1_2 + irregularidade)).^)
figure(9);
plot(y1_ARf);






Aproximacao_Linear_grau=[];
T=365;
for i=1:365
    result=90*cos((2*pi)/365 * i)+ Tendencia(i);
    Aproximacao_Linear_grau=[Aproximacao_Linear_grau; result]; %#ok<AGROW>
end
sinal=new_values-Aproximacao_Linear_grau;
plot((1:365),new_values,1:365,sinal,1:365,Aproximacao_Linear_grau);




Coeficientes_polinomio=polyfit((1:365)',new_values,3); 
Aproximacao_Linear_grau=polyval(Coeficientes_polinomio,(1:365)');

sinal=new_values-Aproximacao_Linear_grau;
plot((1:365),new_values,1:365,sinal,1:365,Aproximacao_Linear_grau);

