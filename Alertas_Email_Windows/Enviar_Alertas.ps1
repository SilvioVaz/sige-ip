$ErrorActionPreference='Stop'
$base=Split-Path -Parent $MyInvocation.MyCommand.Path
$configPath=Join-Path $base 'config_alertas.json'
$logPath=Join-Path $base 'historico_envios.json'
if(!(Test-Path $configPath)){throw 'Execute Configurar_Alertas.ps1 primeiro.'}
$c=Get-Content $configPath -Raw | ConvertFrom-Json
if(!(Test-Path $c.backup_file)){throw "Backup nao encontrado: $($c.backup_file). Abra o SIGE IP e configure o arquivo de backup automatico nesse caminho."}
$root=Get-Content $c.backup_file -Raw | ConvertFrom-Json
$db=if($root.format -eq 'SIGE-IP-BACKUP'){$root.data}else{$root}
$closed=@('Concluído','Concluido','Finalizado','Cancelado','Arquivado','Renovado','Encerrado')
$moduleNames=@{okrs='OKRs';projects='Projetos estratégicos';tasks='Tarefas';meetings='Reuniões';risks='Riscos';demands='Demandas rápidas';commitments='Compromissos';conversations='Conversas';charges='Cobranças';decisions='Decisões';contracts='Contratos';legal='Processos judiciais';mining='Processos minerários';annualRenewals='Renovações anuais';activeRenewals='Renovações tramitando';registrations='Registros'}
$rows=@();$today=(Get-Date).Date
foreach($prop in $db.PSObject.Properties){
 if($prop.Value -isnot [System.Collections.IEnumerable] -or $prop.Value -is [string]){continue}
 foreach($x in @($prop.Value)){
  if($null -eq $x){continue}; if($closed -contains [string]$x.status){continue}
  $dateText=$null
  foreach($f in @('dueDate','endDate','nextDeadline','nextDate','date','expectedEnd')){if($x.PSObject.Properties.Name -contains $f -and $x.$f){$dateText=$x.$f;break}}
  if(!$dateText){continue}
  try{$due=[datetime]::Parse([string]$dateText).Date}catch{continue}
  $days=($due-$today).Days
  $custom=120
  if($x.alertDays){$custom=[int]$x.alertDays}elseif($x.renewalAlert){$custom=[int]$x.renewalAlert}
  $hit=($days -lt 0) -or ($c.thresholds -contains $days) -or (($prop.Name -in @('annualRenewals','registrations','contracts')) -and $days -ge 0 -and $days -le $custom)
  if(!$hit){continue}
  $title=$x.title;if(!$title){$title=$x.objective};if(!$title){$title=$x.processNumber};if(!$title){$title=$x.target};if(!$title){$title='Sem título'}
  $rows += [pscustomobject]@{Modulo=$(if($moduleNames.ContainsKey($prop.Name)){$moduleNames[$prop.Name]}else{$prop.Name});Titulo=$title;Empresa=$x.company;Responsavel=$(if($x.responsible){$x.responsible}else{$x.owner});Vencimento=$due;Dias=$days;Status=$x.status;Prioridade=$x.priority;Id=$x.id}
 }
}
$rows=$rows|Sort-Object Dias,Vencimento
if($rows.Count -eq 0){exit 0}
$dateKey=(Get-Date -Format 'yyyy-MM-dd')
$history=@{};if(Test-Path $logPath){try{$obj=Get-Content $logPath -Raw|ConvertFrom-Json;foreach($pr in $obj.PSObject.Properties){$history[$pr.Name]=$pr.Value}}catch{$history=@{}}}
$signature=($rows|ForEach-Object{"$($_.Modulo)|$($_.Id)|$($_.Dias)"}) -join ';'
if($history[$dateKey] -eq $signature){exit 0}
$style='<style>body{font-family:Arial;color:#1f2937}table{border-collapse:collapse;width:100%}th,td{border:1px solid #ddd;padding:8px;text-align:left}th{background:#17324d;color:white}.late{background:#fee2e2}.soon{background:#fef3c7}</style>'
$html=$style+"<h2>SIGE IP — Alertas de vencimento</h2><p>Gerado em $(Get-Date -Format 'dd/MM/yyyy HH:mm'). Total: <b>$($rows.Count)</b>.</p><table><tr><th>Situação</th><th>Item</th><th>Módulo</th><th>Empresa</th><th>Responsável</th><th>Vencimento</th><th>Status</th></tr>"
foreach($r in $rows){$s=if($r.Dias -lt 0){"ATRASADO HÁ $([math]::Abs($r.Dias)) DIA(S)"}elseif($r.Dias -eq 0){'VENCE HOJE'}else{"FALTAM $($r.Dias) DIA(S)"};$cls=if($r.Dias -lt 0){'late'}else{'soon'};$html+="<tr class='$cls'><td><b>$s</b></td><td>$($r.Titulo)</td><td>$($r.Modulo)</td><td>$($r.Empresa)</td><td>$($r.Responsavel)</td><td>$($r.Vencimento.ToString('dd/MM/yyyy'))</td><td>$($r.Status)</td></tr>"}
$html+='</table><p>Mensagem automática do SIGE IP.</p>'
$sec=ConvertTo-SecureString $c.encrypted_password
$cred=New-Object System.Management.Automation.PSCredential($c.smtp_username,$sec)
$msg=New-Object System.Net.Mail.MailMessage
$msg.From=$c.sender_email;foreach($to in $c.recipient_emails){[void]$msg.To.Add($to)}
$msg.Subject="SIGE IP — $($rows.Count) alerta(s) de vencimento — $(Get-Date -Format 'dd/MM/yyyy')";$msg.Body=$html;$msg.IsBodyHtml=$true
$smtp=New-Object System.Net.Mail.SmtpClient($c.smtp_server,[int]$c.smtp_port);$smtp.EnableSsl=[bool]$c.use_ssl;$smtp.Credentials=$cred;$smtp.Send($msg)
$history[$dateKey]=$signature;$history|ConvertTo-Json -Depth 5|Set-Content $logPath -Encoding UTF8
