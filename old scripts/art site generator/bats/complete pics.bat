@echo off
color 09
cd "img prep"
title Image Loader
cls


echo Starting Image Prep
echo ......................................................
echo ......................................................

echo Flipping Images
start /wait /min flip_image.bat
echo COMPLETE
echo ......................................................

echo Randomly Naming Images
start /wait /min image_name_random_order.bat
echo COMPLETE
echo ......................................................

echo COMPRESS IMAGES NOW (to "smallout")
pause
echo COMPLETE
echo ......................................................

echo Sorting Small Images
start /wait /min sort_small.bat
echo COMPLETE
echo ......................................................

echo Naming Small Images
start /wait /min rename_small.bat
echo COMPLETE
echo ......................................................

echo Transfering Images
start /wait /min image_transfer.bat
echo COMPLETE
echo ......................................................

echo Writing Necessary Pages for Images
start /wait /min sort_images.bat
echo COMPLETE
echo ......................................................

echo Image Loading Complete
timeout /t 5

exit