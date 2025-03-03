CREATE DATABASE cocacola;
pg_restore -U postgres -h localhost -d cocacola -F c D:\paginaWeb\copia_base.backup


psql -U postgres -h localhost -p 5452 -d cocacola -f D:/paginaWeb/backup_db/backup_21_02_2025.sql

