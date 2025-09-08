@echo off
set "BRANCH=main"
set "BATCH=250"
setlocal enabledelayedexpansion

REM 1) Eliminar archivos borrados localmente
for /f "delims=" %%F in ('git ls-files -d') do (
  git rm -- "%%F"
)
git diff --cached --quiet || (
  git commit -m "Borra archivos eliminados"
  git push origin %BRANCH%
)

REM 2) Modificados + no rastreados (respeta .gitignore)
set COUNT=0
set LOTE=1
for /f "delims=" %%F in ('git ls-files -m -o --exclude-standard') do (
  git add "%%F"
  set /a COUNT+=1
  if !COUNT! GEQ %BATCH% (
    git commit -m "Lote !LOTE!: %BATCH% cambios (mods/nuevos)"
    git push origin %BRANCH% || goto :push_error
    set /a LOTE+=1
    set COUNT=0
  )
)
if %COUNT% GTR 0 (
  git commit -m "Lote %LOTE%: %COUNT% cambios (mods/nuevos)"
  git push origin %BRANCH% || goto :push_error
)

echo Hecho.
exit /b 0

:push_error
echo Error al hacer push del Lote !LOTE!. Reintenta: git push origin %BRANCH%
exit /b 1