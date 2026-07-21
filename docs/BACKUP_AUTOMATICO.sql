create extension if not exists pg_cron;
select cron.schedule('sige-backup-diario','0 3 * * *',$$
 insert into public.app_backups(organization_id,data,reason)
 select organization_id,data,'Backup automático diário' from public.app_states;
 select public.prune_old_backups();
$$);
