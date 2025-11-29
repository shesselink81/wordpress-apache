Get-Content .env | ForEach-Object {
    if ($_ -match '^\s*#') { return }     # comment overslaan
    if ($_ -match '^\s*$') { return }     # lege regels overslaan

    $name, $value = $_ -split '=', 2
    [System.Environment]::SetEnvironmentVariable($name, $value)
}
openssl req -x509 -newkey rsa:2048 -nodes -keyout nginx/ssl/server.key -out nginx/ssl/server.crt -days 365 -subj "/CN=${env:WP_DOMAINNAME}"