<#
Script: Renan Portes Toolkit - Cloud Edition
Versão: 2.0
Contato: (44) 98827.9740
#>

# --- CONFIGURAÇÃO INICIAL ---
# IMPORTANTE: Troque esta URL pela URL "Raw" do seu repositório no GitHub
$RepoURL = "https://raw.githubusercontent.com/SEU_USUARIO/renan-toolkit/main"

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
    Write-Host "[-] Iniciando instalação via Winget..." -ForegroundColor Yellow
    
    # Lista de IDs do Winget (Substitui os .exe locais)
    $apps = @{
        "Google Chrome" = "Google.Chrome"
        "Adobe Reader"  = "Adobe.Acrobat.Reader.64-bit"
        "WinRAR"        = "RARLab.WinRAR"
        "AnyDesk"       = "AnyDeskSoftwareGmbH.AnyDesk"
    }

    foreach ($app in $apps.GetEnumerator()) {
        Write-Host "Instalando $($app.Key)..." -ForegroundColor Cyan
        winget install --id $app.Value -e --silent --accept-package-agreements --accept-source-agreements
    }
    Write-Host "Instalação de programas concluída!" -ForegroundColor Green
    Pause
}

function Install-Office {
    Write-Host "[-] Preparando instalação do Office 2024..." -ForegroundColor Yellow
    
    $OfficeTemp = "C:\OfficeTemp"
    New-Item -ItemType Directory -Force -Path $OfficeTemp | Out-Null
    
    # 1. Baixa o ODT oficial da Microsoft
    Write-Host "Baixando Setup Oficial..."
    Invoke-WebRequest -Uri "https://clients.config.office.net/releases/setup.exe" -OutFile "$OfficeTemp\setup.exe"
    
    # 2. Baixa o SEU config.xml do GitHub
    Write-Host "Baixando sua Configuração (config.xml)..."
    try {
        Invoke-WebRequest -Uri "$RepoURL/config.xml" -OutFile "$OfficeTemp\config.xml"
    } catch {
        Write-Host "Erro ao baixar config.xml. Verifique a URL." -ForegroundColor Red
        return
    }

    Write-Host "Instalando Office (Aguarde a janela fechar)..." -ForegroundColor Cyan
    # Executa o setup com seu XML
    Start-Process -FilePath "$OfficeTemp\setup.exe" -ArgumentList "/configure $OfficeTemp\config.xml" -Wait
    
    # Cria atalhos na Área de Trabalho (Excel e Word)
    # Nota: Seu config.xml exclui o Outlook, então não criarei atalho para ele.
    $Desktop = [Environment]::GetFolderPath("Desktop")
    $CommonStartMenu = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"
    
    Copy-Item "$CommonStartMenu\Excel.lnk" -Destination $Desktop -ErrorAction SilentlyContinue
    Copy-Item "$CommonStartMenu\Word.lnk" -Destination $Desktop -ErrorAction SilentlyContinue
    
    Remove-Item -Path $OfficeTemp -Recurse -Force
    Write-Host "Office Instalado com Sucesso!" -ForegroundColor Green
    Pause
}

function Apply-Tweaks {
    Write-Host "[-] Aplicando Otimizações..." -ForegroundColor Yellow
    $TechPath = "C:\meutecnico"
    New-Item -ItemType Directory -Force -Path $TechPath | Out-Null
    
    # 1. Baixar e Configurar Logo OEM
    Write-Host "Configurando Logo OEM..."
    try {
        Invoke-WebRequest -Uri "$RepoURL/logo-win.bmp" -OutFile "$TechPath\logo-win.bmp"
        Set-ItemProperty -Path $TechPath -Name Attributes -Value "Hidden"
    } catch {
        Write-Host "Aviso: Logo não encontrado no repositório." -ForegroundColor DarkGray
    }

    # 2. Baixar e Aplicar Registro
    Write-Host "Aplicando Registro..."
    $RegFile = "$env:TEMP\Registry.reg"
    try {
        Invoke-WebRequest -Uri "$RepoURL/Registry.reg" -OutFile $RegFile
        Start-Process -FilePath "regedit.exe" -ArgumentList "/s $RegFile" -Wait
        Remove-Item $RegFile
    } catch {
        Write-Host "Erro ao baixar Registry.reg" -ForegroundColor Red
    }

    # 3. Importar Plano de Energia (Bitsum/Renan)
    Write-Host "Importando Plano de Energia..."
    $PowFile = "$env:TEMP\Power.pow"
    try {
        Invoke-WebRequest -Uri "$RepoURL/Power.pow" -OutFile $PowFile
        # Importa usando o GUID específico que estava no seu script .bat
        powercfg -import $PowFile 77777777-7777-7777-7777-777777777777
        powercfg -SETACTIVE "77777777-7777-7777-7777-777777777777"
        Remove-Item $PowFile
    } catch {
        Write-Host "Erro ao importar plano de energia." -ForegroundColor Red
    }

    # Reiniciar Explorer para aplicar ícones e registro
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
