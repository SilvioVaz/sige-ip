@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Enviar_Alertas.ps1"
if errorlevel 1 pause
