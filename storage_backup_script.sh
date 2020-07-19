#!/bin/bash
bd=`date +%m-%d-%Y`
#/bin/bash -c "/usr/bin/xtrabackup --backup --target-dir=/backups/$bd --compress" 2>>backup.log
/usr/bin/mydumper --outputdir=/backups/storage_$bd --verbose=3 --host=localhost --use-savepoints --kill-long-queries --chunk-filesize=5120 --build-empty-files --events --routines --triggers --compress --less-locking > /backups/backup_$bd.log 2>&1
if [ "$?" -eq "0" ]; then
        status="Daily backup is successfully completed for Storage server for day $bd"
else
        status="Daily backup failed for Storage server for day $bd"
fi
find /backups/ -daystart -mtime +9 -name 'storage_*' -type d -exec rm -rf {} \;
find /backups/ -daystart -mtime +30 -name '*.log' -type f -exec rm -rf {} \;
find /mysql/data -mmin +120 -name "storage-binlog.*" ! -name "storage-binlog.index" ! -name "*.gz" -type f -exec gzip '{}' \;
find /mysql/data -daystart -mtime +5 -name "storage-binlog*.gz" -type f  -exec rm -rf {} \;
{
echo $status
echo "Total Size of the backup is `du -sh /backups/storage_$bd | awk '{print $1}'`"
echo "`tail -n5 /backups/backup_$bd.log`"
}  | mail -s "Daily backup status for Storage on $bd" abcd@gmail.com yunushaikh@gmail.com -r sender@gmail.com
exit
