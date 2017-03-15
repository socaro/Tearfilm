function PlaceThresholdBars( FigNum, FigR, FigCol, SubPlotNum, lowThresh, highThresh, fontSize, maxY)
% Function to show the low and high threshold bars on the histogram plots.
% Show the lower threshold as green number and upper threshold as red number on the histograms.
% FigNum - figure number
% FigR - number of rows of figurs in subplots
% FigCol - number of collumnst of figures in subplots
% SubPlotNum - subplot number 
% ------------------------------
% 24.2.2014
% Laboratory of Biomechanics, Czech Technical University in Prague, Czech Republic
% Michala.Cadova@fs.cvut.cz
% Dental Clinic, University of Zurich, Switzerland
% Michala.Cadova@zzm.uzh.ch
% ------------------------------

figure(FigNum)
  subplot(FigR, FigCol, SubPlotNum); 
	hold on;
	maxYValue = ylim;
	maxXValue = xlim;
    T1 = text(lowThresh,1/2*maxY, num2str(lowThresh));
    T2 = text(highThresh,3/4*maxY,num2str(highThresh));
    set(T1, 'color', 'green', 'fontsize', fontSize);
    set(T2, 'color', 'red', 'fontsize', fontSize);
