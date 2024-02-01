﻿# Defina as URLs dos arquivos no GitHub
$setupUrl = "https://raw.githubusercontent.com/renan-portes/install/main/office/setup.exe"
$xmlUrl = "https://raw.githubusercontent.com/renan-portes/install/main/office/2021.xml"

# Defina o caminho da pasta temporária
$tempFolder = "C:\office"

# Crie a pasta temporária se não existir
if (-not (Test-Path -Path $tempFolder -PathType Container)) {
    New-Item -ItemType Directory -Path $tempFolder | Out-Null
}

# Baixe os arquivos para a pasta temporária
Invoke-WebRequest -Uri $setupUrl -OutFile "$tempFolder\setup.exe"
Invoke-WebRequest -Uri $xmlUrl -OutFile "$tempFolder\2021.xml"

# Execute o comando de instalação do Office
Start-Process -FilePath "$tempFolder\setup.exe" -ArgumentList "/configure $tempFolder\2021.xml" -Wait
