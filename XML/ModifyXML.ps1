#Reset Bluebeam to View Mode

# Dont do anything if Revu.exe is open, these changes
# will be overwritten when user closes Bluebeam.
If(!(Get-Process -Name Revu)) {

    Get-ChildItem -Path "C:\Users" | ForEach-Object {

        $BBUserPrefFile = "$($_.FullName)\AppData\Roaming\Bluebeam Software\Revu\18\UserPreferences.xml"
        $BBUserPrefFileBackup = "$($_.FullName)\AppData\Roaming\Bluebeam Software\Revu\18\UserPreferences.backup"

            #Modify BB backup file.
            If(Test-Path -Path $BBUserPrefFileBackup) {

            $BBPrefBackupContent = [xml] (Get-Content -Path $BBUserPrefFileBackup)

            $RevuAppDefaultModeInt = Select-Xml -Xml $BBPrefBackupContent -XPath //Record/General/RevuAppDefaultModeInt
            $RevuAppDefaultModeInt.Node.'#text' = '2'

            $RevuAppLastUsedModeInt = Select-Xml -Xml $BBPrefBackupContent -XPath //Record/General/RevuAppLastUsedModeInt
            $RevuAppLastUsedModeInt.Node.'#text' = '2'

            $KeyViewMode  = Select-Xml -Xml $BBPrefBackupContent -XPath //Record/KeyViewModeMsg
            $KeyViewMode.Node.'#text' = 'False'

            $BBPrefBackupContent.Save($BBUserPrefFileBackup)
        }
        #Modify BB main file.
        If(Test-Path -Path $BBUserPrefFile) {

            $BBPrefContent = [xml] (Get-Content -Path $BBUserPrefFile)

            $RevuAppDefaultModeInt = Select-Xml -Xml $BBPrefContent -XPath //Record/General/RevuAppDefaultModeInt
            $RevuAppDefaultModeInt.Node.'#text' = '2'

            $RevuAppLastUsedModeInt = Select-Xml -Xml $BBPrefContent -XPath //Record/General/RevuAppLastUsedModeInt
            $RevuAppLastUsedModeInt.Node.'#text' = '2'

            $KeyViewMode  = Select-Xml -Xml $BBPrefContent -XPath //Record/KeyViewModeMsg
            $KeyViewMode.Node.'#text' = 'False'

            $BBPrefContent.Save($BBUserPrefFile)
        }

    }

}
