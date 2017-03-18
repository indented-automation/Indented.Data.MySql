function New-MySqlConnection {
    [CmdletBinding()]
    param(
        [Switch]$Use
    )
    
    dynamicparam {
        $dynamicParams = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        
        [MySql.Data.MySqlClient.MySqlConnectionStringBuilder].GetProperties().
            Where( { $_.CanWrite -and $_.Name -notin 'Item' } ).
            ForEach( {
                $attributes = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                $attribute = New-Object System.Management.Automation.ParameterAttribute
                $attribute.ParameterSetName = '__AllParameterSets'
                $attributes.Add($Attribute)
                
                $dynamicParam = New-Object System.Management.Automation.RuntimeDefinedParameter(
                    $_.Name,
                    $_.PropertyType,
                    $attributes
                )
                $dynamicParams.Add($_.Name, $DynamicParam)
            } )
        
        return $dynamicParams
    }
    
    end {
        $connectionStringBuilder = New-Object MySql.Data.MySqlClient.MySqlConnectionStringBuilder
        
        $psboundparameters.Keys | ForEach-Object {
            if ($connectionStringBuilder.PSObject.Properties.Item($_)) {
                $connectionStringBuilder.$_ = $psboundparameters[$_]
            }
        }
        
        $connection = New-Object MySql.Data.MySqlClient.MySqlConnection($connectionStringBuilder.ConnectionString)
        
        if ($Use) {
            Use-MySqlConnection -Connection $connection
        } else {
            return $connection
        }
    }
}