CURRENT_PATH=$(pwd);

BASEDIR=$(dirname "$0")
BASEDIR=$(php -r "echo realpath('$BASEDIR');");


INSTALL_PATH_DEFAULT=$(php -r "echo realpath('$CURRENT_PATH/..') . '/public';");
SITE_URL_DEFAULT=$(php -r "echo 'http://localhost' . str_replace('/var/www/html/', '/', '$INSTALL_PATH_DEFAULT');");



echo;
echo "========================================================";
echo "==================== INITIALISATION ====================";
echo "========================================================";
echo;
echo "🛠️ Loading functions";
. "$BASEDIR/include/functions.sh"
echo "🛠️ Loading default configuration";
. "$BASEDIR/include/configuration.default.sh"


# =======================================================================================================
# =======================================================================================================

# configuration checking
if [ -f "$BASEDIR/configuration.sh" ]; then
    echo;
    echo "========================================================";
    echo "== Configuration file found, loading configuration.sh ==";
    echo "========================================================";
    echo;
    echo "🛠️ Loading configuration";
    . "$BASEDIR/configuration.sh";
    echo;
fi

# =======================================================================================================





echo;
echo "========================================================";
echo "================ INSTALL CONFIGURATION =================";
echo "========================================================";
echo;


if [ -z $INSTALL_PATH ]; then
    if [ -z $1 ]; then
        read -p "❔ Installation folder ($INSTALL_PATH_DEFAULT) : " INSTALL_PATH;
    fi
    if [ -z $INSTALL_PATH ]; then
        INSTALL_PATH=$INSTALL_PATH_DEFAULT;
    fi
fi
echo "✔️ Install path $INSTALL_PATH";
echo;


if [ -z $WORDPRESS_URL ]; then
    read -p "❔ Site URL ($SITE_URL_DEFAULT) : " WORDPRESS_URL;
    if [ -z $WORDPRESS_URL ]; then
        WORDPRESS_URL=$SITE_URL_DEFAULT;
    fi
fi
echo "✔️ Site URL : $WORDPRESS_URL";
echo;


if [ -z $MYSQL_USER ]; then
    read -p "❔ Mysql user ($MYSQL_USER_DEFAULT) : " MYSQL_USER;
    if [ -z $MYSQL_USER ]; then
        MYSQL_USER=$MYSQL_USER_DEFAULT;
    fi
fi
echo "✔️ Mysql user : " $MYSQL_USER;
echo

if [ -z $MYSQL_PASSWORD ]; then
    read -p "❔ Mysql password ($MYSQL_PASSWORD_DEFAULT) : " MYSQL_PASSWORD;
    if [ -z $MYSQL_PASSWORD ]; then
        MYSQL_PASSWORD=$MYSQL_PASSWORD_DEFAULT;
    fi
fi
echo "✔️ Mysql password : " $MYSQL_PASSWORD;
echo

if [ -z $MYSQL_HOST ]; then
    read -p "❔ Mysql host ($MYSQL_HOST_DEFAULT) : " MYSQL_HOST;
    if [ -z $MYSQL_HOST ]; then
        MYSQL_HOST=$MYSQL_HOST_DEFAULT;
    fi
fi
echo "✔️ Mysql host : " $MYSQL_HOST;
echo


if [ -z $WORDPRESS_BDD ]; then
    read -p "❔ Mysql database ($WORDPRESS_BDD_DEFAULT) : " WORDPRESS_BDD;
    if [ -z $WORDPRESS_BDD ]; then
        WORDPRESS_BDD=$WORDPRESS_BDD_DEFAULT;
    fi
fi
echo "✔️ Mysql host : " $WORDPRESS_BDD_DEFAULT;
echo


if [ -z $WORDPRESS_TABLE_PREFIX ]; then
    read -p "❔ Mysql table prefix ($WORDPRESS_TABLE_PREFIX_DEFAULT) : " WORDPRESS_TABLE_PREFIX;
    if [ -z $WORDPRESS_TABLE_PREFIX ]; then
        WORDPRESS_TABLE_PREFIX=$WORDPRESS_TABLE_PREFIX_DEFAULT;
    fi
fi
echo "✔️ Mysql table prefix : " $WORDPRESS_TABLE_PREFIX;
echo



if [ -z $WORDPRESS_SITE_NAME ]; then
    read -p "❔ Site name ($WORDPRESS_SITE_NAME_DEFAULT) : " WORDPRESS_SITE_NAME;
    if [ -z $WORDPRESS_SITE_NAME ]; then
        WORDPRESS_SITE_NAME=$WORDPRESS_SITE_NAME_DEFAULT;
    fi
fi
echo "✔️ Site name : " $WORDPRESS_SITE_NAME;
echo


if [ -z $WORDPRESS_ADMIN_NAME ]; then
    read -p "❔ Admin login ($WORDPRESS_ADMIN_NAME_DEFAULT) : " WORDPRESS_ADMIN_NAME;
    if [ -z $WORDPRESS_ADMIN_NAME ]; then
        WORDPRESS_ADMIN_NAME=$WORDPRESS_ADMIN_NAME_DEFAULT;
    fi
fi
echo "✔️ Admin login : " $WORDPRESS_ADMIN_NAME;
echo

if [ -z $WORDPRESS_ADMIN_PASSWORD ]; then
    read -p "❔ Admin password ($WORDPRESS_ADMIN_PASSWORD_DEFAULT) : " WORDPRESS_ADMIN_PASSWORD;
    if [ -z $WORDPRESS_ADMIN_PASSWORD ]; then
        WORDPRESS_ADMIN_PASSWORD=$WORDPRESS_ADMIN_PASSWORD_DEFAULT;
    fi
fi
echo "✔️ Admin password : " $WORDPRESS_ADMIN_PASSWORD;
echo


if [ -z $WORDPRESS_ADMIN_EMAIL ]; then
    read -p "❔ Admin email ($WORDPRESS_ADMIN_EMAIL_DEFAULT) : " WORDPRESS_ADMIN_EMAIL;
    if [ -z $WORDPRESS_ADMIN_EMAIL ]; then
        WORDPRESS_ADMIN_EMAIL=$WORDPRESS_ADMIN_EMAIL_DEFAULT;
    fi
fi
echo "✔️ Admin email : " $WORDPRESS_ADMIN_EMAIL;
echo


# =======================================================================================================

wpi_display_install_info;


read -p "Continue ? [y]/n : " CONFIRM_INSTALL;
if [ "$CONFIRM_INSTALL" = "n" ]; then
    echo "❌ Aborting installation";
    exit;
else
    echo "✔️ Starting installation";
fi

echo;


echo;
echo "========================================================";
echo "================= STARTING INSTALL =====================";
echo "========================================================";
echo;



wpi_test_parent_url $WORDPRESS_URL;
wpi_handle_createfolder;
wpi_test_url $WORDPRESS_URL;


wpi_bdd_setup;
wpi_handle_wpcli;


wpi_handle_gitignore;

wpi_handle_composer;

wpi_handle_index;
wpi_handle_wpconfig;
wpi_wp_cli_config;



wpi_handle_wpinstall;
wpi_handle_postinstall;


echo "👌 Install successfull.";
echo "      🏠 Front URL : $WORDPRESS_URL";
echo "      ⚙️ Back URL : $WORDPRESS_URL/$WORDPRESS_FOLDER/wp-admin";


cd $CURRENT_PATH;
