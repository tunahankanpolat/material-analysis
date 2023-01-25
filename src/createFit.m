function [fitresult, gof] = createFit(V, P)
%CREATEFIT(V,P)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input: V
%      Y Output: P
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 27-Sep-2022 23:03:29


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( V, P );

% Set up fittype and options.
ft = fittype( '2*s*log(3)+(((2*k)/(3*n))*((sin(45)*(1+cos(45)))^n)*(((2*x)/12.8)^n)*(1-(12.8/38.4)^(3*n)))', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Algorithm = 'Levenberg-Marquardt';
opts.Display = 'Off';
opts.Robust = 'LAR';
opts.StartPoint = [0.0758542895630636 0.0539501186666071 0.530797553008973];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
figure( 'Name', 'untitled fit 1' );
h = plot( fitresult, xData, yData );
legend( h, 'P vs. V', 'untitled fit 1', 'Location', 'NorthEast', 'Interpreter', 'none' );
% Label axes
xlabel( 'V', 'Interpreter', 'none' );
ylabel( 'P', 'Interpreter', 'none' );
grid on


