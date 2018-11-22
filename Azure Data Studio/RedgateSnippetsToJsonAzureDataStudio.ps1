param(
    [string]$username = "$env:UserName",
    [string]$snippetsfolder = "C:\Users\$username\AppData\Local\Red Gate\SQL Prompt 9\Snippets",
    [string]$outputfolder = "C:\Users\$username\AppData\Roaming\azuredatastudio\User\snippets"
)

if ($username -eq "") {
    Write-Error "-username cannot be empty";
    return;
}

if ($snippetsfolder -eq "") {
    Write-Error "-snippetsfolder cannot be empty";
    return;
}

if ($snippetsfolder -eq "") {
    Write-Error "-outputfolder cannot be empty";
    return;
}

if (-Not (Test-Path -Path $snippetsfolder)) {
    Write-Error "'$snippetsfolder' does not exists";
    return;
}

if (-Not (Test-Path -Path $outputfolder)) {

    Write-Host "'$outputfolder' does not exists, 'C:\temp' will be used instead" -ForegroundColor Yellow

    $outputfolder = "C:\Temp"
    
    if (-Not (Test-Path -Path $outputfolder)) {
        New-Item -ItemType Directory -Force -Path $outputfolder
    }
}
else {    
    if (-Not (Test-Path -Path $outputfolder -PathType Container)) {
        Write-Error "-outputfolder must be a directory";
        return;
    }
}

$outFile = Join-Path $outputfolder "redgate.code-snippets"
$dict = @{} 

Get-ChildItem $snippetsfolder -Filter *.sqlpromptsnippet | 
    Foreach-Object {

    $content = [XML](Get-Content $_.FullName )

    $body = [System.Collections.ArrayList]@()
    $null = $body.Add($content.SelectSingleNode("//Snippet/Code").InnerText)

    $definition = [ordered]@{
        'prefix'      = $content.SelectSingleNode("//Header/Shortcut").InnerText
        'body'        = $body
        'description' = ''
    }
    $dict[$content.SelectSingleNode("//Header/Title").InnerText] = $definition
}
If (Test-Path $outFile) {
    Remove-Item $outFile
}
$dict |  ConvertTo-Json | Out-File -filepath $outFile -Encoding "UTF8" 

Write-Host "'$outFile' created" -ForegroundColor Green