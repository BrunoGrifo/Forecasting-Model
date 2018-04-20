function [value] = entrada_novo(n)
    value=1.5*sin(0.025*pi*n)*(unitaryStep(n+40)-unitaryStep(n-40));
end

function [y] = unitaryStep(n)
    if(n<0)
        y=0;
    else
        y=1;
    end
end