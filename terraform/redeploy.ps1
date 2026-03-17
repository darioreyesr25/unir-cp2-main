<#
.SYNOPSIS
  Destroy and recreate the Terraform infrastructure from scratch.

.DESCRIPTION
  Runs `terraform destroy` then `terraform apply` in the terraform/ folder.
  It passes the SSH public key content via `-var ssh_public_key`.

  This script is intended to run from Windows PowerShell where Terraform is installed.
#>

param(
  [string]$SshPublicKeyPath = "$HOME\.ssh\id_rsa.pub",
  [switch]$Force
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Push-Location $scriptDir

if (-not (Test-Path $SshPublicKeyPath)) {
    Write-Error "No se encontró la clave pública en '$SshPublicKeyPath'." -ErrorAction Stop
}

$sshPublicKey = Get-Content -Raw -Path $SshPublicKeyPath

Write-Host "[Terraform] Destroying existing infrastructure..."
terraform destroy --auto-approve -var "ssh_public_key=$sshPublicKey"

Write-Host "[Terraform] Recreating infrastructure..."
terraform apply --auto-approve -var "ssh_public_key=$sshPublicKey"

Pop-Location
