<#
Script: Renan Portes Toolkit - Cloud Edition
Versão: 2.1 (Fix Office + Winget)
Contato: (44) 98827.9740
#>

# --- CONFIGURAÇÃO INICIAL ---
# Link do seu repositório (mantive o que você já usa)
$RepoURL = "https://raw.githubusercontent.com/renan-portes/install/main"

# Forçar TLS 1.2 para downloads seguros
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Show-Menu {
    Clear-Host
    Write-Host "==============================================================" -ForegroundColor Cyan
    Write-Host "               RENAN PORTES - MEU TÉCNICO ONLINE              " -ForegroundColor White
    Write-Host "                  Contato: (44) 98827.9740                    " -ForegroundColor DarkGray
    Write-Host "==============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host " [1] Instalar Essenciais (Chrome, Adobe Reader, WinRAR, AnyDesk)"
    Write-Host " [2] Instalar Office 2024 (Configuração Personalizada)"
    Write-Host " [3] Aplicar Otimizações (Regedit + Plano de Energia + Logo)"
    Write-Host " [4] Ativar Windows/Office (MAS Script)"
    Write-Host " [0] Sair"
    Write-Host ""
}

function Install-Essentials {
    Write-Host "[-] Verificando gerenciador de pacotes (Winget)..." -ForegroundColor Yellow
    
    # 1. Tenta forçar a instalação do Winget se não existir
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "Winget não encontrado. Baixando instalador oficial..." -ForegroundColor Cyan
        $wingetUrl = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        $wingetPath = "$env:TEMP\winget.msixbundle"
        try {
            Invoke-WebRequest -Uri $wingetUrl -OutFile $wingetPath
            Add-AppxPackage -Path $wingetPath
            Write-Host "Winget instalado!" -ForegroundColor Green
        } catch {
            Write-Host "Erro crítico: Não foi possível instalar o Winget. Atualize o Windows." -ForegroundColor Red
            Pause; return
        }
    }

    # 2. Localiza o executável real (necessário em sessões novas)
    $wingetCmd = "winget"
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        $wingetCmd = "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe"
    }

    Write-Host "[-] Iniciando instalação de programas..." -ForegroundColor Yellow
    $apps = @{
        "Google Chrome" = "Google.Chrome"
        "Adobe Reader"  = "Adobe.Acrobat.Reader.64-bit"
        "WinRAR"        = "RARLab.WinRAR"
        "AnyDesk"       = "AnyDeskSoftwareGmbH.AnyDesk"
    }

    foreach ($app in $apps.GetEnumerator()) {
        Write-Host "Instalando $($app.Key)..." -ForegroundColor Cyan
        # Usa Invoke-Expression para garantir execução correta do caminho
        Invoke-Expression "& '$wingetCmd' install --id $($app.Value) -e --silent --accept-package-agreements --accept-source-agreements"
    }
    Write-Host "Instalação de programas concluída!" -ForegroundColor Green
    Pause
}

function Install-Office {
    Write-Host "[-] Preparando instalação do Office 2024..." -ForegroundColor Yellow
    
    $OfficeTemp = "C:\OfficeTemp"
    New-Item -ItemType Directory -Force -Path $OfficeTemp | Out-Null
    
    # 1. Baixa o ODT (Ferramenta Oficial) - Link Direto Microsoft
    Write-Host "Baixando Ferramenta de Implantação (ODT)..."
    try {
        # Link oficial permanente da Microsoft para o ODT
        $odtUrl = "https://go.microsoft.com/fwlink/p/?LinkID=626065"
        Invoke-WebRequest -Uri $odtUrl -OutFile "$OfficeTemp\odt.exe"
    } catch {
        Write-Host "Erro ao baixar ODT. Verifique a internet." -ForegroundColor Red; Pause; return
    }

    # 2. Extrai o setup.exe de dentro do odt.exe
    Write-Host "Extraindo arquivos de instalação..."
    Start-Process -FilePath "$OfficeTemp\odt.exe" -ArgumentList "/quiet /extract:$OfficeTemp" -Wait

    # 3. Baixa o SEU config.xml do GitHub
    Write-Host "Baixando sua Configuração (config.xml)..."
    try {
        Invoke-WebRequest -Uri "$RepoURL/config.xml" -OutFile "$OfficeTemp\config.xml"
    } catch {
        Write-Host "Erro ao baixar config.xml do seu GitHub." -ForegroundColor Red; Pause; return
    }

    # 4. Executa a instalação
    if (Test-Path "$OfficeTemp\setup.exe") {
        Write-Host "Iniciando instalação do Office (Isso pode demorar)..." -ForegroundColor Cyan
        Start-Process -FilePath "$OfficeTemp\setup.exe" -ArgumentList "/configure $OfficeTemp\config.xml" -Wait
        Write-Host "Office Instalado com Sucesso!" -ForegroundColor Green
    } else {
        Write-Host "Erro: setup.exe não foi encontrado após extração." -ForegroundColor Red
    }
    
    # Limpeza e Atalhos
    Remove-Item -Path $OfficeTemp -Recurse -Force -ErrorAction SilentlyContinue
    
    $Desktop = [Environment]::GetFolderPath("Desktop")
    $CommonStartMenu = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"
    Copy-Item "$CommonStartMenu\Excel.lnk" -Destination $Desktop -ErrorAction SilentlyContinue
    Copy-Item "$CommonStartMenu\Word.lnk" -Destination $Desktop -ErrorAction SilentlyContinue
    
    Pause
}

function Apply-Tweaks {
    Write-Host "[-] Aplicando Otimizações..." -ForegroundColor Yellow
    $TechPath = "C:\meutecnico"
    New-Item -ItemType Directory -Force -Path $TechPath | Out-Null
    
    Write-Host "Configurando Logo e Registro..."
    try {
        Invoke-WebRequest -Uri "$RepoURL/logo-win.bmp" -OutFile "$TechPath\logo-win.bmp"
        Set-ItemProperty -Path $TechPath -Name Attributes -Value "Hidden"
        
        $RegFile = "$env:TEMP\Registry.reg"
        Invoke-WebRequest -Uri "$RepoURL/Registry.reg" -OutFile $RegFile
        Start-Process -FilePath "regedit.exe" -ArgumentList "/s $RegFile" -Wait
        Remove-Item $RegFile
    } catch { Write-Host "Aviso: Falha ao baixar arquivos de registro/logo." -ForegroundColor DarkGray }

    Write-Host "Importando Plano de Energia..."
    try {
        $PowFile = "$env:TEMP\Power.pow"
        Invoke-WebRequest -Uri "$RepoURL/Power.pow" -OutFile $PowFile
        powercfg -import $PowFile 77777777-7777-7777-7777-777777777777
        powercfg -SETACTIVE "77777777-7777-7777-7777-777777777777"
        Remove-Item $PowFile
    } catch { Write-Host "Aviso: Falha no plano de energia." -ForegroundColor DarkGray }

    Stop-Process -Name explorer -Force
    Write-Host "Otimizações Aplicadas!" -ForegroundColor Green
    Pause
}

function Run-Activator {
    Write-Host "[-] Abrindo Microsoft Activation Scripts (MAS)..." -ForegroundColor Yellow
    irm https://get.activated.win | iex
}

# --- LOOP PRINCIPAL ---
do {
    Show-Menu
    $input = Read-Host " Digite sua opção"
    switch ($input) {
        '1' { Install-Essentials }
        '2' { Install-Office }
        '3' { Apply-Tweaks }
        '4' { Run-Activator }
        '0' { Write-Host "Saindo..."; exit }
        default { Write-Host "Opção Inválida" -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
} while ($true)
