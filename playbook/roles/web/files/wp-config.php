<?php

define('DB_NAME', 'wordpress');
define('DB_USER', 'wpuser');
define('DB_PASSWORD', '!MyPAS$word');
define('DB_HOST', '192.168.100.13');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', 'utf8_unicode_ci');

define('AUTH_KEY', '=KqhnGqB4L8# qhIg1ErqgP]Zbe}-%/KP`i}+kyKC|CD0%j-CMa`IRwXz03zM`2O');
define('SECURE_AUTH_KEY', 'muCS.Bs#tsQ{u}Qzl*A?|#Fbtw&Qn,+}oo%+o>+uGi]j+6W}y+]YJ<yV|=+Dm8F-');
define('LOGGED_IN_KEY', '1&`;Qn3Ywxik0zuncH?|tILKn*t/viL>N+#.eI,-6%zw7eKBJ|m/ZmRxD[->rJ6-');
define('NONCE_KEY', '7BMusWTe}]f{c-jbr4mT)ez<~,-p0T=jb!SE-3G]++V`u}PrM-Ikb:NdqEJX^J-F');
define('AUTH_SALT', 'fo&-C/Sx`V{eU0IJb+Oj3o3R-eX&lHpx80-:[+R)1$QsjqOJsv?;BoF Nv*CRO-N');
define('SECURE_AUTH_SALT', 'X;hXW^7=Z]jI<dIr!/eJA$^FE%g_n0>=Ix|np(ZWyQV_m+qZ(.TY4f=/pZzx$iVT');
define('LOGGED_IN_SALT', 'Mf8|kUYYf*GbkHs)B{[<y}:/}CLziY0>:~Fq$nWu4)|z#jc<.u=5$,bu8lY7h5r-');
define('NONCE_SALT', 'q.-_%aJ(|=be1>kvSF;1s~&`ocy#(RH-[NGeal:kX+X=vCUHeRDen6D;KD[Px7.|');

$table_prefix  = 'wp_';

define('WP_DEBUG', false);
if ( !defined('ABSPATH') )
    define('ABSPATH', dirname(__FILE__) . '/');
require_once(ABSPATH . 'wp-settings.php');
