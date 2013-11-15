%% Helper Function for nonlinear curvefit to FXLAIF model, no vp
function x = FXLStep1AIFhelper(xdata, voxel)
warning off
Ct = xdata{1}.Ct;
i  = voxel;
Ct = Ct(:,i);

t = xdata{1}.timer;
xdata{1}.timer = t(:);


%configure the optimset for use with lsqcurvefit
options = optimset('lsqcurvefit');

%increase the number of function evaluations for more accuracy
options.MaxFunEvals = 50;
options.MaxIter     = 50;
options.TolFun      = 10^(-8);
options.TolX        = 10^(-4);
options.Diagnostics = 'off';
options.Display     = 'off';
options.Algorithm   = 'levenberg-marquardt';

lb = [0 0];
ub = [5 1];
% tic
[x,resnorm,residual,exitflag,output,lambda,jacobian] = lsqcurvefit(@FXLStep1AIF, ...
    [0.005 0.05], xdata, ...
    Ct',lb,ub,options);

x(end+1) = resnorm;
x(end+1) = 1;

% Use Curvefitting tool box
% options = fitoptions('Method', 'NonlinearLeastSquares', 'Algorithm', 'Levenberg-Marquardt', 'MaxIter', 300, 'MaxFunEvals', 300, 'TolFun', 1e-8, 'TolX', 1e-4, 'Display', 'off', 'Lower',[0 0], 'Upper', [5 1], 'StartPoint', [0.005 0.05]);
% ft = fittype('FXLStep1AIFcfit( Ktrans, ve, Cp, T1)', 'independent', {'T1', 'Cp'}, 'coefficients',{'Ktrans', 've'});
% [f gof] = fit([xdata{1}.timer, xdata{1}.Cp],Ct,ft, options);
% toc
% 
% %Calculate the R2 fit
% x(1) = f.Ktrans;
% x(2) = f.ve;
% x(end+1) = gof.rsquare;
% x(end+1) = gof.adjrsquare;
