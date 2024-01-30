@echo off
echo Script criado por Renan Portes.
echo Contato (44) 98827.9740
echo Ultima Atualizacao 30/01/2024
pause

powershell -ExecutionPolicy ByPass -Command "& { Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/renan-portes/install/main/_files/registry.ps1' -UseBasicParsing | Invoke-Expression }"

echo Configuracoes aplicadas com sucesso!
echo Reiniciando o Explorer...
taskkill /f /im explorer.exe
start explorer.exe

set "url=https://raw.githubusercontent.com/renan-portes/install/main/_files/Power.pow"
set "destino=%temp%\Power.pow"
set "guid=77777777-7777-7777-7777-777777777777"

:: Baixar o arquivo Power.pow do GitHub usando curl
curl -o "%destino%" %url%

:: Importar o plano de energia
powercfg -import "%destino%" %guid%
powercfg -SETACTIVE %guid%
powercfg /query

echo Power Plan importado com sucesso!


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

@echo off

set /p installOffice=Deseja instalar o Microsoft Office? (Digite 's' para sim, 'n' para nao): 

if /i "%installOffice%" equ "s" (
    echo Iniciando a instalacao do Microsoft Office...
    
    :: Criar a pasta em c:\Office
    if not exist c:\Office mkdir c:\Office
    
    :: Baixar setup.exe e config.xml do GitHub usando PowerShell
    powershell -Command "& {Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/renan-portes/install/main/_office/setup.exe' -OutFile 'c:\Office\setup.exe'; Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/renan-portes/install/main/_office/config.xml' -OutFile 'c:\Office\config.xml'}"
    
    :: Executar a instalacao
    cd c:\Office
	echo Baixando a ultima versao disponivel
    start "" /wait setup.exe /download config.xml
    timeout 2 >nul
	echo Instalando...
    start "" /wait setup.exe /configure config.xml
	copy "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Word.lnk" "%USERPROFILE%\Desktop\Word.lnk"
	copy "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Excel.lnk" "%USERPROFILE%\Desktop\Excel.lnk"
	cd c:\
    
    :: Excluir os arquivos apos a instalacao
    if exist "c:\Office" rmdir /s /q "c:\Office"
    
    echo Instalacao concluida.
    
) else (
    echo Pulando a instalacao do Microsoft Office.
)

pause

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

echo ------Criar Ponto De Restauracao------

wmic.exe /Namespace:\\root\default Path SystemRestore Call Enable "C:"
timeout 2 >nul
wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "INSTALL", 100, 7
timeout 2 >nul

echo Ponto de Restauracao criado com sucesso!

echo Definindo Google Chrome como padrao
powershell -ExecutionPolicy ByPass -Command "& { Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/renan-portes/install/main/_files/chome-default.ps1' -UseBasicParsing | Invoke-Expression }"

echo Script finalizado com sucesso, instale os update e reinicie o computador
echo Script criado por Renan Portes.
echo Contato (44) 98827.9740
echo Ultima Atualizacao 30/01/2024
pause

control /name Microsoft.WindowsUpdate
