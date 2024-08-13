clear; clc;

coeff = [0.95 0.99 0.65];
for i = 1:length(coeff)
    b = [1 -coeff(i)];
    [h,w] = freqz(b,1,1000);
    fig = figure();
    plot(w/pi,db(h));
    title('Frequency Response (coefficient = ' + string(coeff(i)) + ')');
    xlabel('Normalized Frequency (\times\pi rad/sample)')
    ylabel('Magnitude (dB)')
    grid on;
    saveas(fig, string(coeff(i)) + '.jpg');
end
