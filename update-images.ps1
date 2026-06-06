#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Controleer nieuwe Docker image versies en verwerk ze in projectbestanden.

.DESCRIPTION
    Bevraagt Docker Hub en de WordPress API voor nieuwere versies van:
      - WordPress (Apache, FPM-alpine, CLI varianten)
      - MariaDB
      - PECL memcached extensie

    Past automatisch bij: Dockerfiles, docker-compose.yml,
    Helm Chart.yaml, values.yaml en README bestanden.

.PARAMETER DryRun
    Toont welke wijzigingen worden gemaakt, zonder bestanden aan te passen.

.PARAMETER Force
    Past wijzigingen toe zonder bevestigingsvraag.

.EXAMPLE
    .\update-images.ps1 -DryRun
    .\update-images.ps1
    .\update-images.ps1 -Force
#>

[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ROOT  = $PSScriptRoot
$script:Changes = [System.Collections.Generic.List[hashtable]]::new()

# ----------- output helpers --------------------------------------------------

function Write-Header {
    param([string]$Title)
    Write-Host ''
    Write-Host "=== $Title ===" -ForegroundColor Magenta
}

function Write-Info { param([string]$Msg) Write-Host "    $Msg" -ForegroundColor DarkGray }
function Write-Ok   { param([string]$Msg) Write-Host "  [OK] $Msg" -ForegroundColor Green }
function Write-Warn { param([string]$Msg) Write-Host "  [!]  $Msg" -ForegroundColor Yellow }
function Write-Skip { param([string]$Msg) Write-Host "  [-]  $Msg" -ForegroundColor DarkGray }

# ----------- versie helpers --------------------------------------------------

function Compare-SemVer {
    param([string]$A, [string]$B)
    # Geeft 1 terug als A > B, -1 als A < B, 0 als gelijk
    $splitA = $A -split '\.' | ForEach-Object { [int]$_ }
    $splitB = $B -split '\.' | ForEach-Object { [int]$_ }
    $len = [Math]::Max($splitA.Count, $splitB.Count)
    for ($i = 0; $i -lt $len; $i++) {
        $av = if ($i -lt $splitA.Count) { $splitA[$i] } else { 0 }
        $bv = if ($i -lt $splitB.Count) { $splitB[$i] } else { 0 }
        if ($av -gt $bv) { return  1 }
        if ($av -lt $bv) { return -1 }
    }
    return 0
}

function Get-HighestVersion {
    param([string[]]$Versions)
    return $Versions | Sort-Object {
        $parts = ($_ -split '\.') | ForEach-Object { if ($_ -match '^\d+$') { [long]$_ } else { 0L } }
        $score = 0L
        for ($i = 0; $i -lt $parts.Count; $i++) {
            $score += $parts[$i] * [Math]::Pow(1000, 4 - $i)
        }
        $score
    } -Descending | Select-Object -First 1
}

# ----------- API helpers -----------------------------------------------------

function Invoke-ApiSafely {
    param([string]$Uri, [int]$TimeoutSec = 20)
    try {
        return Invoke-RestMethod -Uri $Uri -TimeoutSec $TimeoutSec -UseBasicParsing
    }
    catch {
        Write-Warn "API-aanroep mislukt voor $Uri : $($_.Exception.Message)"
        return $null
    }
}

function Get-DockerHubTags {
    param([string]$Image, [string]$Filter = '', [int]$MaxPages = 4)

    $all  = [System.Collections.Generic.List[string]]::new()
    $base = "https://hub.docker.com/v2/repositories/library/$Image/tags?page_size=100"
    if ($Filter) { $base += "&name=$([uri]::EscapeDataString($Filter))" }

    for ($p = 1; $p -le $MaxPages; $p++) {
        $resp = Invoke-ApiSafely -Uri "$base&page=$p"
        if (-not $resp -or -not $resp.results) { break }
        $resp.results | ForEach-Object { $all.Add($_.name) }
        if (-not $resp.next) { break }
    }
    return $all.ToArray()
}

# ----------- versie ophalers -------------------------------------------------

function Get-LatestWordPressVersion {
    Write-Info 'Ophalen WordPress stabiele release...'
    $resp = Invoke-ApiSafely 'https://api.wordpress.org/core/version-check/1.7/'
    if (-not $resp) { return $null }
    $stable = $resp.offers | Where-Object { $_.response -eq 'upgrade' -or $_.response -eq 'latest' } |
              Select-Object -First 1
    if ($stable) { return $stable.version } else { return $resp.offers[0].version }
}

function Get-LatestMariaDBTag {
    param([string]$MajorLine = '12')
    Write-Info "Ophalen MariaDB $MajorLine.x tags..."
    $tags   = Get-DockerHubTags -Image 'mariadb' -Filter "$MajorLine."
    $semver = $tags | Where-Object { $_ -match '^\d+\.\d+\.\d+$' -and $_.StartsWith("$MajorLine.") }
    if (-not $semver) { return $null }
    return Get-HighestVersion -Versions $semver
}

function Get-LatestWordPressApacheTag {
    param([string]$CurrentTag)
    Write-Info 'Ophalen WordPress Apache PHP tags...'

    $latestWp = Get-LatestWordPressVersion
    $wpMajor  = if ($latestWp -match '^(\d+)\.') { $Matches[1] }
                elseif ($CurrentTag -match '^(\d+)-php') { $Matches[1] }
                else { '7' }

    $tags       = Get-DockerHubTags -Image 'wordpress' -Filter "$wpMajor-php"
    $apacheTags = $tags | Where-Object { $_ -match "^$wpMajor-php\d+\.\d+-apache$" }

    if (-not $apacheTags) {
        $curMajor   = if ($CurrentTag -match '^(\d+)-php') { $Matches[1] } else { $wpMajor }
        $tags       = Get-DockerHubTags -Image 'wordpress' -Filter "$curMajor-php"
        $apacheTags = $tags | Where-Object { $_ -match "^$curMajor-php\d+\.\d+-apache$" }
    }

    if (-not $apacheTags) { return $null }

    return $apacheTags | Sort-Object {
        if ($_ -match 'php(\d+)\.(\d+)') { [long]([int]$Matches[1] * 100 + [int]$Matches[2]) } else { 0L }
    } -Descending | Select-Object -First 1
}

function Get-LatestWordPressCliTag {
    Write-Info 'Ophalen WordPress CLI PHP tags...'
    $tags    = Get-DockerHubTags -Image 'wordpress' -Filter 'cli-php'
    $cliTags = $tags | Where-Object { $_ -match '^cli-php\d+\.\d+$' }
    if (-not $cliTags) { return $null }
    return $cliTags | Sort-Object {
        if ($_ -match 'cli-php(\d+)\.(\d+)') { [long]([int]$Matches[1] * 100 + [int]$Matches[2]) } else { 0L }
    } -Descending | Select-Object -First 1
}

function Get-LatestPeclExtensionVersion {
    param([string]$Extension)
    Write-Info "Ophalen PECL $Extension versie..."
    try {
        [xml]$xml = (Invoke-WebRequest -Uri "https://pecl.php.net/rest/r/$Extension/allreleases.xml" -TimeoutSec 15 -UseBasicParsing).Content
        $stable   = $xml.a.r | Where-Object { $_.s -eq 'stable' } | Select-Object -ExpandProperty v
        if (-not $stable) { return $null }
        return Get-HighestVersion -Versions $stable
    }
    catch {
        Write-Warn "PECL $Extension ophalen mislukt: $_"
        return $null
    }
}

# ----------- bestandswijziging -----------------------------------------------

function Update-FileText {
    param(
        [string]$RelPath,
        [string]$OldText,
        [string]$NewText,
        [string]$Label
    )

    $fullPath = Join-Path $ROOT $RelPath
    if (-not (Test-Path $fullPath)) { Write-Warn "Bestand niet gevonden: $RelPath" ; return $false }

    $content = [System.IO.File]::ReadAllText($fullPath)
    if (-not $content.Contains($OldText)) { return }

    if (-not $DryRun) {
        [System.IO.File]::WriteAllText($fullPath, $content.Replace($OldText, $NewText), [System.Text.UTF8Encoding]::new($false))
    }

    $script:Changes.Add(@{ File = $RelPath ; Label = $Label ; From = $OldText ; To = $NewText })
    Write-Host "  [UPDATE] $Label" -ForegroundColor Yellow
    Write-Host "           Van: $OldText" -ForegroundColor Red
    Write-Host "           Naar: $NewText" -ForegroundColor Green
}

function Read-FileText {
    param([string]$RelPath)
    $fp = Join-Path $ROOT $RelPath
    if (Test-Path $fp) { return [System.IO.File]::ReadAllText($fp) }
    return ''
}

# ----------- banner ----------------------------------------------------------

Write-Host ''
Write-Host '+==================================================+' -ForegroundColor Blue
Write-Host '|     Docker Image Versie Update Controle          |' -ForegroundColor Blue
Write-Host '+==================================================+' -ForegroundColor Blue
if ($DryRun) { Write-Host '  MODUS: DRY RUN - geen bestanden worden gewijzigd' -ForegroundColor Yellow }

# ----------- huidige versies lezen -------------------------------------------

$rootDockerfile   = Read-FileText 'Dockerfile'
$alpineDockerfile = Read-FileText 'wordpress-alpine\Dockerfile'
$rootCompose      = Read-FileText 'docker-compose.yml'
$alpineCompose    = Read-FileText 'wordpress-alpine\docker-compose.yml'
$chartYamlText    = Read-FileText 'wordpress-alpine\chart\source\Chart.yaml'
$valuesYamlText   = Read-FileText 'wordpress-alpine\chart\source\values.yaml'
$rootReadme       = Read-FileText 'README.md'
$chartReadme      = Read-FileText 'wordpress-alpine\chart\source\README.md'

$curApacheTag     = if ($rootDockerfile   -match 'FROM wordpress:([^\s\r\n]+)')          { $Matches[1] } else { $null }
$curFpmTag        = if ($alpineDockerfile -match 'FROM wordpress:(php[\d.]+-fpm-alpine)') { $Matches[1] } else { $null }
$curCliTagRoot    = if ($rootCompose      -match 'image: wordpress:(cli-php[\d.]+)') { $Matches[1] } else { $null }
$curCliTagAlpine  = if ($alpineCompose    -match 'image: wordpress:(cli-php[\d.]+)') { $Matches[1] } else { $null }
$debianCompose    = Read-FileText 'wordpress-alpine\docker-compose-debian.yml'
$curCliTagDebian  = if ($debianCompose   -match 'image: wordpress:(cli-php[\d.]+)') { $Matches[1] } else { $null }
$curMariaDBDebian = if ($debianCompose   -match 'image: mariadb:([\d.]+)')           { $Matches[1] } else { $null }
$curCliTagValues  = if ($valuesYamlText   -match 'init: wordpress:(cli-php[\d.]+)')  { $Matches[1] } else { $null }
$curMariaDB       = if ($alpineCompose    -match 'image: mariadb:([\d.]+)')          { $Matches[1] } else { $null }
$curMariaDBReadme = if ($chartReadme      -match 'mariadb:([\d.]+)')                 { $Matches[1] } else { $null }
$curAppVersion    = if ($chartYamlText    -match 'appVersion:\s+"?([\d.]+)"?')       { $Matches[1] } else { $null }
$curWpVersion     = if ($valuesYamlText   -match 'version:\s+"?([\d.]+)"?')          { $Matches[1] } else { $null }
$curPeclMemcached = if ($rootDockerfile   -match 'memcached-([\d.]+)')               { $Matches[1] } else { $null }
$curReadmeWpVer   = if ($rootReadme       -match 'Wordpress version:\s+(\S+)')       { $Matches[1] } else { $null }
$curReadmePhpVer  = if ($rootReadme       -match 'PHP version:\s+(\S+)')             { $Matches[1] } else { $null }
$curReadmeMemcach = if ($rootReadme       -match 'memcached: v([\d.]+)')             { $Matches[1] } else { $null }

# ----------- 1. WordPress appVersion -----------------------------------------

Write-Header 'WordPress versie (appVersion)'
$latestWp = Get-LatestWordPressVersion

if ($latestWp -and $curAppVersion) {
    Write-Info "Huidig: $curAppVersion  |  Nieuwste: $latestWp"
    if ((Compare-SemVer $latestWp $curAppVersion) -gt 0) {
        Update-FileText 'wordpress-alpine\chart\source\Chart.yaml' `
            "appVersion: `"$curAppVersion`"" "appVersion: `"$latestWp`"" 'Chart.yaml appVersion'

        if ($curWpVersion) {
            Update-FileText 'wordpress-alpine\chart\source\values.yaml' `
                "version: `"$curWpVersion`"" "version: `"$latestWp`"" 'values.yaml wp.version'
        }

        $latestWpShort = ($latestWp -split '\.' | Select-Object -First 2) -join '.'
        if ($curReadmeWpVer) {
            Update-FileText 'README.md' `
                "Wordpress version:  $curReadmeWpVer" "Wordpress version:  $latestWpShort" 'README.md WordPress versie'
        }
    } else {
        Write-Ok "WordPress appVersion $curAppVersion is actueel"
    }
} else {
    Write-Skip 'WordPress versie kon niet worden bepaald'
}

# ----------- 2. WordPress Apache base image ----------------------------------

Write-Header 'WordPress Apache base image'
if ($curApacheTag) {
    Write-Info "Huidig: wordpress:$curApacheTag"
    $latestApacheTag = Get-LatestWordPressApacheTag -CurrentTag $curApacheTag
    Write-Info "Nieuwste: wordpress:$latestApacheTag"

    if ($latestApacheTag -and $latestApacheTag -ne $curApacheTag) {
        Update-FileText 'Dockerfile' `
            "FROM wordpress:$curApacheTag" "FROM wordpress:$latestApacheTag" 'Dockerfile base image'

        if ($latestApacheTag -match 'php(\d+\.\d+)' -and $curReadmePhpVer) {
            $newPhp = $Matches[1]
            Update-FileText 'README.md' `
                "PHP version:        $curReadmePhpVer" "PHP version:        $newPhp" 'README.md PHP versie'
        }
    } else {
        Write-Ok "WordPress Apache tag $curApacheTag is actueel"
    }
} else {
    Write-Skip 'Geen Apache tag gevonden in Dockerfile'
}

# ----------- 3. WordPress CLI image ------------------------------------------

Write-Header 'WordPress CLI image'
$currentCliTag = if ($curCliTagAlpine) { $curCliTagAlpine } elseif ($curCliTagRoot) { $curCliTagRoot } else { $curCliTagValues }
$latestCliTag  = Get-LatestWordPressCliTag

if ($currentCliTag) {
    Write-Info "Huidig: wordpress:$currentCliTag"
    Write-Info "Nieuwste: wordpress:$latestCliTag"
}

if ($latestCliTag -and $currentCliTag -and $latestCliTag -ne $currentCliTag) {
    if ($curCliTagRoot) {
        Update-FileText 'docker-compose.yml' `
            "image: wordpress:$curCliTagRoot" "image: wordpress:$latestCliTag" 'docker-compose.yml CLI image'
    }
    if ($curCliTagAlpine) {
        Update-FileText 'wordpress-alpine\docker-compose.yml' `
            "image: wordpress:$curCliTagAlpine" "image: wordpress:$latestCliTag" 'wordpress-alpine/docker-compose.yml CLI image'
    }
    if ($curCliTagDebian) {
        Update-FileText 'wordpress-alpine\docker-compose-debian.yml' `
            "image: wordpress:$curCliTagDebian" "image: wordpress:$latestCliTag" 'wordpress-alpine/docker-compose-debian.yml CLI image'
    }
    if ($curCliTagValues) {
        Update-FileText 'wordpress-alpine\chart\source\values.yaml' `
            "init: wordpress:$curCliTagValues" "init: wordpress:$latestCliTag" 'values.yaml init image'
    }
    if ($chartReadme -match [regex]::Escape($currentCliTag)) {
        Update-FileText 'wordpress-alpine\chart\source\README.md' `
            "wordpress:$currentCliTag" "wordpress:$latestCliTag" 'chart README CLI image'
    }
    # PHP versie in alpine Dockerfile bijwerken (FROM tag + LABEL)
    if ($latestCliTag -match 'cli-php(\d+\.\d+)') {
        $newPhp = $Matches[1]
        # FROM wordpress:phpX.X-fpm-alpine pinnen/bijwerken
        if ($curFpmTag) {
            $newFpmTag = "php$newPhp-fpm-alpine"
            if ($curFpmTag -ne $newFpmTag) {
                Update-FileText 'wordpress-alpine\Dockerfile' `
                    "FROM wordpress:$curFpmTag" "FROM wordpress:$newFpmTag" 'alpine Dockerfile FROM tag'
            }
        }
        # LABEL bijwerken
        if ($alpineDockerfile -match 'php ([\d.]+)') {
            $oldPhpLabel = $Matches[1]
            if ($oldPhpLabel -ne $newPhp) {
                Update-FileText 'wordpress-alpine\Dockerfile' `
                    "php $oldPhpLabel" "php $newPhp" 'alpine Dockerfile LABEL PHP versie'
            }
        }
    }
} elseif ($currentCliTag) {
    Write-Ok "WordPress CLI tag $currentCliTag is actueel"
} else {
    Write-Skip 'Geen CLI tag gevonden'
}

# ----------- 4. MariaDB image ------------------------------------------------

Write-Header 'MariaDB image'
if ($curMariaDB) {
    $mariadbMajor  = if ($curMariaDB -match '^(\d+)\.') { $Matches[1] } else { '12' }
    Write-Info "Huidig: mariadb:$curMariaDB"
    $latestMariaDB = Get-LatestMariaDBTag -MajorLine $mariadbMajor
    Write-Info "Nieuwste: mariadb:$latestMariaDB"

    if ($latestMariaDB -and (Compare-SemVer $latestMariaDB $curMariaDB) -gt 0) {
        Update-FileText 'wordpress-alpine\docker-compose.yml' `
            "image: mariadb:$curMariaDB" "image: mariadb:$latestMariaDB" 'docker-compose.yml MariaDB image'

        if ($curMariaDBDebian -and (Compare-SemVer $latestMariaDB $curMariaDBDebian) -gt 0) {
            Update-FileText 'wordpress-alpine\docker-compose-debian.yml' `
                "image: mariadb:$curMariaDBDebian" "image: mariadb:$latestMariaDB" 'docker-compose-debian.yml MariaDB image'
        }

        if ($curMariaDBReadme -and $curMariaDBReadme -ne $latestMariaDB) {
            Update-FileText 'wordpress-alpine\chart\source\README.md' `
                "mariadb:$curMariaDBReadme" "mariadb:$latestMariaDB" 'chart README MariaDB versie'
        }
    } else {
        Write-Ok "MariaDB $curMariaDB is actueel"
    }
} else {
    Write-Skip 'Geen gepinde MariaDB versie gevonden in alpine docker-compose.yml'
}

# ----------- 5. PECL memcached -----------------------------------------------

Write-Header 'PECL memcached extensie'
if ($curPeclMemcached) {
    Write-Info "Huidig: memcached-$curPeclMemcached"
    $latestPecl = Get-LatestPeclExtensionVersion -Extension 'memcached'
    Write-Info "Nieuwste: memcached-$latestPecl"

    if ($latestPecl -and (Compare-SemVer $latestPecl $curPeclMemcached) -gt 0) {
        Update-FileText 'Dockerfile' `
            "memcached-$curPeclMemcached" "memcached-$latestPecl" 'Dockerfile PECL memcached versie'

        if ($curReadmeMemcach) {
            Update-FileText 'README.md' `
                "memcached: v$curReadmeMemcach" "memcached: v$latestPecl" 'README.md memcached versie'
        }
    } else {
        Write-Ok "PECL memcached $curPeclMemcached is actueel"
    }
} else {
    Write-Skip 'Geen PECL memcached versie gevonden in Dockerfile'
}

# ----------- samenvatting ----------------------------------------------------

Write-Host ''
Write-Host '+==================================================+' -ForegroundColor Blue
Write-Host '|                  Samenvatting                   |' -ForegroundColor Blue
Write-Host '+==================================================+' -ForegroundColor Blue

if ($script:Changes.Count -eq 0) {
    Write-Host '  Alle images zijn actueel. Geen wijzigingen nodig.' -ForegroundColor Green
} else {
    $mode = if ($DryRun) { ' (dry run - niet toegepast)' } else { ' toegepast' }
    Write-Host "  $($script:Changes.Count) wijziging(en)$mode :" -ForegroundColor Yellow
    Write-Host ''

    $script:Changes | Group-Object { $_.File } | ForEach-Object {
        Write-Host "  $($_.Name)" -ForegroundColor White
        $_.Group | ForEach-Object {
            Write-Host "    * $($_.Label)" -ForegroundColor Cyan
            Write-Host "      Van:  $($_.From)" -ForegroundColor DarkGray
            Write-Host "      Naar: $($_.To)" -ForegroundColor DarkGray
        }
        Write-Host ''
    }

    if ($DryRun) {
        Write-Host '  Start zonder -DryRun om de wijzigingen toe te passen.' -ForegroundColor Yellow
    }
}

Write-Host ''
