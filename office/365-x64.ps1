# Defina as URLs dos arquivos no GitHub
$setupUrl = "https://raw.githubusercontent.com/renan-portes/install/main/office/setup.exe"
$xmlUrl = "https://raw.githubusercontent.com/renan-portes/install/main/office/365-x64.xml"

# Defina o caminho da pasta temporária
$tempFolder = "C:\office"

# Crie a pasta temporária se não existir
if (-not (Test-Path -Path $tempFolder -PathType Container)) {
    New-Item -ItemType Directory -Path $tempFolder | Out-Null
}

# Baixe os arquivos para a pasta temporária
Invoke-WebRequest -Uri $setupUrl -OutFile "$tempFolder\setup.exe"
Invoke-WebRequest -Uri $xmlUrl -OutFile "$tempFolder\365-x64.xml"

# Execute o comando de instalação do Office
Start-Process -FilePath "$tempFolder\setup.exe" -ArgumentList "/configure $tempFolder\365-x64.xml" -Wait

Copy-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Word.lnk" "$env:USERPROFILE\Desktop\Word.lnk"
Copy-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Excel.lnk" "$env:USERPROFILE\Desktop\Excel.lnk"
Copy-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\PowerPoint.lnk" "$env:USERPROFILE\Desktop\PowerPoint.lnk"