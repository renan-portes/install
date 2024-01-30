@echo off
@echo Script criado por Renan Portes.
@echo Contato (44) 98827.9740
@echo Ultima Atualizacao 30/01/2024
pause

echo Configuracoes aplicadas com sucesso!
echo Reiniciando o Explorer

REM Restart Explorer
taskkill /f /im explorer.exe
start explorer.exe

@echo ------Instalando Power Plan------
powercfg -import "c:\_install\_files\Power.pow" 77777777-7777-7777-7777-777777777777
powercfg -SETACTIVE "77777777-7777-7777-7777-777777777777"
powercfg /query


@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

choco --version

choco install directx --ignore-checksums -y
choco install dotnet-runtime --ignore-checksums -y
choco install vcredist2008 --ignore-checksums -y
choco install vcredist2010 --ignore-checksums -y
choco install vscommands2012 --ignore-checksums -y
choco install vcredist2013 --ignore-checksums -y
choco install vcredist140 --ignore-checksums -y
choco install googlechrome --ignore-checksums -y
choco install winrar --ignore-checksums -y
choco install adobereader --ignore-checksums -y
choco install anydesk.install --ignore-checksums -y

timeout 2 >nul

:: Pergunta sobre a instalação do Office
set /p installOffice=Deseja instalar o Microsoft Office? (Digite 's' para sim, 'n' para nao): 

if /i "%installOffice%" equ "s" (
    echo Iniciando a instalacao do Microsoft Office...
    :: Adicione aqui os comandos ou chamadas de instalação do Office
		cd c:\_install\Office
		setup.exe /configure config.xml
		timeout 2 >nul
		copy "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Word.lnk" "%USERPROFILE%\Desktop\Word.lnk"
		copy "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Excel.lnk" "%USERPROFILE%\Desktop\Excel.lnk"
) else (
    echo Pulando a instalacao do Microsoft Office.
)

timeout 2 >nul

:: Pergunta sobre a ativação do Windows/Office
set /p activateWindows=Deseja ativar o Windows/Office? (Digite 's' para sim, 'n' para nao): 

if /i "%activateWindows%" equ "s" (
    :: Adicione aqui os comandos ou chamadas para ativar o Windows
	powershell -Command "& {irm https://massgrave.dev/get | iex}"
    echo Ativando o Windows/Office...
) else (
    echo Pulando a ativacao do Windows.
)

timeout 2 >nul

:: Pergunta para excluir o diretório
set /p deleteDirectory=Deseja excluir o diretorio C:\_install? (Digite 's' para sim, 'n' para nao): 

if /i "%deleteDirectory%" equ "s" (
    :: Excluir o diretório
    rmdir /s /q "C:\_install"
    echo Diretorio C:\_install excluído.
) else (
    echo Operacao de exclusao cancelada.
)

timeout 2 >nul

@echo off
echo ------Criar Ponto De Restauracao------

wmic.exe /Namespace:\\root\default Path SystemRestore Call Enable "C:"
timeout 2 >nul
wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "INSTALL", 100, 7
timeout 2 >nul

echo Ponto de Restauracao criado com sucesso!

control /name Microsoft.WindowsUpdate
