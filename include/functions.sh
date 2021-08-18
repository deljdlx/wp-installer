wpi_wp_cli_install() {
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    sudo mv wp-cli.phar /usr/local/bin/wp
}

wpi_display_install_info() {
    echo "=============================================================="
    echo "🟢 Install folder : $INSTALL_PATH";
    echo
    echo "    ◻️ Site url : $WORDPRESS_URL"
    echo "    ◻️ Database host : $MYSQL_HOST"
    echo "    ◻️ Database : $WORDPRESS_BDD"
    echo
    echo "    ◻️ Wordpress source folder : $WORDPRESS_FOLDER"
    echo "    ◻️ Content folder : $WORDPRESS_CONTENT_FOLDER"
    echo
    echo
}

wpi_wp_cli_config() {
    echo "💚 wp-cli configuration";
    echo "path: $WORDPRESS_FOLDER" > wp-cli.yml;
    echo "apache_modules:" >> wp-cli.yml;
    echo "  - mod_rewrite" >> wp-cli.yml;
}

wpi_replace_in_file() {
    php -r "file_put_contents('$3', str_replace('$1', '$2', file_get_contents('$3')));";
}

wpi_bdd_setup() {
    echo "💚 Database setup";

    DATABASE_LIST=`mysql -h$MYSQL_HOST -u$MYSQL_USER -p$MYSQL_PASSWORD --execute "SHOW DATABASES;"`;
    DATABASE_EXISTS=`echo $DATABASE_LIST | grep -e "\\b$WORDPRESS_BDD\\b"`

    if [ -z "$DATABASE_EXISTS" ]; then
        echo "✔️ Database does not exist";
        echo "    👌 Creating database $WORDPRESS_BDD";
        wpi_create_bdd
    else
        echo "⚠️ Database $WORDPRESS_BDD exists";
        read -p "☠️ Do you want to drop database $WORDPRESS_BDD. ? y/(N)" DROP_DATABASE

        echo
        if [ $DROP_DATABASE = "Y" ] || [ $DROP_DATABASE = "y" ]; then
            #clear bdd
            echo "    ☠️ Dropping database $WORDPRESS_BDD";
            echo "    👌 Creating database $WORDPRESS_BDD";
            mysql -h$MYSQL_HOST -u$MYSQL_USER -p$MYSQL_PASSWORD --execute="DROP DATABASE $WORDPRESS_BDD;"
            wpi_create_bdd
        fi
    fi
}


wpi_create_bdd()
{
    mysql -h$MYSQL_HOST -u$MYSQL_USER -p$MYSQL_PASSWORD --execute="CREATE DATABASE IF NOT EXISTS $WORDPRESS_BDD CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
}


wpi_handle_wpconfig() {
    echo "💚 Building wp-config.php";

    if [ -f wp-config.php ]
    then
        echo "💚 Backup of existing wp-config.php";
        BACKUP_DATE=`date +"%Y-%m-%d.%H-%M-%S"`;
        cp wp-config.php "wp-config.$BACKUP_DATE.php";
    fi

    cp "$INSTALL_PATH/$WORDPRESS_FOLDER/wp-config-sample.php" "$INSTALL_PATH/wp-config.php";

    wpi_replace_in_file 'database_name_here' $WORDPRESS_BDD "$INSTALL_PATH/wp-config.php";
    wpi_replace_in_file 'username_here' $MYSQL_USER "$INSTALL_PATH/wp-config.php";
    wpi_replace_in_file 'password_here' $MYSQL_PASSWORD "$INSTALL_PATH/wp-config.php";
    wpi_replace_in_file "define( \'WP_DEBUG\', false )" "define( \'WP_DEBUG\', true )" "$INSTALL_PATH/wp-config.php";

    wpi_replace_in_file "table_prefix = \'wp_\'" "table_prefix = \'$WORDPRESS_TABLE_PREFIX\'" "$INSTALL_PATH/wp-config.php";


    php -r "
        \$config = file_get_contents('$INSTALL_PATH/wp-config.php');

        \$config = preg_replace_callback('/put your unique phrase here/', function(\$matches) {
            return password_hash(uniqid(), PASSWORD_DEFAULT );
        }, \$config);

        file_put_contents('$INSTALL_PATH/wp-config.php', \$config);
    ";


    php -r "file_put_contents('$INSTALL_PATH/wp-config.php', str_replace('/* That\'s all, stop editing! Happy publishing. */', \"

define('WP_HOME', rtrim ( '$WORDPRESS_URL', '/' ));
define('WP_SITEURL', WP_HOME . '/$WORDPRESS_FOLDER');
define('WP_CONTENT_URL', WP_HOME . '/$WORDPRESS_CONTENT_FOLDER');
define('WP_CONTENT_DIR', __DIR__ . '/$WORDPRESS_CONTENT_FOLDER');
define('FS_METHOD','direct');
/* That\'s all, stop editing! Happy publishing. */\"
    , file_get_contents('$INSTALL_PATH/wp-config.php')));";


    # JWT auth plugin configuration

    php -r "
        \$lines = file('$INSTALL_PATH/wp-config.php');
        array_splice(\$lines, 20, 0, [
            '',
            '// JWT AUTH CONFIGURATION' . PHP_EOL,
            'define(\"JWT_AUTH_SECRET_KEY\", \"' . sha1(uniqid()) . md5(uniqid()) . '\");' . PHP_EOL,
            'define(\"JWT_AUTH_CORS_ENABLE\", true);' . PHP_EOL . PHP_EOL,
            '// ================================='  . PHP_EOL,
         ]);

         file_put_contents('$INSTALL_PATH/wp-config.php', implode('', \$lines));
    ";
}

wpi_handle_composer()
{
    if [ -f "$INSTALL_PATH/composer.json" ]
    then
        echo "💚 composer.json file exists================";
        echo "💚 Composer update================";
        cd $INSTALL_PATH;
        composer update;
    else
        echo "💚 creating composer.json file================";
        cp "$BASEDIR/provision/composer.json" "$INSTALL_PATH";
        wpi_replace_in_file  '"wordpress-install-dir": "wp"' '"wordpress-install-dir": "'$WORDPRESS_FOLDER'"' $INSTALL_PATH"/composer.json"
        wpi_replace_in_file  'wp-content/' $WORDPRESS_CONTENT_FOLDER"/" $INSTALL_PATH"/composer.json"
        echo "💚 Composer install================";
        cd $INSTALL_PATH;
        composer install;
    fi
}

wpi_handle_index()
{
    if [ -f "$INSTALL_PATH/index.php" ]
    then
        echo "💚 index.php file exists";
    else
        echo "💚 Building index.php";
        cp $WORDPRESS_FOLDER/index.php .;
        php -r "file_put_contents('index.php', str_replace('/wp-blog-header.php', '/$WORDPRESS_FOLDER/wp-blog-header.php', file_get_contents('index.php')));";
    fi
}

wpi_handle_gitignore()
{
    if [ -f "$INSTALL_PATH/.gitignore" ]
    then
        echo "💚 gitignore already exists================";
    else
        echo "💚 Adding .gitignore================";

        echo "$BASEDIR/provision/.gitignore";
        cp "$BASEDIR/provision/.gitignore" "$INSTALL_PATH";
    fi

    wpi_replace_in_file 'wp-content/' "$WORDPRESS_CONTENT_FOLDER/" "$INSTALL_PATH/.gitignore"
    wpi_replace_in_file 'wp_source_folder' "$WORDPRESS_FOLDER" "$INSTALL_PATH/.gitignore"
}

wpi_handle_wpcli()
{
    # vérification est ce que wp-cli est installé
    if [ -f "/usr/local/bin/wp" ]; then
        echo "✔️ wp-cli already installed================";
    else
        echo "💚 Install wp-cli================";
        wpi_wp_cli_install;
    fi
}

wpi_handle_createfolder()
{
    if [ ! -d $INSTALL_PATH ]; then
        echo "💚 Creating folder $INSTALL_PATH================";
        mkdir $INSTALL_PATH;
    fi

    if [ ! -d $INSTALL_PATH ]; then
        echo "❌ Creating folder $INSTALL_PATH failed================";
        exit;
    fi
}

wpi_handle_postinstall()
{
    echo "💚 Changing folder rigths";
    composer run chmod

    echo "💚 Generating .htaccess";
    composer run activate-htaccess


    php -r "
        \$lines = file('$INSTALL_PATH/.htaccess');
        array_splice(\$lines, 0, 0, [
            '# JWT AUTH CONFIGURATION' . PHP_EOL,
            'RewriteCond %{HTTP:Authorization} ^(.*)' . PHP_EOL,
            'RewriteRule ^(.*) - [E=HTTP_AUTHORIZATION:%1]' . PHP_EOL,
            'SetEnvIf Authorization \"(.*)\" HTTP_AUTHORIZATION=\$1' . PHP_EOL . PHP_EOL,
         ]);

         file_put_contents('$INSTALL_PATH/.htaccess', implode('', \$lines));
    ";


    echo "💚 Plugins activations";
    composer run activate-plugins
}

wpi_handle_wpinstall()
{
    # https://developer.wordpress.org/cli/commands/core/
    echo "💚 Wordpress installation";
    wp core install --url="$WORDPRESS_URL" --title="$WORDPRESS_SITE_NAME" --admin_user="$WORDPRESS_ADMIN_NAME" --admin_password="$WORDPRESS_ADMIN_PASSWORD" --admin_email="$WORDPRESS_ADMIN_EMAIL" --skip-email;
}


wpi_test_url()
{
    CHECK_URL=`curl -o /dev/null --silent --head --write-out '%{http_code}' $1/`
    if [ "$CHECK_URL" = 404 ]; then
        echo "❌ URL $1 can no be found. Please check your configuration. Installation stopped.";
        exit;
    else
        echo "✔️ URL $1 OK. Processing installation";
    fi
}


wpi_test_parent_url()
{
    PARENT_URL=`echo $WORDPRESS_URL | sed -r "s/\/[^\/]+\/?$//"`;
    wpi_test_url $PARENT_URL;
}


