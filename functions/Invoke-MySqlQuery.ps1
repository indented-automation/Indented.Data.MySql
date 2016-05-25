function Invoke-MySqlQuery {
    [CmdletBinding()]
    param(
        [MySql.Data.MySqlClient.MySqlConnection]$Connection = $Script:Connection,
        
        [MySql.Data.MySqlClient.MySqlTransaction]$Transaction
    )
    
    end {
        if ($null -eq $Connection) {
            $errorRecord = New-Object System.Management.Automation.ErrorRecord(
                (New-Object ArgumentException 'An MySql connection must be available for this query.'),
                'NoConnection',
                [System.Management.Automation.ErrorCategory]::InvalidArgument,
                $Connection
            )
            $pscmdlet.ThrowTerminatingError($errorRecord)
        }
        
        $shouldClose = $false
        if ($Connection.State -eq 'Closed') {
            $shouldClose = $true
            try {
                $Connection.Open()
            } catch {
                $pscmdlet.ThrowTerminatingError($_)
            }
        }
        
        $command = $Connection.CreateCommand()
        $command.CommandText = $Query
        
        if ($psboundparameters.ContainsKey('Transaction')) {
            $command.Transaction = $Transaction
        }
        
        try {
            $reader = $command.ExecuteReader()
        } catch {
            $pscmdlet.ThrowTerminatingError($_)
        }
        
        if ($reader.IsClosed -eq $false) {
            if ($reader.HasRows) {
                while ($reader.Read()) {
                    $psObject = New-Object PSObject
                    
                    for ($i = 0; $i -lt $reader.FieldCount; $i++) {
                        $name = $reader.GetName($i)
                        $j = 1
                        if ($psObject.Properties.Item($name)) {
                            do {
                                $newName = $name + $j++
                            } until (-not $psObject.Properties.Item($newName))
                            $name = $newName
                        }
                        
                        $psObject | Add-Member $name $reader.GetValue($i)
                    }
                    
                    $psObject
                }
            }
            $reader.Close()
        }
        
        if ($shouldClose) {
            $Connection.Close()
        }
    }
}