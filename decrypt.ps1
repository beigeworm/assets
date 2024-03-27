
# $key = Read-Host "Enter the keyphrase "
# $enc = Read-Host "Enter encrypted message "

function Decipher-Text {
    param ([string]$encodedText,[string]$key)
    $decodedText = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($encodedText))
    $result = ""
    for ($i = 0; $i -lt $decodedText.Length; $i++) {
        $charCode = [int]$decodedText[$i] -bxor [int]$key[$i % $key.Length]
        $result += [char]$charCode
    }
    return $result
}

$global:decrypted = Decipher-Text -encodedText $enc -key $key
