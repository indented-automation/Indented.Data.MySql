function Use-MySqlConnection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [MySql.Data.MySqlClient.MySqlConnection]$Connection
    )
    
    end {
        $Script:Connection = $Connection
    }
}