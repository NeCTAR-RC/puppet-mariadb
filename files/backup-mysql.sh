#!/bin/bash -e

PATH=/usr/bin:/usr/sbin:/bin:/sbin

date=`date +"%Y-%m-%d"`
hostname=`hostname -f`
backup_dir=/var/lib/backup/mysql/$hostname/
days_to_keep=30

dump=/usr/bin/mysqldump
dump_options=""
show=/usr/bin/mysqlshow
show_options=""

dir_name=backup-${date}
dir_name_full=${backup_dir}/${dir_name}
file_name=${dir_name}.tar.gz

rm -fr ${dir_name_full}
mkdir -p ${dir_name_full}

for database in `${show} ${show_options} | awk '{if (NF == 3) { print $2 }}' | egrep -v "^Databases$|^information_schema$|^performance_schema$"` ; do
    ${dump} ${dump_options} ${database} >> ${dir_name_full}/${database}.sql
done

mkdir -p ${backup_dir}
cd ${backup_dir}
rm -f ${file_name}
tar czf ${file_name} ${dir_name}
rm -rf ${dir_name}

find ${backup_dir} -ctime +${days_to_keep} -type f -print | xargs rm 2>/dev/null
