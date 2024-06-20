function sigma_plot

sigma_forrester = [40
26.6
20
13
9.5
7.3
5.5
4.3
3.3
2.1
0.1];

CNR_forrester = [0.5058
0.7595
1.0059
1.5203
2.0177
2.5076
3.0723
3.5479
3.9907
4.5026
4.8400];

subplot(3,1,1)
plot(sigma_forrester, CNR_forrester)
ylabel('Contrast-to-Noise Ratio');
xlabel('Sigma Values')
title('Forrester')

CNR_goldstein_price = [3.8001
3.8052
3.7981
3.7210
3.4823
2.9998
2.5339
1.95443
1.5072
1.0590
0.4926];

sigma_goldstein_price = [50
35
15
100
170
275
380
550
750
1100
2400];

subplot(3,1,2)
plot(sigma_goldstein_price, CNR_goldstein_price)
ylabel('Contrast-to-Noise Ratio');
xlabel('Sigma Values')
title('Goldstein Price')

CNR_hartmann = [0.1454
0.4924
1.0128
1.5233
1.9849
2.4935
2.9619
3.3474];

sigma_hartmann = [11.5
3.3
1.5
0.9
0.6
0.37
0.19
0.0001];

subplot(3,1,3)
plot(sigma_hartmann, CNR_hartmann)
ylabel('Contrast-to-Noise Ratio');
xlabel('Sigma Values')
title('Hartmann')

end 