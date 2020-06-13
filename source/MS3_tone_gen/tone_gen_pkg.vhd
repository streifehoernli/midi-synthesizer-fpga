-------------------------------------------
-- ZHAW School of Engineering
-- Technikumstrasse 9
-- 8401 Winterthur
--
-- Autoren:
-- Beat Sturzenegger
-- Markus Bodenmann
-- Tharmelan Theivanesan
--
-- source name: tone_gen_pkg
-- Datum:       14.06.2020
-------------------------------------------

-------------------------------------------------------------------------------
-- Project     : audio_top
-- Description : Constants and LUT for tone generation with DDS
--
--
-------------------------------------------------------------------------------
--
-- Change History
-- Date     |Name      |Modification
------------|----------|-------------------------------------------------------
-- 12.04.13 | dqtm     | file created for DTP2 Milestone-3 in FS13
-- 02.04.14 | dqtm     | updated for DTP2 in FS14, cause using new parameters
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Package  Declaration
-------------------------------------------------------------------------------
-- Include in Design of Block dds.vhd and tone_decoder.vhd :
--   use work.tone_gen_pkg.all;
-------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

package tone_gen_pkg is

 type t_tone_array is array (0 to 9) of std_logic_vector(6 downto 0) ;
 type t_note_on is array (0 to 9) of std_logic;

  
    -------------------------------------------------------------------------------
	-- TYPES AND CONSTANTS FOR MIDI INTERFACE
	-------------------------------------------------------------------------------	
	-- type t_note_record is
	--   record
	-- 	valid 		: std_logic;
	-- 	number 		: std_logic_vector(6 downto 0);
	-- 	velocity	: std_logic_vector(6 downto 0); 
	--   end record;

	-- CONSTANT NOTE_INIT_VALUE : t_note_record := (valid  	=> '0',
	-- 											 number 	=> (others => '0'),
	-- 											 velocity 	=> (others => '0'));
	  
	-- type t_midi_array is array (0 to 9) of t_note_record; -- 10x note_record


    -------------------------------------------------------------------------------
	-- CONSTANT DECLARATION FOR SEVERAL BLOCKS (DDS, TONE_GENERATOR, ...)
	-------------------------------------------------------------------------------
    constant N_CUM:					natural :=19; 			-- number of bits in phase cumulator phicum_reg
    constant N_LUT:					natural :=8;  			-- number of bits in LUT address
    constant L: 					natural := 2**N_LUT; 	-- length of LUT
    constant N_RESOL:				natural := 13;			-- Attention: 1 bit reserved for sign
	 constant N_AUDIO :				natural := 16;			-- Audio Paralell Bus width
	-------------------------------------------------------------------------------
	-- TYPE DECLARATION FOR DDS
	-------------------------------------------------------------------------------
    subtype t_audio_range is integer range -(2**(N_RESOL-1)) to (2**(N_RESOL-1))-1;  -- range : [-2^12; +(2^12)-1]

 type t_lut_rom is array (0 to L-1) of t_audio_range;
 --type t_lut_rom is array (0 to L-1) of integer;

	constant LUT : t_lut_rom :=(
	0, 101, 201, 301, 401, 501, 601, 700, 799, 897, 995, 1092, 1189, 1285, 1380, 1474, 1567,
	1660, 1751, 1842, 1931, 2019, 2106, 2191, 2276, 2359, 2440, 2520, 2598, 2675, 2751, 2824,
	2896, 2967, 3035, 3102, 3166, 3229, 3290, 3349, 3406, 3461, 3513, 3564, 3612, 3659, 3703,
	3745, 3784, 3822, 3857, 3889, 3920, 3948, 3973, 3996, 4017, 4036, 4052, 4065, 4076, 4085,
	4091, 4095, 4095, 4095, 4091, 4085, 4076, 4065, 4052, 4036, 4017, 3996, 3973, 3948, 3920,
	3889, 3857, 3822, 3784, 3745, 3703, 3659, 3612, 3564, 3513, 3461, 3406, 3349, 3290, 3229,
	3166, 3102, 3035, 2967, 2896, 2824, 2751, 2675, 2598, 2520, 2440, 2359, 2276, 2191, 2106,
	2019, 1931, 1842, 1751, 1660, 1567, 1474, 1380, 1285, 1189, 1092, 995, 897, 799, 700, 601,
	501, 401, 301, 201, 101, 0, -101, -201, -301, -401, -501, -601, -700, -799, -897, -995,
	-1092, -1189, -1285, -1380, -1474, -1567, -1660, -1751, -1842, -1931, -2019, -2106, -2191,
	-2276, -2359, -2440, -2520, -2598, -2675, -2751, -2824, -2896, -2967, -3035, -3102, -3166,
	-3229, -3290, -3349, -3406, -3461, -3513, -3564, -3612, -3659, -3703, -3745, -3784, -3822,
	-3857, -3889, -3920, -3948, -3973, -3996, -4017, -4036, -4052, -4065, -4076, -4085, -4091,
	-4095, -4096, -4095, -4091, -4085, -4076, -4065, -4052, -4036, -4017, -3996, -3973, -3948,
	-3920, -3889, -3857, -3822, -3784, -3745, -3703, -3659, -3612, -3564, -3513, -3461, -3406,
	-3349, -3290, -3229, -3166, -3102, -3035, -2967, -2896, -2824, -2751, -2675, -2598, -2520,
	-2440, -2359, -2276, -2191, -2106, -2019, -1931, -1842, -1751, -1660, -1567, -1474, -1380,
	-1285, -1189, -1092, -995, -897, -799, -700, -601, -501, -401, -301, -201, -101 );
	
	constant LUT_VIOLA : t_lut_rom :=(
	496,1165,1586,1781,1832,1842,1868,1903,1922,1898,1783,1531,1179,848,645,603,692,865,1075,1271,1403,1453,1464,1504,1588,1667,1711,1732,1716,1619,1444,1248,1050,819,534,194,-205,-649,-1095,-1510,-1880,-2176,-2383,-2536,-2653,-2678,-2562,-2351,-2116,-1848,-1512,-1124,-715,-288,157,593,990,1322,1576,1772,1961,2159,2340,2496,2647,2791,2891,2917,2874,2772,2622,2440,2233,1996,1716,1383,995,563,112,-338,-776,-1193,-1580,-1936,-2252,-2499,-2644,-2669,-2577,-2386,-2120,-1811,-1492,-1196,-952,-770,-637,-529,-425,-314,-195,-76,30,109,152,163,148,111,54,-6,-45,-49,-12,61,158,254,323,345,309,210,64,-99,-247,-364,-452,-521,-580,-633,-681,-722,-750,-756,-737,-682,-573,-393,-152,113,354,526,605,584,463,253,-14,-294,-552,-763,-907,-972,-961,-889,-786,-684,-607,-569,-578,-641,-753,-896,-1055,-1219,-1369,-1485,-1549,-1552,-1486,-1344,-1128,-843,-496,-95,363,874,1417,1951,2440,2850,3136,3261,3216,3024,2725,2380,2074,1875,1800,1810,1833,1793,1643,1379,1030,651,320,101,27,93,271,512,753,950,1098,1229,1381,1573,1783,1954,2011,1885,1542,1013,397,-190,-667,-997,-1179,-1245,-1261,-1296,-1384,-1506,-1613,-1653,-1603,-1463,-1265,-1064,-921,-855,-833,-811,-757,-651,-491,-316,-200,-202,-337,-594,-952,-1382,-1832,-2254,-2639,-3005,-3361,-3687,-3947,-4095,-4062,-3767,-3178,-2341,-1364,-377
	);
	
	constant LUT_BASSOON : t_lut_rom :=(
	173,185,250,358,477,564,595,573,519,459,405,349,268,147,-15,-191,-338,-414,-395,-279,-88,144,382,602,784,920,1005,1037,1022,972,898,812,717,610,485,339,183,35,-81,-150,-168,-144,-92,-24,61,173,320,505,712,915,1082,1191,1238,1233,1197,1145,1080,990,856,659,392,66,-298,-671,-1022,-1329,-1576,-1758,-1874,-1927,-1916,-1836,-1672,-1404,-1018,-511,92,746,1387,1951,2394,2698,2881,2980,3034,3069,3088,3071,2987,2807,2517,2122,1647,1130,615,141,-263,-583,-822,-995,-1118,-1201,-1234,-1192,-1046,-777,-406,8,371,583,572,322,-115,-638,-1130,-1498,-1701,-1760,-1738,-1712,-1731,-1799,-1876,-1886,-1759,-1449,-961,-348,297,871,1282,1476,1438,1195,797,299,-253,-833,-1423,-2013,-2584,-3106,-3544,-3863,-4043,-4081,-3987,-3779,-3466,-3052,-2530,-1900,-1170,-369,459,1260,1983,2581,3021,3277,3337,3201,2888,2433,1889,1314,760,256,-189,-587,-954,-1304,-1633,-1923,-2147,-2280,-2305,-2215,-2015,-1715,-1332,-889,-417,50,478,838,1120,1326,1466,1554,1596,1592,1534,1417,1243,1023,776,519,270,38,-168,-340,-469,-549,-577,-555,-495,-409,-306,-190,-57,96,267,449,625,775,880,928,913,837,710,548,372,204,61,-48,-131,-201,-277,-366,-460,-538,-577,-564,-506,-430,-367,-337,-339,-349,-338,-291,-218,-158,-152,-224,-360,-508,-604,-596,-474,-276,-66,94,173,185
	);
	
	constant LUT_CLARINET : t_lut_rom :=(	
	-448,-950,-1484,-2020,-2526,-2979,-3362,-3665,-3887,-4030,-4096,-4091,-4021,-3893,-3718,-3512,-3289,-3066,-2855,-2665,-2498,-2349,-2211,-2078,-1946,-1814,-1688,-1572,-1474,-1396,-1338,-1295,-1259,-1223,-1183,-1137,-1090,-1046,-1010,-983,-963,-942,-912,-865,-797,-710,-610,-507,-410,-328,-263,-214,-176,-145,-116,-89,-66,-53,-56,-79,-124,-186,-260,-337,-410,-474,-526,-568,-602,-633,-665,-698,-735,-775,-819,-867,-916,-968,-1019,-1068,-1110,-1143,-1165,-1172,-1164,-1140,-1097,-1032,-941,-819,-662,-470,-247,-1,253,500,723,908,1046,1132,1167,1152,1091,989,848,672,466,236,-6,-250,-481,-690,-870,-1019,-1138,-1232,-1307,-1363,-1402,-1420,-1411,-1371,-1298,-1194,-1062,-908,-737,-550,-346,-123,125,400,698,1015,1339,1657,1960,2238,2489,2712,2911,3084,3231,3346,3420,3448,3425,3357,3254,3132,3009,2902,2819,2759,2714,2671,2613,2530,2416,2274,2116,1954,1801,1667,1554,1459,1376,1296,1211,1117,1012,895,768,634,492,346,198,56,-74,-180,-254,-287,-278,-226,-137,-20,117,266,422,584,750,919,1088,1251,1401,1527,1622,1678,1694,1667,1602,1500,1366,1202,1010,795,559,310,56,-195,-431,-644,-827,-976,-1085,-1154,-1178,-1156,-1087,-971,-810,-611,-384,-139,109,350,573,770,938,1071,1170,1232,1259,1252,1217,1163,1100,1039,990,961,951,959,978,1000,1018,1030,1035,1035,1031,1019,990,927,812,625,353,-7
	);
	
	constant LUT_ENGLISH_HORN : t_lut_rom :=(	
	-568,-1083,-1590,-2071,-2505,-2875,-3170,-3390,-3541,-3638,-3695,-3721,-3721,-3690,-3621,-3504,-3333,-3108,-2835,-2524,-2190,-1846,-1505,-1177,-870,-584,-319,-71,168,402,632,854,1058,1228,1352,1418,1424,1373,1277,1146,994,831,661,489,320,158,8,-124,-236,-325,-393,-444,-481,-506,-519,-520,-510,-490,-461,-427,-388,-345,-295,-240,-178,-112,-46,17,73,126,179,236,302,376,453,528,591,639,669,684,686,680,667,648,620,583,536,482,423,360,295,228,159,87,13,-59,-128,-191,-249,-303,-355,-405,-450,-489,-516,-529,-531,-526,-521,-522,-532,-550,-569,-584,-588,-580,-561,-536,-511,-490,-474,-463,-455,-447,-437,-425,-407,-383,-352,-313,-270,-227,-190,-163,-148,-143,-143,-140,-130,-113,-91,-69,-55,-52,-57,-65,-68,-61,-40,-7,34,77,114,142,158,163,158,145,127,110,97,92,97,110,127,143,152,154,150,148,156,181,225,286,356,429,498,562,623,685,754,831,913,995,1069,1130,1171,1191,1190,1169,1131,1078,1013,938,853,754,637,494,318,107,-135,-396,-659,-904,-1116,-1287,-1419,-1520,-1604,-1686,-1774,-1867,-1958,-2036,-2088,-2101,-2068,-1986,-1857,-1687,-1484,-1258,-1016,-763,-499,-221,79,408,771,1164,1576,1991,2387,2747,3061,3323,3539,3715,3858,3970,4050,4092,4086,4026,3909,3736,3509,3236,2921,2571,2192,1786,1357,905,433,-60
	); 

	constant LUT_TRUMPET : t_lut_rom :=(	
	0,377,751,1118,1474,1816,2141,2446,2729,2987,3218,3422,3596,3740,3854,3938,3992,4017,4014,3985,3932,3856,3760,3647,3518,3376,3225,3067,2904,2739,2574,2411,2253,2102,1958,1823,1698,1583,1480,1388,1307,1237,1178,1127,1086,1052,1024,1002,984,968,953,939,923,906,886,862,834,801,763,720,673,620,564,503,440,374,307,239,171,104,39,-23,-82,-136,-186,-230,-269,-303,-330,-352,-368,-379,-385,-388,-387,-383,-377,-370,-364,-357,-352,-350,-350,-353,-360,-371,-387,-406,-431,-459,-490,-525,-563,-602,-642,-682,-721,-758,-793,-823,-848,-867,-879,-884,-881,-869,-849,-819,-780,-732,-676,-611,-539,-460,-375,-286,-193,-97,0,97,193,286,375,460,539,611,676,732,780,819,849,869,881,884,879,867,848,823,793,758,721,682,642,602,563,525,490,459,431,406,387,371,360,353,350,350,352,357,364,370,377,383,387,388,385,379,368,352,330,303,269,230,186,136,82,23,-39,-104,-171,-239,-307,-374,-440,-503,-564,-620,-673,-720,-763,-801,-834,-862,-886,-906,-923,-939,-953,-968,-984,-1002,-1024,-1052,-1086,-1127,-1178,-1237,-1307,-1388,-1480,-1583,-1698,-1823,-1958,-2102,-2253,-2411,-2574,-2739,-2904,-3067,-3225,-3376,-3518,-3647,-3760,-3856,-3932,-3985,-4014,-4017,-3992,-3938,-3854,-3740,-3596,-3422,-3218,-2987,-2729,-2446,-2141,-1816,-1474,-1118,-751,-377
	); 
	
	constant LUT_PIANO : t_lut_rom :=(	
	0,234,466,697,926,1152,1373,1590,1801,2006,2204,2395,2578,2752,2917,3072,3217,3352,3476,3588,3690,3780,3859,3926,3981,4025,4057,4078,4087,4086,4074,4052,4019,3977,3926,3866,3798,3722,3639,3549,3453,3352,3245,3134,3020,2902,2782,2659,2536,2411,2285,2160,2036,1912,1790,1671,1553,1438,1326,1217,1112,1011,914,821,733,648,569,494,424,359,298,242,190,143,100,62,28,-3,-29,-52,-72,-88,-102,-112,-120,-126,-129,-130,-129,-127,-124,-119,-113,-106,-99,-91,-83,-74,-65,-57,-48,-39,-31,-23,-16,-9,-3,3,9,13,17,21,23,26,27,28,28,28,27,26,24,22,20,17,14,11,7,4,0,-4,-7,-11,-14,-17,-20,-22,-24,-26,-27,-28,-28,-28,-27,-26,-23,-21,-17,-13,-9,-3,3,9,16,23,31,39,48,57,65,74,83,91,99,106,113,119,124,127,129,130,129,126,120,112,102,88,72,52,29,3,-28,-62,-100,-143,-190,-242,-298,-359,-424,-494,-569,-648,-732,-821,-914,-1011,-1112,-1217,-1326,-1438,-1553,-1671,-1790,-1912,-2036,-2160,-2285,-2411,-2536,-2659,-2782,-2902,-3020,-3134,-3245,-3352,-3453,-3549,-3639,-3722,-3798,-3866,-3926,-3977,-4019,-4052,-4074,-4086,-4087,-4078,-4057,-4025,-3981,-3926,-3859,-3780,-3690,-3588,-3476,-3352,-3217,-3072,-2917,-2752,-2578,-2395,-2204,-2006,-1801,-1590,-1373,-1152,-926,-697,-466,-234
	); 
	
	constant LUT_ORGAN : t_lut_rom :=(	
	0,223,445,665,883,1099,1310,1517,1719,1915,2105,2288,2463,2631,2790,2941,3083,3215,3338,3452,3555,3650,3734,3809,3874,3930,3976,4014,4043,4064,4077,4082,4080,4071,4056,4035,4009,3977,3941,3901,3857,3810,3760,3708,3653,3597,3539,3480,3420,3359,3298,3236,3173,3111,3048,2984,2921,2857,2792,2727,2662,2595,2528,2460,2390,2319,2246,2172,2095,2017,1936,1853,1767,1680,1589,1496,1401,1303,1203,1101,996,890,782,673,562,451,340,228,117,7,-102,-209,-314,-416,-514,-609,-700,-786,-867,-942,-1011,-1073,-1129,-1177,-1218,-1251,-1277,-1294,-1302,-1303,-1294,-1278,-1253,-1221,-1180,-1131,-1076,-1013,-943,-868,-786,-700,-609,-513,-415,-314,-210,-105,0,105,210,314,415,513,609,700,786,868,943,1013,1076,1131,1180,1221,1253,1278,1294,1303,1302,1294,1277,1251,1218,1177,1129,1073,1011,942,867,786,700,609,514,416,314,209,102,-7,-117,-228,-340,-451,-562,-673,-782,-890,-996,-1101,-1203,-1303,-1401,-1496,-1589,-1680,-1767,-1853,-1936,-2017,-2095,-2172,-2246,-2319,-2390,-2460,-2528,-2595,-2662,-2727,-2792,-2857,-2921,-2984,-3048,-3111,-3173,-3236,-3298,-3359,-3420,-3480,-3539,-3597,-3653,-3708,-3760,-3810,-3857,-3901,-3941,-3977,-4009,-4035,-4056,-4071,-4080,-4082,-4077,-4064,-4043,-4014,-3976,-3930,-3874,-3809,-3734,-3650,-3555,-3452,-3338,-3215,-3083,-2941,-2790,-2631,-2463,-2288,-2105,-1915,-1719,-1517,-1310,-1099,-883,-665,-445,-223
	); 
	
	constant LUT_OBOE : t_lut_rom :=(	
	0,234,467,699,927,1153,1374,1590,1800,2004,2201,2390,2571,2742,2905,3057,3200,3332,3453,3564,3664,3753,3830,3898,3954,4000,4036,4062,4078,4086,4085,4075,4058,4034,4004,3967,3925,3879,3828,3774,3718,3659,3598,3537,3474,3412,3351,3290,3231,3173,3118,3064,3014,2966,2922,2880,2842,2807,2776,2748,2722,2700,2681,2664,2650,2638,2628,2620,2613,2607,2602,2598,2593,2589,2584,2578,2571,2562,2552,2540,2526,2510,2492,2470,2446,2419,2390,2357,2321,2283,2241,2197,2150,2101,2049,1995,1938,1880,1820,1758,1695,1631,1566,1500,1433,1367,1300,1233,1167,1100,1035,970,906,843,780,719,658,599,541,483,427,372,317,263,210,157,104,52,0,-52,-104,-157,-210,-263,-317,-372,-427,-483,-541,-599,-658,-719,-780,-843,-906,-970,-1035,-1100,-1167,-1233,-1300,-1367,-1433,-1500,-1566,-1631,-1695,-1758,-1820,-1880,-1938,-1995,-2049,-2101,-2150,-2197,-2241,-2283,-2321,-2357,-2390,-2419,-2446,-2470,-2492,-2510,-2526,-2540,-2552,-2562,-2571,-2578,-2584,-2589,-2593,-2598,-2602,-2607,-2613,-2620,-2628,-2638,-2650,-2664,-2681,-2700,-2722,-2748,-2776,-2807,-2842,-2880,-2922,-2966,-3014,-3064,-3118,-3173,-3231,-3290,-3351,-3412,-3474,-3537,-3598,-3659,-3718,-3774,-3828,-3879,-3925,-3967,-4004,-4034,-4058,-4075,-4085,-4086,-4078,-4062,-4036,-4000,-3954,-3898,-3830,-3753,-3664,-3564,-3453,-3332,-3200,-3057,-2905,-2742,-2571,-2390,-2201,-2004,-1800,-1590,-1374,-1153,-927,-699,-467,-234
	); 
	
	constant LUT_FLUTE : t_lut_rom :=(	
	126,154,182,209,234,255,273,286,293,293,288,275,255,229,197,159,116,69,18,-34,-88,-143,-198,-253,-309,-364,-420,-477,-535,-596,-658,-723,-792,-863,-936,-1010,-1086,-1161,-1233,-1302,-1365,-1422,-1469,-1507,-1533,-1547,-1549,-1537,-1513,-1477,-1430,-1374,-1309,-1239,-1164,-1088,-1013,-940,-873,-814,-764,-726,-702,-693,-700,-723,-763,-818,-889,-972,-1065,-1164,-1267,-1368,-1462,-1544,-1608,-1651,-1666,-1649,-1597,-1506,-1376,-1205,-994,-745,-462,-148,190,547,917,1291,1663,2025,2371,2695,2991,3256,3486,3678,3834,3951,4032,4080,4095,4083,4047,3990,3917,3831,3735,3634,3528,3420,3310,3200,3089,2977,2862,2745,2622,2494,2358,2214,2061,1899,1728,1549,1361,1168,970,770,570,373,181,-5,-180,-345,-496,-632,-753,-858,-946,-1017,-1072,-1111,-1134,-1143,-1138,-1122,-1095,-1059,-1016,-969,-919,-869,-822,-780,-746,-723,-713,-719,-741,-781,-840,-916,-1009,-1116,-1235,-1362,-1493,-1623,-1748,-1863,-1963,-2045,-2105,-2142,-2154,-2141,-2104,-2045,-1968,-1874,-1770,-1659,-1545,-1432,-1325,-1225,-1134,-1054,-984,-923,-870,-821,-775,-727,-676,-618,-552,-475,-387,-289,-180,-63,60,186,312,436,553,661,758,842,911,964,1003,1026,1036,1033,1019,997,966,931,890,847,801,755,707,659,611,562,513,464,416,367,319,272,227,184,144,107,74,46,23,5,-8,-15,-17,-13,-4,9,26,48,72,98
	); 
	
	constant LUT_VIOLIN : t_lut_rom :=(	
	-131,-244,-277,-230,-112,64,285,534,797,1057,1300,1516,1695,1839,1952,2044,2123,2200,2278,2360,2445,2530,2610,2675,2711,2700,2622,2464,2220,1901,1527,1128,741,401,139,-24,-77,-22,127,342,589,831,1037,1185,1265,1280,1240,1155,1036,889,718,526,320,102,-121,-350,-585,-829,-1087,-1359,-1644,-1939,-2238,-2538,-2833,-3119,-3384,-3615,-3795,-3908,-3941,-3890,-3758,-3559,-3310,-3029,-2736,-2444,-2163,-1896,-1642,-1390,-1132,-858,-564,-258,49,336,584,778,911,982,993,949,858,728,573,413,270,163,106,98,131,190,262,338,418,500,575,624,616,515,295,-48,-494,-997,-1496,-1931,-2255,-2442,-2487,-2405,-2224,-1973,-1681,-1370,-1053,-735,-417,-93,236,564,878,1159,1392,1573,1712,1832,1961,2121,2321,2547,2776,2979,3136,3245,3321,3389,3473,3587,3730,3883,4015,4089,4070,3924,3629,3181,2594,1908,1183,489,-109,-568,-883,-1081,-1212,-1334,-1486,-1677,-1887,-2074,-2195,-2223,-2156,-2019,-1851,-1692,-1567,-1483,-1425,-1369,-1290,-1172,-1011,-819,-615,-424,-271,-175,-150,-198,-315,-484,-680,-870,-1023,-1113,-1122,-1052,-913,-725,-508,-278,-44,188,407,591,708,719,594,325,-68,-533,-1005,-1421,-1742,-1960,-2098,-2191,-2271,-2355,-2434,-2493,-2517,-2504,-2474,-2452,-2454,-2478,-2490,-2442,-2285,-1994,-1576,-1070,-531,-12,455,864,1228,1565,1882,2168,2396,2534,2559,2465,2264,1981,1648,1294,941,607,308,57
	);
	
	constant LUT_TUBA : t_lut_rom :=(	
	61,-156,-337,-482,-590,-663,-702,-709,-689,-645,-582,-503,-414,-317,-216,-111,-6,98,201,302,399,490,575,651,716,768,805,827,832,821,794,752,697,629,550,462,366,264,157,46,-67,-181,-292,-398,-498,-589,-669,-737,-794,-839,-873,-900,-921,-939,-956,-975,-996,-1021,-1048,-1078,-1109,-1139,-1167,-1193,-1215,-1234,-1248,-1258,-1264,-1266,-1262,-1252,-1235,-1208,-1171,-1120,-1057,-979,-888,-784,-670,-549,-422,-293,-164,-38,84,200,309,410,502,585,657,718,765,798,816,818,806,780,742,696,644,589,535,484,437,396,361,331,305,280,256,231,205,177,150,125,103,87,80,83,98,126,167,219,281,350,423,496,565,624,669,696,701,681,634,559,457,330,183,21,-150,-322,-489,-644,-781,-895,-985,-1048,-1087,-1102,-1096,-1074,-1039,-994,-942,-885,-824,-760,-694,-626,-557,-488,-421,-357,-298,-245,-200,-162,-133,-109,-91,-74,-57,-39,-17,8,35,62,86,102,107,96,66,16,-56,-147,-256,-377,-507,-641,-772,-898,-1014,-1119,-1213,-1296,-1372,-1443,-1513,-1588,-1670,-1763,-1868,-1986,-2114,-2249,-2384,-2512,-2623,-2707,-2755,-2755,-2701,-2586,-2407,-2164,-1861,-1503,-1102,-668,-215,245,698,1135,1546,1926,2271,2580,2855,3097,3311,3499,3662,3802,3918,4007,4067,4094,4084,4033,3939,3802,3622,3401,3144,2857,2545,2217,1880,1541,1208,888,586,309
	);
	
	constant LUT_PICCOLO : t_lut_rom :=(	
	28,-135,-305,-483,-669,-862,-1061,-1265,-1474,-1686,-1899,-2111,-2321,-2526,-2725,-2916,-3096,-3266,-3422,-3564,-3691,-3801,-3894,-3970,-4028,-4068,-4090,-4096,-4086,-4061,-4023,-3975,-3917,-3853,-3783,-3709,-3633,-3557,-3481,-3405,-3331,-3256,-3182,-3108,-3033,-2956,-2878,-2798,-2715,-2631,-2545,-2459,-2373,-2289,-2207,-2130,-2057,-1990,-1930,-1875,-1828,-1787,-1752,-1721,-1696,-1673,-1654,-1636,-1620,-1605,-1592,-1580,-1571,-1565,-1564,-1568,-1580,-1599,-1628,-1665,-1713,-1769,-1834,-1906,-1982,-2061,-2141,-2219,-2293,-2360,-2420,-2471,-2512,-2544,-2566,-2579,-2584,-2580,-2569,-2549,-2522,-2484,-2436,-2374,-2297,-2202,-2086,-1948,-1788,-1603,-1396,-1169,-923,-663,-393,-119,155,423,680,923,1148,1354,1538,1702,1846,1971,2079,2172,2252,2321,2381,2432,2475,2511,2540,2562,2577,2587,2593,2595,2595,2595,2598,2605,2617,2636,2664,2699,2741,2788,2840,2893,2946,2995,3040,3077,3106,3126,3138,3142,3139,3130,3117,3101,3084,3065,3046,3026,3004,2981,2954,2923,2887,2846,2799,2746,2689,2627,2563,2496,2429,2363,2298,2236,2175,2117,2061,2006,1952,1898,1845,1793,1741,1689,1640,1593,1549,1509,1475,1445,1421,1402,1388,1378,1371,1366,1362,1359,1355,1351,1346,1341,1336,1331,1327,1324,1322,1322,1324,1327,1330,1335,1339,1343,1347,1350,1353,1356,1360,1365,1372,1381,1392,1405,1419,1434,1449,1461,1470,1473,1469,1456,1433,1399,1353,1296,1227,1147,1056,956,846,729,603,470,330,182
);
    -------------------------------------------------------------------------------
	-- More Constant Declarations (DDS: Phase increment values for tones in 10 octaves of piano)
	-------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	-- OCTAVE # Minus-2 (C-2 until B-2)
	constant CM2_DO		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(2858/64,N_CUM)); -- CM2_DO	tone ~(2^-6)*261.63Hz
    constant CM2S_DOS	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3028/64,N_CUM)); -- CM2S_DOS	tone ~(2^-6)*277.18Hz
    constant DM2_RE		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3208/64,N_CUM)); -- DM2_RE	tone ~(2^-6)*293.66Hz
    constant DM2S_RES	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3398/64,N_CUM)); -- DM2S_RES	tone ~(2^-6)*311.13Hz
    constant EM2_MI		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3600/64,N_CUM)); -- EM2_MI	tone ~(2^-6)*329.63Hz
    constant FM2_FA		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3815/64,N_CUM)); -- FM2_FA	tone ~(2^-6)*349.23Hz
    constant FM2S_FAS	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4041/64,N_CUM)); -- FM2S_FAS	tone ~(2^-6)*369.99Hz
    constant GM2_SOL  	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4282/64,N_CUM)); -- GM2_SOL  tone ~(2^-6)*392.00Hz
    constant GM2S_SOLS	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4536/64,N_CUM)); -- GM2S_SOLS	tone ~(2^-6)*415.30Hz
    constant AM2_LA		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4806/64,N_CUM)); -- AM2_LA	tone ~(2^-6)*440.00Hz
    constant AM2S_LAS	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(5092/64,N_CUM)); -- AM2S_LAS	tone ~(2^-6)*466.16Hz
    constant BM2_SI		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(5394/64,N_CUM)); -- BM2_SI	tone ~(2^-6)*493.88Hz
	-------------------------------------------------------------------------------
	-- OCTAVE # Minus-1 (C-1 until B-1)
	constant CM1_DO		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(2858/32,N_CUM)); -- CM1_DO	tone ~(2^-5)*261.63Hz
    constant CM1S_DOS	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3028/32,N_CUM)); -- CM1S_DOS	tone ~(2^-5)*277.18Hz
    constant DM1_RE		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3208/32,N_CUM)); -- DM1_RE	tone ~(2^-5)*293.66Hz
    constant DM1S_RES	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3398/32,N_CUM)); -- DM1S_RES	tone ~(2^-5)*311.13Hz
    constant EM1_MI		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3600/32,N_CUM)); -- EM1_MI	tone ~(2^-5)*329.63Hz
    constant FM1_FA		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3815/32,N_CUM)); -- FM1_FA	tone ~(2^-5)*349.23Hz
    constant FM1S_FAS	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4041/32,N_CUM)); -- FM1S_FAS	tone ~(2^-5)*369.99Hz
    constant GM1_SOL  	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4282/32,N_CUM)); -- GM1_SOL  tone ~(2^-5)*392.00Hz
    constant GM1S_SOLS	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4536/32,N_CUM)); -- GM1S_SOLS	tone ~(2^-5)*415.30Hz
    constant AM1_LA		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4806/32,N_CUM)); -- AM1_LA	tone ~(2^-5)*440.00Hz
    constant AM1S_LAS	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(5092/32,N_CUM)); -- AM1S_LAS	tone ~(2^-5)*466.16Hz
    constant BM1_SI		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(5394/32,N_CUM)); -- BM1_SI	tone ~(2^-5)*493.88Hz
	-------------------------------------------------------------------------------
    -- OCTAVE #0 (C0 until B0)
	constant C0_DO		: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(2858/16,N_CUM)); -- C0_DO		tone ~(2^-4)*261.63Hz
    constant C0S_DOS	: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3028/16,N_CUM)); -- C0S_DOS	tone ~(2^-4)*277.18Hz
    constant D0_RE		: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3208/16,N_CUM)); -- D0_RE		tone ~(2^-4)*293.66Hz
    constant D0S_RES	: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3398/16,N_CUM)); -- D0S_RES	tone ~(2^-4)*311.13Hz
    constant E0_MI		: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3600/16,N_CUM)); -- E0_MI		tone ~(2^-4)*329.63Hz
    constant F0_FA		: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3815/16,N_CUM)); -- F0_FA		tone ~(2^-4)*349.23Hz
    constant F0S_FAS	: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4041/16,N_CUM)); -- F0S_FAS	tone ~(2^-4)*369.99Hz
    constant G0_SOL  	: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4282/16,N_CUM)); -- G0_SOL  	tone ~(2^-4)*392.00Hz
    constant G0S_SOLS	: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4536/16,N_CUM)); -- G0S_SOLS	tone ~(2^-4)*415.30Hz
    constant A0_LA		: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4806/16,N_CUM)); -- A0_LA		tone ~(2^-4)*440.00Hz
    constant A0S_LAS	: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(5092/16,N_CUM)); -- A0S_LAS	tone ~(2^-4)*466.16Hz
    constant B0_SI		: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(5394/16,N_CUM)); -- B0_SI		tone ~(2^-4)*493.88Hz
	-------------------------------------------------------------------------------
     -- OCTAVE #1 (C1 until B1)
	constant C1_DO		: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(2858/8,N_CUM)); -- C1_DO		tone ~(2^-3)*261.63Hz
    constant C1S_DOS	:  	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3028/8,N_CUM)); -- C1S_DOS	tone ~(2^-3)*277.18Hz
    constant D1_RE		: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3208/8,N_CUM)); -- D1_RE		tone ~(2^-3)*293.66Hz
    constant D1S_RES	:  	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3398/8,N_CUM)); -- D1S_RES	tone ~(2^-3)*311.13Hz
    constant E1_MI		: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3600/8,N_CUM)); -- E1_MI		tone ~(2^-3)*329.63Hz
    constant F1_FA		: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3815/8,N_CUM)); -- F1_FA		tone ~(2^-3)*349.23Hz
    constant F1S_FAS	:  	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4041/8,N_CUM)); -- F1S_FAS	tone ~(2^-3)*369.99Hz
    constant G1_SOL  	: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4282/8,N_CUM)); -- G1_SOL  	tone ~(2^-3)*392.00Hz
    constant G1S_SOLS	:  	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4536/8,N_CUM)); -- G1S_SOLS	tone ~(2^-3)*415.30Hz
    constant A1_LA		: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4806/8,N_CUM)); -- A1_LA		tone ~(2^-3)*440.00Hz
    constant A1S_LAS	:  	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(5092/8,N_CUM)); -- A1S_LAS	tone ~(2^-3)*466.16Hz
    constant B1_SI		: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(5394/8,N_CUM)); -- B1_SI		tone ~(2^-3)*493.88Hz
	-------------------------------------------------------------------------------
	-- OCTAVE #2 (C2 until B2)
	constant C2_DO		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(2858/4,N_CUM)); -- C2_DO		tone ~0,25*261.63Hz
    constant C2S_DOS	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3028/4,N_CUM)); -- C2S_DOS	tone ~0,25*277.18Hz
    constant D2_RE		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3208/4,N_CUM)); -- D2_RE		tone ~0,25*293.66Hz
    constant D2S_RES	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3398/4,N_CUM)); -- D2S_RES	tone ~0,25*311.13Hz
    constant E2_MI		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3600/4,N_CUM)); -- E2_MI		tone ~0,25*329.63Hz
    constant F2_FA		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3815/4,N_CUM)); -- F2_FA		tone ~0,25*349.23Hz
    constant F2S_FAS	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4041/4,N_CUM)); -- F2S_FAS	tone ~0,25*369.99Hz
    constant G2_SOL  	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4282/4,N_CUM)); -- G2_SOL  	tone ~0,25*392.00Hz
    constant G2S_SOLS	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4536/4,N_CUM)); -- G2S_SOLS	tone ~0,25*415.30Hz
    constant A2_LA		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4806/4,N_CUM)); -- A2_LA		tone ~0,25*440.00Hz
    constant A2S_LAS	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(5092/4,N_CUM)); -- A2S_LAS	tone ~0,25*466.16Hz
    constant B2_SI		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(5394/4,N_CUM)); -- B2_SI		tone ~0,25*493.88Hz
	-------------------------------------------------------------------------------
	-- OCTAVE #3 (C3 until B3)
	constant C3_DO		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(2858/2,N_CUM)); -- C2_DO		tone ~0,5*261.63Hz
    constant C3S_DOS	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3028/2,N_CUM)); -- C2S_DOS	tone ~0,5*277.18Hz
    constant D3_RE		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3208/2,N_CUM)); -- D2_RE		tone ~0,5*293.66Hz
    constant D3S_RES	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3398/2,N_CUM)); -- D2S_RES	tone ~0,5*311.13Hz
    constant E3_MI		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3600/2,N_CUM)); -- E2_MI		tone ~0,5*329.63Hz
    constant F3_FA		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3815/2,N_CUM)); -- F2_FA		tone ~0,5*349.23Hz
    constant F3S_FAS	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4041/2,N_CUM)); -- F2S_FAS	tone ~0,5*369.99Hz
    constant G3_SOL  	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4282/2,N_CUM)); -- G2_SOL  	tone ~0,5*392.00Hz
    constant G3S_SOLS	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4536/2,N_CUM)); -- G2S_SOLS	tone ~0,5*415.30Hz
    constant A3_LA		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4806/2,N_CUM)); -- A2_LA		tone ~0,5*440.00Hz
    constant A3S_LAS	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(5092/2,N_CUM)); -- A2S_LAS	tone ~0,5*466.16Hz
    constant B3_SI		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(5394/2,N_CUM)); -- B2_SI		tone ~0,5*493.88Hz
	-------------------------------------------------------------------------------
    -- OCTAVE #4 (C4 until B4)
	constant C4_DO		: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(2858,N_CUM));   -- C4_DO		tone ~261.63Hz
    constant C4S_DOS	: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3028,N_CUM));   -- C4S_DOS	tone ~277.18Hz
    constant D4_RE		: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3208,N_CUM));   -- D4_RE		tone ~293.66Hz
    constant D4S_RES	: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3398,N_CUM));   -- D4S_RES	tone ~311.13Hz
    constant E4_MI		: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3600,N_CUM));   -- E4_MI		tone ~329.63Hz
    constant F4_FA		: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3815,N_CUM));   -- F4_FA		tone ~349.23Hz
    constant F4S_FAS	: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4041,N_CUM));   -- F4S_FAS	tone ~369.99Hz
    constant G4_SOL  	: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4282,N_CUM));   -- G4_SOL  	tone ~392.00Hz
    constant G4S_SOLS	: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4536,N_CUM));   -- G4S_SOLS	tone ~415.30Hz
    constant A4_LA		: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4806,N_CUM));   -- A4_LA		tone ~440.00Hz
    constant A4S_LAS	: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(5092,N_CUM));   -- A4S_LAS	tone ~466.16Hz
    constant B4_SI		: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(5394,N_CUM));   -- B4_SI		tone ~493.88Hz
	-------------------------------------------------------------------------------
     -- OCTAVE #5 (C5 until B5)
	constant C5_DO		: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(2858*2,N_CUM)); -- C5_DO		tone ~2*261.63Hz
    constant C5S_DOS	:  	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3028*2,N_CUM)); -- C5S_DOS	tone ~2*277.18Hz
    constant D5_RE		: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3208*2,N_CUM)); -- D5_RE		tone ~2*293.66Hz
    constant D5S_RES	:  	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3398*2,N_CUM)); -- D5S_RES	tone ~2*311.13Hz
    constant E5_MI		: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3600*2,N_CUM)); -- E5_MI		tone ~2*329.63Hz
    constant F5_FA		: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3815*2,N_CUM)); -- F5_FA		tone ~2*349.23Hz
    constant F5S_FAS	:  	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4041*2,N_CUM)); -- F5S_FAS	tone ~2*369.99Hz
    constant G5_SOL  	: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4282*2,N_CUM)); -- G5_SOL  	tone ~2*392.00Hz
    constant G5S_SOLS	:  	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4536*2,N_CUM)); -- G5S_SOLS	tone ~2*415.30Hz
    constant A5_LA		: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4806*2,N_CUM)); -- A5_LA		tone ~2*440.00Hz
    constant A5S_LAS	:  	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(5092*2,N_CUM)); -- A5S_LAS	tone ~2*466.16Hz
    constant B5_SI		: 	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(5394*2,N_CUM)); -- B5_SI		tone ~2*493.88Hz
	-------------------------------------------------------------------------------
	-- OCTAVE #6 (C6 until B6)
	constant C6_DO		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(2858*4,N_CUM)); -- C6_DO		tone ~4*261.63Hz
    constant C6S_DOS	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3028*4,N_CUM)); -- C6S_DOS	tone ~4*277.18Hz
    constant D6_RE		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3208*4,N_CUM)); -- D6_RE		tone ~4*293.66Hz
    constant D6S_RES	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3398*4,N_CUM)); -- D6S_RES	tone ~4*311.13Hz
    constant E6_MI		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3600*4,N_CUM)); -- E6_MI		tone ~4*329.63Hz
    constant F6_FA		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3815*4,N_CUM)); -- F6_FA		tone ~4*349.23Hz
    constant F6S_FAS	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4041*4,N_CUM)); -- F6S_FAS	tone ~4*369.99Hz
    constant G6_SOL  	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4282*4,N_CUM)); -- G6_SOL  	tone ~4*392.00Hz
    constant G6S_SOLS	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4536*4,N_CUM)); -- G6S_SOLS	tone ~4*415.30Hz
    constant A6_LA		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4806*4,N_CUM)); -- A6_LA		tone ~4*440.00Hz
    constant A6S_LAS	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(5092*4,N_CUM)); -- A6S_LAS	tone ~4*466.16Hz
    constant B6_SI		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(5394*4,N_CUM)); -- B6_SI		tone ~4*493.88Hz
	-------------------------------------------------------------------------------
	-- OCTAVE #7 (C7 until B7)
	constant C7_DO		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(2858*8,N_CUM)); -- C7_DO		tone ~8*261.63Hz
    constant C7S_DOS	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3028*8,N_CUM)); -- C7S_DOS	tone ~8*277.18Hz
    constant D7_RE		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3208*8,N_CUM)); -- D7_RE		tone ~8*293.66Hz
    constant D7S_RES	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3398*8,N_CUM)); -- D7S_RES	tone ~8*311.13Hz
    constant E7_MI		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3600*8,N_CUM)); -- E7_MI		tone ~8*329.63Hz
    constant F7_FA		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3815*8,N_CUM)); -- F7_FA		tone ~8*349.23Hz
    constant F7S_FAS	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4041*8,N_CUM)); -- F7S_FAS	tone ~8*369.99Hz
    constant G7_SOL  	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4282*8,N_CUM)); -- G7_SOL  	tone ~8*392.00Hz
    constant G7S_SOLS	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4536*8,N_CUM)); -- G7S_SOLS	tone ~8*415.30Hz
    constant A7_LA		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4806*8,N_CUM)); -- A7_LA		tone ~8*440.00Hz
    constant A7S_LAS	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(5092*8,N_CUM)); -- A7S_LAS	tone ~8*466.16Hz
    constant B7_SI		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(5394*8,N_CUM)); -- B7_SI		tone ~8*493.88Hz
	-------------------------------------------------------------------------------
	-- OCTAVE #8 (C8 until G8)
	constant C8_DO		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(2858*16,N_CUM)); -- C8_DO		tone ~16*261.63Hz
    constant C8S_DOS	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3028*16,N_CUM)); -- C8S_DOS	tone ~16*277.18Hz
    constant D8_RE		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3208*16,N_CUM)); -- D8_RE		tone ~16*293.66Hz
    constant D8S_RES	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3398*16,N_CUM)); -- D8S_RES	tone ~16*311.13Hz
    constant E8_MI		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3600*16,N_CUM)); -- E8_MI		tone ~16*329.63Hz
    constant F8_FA		:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(3815*16,N_CUM)); -- F8_FA		tone ~16*349.23Hz
    constant F8S_FAS	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4041*16,N_CUM)); -- F8S_FAS	tone ~16*369.99Hz
    constant G8_SOL  	:	std_logic_vector(N_CUM-1 downto 0):= std_logic_vector(to_unsigned(4282*16,N_CUM)); -- G8_SOL  	tone ~16*392.00Hz
    -- STOP MIDI RANGE ------------------------------------------------------------ 	


    -------------------------------------------------------------------------------
	-- TYPE AND LUT FOR MIDI NOTE_NUMBER (need to translate midi_cmd.number for dds.phi_incr)
	-------------------------------------------------------------------------------
	type t_lut_note_number is array (0 to 127) of std_logic_vector(N_CUM-1 downto 0);

	constant LUT_midi2dds : t_lut_note_number :=(
		0	 => CM2_DO		,  
		1	 => CM2S_DOS	,  
		2	 => DM2_RE		,  
		3	 => DM2S_RES	,  
		4	 => EM2_MI		,  
		5	 => FM2_FA		,  
		6	 => FM2S_FAS	,  
		7	 => GM2_SOL  	,  
		8	 => GM2S_SOLS	,  
		9    => AM2_LA		,  
		10	 => AM2S_LAS	,  
		11	 => BM2_SI		,  
		12	 => CM1_DO		,  
		13	 => CM1S_DOS	,  
		14	 => DM1_RE		,  
		15	 => DM1S_RES	,  
		16	 => EM1_MI		,  
		17	 => FM1_FA		,  
		18	 => FM1S_FAS	,  
		19   => GM1_SOL  	,  
		20	 => GM1S_SOLS	,  
		21	 => AM1_LA		,  
		22	 => AM1S_LAS	,  
		23	 => BM1_SI		,  
		24	 => C0_DO		,  
		25	 => C0S_DOS		,  
		26	 => D0_RE		,  
		27	 => D0S_RES		,  
		28	 => E0_MI		,  
		29   => F0_FA		,  
		30	 => F0S_FAS		,  
		31	 => G0_SOL  	,  
		32	 => G0S_SOLS	,  
		33	 => A0_LA		,  
		34	 => A0S_LAS		,  
		35	 => B0_SI		,  
		36	 => C1_DO		,  
		37	 => C1S_DOS		,  
		38	 => D1_RE		,  
		39   => D1S_RES		,  
		40	 => E1_MI		,  
		41	 => F1_FA		,  
		42	 => F1S_FAS		,  
		43	 => G1_SOL  	,  
		44	 => G1S_SOLS	,  
		45	 => A1_LA		,  
		46	 => A1S_LAS		,  
		47	 => B1_SI		,  
		48	 =>  C2_DO		,
		49   =>  C2S_DOS	,
		50	 =>  D2_RE		,
		51	 =>  D2S_RES	,
		52	 =>  E2_MI		,
		53	 =>  F2_FA		,
		54	 =>  F2S_FAS	,
		55	 =>  G2_SOL  	,
		56	 =>  G2S_SOLS	,
		57	 =>  A2_LA		,
		58	 =>  A2S_LAS	,
		59   =>  B2_SI		,
		60	 =>  C3_DO		, 
		61	 =>  C3S_DOS	, 
		62	 =>  D3_RE		, 
		63	 =>  D3S_RES	, 
		64	 =>  E3_MI		, 
		65	 =>  F3_FA		, 
		66	 =>  F3S_FAS	, 
		67	 =>  G3_SOL  	, 
		68	 =>  G3S_SOLS	, 
		69   =>  A3_LA		, 
		70	 =>  A3S_LAS	, 
		71	 =>  B3_SI		, 
		72	 =>  C4_DO		, 
		73	 =>  C4S_DOS	, 
		74	 =>  D4_RE		, 
		75	 =>  D4S_RES	, 
		76	 =>  E4_MI		, 
		77	 =>  F4_FA		, 
		78	 =>  F4S_FAS	, 
		79   =>  G4_SOL  	, 
		80	 =>  G4S_SOLS	, 
		81	 =>  A4_LA		, 
		82	 =>  A4S_LAS	, 
		83	 =>  B4_SI		, 
		84	 =>  C5_DO		, 
		85	 =>  C5S_DOS	, 
		86	 =>  D5_RE		, 
		87	 =>  D5S_RES	, 
		88	 =>  E5_MI		, 
		89   =>  F5_FA		, 
		90	 =>  F5S_FAS	, 
		91	 =>  G5_SOL  	, 
		92	 =>  G5S_SOLS	, 
		93	 =>  A5_LA		, 
		94	 =>  A5S_LAS	, 
		95	 =>  B5_SI		, 
		96	 =>  C6_DO		, 
		97	 =>  C6S_DOS	, 
		98	 =>  D6_RE		, 
		99   =>  D6S_RES	, 
		100	 =>  E6_MI		, 
		101	 =>  F6_FA		, 
		102	 =>  F6S_FAS	, 
		103	 =>  G6_SOL  	, 
		104	 =>  G6S_SOLS	, 
		105	 =>  A6_LA		, 
		106	 =>  A6S_LAS	, 
		107	 =>  B6_SI		, 
		108	 =>  C7_DO		, 
		109  =>  C7S_DOS	, 
		110	 =>  D7_RE		, 
		111	 =>  D7S_RES	, 
		112	 =>  E7_MI		, 
		113	 =>  F7_FA		, 
		114	 =>  F7S_FAS	, 
		115	 =>  G7_SOL  	, 
		116	 =>  G7S_SOLS	, 
		117	 =>  A7_LA		, 
		118	 =>  A7S_LAS	, 
		119  =>  B7_SI		, 
		120	 =>  C8_DO		, 
		121	 =>  C8S_DOS	, 
		122	 =>  D8_RE		, 
		123	 =>  D8S_RES	, 
		124	 =>  E8_MI		, 
		125	 =>  F8_FA		, 
		126	 =>  F8S_FAS	, 
		127	 =>  G8_SOL  	
		);
	
	-------------------------------------------------------------------------------		
end package;
