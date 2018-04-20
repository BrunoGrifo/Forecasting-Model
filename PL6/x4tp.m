function sig=x4tp(n)
ix=union(find(n<-40),find(n>40));
sig=2*sin(0.02*pi*n);
sig(ix)=0;
end