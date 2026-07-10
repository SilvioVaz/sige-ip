$ErrorActionPreference='Stop'
$base=Split-Path -Parent $MyInvocation.MyCommand.Path
$c=Get-Content (Join-Path $base 'config_alertas.json') -Raw|ConvertFrom-Json
$parts=$c.daily_time -split ':';$hour=[int]$parts[0];$minute=[int]$parts[1]
$script=Join-Path $base 'Enviar_Alertas.ps1'
$action=New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$script`""
$trigger=New-ScheduledTaskTrigger -Daily -At ([datetime]::Today.AddHours($hour).AddMinutes($minute))
$settings=New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries
Register-ScheduledTask -TaskName 'SIGE IP - Alertas de Vencimento' -Action $action -Trigger $trigger -Settings $settings -Description 'Envia alertas automáticos do SIGE IP' -Force | Out-Null
Write-Host 'Agendamento instalado com sucesso.' -ForegroundColor Green
Pause
