$ErrorActionPreference = "Stop"

Get-ChildItem -Recurse .\build\app\smali | ForEach-Object -Process {
    $filepath = $_.FullName
    if ($filepath.EndsWith(".smali")) {
        [IO.File]::WriteAllText($filepath, ([IO.File]::ReadAllText($filepath) -replace "`r`n", "`n"))
    }
}