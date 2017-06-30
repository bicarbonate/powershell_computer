Set-ExecutionPolicy unrestricted
import-module activedirectory
# Functions
Function Get_Computers_From_AD {
    $raw_list = Get-ADComputer -Filter 'ObjectClass -eq "Computer"' | ForEach-Object {$_.Name}
    $filter_list = @()
    $raw_list | % {
        $sys = $_.ToString().ToLower()
        # Skip ePCR tablets
        if ($sys.EndsWith("t")) { }
        # Skip laptops
        elseif ($sys.EndsWith("l")) {}
        elseif ($sys.StartsWith("rune")) {
            $filter_list += @($sys)
        }
        # Add all standard systems
        elseif ($sys.StartsWith("vnc")) {
            $filter_list += @($sys)
        }
    }
    return $filter_list
    }
$systems = Get_Computers_From_AD
$list_as_array = "@("
 
$systems | % {
    $ComputerName = $_.ToString()
    try {
        $ct += 1
        $results = Do-Function
        if ($results)
        {
            LogWrite "Yay"
        }
        else {$list_as_array += "'$ComputerName', " }
    }
    catch { $list_as_array += "'$ComputerName', " }
    # Shows progress
    finally {echo "$ComputerName ($ct / $len)"}
}