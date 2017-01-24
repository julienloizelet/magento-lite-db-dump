magento-lite-db-dump
====================

Shell script that dumps a reduced version of the Magento database for use in
development.

This script dumps the entire database structure but leaves many tables empty.
These are generally tables corresponding to logs, customers, orders, wishlists,
etc.

The result is a more lightweight file to download, and does not contain
potentially sensitive customer data.

This would ideally be imported into the local database environment. I always
follow this with a second script that updates the development environment. The
most basic version of this would look something like this:

    UPDATE core_config_data SET value = 'http://magento.dev/' WHERE path = 'web/unsecure/baseurl';
    UPDATE core_config_data SET value = 'http://magento.dev/' WHERE path = 'web/secure/baseurl';

Probably you would have other configurations you should change too.

Usage
-----

Called from the command line, dumper.sh has the following options:
*   -h help
*   -d database
*   -u username
*   -H host
*   -g flag to gzip the resulting file.

The script produces a filename called $dbname.dump.sql(.gz)

Tables in 'global-parameters' file are left empty : see GLOBAL_IGNORED_TABLES variable.

If you have tables that are specifics to your project (e.g from third parts extension), you should
create a file called 'project-specific-parameters' with a content like :
SPECIFIC_IGNORED_TABLES=(
"my_module_table1"

"my_module_table2"

)


Collaboration
-------------

Your suggestions and pull requests are welcome!
