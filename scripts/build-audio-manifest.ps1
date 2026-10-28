param(
  [string]$AudioFolder = (Join-Path $PSScriptRoot "..\public\Mairaj_Uddin_Khan"),
  [string]$OutputFile = (Join-Path $PSScriptRoot "..\public\audio-manifest.json")
)
$ErrorActionPreference = "Stop"
$surahs = @("Al-Fatihah","Al-Baqarah","Ali-Imran","An-Nisa","Al-Maidah","Al-Anam","Al-Araf","Al-Anfal","At-Tawbah","Yunus","Hud","Yusuf","Ar-Rad","Ibrahim","Al-Hijr","An-Nahl","Al-Isra","Al-Kahf","Maryam","Ta-Ha","Al-Anbiya","Al-Hajj","Al-Muminun","An-Nur","Al-Furqan","Ash-Shuara","An-Naml","Al-Qasas","Al-Ankabut","Ar-Rum","Luqman","As-Sajdah","Al-Ahzab","Saba","Fatir","Ya-Sin","As-Saffat","Sad","Az-Zumar","Ghafir","Fussilat","Ash-Shura","Az-Zukhruf","Ad-Dukhan","Al-Jathiyah","Al-Ahqaf","Muhammad","Al-Fath","Al-Hujurat","Qaf","Adh-Dhariyat","At-Tur","An-Najm","Al-Qamar","Ar-Rahman","Al-Waqiah","Al-Hadid","Al-Mujadila","Al-Hashr","Al-Mumtahanah","As-Saff","Al-Jumuah","Al-Munafiqun","At-Taghabun","At-Talaq","At-Tahrim","Al-Mulk","Al-Qalam","Al-Haqqah","Al-Maarij","Nuh","Al-Jinn","Al-Muzzammil","Al-Muddaththir","Al-Qiyamah","Al-Insan","Al-Mursalat","An-Naba","An-Naziat","Abasa","At-Takwir","Al-Infitar","Al-Mutaffifin","Al-Inshiqaq","Al-Buruj","At-Tariq","Al-Ala","Al-Ghashiyah","Al-Fajr","Al-Balad","Ash-Shams","Al-Layl","Ad-Duha","Ash-Sharh","At-Tin","Al-Alaq","Al-Qadr","Al-Bayyinah","Az-Zalzalah","Al-Adiyat","Al-Qariah","At-Takathur","Al-Asr","Al-Humazah","Al-Fil","Quraysh","Al-Maun","Al-Kawthar","Al-Kafirun","An-Nasr","Al-Masad","Al-Ikhlas","Al-Falaq","An-Nas")
if (-not (Test-Path -LiteralPath $AudioFolder -PathType Container)) { throw "Audio folder not found: $AudioFolder. Put files in public\Mairaj_Uddin_Khan or pass -AudioFolder." }
$files = Get-ChildItem -LiteralPath $AudioFolder -File | Where-Object { $_.Extension -match '^\.(mp3|m4a|aac|ogg|opus|wav|flac|mp4|webm)$' }
$map = [ordered]@{}
$unmatched = [System.Collections.Generic.List[string]]::new()
function Normalize-Name([string]$value) {
  $v = [System.IO.Path]::GetFileNameWithoutExtension($value).ToLowerInvariant()
  $v = $v -replace '^\s*\d{1,3}\s*[-_. )\]]+\s*', ''
  $v = $v -replace '[^a-z0-9]', ''
  return $v
}
foreach ($file in $files) {
  $base = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
  $surahNumber = $null
  if ($base -match '^\s*(\d{1,3})(?:\s*[-_. )\]]|$)') {
    $candidate = [int]$Matches[1]
    if ($candidate -ge 1 -and $candidate -le 114) { $surahNumber = $candidate }
  }
  if (-not $surahNumber) {
    $normalizedFile = Normalize-Name $file.Name
    for ($i = 0; $i -lt $surahs.Count; $i++) {
      $normalizedSurah = Normalize-Name ($surahs[$i] + ".mp3")
      if ($normalizedFile.Contains($normalizedSurah)) { $surahNumber = $i + 1; break }
    }
  }
  if ($surahNumber) {
    $key = [string]$surahNumber
    if ($map.Contains($key)) { Write-Warning "Duplicate audio match for Surah $key. Keeping first: $($map[$key]); ignored: $($file.Name)" }
    else { $map[$key] = $file.Name }
  } else { $unmatched.Add($file.Name) }
}
$payload = [ordered]@{ generatedAt = (Get-Date).ToString("o"); folder = "Mairaj_Uddin_Khan"; files = $map }
$parent = Split-Path -Parent $OutputFile
if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
$payload | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $OutputFile -Encoding utf8
Write-Host "Audio manifest written to: $OutputFile"
Write-Host "Matched Surahs: $($map.Count) / 114"
if ($unmatched.Count -gt 0) { Write-Host "Unmatched files:"; $unmatched | ForEach-Object { Write-Host " - $_" } }
Write-Host "Recommended names: 001-Al-Fatihah.mp3, 002-Al-Baqarah.mp3, ... 114-An-Nas.mp3"
