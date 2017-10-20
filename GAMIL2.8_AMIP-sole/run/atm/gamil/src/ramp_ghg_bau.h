! Declarations

      integer ntim
      parameter(ntim=231)
      integer yrdata(ntim)      ! yearly data values
      real(r8)    co2(ntim)         ! input co2   in ppmv (bau)
      real(r8)    ch4(ntim)         ! input ch4   in ppbv
      real(r8)    n2o(ntim)         ! input n2o   in ppbv 
      real(r8)    f11(ntim)         ! input cfc11 in pptv
      real(r8)    f12(ntim)         ! input cfc12 in pptv
      real(r8)    adj(ntim)         ! input adjustment factor for f11 and f12

! Ouput type declaration

      character*64, parameter :: ramp_type = &
                       'RAMP_GHG: using ramp_bau_ghg data'
      logical :: ramp_write
      data ramp_write / .true. /

! Input data values

      data yrdata / &
           1870  ,1871  ,1872  ,1873  ,1874  , &
           1875  ,1876  ,1877  ,1878  ,1879  , &
           1880  ,1881  ,1882  ,1883  ,1884  , &
           1885  ,1886  ,1887  ,1888  ,1889  , &
           1890  ,1891  ,1892  ,1893  ,1894  , &
           1895  ,1896  ,1897  ,1898  ,1899  , &
           1900  ,1901  ,1902  ,1903  ,1904  , &
           1905  ,1906  ,1907  ,1908  ,1909  , &
           1910  ,1911  ,1912  ,1913  ,1914  , &
           1915  ,1916  ,1917  ,1918  ,1919  , &
           1920  ,1921  ,1922  ,1923  ,1924  , &
           1925  ,1926  ,1927  ,1928  ,1929  , &
           1930  ,1931  ,1932  ,1933  ,1934  , &
           1935  ,1936  ,1937  ,1938  ,1939  , &
           1940  ,1941  ,1942  ,1943  ,1944  , &
           1945  ,1946  ,1947  ,1948  ,1949  , &
           1950  ,1951  ,1952  ,1953  ,1954  , &
           1955  ,1956  ,1957  ,1958  ,1959  , &
           1960  ,1961  ,1962  ,1963  ,1964  , &
           1965  ,1966  ,1967  ,1968  ,1969  , &
           1970  ,1971  ,1972  ,1973  ,1974  , &
           1975  ,1976  ,1977  ,1978  ,1979  , &
           1980  ,1981  ,1982  ,1983  ,1984  , &
           1985  ,1986  ,1987  ,1988  ,1989  , &
           1990  ,1991  ,1992  ,1993  ,1994  , &
           1995  ,1996  ,1997  ,1998  ,1999  , &
           2000  ,2001  ,2002  ,2003  ,2004  , &
           2005  ,2006  ,2007  ,2008  ,2009  , &
           2010  ,2011  ,2012  ,2013  ,2014  , &
           2015  ,2016  ,2017  ,2018  ,2019  , &
           2020  ,2021  ,2022  ,2023  ,2024  , &
           2025  ,2026  ,2027  ,2028  ,2029  , &
           2030  ,2031  ,2032  ,2033  ,2034  , &
           2035  ,2036  ,2037  ,2038  ,2039  , &
           2040  ,2041  ,2042  ,2043  ,2044  , &
           2045  ,2046  ,2047  ,2048  ,2049  , &
           2050  ,2051  ,2052  ,2053  ,2054  , &
           2055  ,2056  ,2057  ,2058  ,2059  , &
           2060  ,2061  ,2062  ,2063  ,2064  , &
           2065  ,2066  ,2067  ,2068  ,2069  , &
           2070  ,2071  ,2072  ,2073  ,2074  , &
           2075  ,2076  ,2077  ,2078  ,2079  , &
           2080  ,2081  ,2082  ,2083  ,2084  , &
           2085  ,2086  ,2087  ,2088  ,2089  , &
           2090  ,2091  ,2092  ,2093  ,2094  , &
           2095  ,2096  ,2097  ,2098  ,2099  , &
           2100/                              
!
! data co2bau is the default co2 mixing ratios
! for business as usual scenario 
!
       data co2 /  &          !BAU ppmv
       289.263, 289.416, 289.577, 289.745, 289.919, &
       290.102, 290.293, 290.491, 290.696, 290.909, &
       291.129, 291.355, 291.587, 291.824, 292.066, &
       292.313, 292.563, 292.815, 293.071, 293.328, &
       293.586, 293.843, 294.098, 294.350, 294.598, &
       294.842, 295.082, 295.320, 295.558, 295.797, &
       296.038, 296.284, 296.535, 296.794, 297.062, &
       297.338, 297.620, 297.910, 298.204, 298.504, &
       298.806, 299.111, 299.419, 299.729, 300.040, &
       300.352, 300.666, 300.980, 301.294, 301.608, &
       301.923, 302.237, 302.551, 302.863, 303.172, &
       303.478, 303.779, 304.075, 304.366, 304.651, &
       304.930, 305.206, 305.478, 305.746, 306.013, &
       306.280, 306.546, 306.815, 307.087, 307.365, &
       307.650, 307.943, 308.246, 308.560, 308.887, &
       309.228, 309.584, 309.956, 310.344, 310.749, &
       311.172, 311.614, 312.077, 312.561, 313.068, &
       313.599, 314.154, 314.737, 315.347, 315.984, &
       316.646, 317.328, 318.026, 318.742, 319.489, &
       320.282, 321.133, 322.045, 323.021, 324.060, &
       325.155, 326.299, 327.484, 328.698, 329.933, &
       331.194, 332.499, 333.854, 335.254, 336.690, &
       338.150, 339.628, 341.125, 342.650, 344.206, &
       345.797, 347.397, 348.980, 350.551, 352.100, &
       353.636, 355.197, 356.755, 358.286, 359.850, &
       361.499, 363.231, 365.026, 366.880, 368.792, &
       370.763, 372.759, 374.753, 376.750, 378.751, &
       380.759, 382.788, 384.852, 386.947, 389.076, &
       391.237, 393.441, 395.696, 398.001, 400.357, &
       402.761, 406.186, 408.635, 411.112, 413.616, &
       416.147, 418.703, 421.281, 423.883, 426.507, &
       429.154, 431.823, 434.514, 437.226, 439.961, &
       442.717, 445.496, 448.297, 451.122, 453.969, &
       456.839, 459.745, 462.697, 465.695, 468.739, &
       471.827, 474.960, 478.138, 481.361, 484.630, &
       487.946, 491.308, 494.716, 498.172, 501.675, &
       505.226, 508.812, 512.425, 516.065, 519.735, &
       523.434, 527.163, 530.922, 534.712, 538.534, &
       542.388, 546.273, 550.191, 554.142, 558.126, &
       562.144, 566.179, 570.217, 574.260, 578.309, &
       582.365, 586.429, 590.502, 594.584, 598.676, &
       602.779, 606.896, 611.033, 615.189, 619.364, &
       623.558, 627.769, 631.993, 636.231, 640.484, &
       644.753, 649.036, 653.336, 657.653, 661.986, &
       666.337, 670.705, 675.091, 679.496, 683.918, &
       688.360, 692.820, 697.300, 701.800, 706.320, &
       710.859 / 

      data ch4 /    &                    ! ppbv
       901.355, 903.486, 905.637, 907.809, 910.001,  &
       912.213, 914.445, 916.697, 918.969, 921.262,  &
       923.575, 925.908, 928.261, 930.635, 933.029,  &
       935.443, 937.877, 940.331, 942.805, 945.300,  &
       947.815, 950.350, 952.905, 955.481, 958.077,  &
       960.693, 963.329, 965.985, 968.661, 971.358,  &
       974.075, 976.812, 979.569, 982.347, 985.145,  &
       987.963, 990.801, 993.659, 996.537, 999.436,  &
       1002.355, 1005.294, 1008.253, 1011.233, 1014.233,  &
       1017.253, 1020.293, 1023.353, 1026.433, 1029.534,  &
       1032.655, 1035.796, 1038.957, 1042.139, 1045.341,  &
       1048.563, 1051.805, 1055.067, 1058.349, 1061.652,  &
       1064.975, 1068.318, 1071.681, 1075.065, 1078.469,  &
       1081.893, 1085.337, 1088.801, 1092.285, 1095.790,  &
       1099.325, 1102.968, 1106.796, 1110.819, 1115.037,  &
       1119.451, 1124.060, 1128.865, 1133.864, 1139.059,  &
       1144.450, 1150.035, 1155.816, 1161.792, 1167.964,  &
       1174.414, 1181.578, 1189.860, 1199.279, 1209.776,  &
       1221.286, 1233.749, 1247.103, 1261.286, 1276.237,  &
       1291.892, 1308.192, 1325.074, 1342.476, 1360.336,  &
       1378.593, 1397.185, 1416.049, 1435.126, 1454.351,  &
       1473.665, 1493.005, 1512.308, 1531.514, 1550.561,  &
       1569.302, 1587.137, 1603.569, 1618.667, 1632.584,  &
       1645.476, 1657.498, 1668.806, 1679.553, 1689.896,  &
       1700.000, 1709.000, 1717.000, 1724.000, 1730.000,  &
       1735.000, 1739.000, 1743.152, 1747.614, 1752.391,  &
       1757.491, 1762.919, 1768.681, 1774.780, 1781.221,  &
       1788.006, 1795.137, 1802.615, 1810.442, 1818.614,  &
       1827.131, 1835.989, 1845.183, 1854.708, 1864.558,  &
       1874.723, 1885.194, 1895.961, 1907.012, 1918.333,  &
       1929.910, 1941.727, 1953.768, 1966.015, 1978.450,  &
       1991.053, 2003.804, 2016.683, 2029.667, 2042.736,  &
       2055.866, 2069.037, 2082.226, 2095.410, 2108.568,  &
       2121.678, 2134.719, 2147.670, 2160.512, 2173.224,  &
       2185.790, 2198.190, 2210.409, 2222.431, 2234.242,  &
       2245.828, 2257.177, 2268.278, 2279.121, 2289.698,  &
       2300.000, 2310.021, 2319.757, 2329.201, 2338.352,  &
       2347.206, 2355.763, 2364.021, 2371.981, 2379.645,  &
       2387.012, 2394.088, 2400.873, 2407.373, 2413.590,  &
       2419.530, 2425.198, 2430.598, 2435.737, 2440.621,  &
       2445.255, 2449.646, 2453.800, 2457.725, 2461.426,  &
       2464.910, 2468.184, 2471.255, 2474.129, 2476.813,  &
       2479.314, 2481.638, 2483.792, 2485.782, 2487.614,  &
       2489.295, 2490.829, 2492.224, 2493.484, 2494.616,  &
       2495.624, 2496.514, 2497.292, 2497.961, 2498.526,  &
       2498.994, 2499.366, 2499.649, 2499.847, 2499.962,  &
       2500.000/

      data n2o / &                       ! ppbv
       281.351, 281.459, 281.568, 281.676, 281.784,  &
       281.892, 282.000, 282.108, 282.216, 282.324,  &
       282.432, 282.541, 282.649, 282.757, 282.865,  &
       282.973, 283.081, 283.189, 283.297, 283.405,  &
       283.514, 283.622, 283.730, 283.838, 283.946,  &
       284.054, 284.162, 284.270, 284.378, 284.486,  &
       284.595, 284.703, 284.811, 284.919, 285.027,  &
       285.135, 285.243, 285.351, 285.459, 285.568,  &
       285.676, 285.784, 285.892, 286.000, 286.108,  &
       286.216, 286.324, 286.432, 286.541, 286.649,  &
       286.757, 286.865, 286.973, 287.081, 287.189,  &
       287.297, 287.405, 287.514, 287.622, 287.730,  &
       287.838, 287.946, 288.054, 288.162, 288.270,  &
       288.378, 288.486, 288.595, 288.703, 288.811,  &
       288.919, 289.027, 289.135, 289.243, 289.351,  &
       289.459, 289.568, 289.676, 289.784, 289.892,  &
       290.018, 290.186, 290.381, 290.588, 290.808,  &
       291.039, 291.282, 291.537, 291.803, 292.082,  &
       292.372, 292.674, 292.988, 293.314, 293.652,  &
       294.037, 294.500, 295.000, 295.500, 296.000,  &
       296.500, 297.000, 297.500, 298.000, 298.500,  &
       299.000, 299.500, 300.000, 300.500, 301.000,  &
       301.500, 302.000, 302.500, 303.000, 303.500,  &
       304.075, 304.800, 305.600, 306.400, 307.200,  &
       308.000, 308.801, 309.607, 310.424, 311.250,  &
       312.086, 312.934, 313.795, 314.670, 315.558,  &
       316.460, 317.371, 318.286, 319.207, 320.132,  &
       321.062, 321.998, 322.944, 323.898, 324.861,  &
       325.832, 326.812, 327.801, 328.797, 329.802,  &
       330.816, 331.839, 332.875, 333.923, 334.982,  &
       336.054, 337.136, 338.225, 339.321, 340.425,  &
       341.537, 342.650, 343.762, 344.870, 345.976,  &
       347.080, 348.180, 349.279, 350.375, 351.468,  &
       352.559, 353.648, 354.734, 355.818, 356.899,  &
       357.978, 359.055, 360.129, 361.201, 362.271,  &
       363.339, 364.404, 365.467, 366.528, 367.587,  &
       368.644, 369.695, 370.739, 371.775, 372.803,  &
       373.823, 374.836, 375.841, 376.839, 377.829,  &
       378.812, 379.787, 380.755, 381.716, 382.670,  &
       383.617, 384.557, 385.489, 386.415, 387.334,  &
       388.247, 389.152, 390.051, 390.943, 391.828,  &
       392.707, 393.581, 394.450, 395.313, 396.173,  &
       397.027, 397.877, 398.723, 399.563, 400.400,  &
       401.232, 402.059, 402.882, 403.701, 404.516,  &
       405.326, 406.132, 406.934, 407.731, 408.525,  &
       409.314, 410.099, 410.880, 411.658, 412.431,  &
       413.200/ 

      data f11 / &                       ! pptv
           0.0000  ,0.0000  ,0.0000  ,0.0000  ,0.0000  , &
           0.0000  ,0.0000  ,0.0000  ,0.0000  ,0.0000  , &
           0.0000  ,0.0000  ,0.0000  ,0.0000  ,0.0000  , &
           0.0000  ,0.0000  ,0.0000  ,0.0000  ,0.0000  , &
           0.0000  ,0.0000  ,0.0000  ,0.0000  ,0.0000  , &
           0.0000  ,0.0000  ,0.0000  ,0.0000  ,0.0000  , &
           0.0000  ,0.0000  ,0.0000  ,0.0000  ,0.0000  , &
           0.0000  ,0.0000  ,0.0000  ,0.0000  ,0.0000  , &
           0.0000  ,0.0000  ,0.0000  ,0.0000  ,0.0000  , &
           0.0000  ,0.0000  ,0.0000  ,0.0000  ,0.0000  , &
           0.0000  ,0.0000  ,0.0000  ,0.0000  ,0.0000  , &
           0.0000  ,0.0000  ,0.0000  ,0.0000  ,0.0000  , &
           0.0000  ,0.0000  ,0.0000  ,0.0000  ,0.0000  , &
           0.0000  ,0.0000  ,0.0000  ,0.0000  ,0.01000 , &
           0.01000 ,0.01000 ,0.02000 ,0.02000 ,0.03000 , &
           0.04000 ,0.05000 ,0.08000 ,0.13000 ,0.23000 , &
           0.40000 ,0.63000 ,0.96000 ,1.4400  ,2.0700  , &
           2.8600  ,3.8300  ,5.0300  ,6.3700  ,7.5900  , &
           8.8100  ,10.440  ,12.550  ,15.200  ,18.450  , &
           22.300  ,26.660  ,31.510  ,36.990  ,43.210  , &
           50.410  ,58.820  ,68.270  ,79.000  ,91.400  , &
           105.12  ,118.19  ,130.66  ,142.86  ,153.92  , &
           163.49  ,172.26  ,180.82  ,188.67  ,197.22  , &
           206.06  ,215.24  ,225.80  ,237.18  ,247.38  , &
           255.61  ,263.70  ,267.82  ,270.17  ,270.97  , &
           270.87  ,270.19  ,269.72  ,268.96  ,267.94  , &
           266.70  ,265.25  ,263.62  ,261.84  ,259.92  , &
           257.88  ,255.75  ,253.46  ,251.04  ,248.47  , &
           245.77  ,242.95  ,240.01  ,236.96  ,233.81  , &
           230.59  ,227.31  ,223.97  ,220.60  ,217.20  , &
           213.78  ,210.34  ,206.90  ,203.47  ,200.04  , &
           196.63  ,193.24  ,189.86  ,186.52  ,183.20  , &
           179.92  ,176.66  ,173.45  ,170.27  ,167.14  , &
           164.04  ,160.99  ,157.97  ,155.01  ,152.08  , &
           149.21  ,146.37  ,143.59  ,140.84  ,138.15  , &
           135.49  ,132.89  ,130.32  ,127.81  ,125.33  , &
           122.90  ,120.52  ,118.17  ,115.87  ,113.61  , &
           111.40  ,109.22  ,107.08  ,104.99  ,102.93  , &
           100.91  ,98.930  ,96.990  ,95.080  ,93.220  , &
           91.380  ,89.580  ,87.820  ,86.090  ,84.400  , &
           82.730  ,81.100  ,79.500  ,77.930  ,76.400  , &
           74.890  ,73.410  ,71.960  ,70.540  ,69.150  , &
           67.780  ,66.440  ,65.130  ,63.840  ,62.580  , &
           61.340  ,60.130  ,58.940  ,57.770  ,56.630  , &
           55.510  ,54.410  ,53.340  ,52.280  ,51.250  , &
           50.230  ,49.240  ,48.260  ,47.310  ,46.370  , &
           46.370  / 

      data f12 / &                       ! pptv
           0.0000  ,0.0000  ,0.0000  ,0.0000  ,0.0000  , &
           0.0000  ,0.0000  ,0.0000  ,0.0000  ,0.0000  , &
           0.0000  ,0.0000  ,0.0000  ,0.0000  ,0.0000  , &
           0.0000  ,0.0000  ,0.0000  ,0.0000  ,0.0000  , &
           0.0000  ,0.0000  ,0.0000  ,0.0000  ,0.0000  , &
           0.0000  ,0.0000  ,0.0000  ,0.0000  ,0.0000  , &
           0.0000  ,0.0000  ,0.0000  ,0.0000  ,0.0000  , &
           0.0000  ,0.0000  ,0.0000  ,0.0000  ,0.0000  , &
           0.0000  ,0.0000  ,0.0000  ,0.0000  ,0.0000  , &
           0.0000  ,0.0000  ,0.0000  ,0.0000  ,0.0000  , &
           0.0000  ,0.0000  ,0.0000  ,0.0000  ,0.0000  , &
           0.0000  ,0.0000  ,0.0000  ,0.0000  ,0.0000  , &
           0.0000  ,0.0000  ,0.0000  ,0.0000  ,0.0100  , &
           0.0200  ,0.0400  ,0.0600  ,0.1000  ,0.1600  , &
           0.2400  ,0.3500  ,0.4900  ,0.6700  ,0.8800  , &
           1.1700  ,1.5500  ,2.2200  ,3.2400  ,4.4200  , &
           5.6900  ,7.0800  ,8.6000  ,10.160  ,11.920  , &
           13.910  ,16.130  ,18.710  ,21.660  ,24.730  , &
           28.150  ,32.240  ,36.810  ,42.060  ,48.190  , &
           55.320  ,63.370  ,72.300  ,82.360  ,94.210  , &
           107.96  ,123.02  ,139.18  ,156.72  ,176.18  , &
           197.22  ,217.36  ,236.41  ,254.20  ,270.21  , &
           286.69  ,303.60  ,320.09  ,336.09  ,352.72  , &
           370.10  ,387.83  ,406.13  ,424.91  ,444.14  , &
           462.67  ,481.09  ,493.66  ,505.03  ,513.77  , &
           520.35  ,523.77  ,528.35  ,531.51  ,533.62  , &
           534.96  ,535.73  ,536.04  ,536.03  ,535.80  , &
           535.42  ,534.93  ,533.80  ,532.21  ,530.00  , &
           527.34  ,524.35  ,520.85  ,516.98  ,512.85  , &
           508.53  ,504.08  ,499.54  ,494.96  ,490.34  , &
           485.72  ,481.11  ,476.50  ,471.92  ,467.37  , &
           462.85  ,458.36  ,453.91  ,449.50  ,445.13  , &
           440.79  ,436.50  ,432.25  ,428.03  ,423.86  , &
           419.73  ,415.63  ,411.58  ,407.57  ,403.59  , &
           399.65  ,395.75  ,391.89  ,388.07  ,384.28  , &
           380.54  ,376.82  ,373.15  ,369.51  ,365.90  , &
           362.33  ,358.80  ,355.30  ,351.83  ,348.40  , &
           345.00  ,341.63  ,338.30  ,335.00  ,331.73  , &
           328.49  ,325.29  ,322.12  ,318.97  ,315.86  , &
           312.78  ,309.73  ,306.71  ,303.71  ,300.75  , &
           297.82  ,294.91  ,292.04  ,289.19  ,286.36  , &
           283.57  ,280.80  ,278.06  ,275.35  ,272.67  , &
           270.01  ,267.37  ,264.76  ,262.18  ,259.62  , &
           257.09  ,254.58  ,252.10  ,249.64  ,247.20  , &
           244.79  ,242.40  ,240.04  ,237.70  ,235.38  , &
           233.08  ,230.81  ,228.55  ,226.32  ,224.12  , &
           224.12 /                                 
!
      data adj /  &                      ! unitless
           0.000    , 0.000   , 0.000   , 0.000   , 0.000   , &
           0.000    , 0.000   , 0.000   , 0.000   , 0.000   , &
           0.000    , 0.000   , 0.000   , 0.000   , 0.000   , &
           0.000    , 0.000   , 0.000   , 0.000   , 0.000   , &
           0.000    , 0.000   , 0.000   , 0.000   , 0.000   , &
           0.000    , 0.000   , 0.000   , 0.000   , 0.000   , &
           0.000    , 0.000   , 0.000   , 0.000   , 0.000   , &
           0.000    , 0.000   , 0.000   , 0.000   , 0.000   , &
           0.000    , 0.000   , 0.000   , 0.000   , 0.000   , &
           0.000    , 0.000   , 0.000   , 0.000   , 0.000   , &
           0.000    , 0.000   , 0.000   , 0.000   , 0.000   , &
           0.000    , 0.000   , 0.000   , 0.000   , 0.000   , &
           0.000    , 0.000   , 0.000   , 0.000   , 0.000   , &
           0.000    , 0.000   , 0.000   , 0.000   , 0.000   , &
           0.000    , 0.000   , 0.000   , 0.000   , 0.000   , &
           0.000    , 0.000   , 0.000   , 0.000   ,32.000   , &
           34.000   ,36.000   ,19.500   ,13.667   ,8.6000   , &
           7.3333   ,5.7500   ,4.2727   ,3.4286   ,3.0000   , &
           2.8421   ,2.4348   ,2.1071   ,1.8788   ,1.6098   , &
           1.4490   ,1.3051   ,1.2464   ,1.1975   ,1.1368   , &
           1.0721   ,1.0388   ,0.98667  ,0.92529  ,0.87065  , &
           0.83550  ,0.80385  ,0.79443  ,0.78981  ,0.79351  , &
           0.81111  ,0.83377  ,0.85176  ,0.86988  ,0.88249  , &
           0.90066  ,0.91772  ,0.93360  ,0.95019  ,0.97426  , &
           1.0107   ,1.08966  ,1.11885  ,1.15320  ,1.17282  , &
           1.18960  ,1.20707  ,1.21585  ,1.23311  ,1.30153  , &
           1.3595   ,1.4161   ,1.4862   ,1.5590   ,1.6364   , &
           1.7160   ,1.7815   ,1.8459   ,1.9094   ,1.9671   , &
           2.0277   ,2.0899   ,2.1345   ,2.1747   ,2.2101   , &
           2.2426   ,2.2720   ,2.2901   ,2.3031   ,2.3075   , &
           2.3149   ,2.3175   ,2.3231   ,2.3214   ,2.3273   , &
           2.3303   ,2.3412   ,2.3493   ,2.3683   ,2.3846   , &
           2.4040   ,2.4267   ,2.4555   ,2.4880   ,2.5245   , &
           2.5651   ,2.6102   ,2.6523   ,2.7067   ,2.7582   , &
           2.8201   ,2.8820   ,2.9399   ,2.9935   ,3.0526   , &
           3.1141   ,3.1781   ,3.2369   ,3.3132   ,3.3841   , &
           3.4704   ,3.5547   ,3.6423   ,3.7412   ,3.8440   , &
           3.9551   ,4.0750   ,4.1864   ,4.3247   ,4.4690   , &
           4.6036   ,4.7477   ,4.9249   ,5.0909   ,5.2634   , &
           5.4478   ,5.6447   ,5.8549   ,6.0741   ,6.2742   , &
           6.5220   ,6.7865   ,7.0229   ,7.3158   ,7.5833   , &
           7.8667   ,8.1605   ,8.5316   ,8.8645   ,9.2105   , &
           9.5839   ,9.9795   ,10.392   ,10.829   ,11.210   , &
           11.696   ,12.212   ,12.662   ,13.228   ,13.728   , &
           14.369   ,14.925   ,15.632   ,16.252   ,16.903   , &
           17.586   ,18.472   ,19.245   ,20.048   ,20.902   , &
           20.902 /                            
