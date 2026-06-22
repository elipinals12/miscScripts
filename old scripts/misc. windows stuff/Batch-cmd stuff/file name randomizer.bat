echo off
title file name changer
cls
setlocal EnableDelayedExpansion

for %%i in (*.JPG) do (
	ren "%%i" !random!.jpg
)