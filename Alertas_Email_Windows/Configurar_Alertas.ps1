$ErrorActionPreference = 'Stop'
$base = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Host "CONFIGURACAO DOS ALERTAS DE E-MAIL - SIGE IP" -ForegroundColor Cyan
$smtp = Read-Host "Servidor SMTP (ex.: smtp.office365.com ou smtp.gmail.com)"
$port = Read-Host "Porta SMTP (normalmente 587)"
$sender = Read-Host "E-mail remetente"
$recipients = Read-Host "Destinatarios separados por ponto e virgula"
$backup = Read-Host "Caminho completo do backup automatico JSON (ex.: C:\SIGE-IP\dados\SIGE_IP_BACKUP_AUTOMATICO.json)"
$time = Read-Host "Horario diario no formato HH:mm (ex.: 07:00)"
$cred = Get-Credential -UserName $sender -Message "Informe o usuario e a senha do e-mail. A senha sera criptografada pelo Windows para este usuario."
$secure = $cred.Password | ConvertFrom-SecureString
$config = [ordered]@{
 smtp_server=$smtp; smtp_port=[int]$port; use_ssl=$true; sender_email=$sender;
 recipient_emails=@($recipients -split ';' | ForEach-Object {$_.Trim()} | Where-Object {$_});
 backup_file=$backup; daily_time=$time; thresholds=@(120,90,60,30,15,7,0);
 encrypted_password=$secure; smtp_username=$cred.UserName
}
$config | ConvertTo-Json -Depth 5 | Set-Content -Path (Join-Path $base 'config_alertas.json') -Encoding UTF8
Write-Host "Configuracao salva." -ForegroundColor Green
Write-Host "Agora execute Instalar_Agendamento.bat como administrador." -ForegroundColor Yellow
Pause
