#1 Переменная для папки с исходными данными
$sourceFolder = "C:\Users\root\Home\test\b1\*"

#2 Переменная для папки с названием текущей даты
$datFolder = (Get-Date).AddDays($_).ToString("MMddyyyy")

#3 Переменная для папки на сетевом диске Y для резервного копирования (на основе текущей даты)
$backUpFolder = "Y:\b2\$datFolder"

#4 Переменная для архива zip (на основе текущей даты) 
$zipFolder = "Y:\b2\$datFolder.zip"

#5 Создание папки бэкапа с именем текущей даты
New-Item -Path $backUpFolder -ItemType directory

#6 Копирование исходной папки в папку Бэкап
Copy-Item -Path $sourceFolder -Recurse $backUpFolder -Force

#7 Функция для работы с архиватором 7z
function zip ($source, $destination) {
    $7zip = "$($Env:ProgramFiles)\7-Zip\7z.exe"
    $args = "a", "-tzip", "$destination", "$source", "-r"
    & $7zip $args
}

#8 Архивирование  
zip $backUpFolder $zipFolder

#9 Удаление скопированнной на сетевой диск папки с бэкапом
Remove-Item $backUpFolder -Recurse

#10 Удаление файлов старше 14 дней от текущей даты

# Переменная для сетевой папки, где хранятся созданные архивы бэкапа
$TargetFolder = "Y:\b2\"   

# Функция для удаления файлов старше 6 дней
function deleteLastDays ($Target) {
    $Now = Get-Date
    $Days = "6"
    $LastWrite = $Now.AddDays(-$Days)
    $Files = Get-ChildItem $Target -Recurse | where{$_.LastWriteTime -le "$LastWrite"}

    foreach ($File in $Files) {
        if ($File -ne $NULL)
        {
            Write-Host "Deleting File $File" -ForegroundColor "DarkRed"
            Remove-Item $File.FullName -Recurse | Out-Null
        }
        else
        {
            Write-Host "No more files to delete!" -ForegroundColor "Green"
        }

    }
}

# Удаление архивов старше 6 дней при помощи функции
deleteLastDays $TargetFolder