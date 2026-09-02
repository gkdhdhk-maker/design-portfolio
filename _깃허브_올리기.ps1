# GitHub Pages 배포 — 처음 1회: 터미널에서  gh auth login  (브라우저 로그인) 후 이 파일 더블클릭/실행
# 이후엔 이 파일만 다시 실행하면 갱신됨.
$ErrorActionPreference = 'Stop'
$env:Path += ';C:\Program Files\GitHub CLI'
$HERE = Split-Path -Parent $MyInvocation.MyCommand.Path
$REPO = 'design-portfolio'
Set-Location $HERE

$who = (gh api user --jq .login) 2>$null
if (-not $who) { Write-Host '먼저 gh auth login 으로 로그인하세요.' -ForegroundColor Yellow; pause; exit 1 }

if (-not (Test-Path (Join-Path $HERE '.git'))) {
  git init -q
  git checkout -q -b main
}
git add -A
git -c user.name="$who" -c user.email="$who@users.noreply.github.com" commit -q -m ("update " + (Get-Date -Format 'yyyy-MM-dd HH:mm')) 2>$null

$exists = (gh repo view "$who/$REPO" --json name --jq .name) 2>$null
if (-not $exists) {
  gh repo create $REPO --public --source . --remote origin --push
} else {
  if (-not (git remote | Select-String '^origin$')) { git remote add origin "https://github.com/$who/$REPO.git" }
  git push -u origin main
}
# Pages 켜기 (main 브랜치 루트)
try { gh api -X POST "repos/$who/$REPO/pages" -f "source[branch]=main" -f "source[path]=/" | Out-Null } catch {}
$url = "https://$who.github.io/$REPO/"
Set-Content -Path (Join-Path $HERE '_url.txt') -Value $url -Encoding UTF8
Write-Host "공개 주소: $url  (첫 배포는 1~2분 뒤 열림)" -ForegroundColor Green
Write-Host "갤러리의 '링크 복사'에 이 주소가 들어가도록  _새로고침.bat  한 번 더 실행하세요."
pause
