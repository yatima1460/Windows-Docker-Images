@echo off

echo +-------------------------------------------+
echo ^| Welcome to Yatima's Windows container! ♥  ^|
echo +-------------------------------------------+
echo(
echo vCores: %NUMBER_OF_PROCESSORS%
systeminfo | findstr "Available" | findstr "Physical" | findstr "Memory"
echo vDisks:
wmic diskdrive get Name,Model,SerialNumber,Size,Status
echo(
ver
echo(
