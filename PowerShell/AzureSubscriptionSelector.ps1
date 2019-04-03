function Login {
    $needLogin = $true
    Try {
        $content = Get-AzContext
        if ($content) {
            $needLogin = ([string]::IsNullOrEmpty($content.Account))
        } 
    } 
    Catch {
        if ($_ -like "*Login-AzAccount to login*") {
            $needLogin = $true
        } 
        else {
            throw
        }
    }

    if ($needLogin) {
        Login-AzAccount
    }
}


Function Select-Subs {
    CLS
    $ErrorActionPreference = 'SilentlyContinue'
    $Menu = 0
    $Subs = @(Get-AzSubscription | select Name, ID, TenantId)

    Write-Host "Please select the subscription you want to use:" -ForegroundColor Green;
    % {Write-Host ""}
    $Subs | % {Write-Host "[$($Menu)]" -ForegroundColor Cyan -NoNewline ; Write-host ". $($_.Name)"; $Menu++; }
    % {Write-Host ""}
    % {Write-Host "[S]" -ForegroundColor Yellow -NoNewline ; Write-host ". To switch Azure Account."}
    % {Write-Host ""}
    % {Write-Host "[Q]" -ForegroundColor Red -NoNewline ; Write-host ". To quit."}
    % {Write-Host ""}
    $selection = Read-Host "Please select the Subscription Number - Valid numbers are 0 - $($Subs.count -1), S to switch Azure Account or Q to quit"
    If ($selection -eq 'S') { 
        Get-AzContext | ForEach-Object {Clear-AzContext -Scope CurrentUser -Force}
        Login
        Select-Subs
    }
    If ($selection -eq 'Q') { 
        Clear-Host
        Exit
    }
    If ($Subs.item($selection) -ne $null)
    { Return @{name = $subs[$selection].Name; ID = $subs[$selection].ID} 
    }

}

$SubscriptionSelection = Select-Subs
Select-AzSubscription -SubscriptionName $SubscriptionSelection.Name -ErrorAction Stop