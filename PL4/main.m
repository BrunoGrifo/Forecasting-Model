load('seriestemp.dat');
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

N=size(seriestemp,1);

%Verifica outlines |X1 - Mu|>3*sigma
MeanMat1=repmat(mu1,N,1); %repete media (mu) em N linhas
SigmaMat1 = repmat(sigma1,N,1); %repete desvio padrão (sigma) em N linhas
outliers1 = find(abs(x1r - MeanMat1)>3*SigmaMat1); % identifica os outliers
nout1=length(outliers1);  %numero de outliers
outliers1=[];
for i=1:N
    if (abs(x1r(i) - mu1) > 3*sigma1)
        %é outlier
        outliers1=[outliers1, i];
    end
end

MeanMat2=repmat(mu2,N,1); %repete media (mu) em N linhas
SigmaMat2 = repmat(sigma2,N,1); %repete desvio padrão (sigma) em N linhas
outliers2 = find(abs(x2r - MeanMat2)>3*SigmaMat2); % identifica os outliers
nout2=length(outliers2);  %numero de outliers

x1ro=x1r;%substituição do outlier

if nout1
     for k=outliers1
         if x1ro(k)>mu1
             x1ro(k) = mu1 + 2.5*sigma1;
         else
             x1ro = mu1 - 2.5*sigma1;
         end
     end
end


x2ro=x2r;%substituição do outlier

if nout2
     for k=outliers2
         if x2ro(k)>mu2
             x2ro(k) = mu2 + 2.5*sigma2;
         else
             x2ro = mu2 - 2.5*sigma2;
         end
     end
end

