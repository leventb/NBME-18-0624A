function x = linInterp(x1,x2,fx1,fx2,y)
x=x1+(y-fx1).*(x2-x1)./(fx2-fx1);
    