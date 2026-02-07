# Variable declaration
$Start_Time       =       Get-Date -Format T
$logFile          =       ‘Not_Reachable_PCs.txt’
$Message          =       Read-Host -Prompt “Type Your Message Here”      
$ComputerName     =       Read-Host -Prompt “Type Computer Name Here”    
$Time             =       Read-Host -Prompt “Type Time Here” 
$Session          =       “*”
$ComputerName     =       $ComputerName -split ‘,’

if ($ComputerName -match “:”)

                      {
                      $Path = $ComputerName
                      $ComputerName = Get-Content $path
          }
                      $Total = $ComputerName.count 
                                foreach ($Computer in $ComputerName )
                                                {
                                                             if (Test-Connection -ComputerName $Computer -Count 1 -ErrorAction 0)
                                {
                                                                Write-Host “Sending Message to $Computer…….” -ForegroundColor yellow
                                msg $Session /Server:$Computer /Time:$Time $Message
                                                                Write-Host “Message Successfully Sent to $Computer” -ForegroundColor Green
                                                                }
                                                                else
                                                                                {

                                                                Out-File -FilePath $logFile -InputObject $Computer -Append -Force

                                                                                                Write-Host “$Computer is not Reachable…” -ForegroundColor red

                                                                                }

                                                }

        $Not_Reachable_Count  = @(Get-Content $logFile).count
        $End_Time   =    Get-Date -Format T
        $Minute = (New-TimeSpan -Start $Start_Time -End $End_Time).Minutes
        $Second = (New-TimeSpan -Start $Start_Time -End $End_Time).Seconds
        Write-Host Start at $Start_Time, End At $End_Time, Took About $Minute Minutes $seconds Seconds
        Write-Host “Total $Total Computer Processed, $Not_Reachable_Count computers were offline. The list is stored in $logFile” -ForegroundColor white