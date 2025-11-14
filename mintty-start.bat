@echo off
setlocal enabledelayedexpansion
:: \ => /
set "HOME=%USERPROFILE:\=/%"
:: TODO chdir to HOME
mintty.exe -e /bin/zsh
