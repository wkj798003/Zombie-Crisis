@echo off
title Push Zombie-Crisis to GitHub
cd /d "E:\GoDotGame\text-1"
echo.
echo ==============================================
echo   ?? Project Z^2 ? GitHub
echo ==============================================
echo.
echo === 1/6 ??? .git ===
if exist .git (attrib -r -s .git /s /d >nul 2>nul & rmdir /s /q .git >nul 2>nul)
echo.
echo === 2/6 Git init ===
git init
echo.
echo === 3/6 Set branch ===
git branch -M main
echo.
echo === 4/6 Set remote ===
git remote add origin https://github.com/wkj798003/Zombie-Crisis.git
echo.
echo === 5/6 Add files ===
git add .
echo.
echo === 6/6 Commit and Push ===
git -c user.name="wkj798003" -c user.email="wkj798003@github.com" ^
    commit -m "v0.5: deployable wall system + collision fixes + HP tuning"
echo.
echo ?????? Push????????
pause
git push --force -u origin main
echo.
echo ??!
pause
