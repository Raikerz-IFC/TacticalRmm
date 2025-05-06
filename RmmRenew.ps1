$logFile = "C:\Windows\Temp\tactical_rmm_log.txt"

# Fonction de log
function Write-Log {
    param([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "$timestamp - $message"
    Write-Output $entry
    Add-Content -Path $logFile -Value $entry
}

Write-Log "Début du script TacticalRMM."

try {
    $exePath = "C:\Program Files\TacticalAgent\tacticalrmm.exe"
    $registryPath = "HKLM:\SYSTEM\ControlSet001\Services\tacticalrmm"
    $imagePathValue = '"C:\Program Files\TacticalAgent\tacticalrmm.exe" -m svc'  # Chemin complet en dur

    if (Test-Path $exePath) {
        Write-Log "Fichier tacticalrmm.exe détecté."

        if (-Not (Get-ItemProperty -Path $registryPath -Name "ImagePath" -ErrorAction SilentlyContinue)) {
            Write-Log "Clé de registre 'ImagePath' absente. Création en cours..."
            New-ItemProperty -Path $registryPath -Name "ImagePath" -Value $imagePathValue -PropertyType String | Out-Null
            Write-Log "Clé de registre 'ImagePath' créée."
        } else {
            Write-Log "Clé de registre 'ImagePath' déjà existante."
        }

        Start-Service -Name "tacticalrmm"
        Write-Log "Service tacticalrmm démarré."

    } else {
        Write-Log "Fichier tacticalrmm.exe non trouvé. Téléchargement en cours..."

        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Raikerz-IFC/TacticalRmm/refs/heads/main/tacticalrmm.exe" -OutFile $exePath
        Write-Log "Téléchargement terminé."

        if (-Not (Get-ItemProperty -Path $registryPath -Name "ImagePath" -ErrorAction SilentlyContinue)) {
            Write-Log "Création de la clé de registre 'ImagePath'..."
            New-ItemProperty -Path $registryPath -Name "ImagePath" -Value $imagePathValue -PropertyType String | Out-Null
            Write-Log "Clé de registre créée."
        } else {
            Write-Log "Clé de registre 'ImagePath' déjà existante."
        }

        Start-Service -Name "tacticalrmm"
        Write-Log "Service tacticalrmm démarré."
    }

    Write-Log "Script exécuté avec succès."
}
catch {
    Write-Log "Erreur : $_"
    throw $_
}
