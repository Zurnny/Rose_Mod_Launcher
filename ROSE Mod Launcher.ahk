; <COMPILER: v1.1.36.02>
#Requires AutoHotkey v2
#Requires AutoHotkey v2.0-
class Encrypt extends CNG
{
static String(AlgId, Mode, String, Key, IV := "", Encoding := "UTF-8", Output := "Base64")
{
static hAlgorithm := 0, hKey := 0, IVBuf := 0, IVSize := 0
try
{
if !(ALGORITHM := this.BCrypt.EncryptionAlgorithm(AlgId))
throw Error("Unrecognized encryption algorithm identifier: " AlgId, -1)
hAlgorithm := this.BCrypt.OpenAlgorithmProvider(ALGORITHM)
if (CHAIN_MODE := this.BCrypt.ChainingMode(Mode))
this.BCrypt.SetProperty(hAlgorithm, this.BCrypt.Constants.BCRYPT_CHAINING_MODE, CHAIN_MODE)
KeyBuf := this.StrBuf(Key, Encoding)
hKey := this.BCrypt.GenerateSymmetricKey(hAlgorithm, KeyBuf, KeyBuf.Size - 1)
BLOCK_LENGTH := this.BCrypt.GetProperty(hAlgorithm, this.BCrypt.Constants.BCRYPT_BLOCK_LENGTH, 4)
DataBuf := this.StrBuf(String, Encoding)
if (IV) {
IVBuf := Buffer(BLOCK_LENGTH, 0)
StrPut(IV, IVBuf, BLOCK_LENGTH, Encoding)
IVSize := IVBuf.Size
}
CIPHER_LENGTH := this.BCrypt.Encrypt(hKey, DataBuf, DataBuf.Size - 1, IVBuf, IVSize, &CIPHER_DATA, this.BCrypt.Constants.BCRYPT_BLOCK_PADDING)
ENCRYPT := this.Crypt.BinaryToString(CIPHER_DATA, CIPHER_LENGTH, Output)
}
catch as Exception
{
throw Exception
}
finally
{
if (hKey)
this.BCrypt.DestroyKey(hKey)
if (hAlgorithm)
this.BCrypt.CloseAlgorithmProvider(hAlgorithm)
}
return ENCRYPT
}
static File(AlgId, Mode, FileNameIn, FileNameOut, Key, IV := "", Bytes := 1048576, Offset := 0, Length := -1, Encoding := "UTF-8")
{
static hAlgorithm := 0, hKey := 0, IVBuf := 0, IVSize := 0
try
{
if !(ALGORITHM := this.BCrypt.EncryptionAlgorithm(AlgId))
throw Error("Unrecognized encryption algorithm identifier: " AlgId, -1)
hAlgorithm := this.BCrypt.OpenAlgorithmProvider(ALGORITHM)
if (CHAIN_MODE := this.BCrypt.ChainingMode(Mode))
this.BCrypt.SetProperty(hAlgorithm, this.BCrypt.Constants.BCRYPT_CHAINING_MODE, CHAIN_MODE)
KeyBuf := this.StrBuf(Key, Encoding)
hKey := this.BCrypt.GenerateSymmetricKey(hAlgorithm, KeyBuf, KeyBuf.Size - 1)
BLOCK_LENGTH := this.BCrypt.GetProperty(hAlgorithm, this.BCrypt.Constants.BCRYPT_BLOCK_LENGTH, 4)
if (IV) {
IVBuf := Buffer(BLOCK_LENGTH, 0)
StrPut(IV, IVBuf, BLOCK_LENGTH, Encoding)
IVSize := IVBuf.Size
}
if !(FileIn := FileOpen(FileNameIn, "r", Encoding))
throw Error("Failed to open file: " FileNameIn, -1)
if !(FileOut := FileOpen(FileNameOut, "rw", Encoding))
throw Error("Failed to create file: " FileNameOut, -1)
FileOut.Seek(0)
Length := Length < 0 ? FileIn.Length - Offset : Length
Data := Buffer(Bytes)
if ((Offset + Length) > FileIn.Length)
throw Error("Invalid parameters offset / length!", -1)
while (Length > Bytes) && (Dataread := FileIn.RawRead(Data, Bytes))
{
CIPHER_LENGTH := this.BCrypt.Encrypt(hKey, Data, Dataread, IVBuf, IVSize, &CIPHER_DATA, this.BCrypt.Constants.BCRYPT_BLOCK_PADDING)
FileOut.RawWrite(CIPHER_DATA, CIPHER_LENGTH)
Length -= Dataread
}
if (Length > 0)
{
if (Dataread := FileIn.RawRead(Data, Length))
{
CIPHER_LENGTH := this.BCrypt.Encrypt(hKey, Data, Dataread, IVBuf, IVSize, &CIPHER_DATA, this.BCrypt.Constants.BCRYPT_BLOCK_PADDING)
FileOut.RawWrite(CIPHER_DATA, CIPHER_LENGTH)
}
}
}
catch as Exception
{
throw Exception
}
finally
{
if (FileIn)
FileIn.Close()
if (FileOut)
FileOut.Close()
if (hKey)
this.BCrypt.DestroyKey(hKey)
if (hAlgorithm)
this.BCrypt.CloseAlgorithmProvider(hAlgorithm)
}
return true
}
}
class Decrypt extends CNG
{
static String(AlgId, Mode, String, Key, IV := "", Encoding := "UTF-8", Input := "Base64")
{
static hAlgorithm := 0, hKey := 0, IVBuf := 0, IVSize := 0
try
{
if !(ALGORITHM := this.BCrypt.EncryptionAlgorithm(AlgId))
throw Error("Unrecognized encryption algorithm identifier: " AlgId, -1)
hAlgorithm := this.BCrypt.OpenAlgorithmProvider(ALGORITHM)
if (CHAIN_MODE := this.BCrypt.ChainingMode(Mode))
this.BCrypt.SetProperty(hAlgorithm, this.BCrypt.Constants.BCRYPT_CHAINING_MODE, CHAIN_MODE)
KeyBuf := this.StrBuf(Key, Encoding)
hKey := this.BCrypt.GenerateSymmetricKey(hAlgorithm, KeyBuf, KeyBuf.Size - 1)
CIPHER_LENGTH := this.Crypt.StringToBinary(String, &CIPHER_DATA, Input)
BLOCK_LENGTH := this.BCrypt.GetProperty(hAlgorithm, this.BCrypt.Constants.BCRYPT_BLOCK_LENGTH, 4)
if (IV) {
IVBuf := Buffer(BLOCK_LENGTH, 0)
StrPut(IV, IVBuf, BLOCK_LENGTH, Encoding)
IVSize := IVBuf.Size
}
DECRYPT_LENGTH := this.BCrypt.Decrypt(hKey, CIPHER_DATA, CIPHER_LENGTH, IVBuf, IVSize, &DECRYPT_DATA, this.BCrypt.Constants.BCRYPT_BLOCK_PADDING)
DECRYPT := StrGet(DECRYPT_DATA, DECRYPT_LENGTH, Encoding)
}
catch as Exception
{
throw Exception
}
finally
{
if (hKey)
this.BCrypt.DestroyKey(hKey)
if (hAlgorithm)
this.BCrypt.CloseAlgorithmProvider(hAlgorithm)
}
return DECRYPT
}
static File(AlgId, Mode, FileNameIn, FileNameOut, Key, IV := "", Bytes := 1048576, Offset := 0, Length := -1, Encoding := "UTF-8")
{
static hAlgorithm := 0, hKey := 0, IVBuf := 0, IVSize := 0
try
{
if !(ALGORITHM := this.BCrypt.EncryptionAlgorithm(AlgId))
throw Error("Unrecognized encryption algorithm identifier: " AlgId, -1)
hAlgorithm := this.BCrypt.OpenAlgorithmProvider(ALGORITHM)
if (CHAIN_MODE := this.BCrypt.ChainingMode(Mode))
this.BCrypt.SetProperty(hAlgorithm, this.BCrypt.Constants.BCRYPT_CHAINING_MODE, CHAIN_MODE)
KeyBuf := this.StrBuf(Key, Encoding)
hKey := this.BCrypt.GenerateSymmetricKey(hAlgorithm, KeyBuf, KeyBuf.Size - 1)
BLOCK_LENGTH := this.BCrypt.GetProperty(hAlgorithm, this.BCrypt.Constants.BCRYPT_BLOCK_LENGTH, 4)
if (IV) {
IVBuf := Buffer(BLOCK_LENGTH, 0)
StrPut(IV, IVBuf, BLOCK_LENGTH, Encoding)
IVSize := IVBuf.Size
}
if !(FileIn := FileOpen(FileNameIn, "r", Encoding))
throw Error("Failed to open file: " FileNameIn, -1)
if !(FileOut := FileOpen(FileNameOut, "rw", Encoding))
throw Error("Failed to create file: " FileNameOut, -1)
FileOut.Seek(0)
Length := Length < 0 ? FileIn.Length - Offset : Length
Data := Buffer(Bytes)
if ((Offset + Length) > FileIn.Length)
throw Error("Invalid parameters offset / length!", -1)
while (Length > Bytes) && (Dataread := FileIn.RawRead(Data, Bytes))
{
DECRYPT_LENGTH := this.BCrypt.Decrypt(hKey, Data, Dataread, IVBuf, IVSize, &DECRYPT_DATA, this.BCrypt.Constants.BCRYPT_BLOCK_PADDING)
DECRYPT := StrGet(DECRYPT_DATA, DECRYPT_LENGTH, Encoding)
FileOut.Write(DECRYPT)
Length -= Dataread
}
if (Length > 0)
{
if (Dataread := FileIn.RawRead(Data, Length))
{
DECRYPT_LENGTH := this.BCrypt.Decrypt(hKey, Data, Length, IVBuf, IVSize, &DECRYPT_DATA, this.BCrypt.Constants.BCRYPT_BLOCK_PADDING)
DECRYPT := StrGet(DECRYPT_DATA, DECRYPT_LENGTH, Encoding)
FileOut.Write(DECRYPT)
}
}
}
catch as Exception
{
throw Exception
}
finally
{
if (FileIn)
FileIn.Close()
if (FileOut)
FileOut.Close()
if (hKey)
this.BCrypt.DestroyKey(hKey)
if (hAlgorithm)
this.BCrypt.CloseAlgorithmProvider(hAlgorithm)
}
return true
}
}
class Hash extends CNG
{
static String(AlgId, String, Encoding := "UTF-8", Output := "HEXRAW")
{
static hAlgorithm := 0, hHash := 0
try
{
if !(ALGORITHM := this.BCrypt.HashAlgorithm(AlgId))
throw Error("Unrecognized hash algorithm identifier: " AlgId, -1)
hAlgorithm := this.BCrypt.OpenAlgorithmProvider(ALGORITHM)
hHash := this.BCrypt.CreateHash(hAlgorithm)
Data := this.StrBuf(String, Encoding)
this.BCrypt.HashData(hHash, Data, Data.Size - 1)
HASH_LENGTH := this.BCrypt.GetProperty(hAlgorithm, this.BCrypt.Constants.BCRYPT_HASH_LENGTH, 4)
HASH_DATA := Buffer(HASH_LENGTH, 0)
FINISH_HASH := this.BCrypt.FinishHash(hHash, &HASH_DATA, HASH_LENGTH)
HASH := this.Crypt.BinaryToString(HASH_DATA, HASH_LENGTH, Output)
}
catch as Exception
{
throw Exception
}
finally
{
if (hHash)
this.BCrypt.DestroyHash(hHash)
if (hAlgorithm)
this.BCrypt.CloseAlgorithmProvider(hAlgorithm)
}
return HASH
}
static File(AlgId, FileName, Bytes := 1048576, Offset := 0, Length := -1, Encoding := "UTF-8", Output := "HEXRAW")
{
static hAlgorithm := 0, hHash := 0, File := 0
try
{
if !(ALGORITHM := this.BCrypt.HashAlgorithm(AlgId))
throw Error("Unrecognized hash algorithm identifier: " AlgId, -1)
hAlgorithm := this.BCrypt.OpenAlgorithmProvider(ALGORITHM)
hHash := this.BCrypt.CreateHash(hAlgorithm)
if !(File := FileOpen(FileName, "r", Encoding))
throw Error("Failed to open file: " FileName, -1)
Length := Length < 0 ? File.Length - Offset : Length
Data := Buffer(Bytes)
if ((Offset + Length) > File.Length)
throw Error("Invalid parameters offset / length!", -1)
while (Length > Bytes) && (Dataread := File.RawRead(Data, Bytes)) {
this.BCrypt.HashData(hHash, Data, Dataread)
Length -= Dataread
}
if (Length > 0) {
if (Dataread := File.RawRead(Data, Length))
this.BCrypt.HashData(hHash, Data, Dataread)
}
HASH_LENGTH := this.BCrypt.GetProperty(hAlgorithm, this.BCrypt.Constants.BCRYPT_HASH_LENGTH, 4)
HASH_DATA := Buffer(HASH_LENGTH, 0)
FINISH_HASH := this.BCrypt.FinishHash(hHash, &HASH_DATA, HASH_LENGTH)
HASH := this.Crypt.BinaryToString(HASH_DATA, HASH_LENGTH, Output)
}
catch as Exception
{
throw Exception
}
finally
{
if (File)
File.Close()
if (hHash)
this.BCrypt.DestroyHash(hHash)
if (hAlgorithm)
this.BCrypt.CloseAlgorithmProvider(hAlgorithm)
}
return HASH
}
static HMAC(AlgId, String, Hmac, Encoding := "UTF-8", Output := "HEXRAW")
{
static hAlgorithm := 0, hHash := 0
try
{
if !(ALGORITHM := this.BCrypt.HashAlgorithm(AlgId))
throw Error("Unrecognized hash algorithm identifier: " AlgId, -1)
hAlgorithm := this.BCrypt.OpenAlgorithmProvider(ALGORITHM, this.BCrypt.Constants.BCRYPT_ALG_HANDLE_HMAC_FLAG)
Mac := this.StrBuf(Hmac, Encoding)
hHash := this.BCrypt.CreateHash(hAlgorithm, Mac, Mac.Size - 1)
Data := this.StrBuf(String, Encoding)
this.BCrypt.HashData(hHash, Data, Data.Size - 1)
HASH_LENGTH := this.BCrypt.GetProperty(hAlgorithm, this.BCrypt.Constants.BCRYPT_HASH_LENGTH, 4)
HASH_DATA := Buffer(HASH_LENGTH, 0)
FINISH_HASH := this.BCrypt.FinishHash(hHash, &HASH_DATA, HASH_LENGTH)
HASH := this.Crypt.BinaryToString(HASH_DATA, HASH_LENGTH, Output)
}
catch as Exception
{
throw Exception
}
finally
{
if (hHash)
this.BCrypt.DestroyHash(hHash)
if (hAlgorithm)
this.BCrypt.CloseAlgorithmProvider(hAlgorithm)
}
return HASH
}
static PBKDF2(AlgId, Password, Salt, Iterations := 4096, KeySize := 256, Encoding := "UTF-8", Output := "HEXRAW")
{
static hAlgorithm := 0, hHash := 0
try
{
if !(ALGORITHM := this.BCrypt.HashAlgorithm(AlgId))
throw Error("Unrecognized hash algorithm identifier: " AlgId, -1)
if (Mod(KeySize, 8) != 0)
throw Error("The desired key bit length must be a multiple of 8!", -1)
hAlgorithm := this.BCrypt.OpenAlgorithmProvider(ALGORITHM, this.BCrypt.Constants.BCRYPT_ALG_HANDLE_HMAC_FLAG)
PBKDF2_DATA := this.BCrypt.DeriveKeyPBKDF2(hAlgorithm, Password, Salt, Iterations, KeySize / 8, Encoding)
PBKDF2 := this.Crypt.BinaryToString(PBKDF2_DATA, PBKDF2_DATA.size, Output)
}
catch as Exception
{
throw Exception
}
finally
{
if (hAlgorithm)
this.BCrypt.CloseAlgorithmProvider(hAlgorithm)
}
return PBKDF2
}
}
class CNG
{
class BCrypt
{
#DllLoad "*i bcrypt.dll"
static CloseAlgorithmProvider(hAlgorithm)
{
NT_STATUS := DllCall("bcrypt\BCryptCloseAlgorithmProvider", "Ptr",  hAlgorithm
, "UInt", Flags := 0
, "UInt")
if (NT_STATUS = this.NT.SUCCESS)
return true
throw Error(this.GetErrorMessage(NT_STATUS), -1)
}
static CreateHash(hAlgorithm, Buf := 0, Size := 0)
{
NT_STATUS := DllCall("bcrypt\BCryptCreateHash", "Ptr",  hAlgorithm
, "Ptr*", &hHash := 0
, "Ptr",  0
, "UInt", 0
, "Ptr",  Buf
, "UInt", Size
, "UInt", Flags := 0
, "UInt")
if (NT_STATUS = this.NT.SUCCESS)
return hHash
throw Error(this.GetErrorMessage(NT_STATUS), -1)
}
static Decrypt(hKey, InputBuf, InputSize, IVBuf := 0, IVSize := 0, &OutputBuf := 0, Flags := 0)
{
NT_STATUS := DllCall("bcrypt\BCryptDecrypt", "Ptr",   hKey
, "Ptr",   InputBuf
, "UInt",  InputSize
, "Ptr",   0
, "Ptr",   IVBuf
, "UInt",  IVSize
, "Ptr",   0
, "UInt",  0
, "UInt*", &Result := 0
, "UInt",  Flags
, "UInt")
if (NT_STATUS != this.NT.SUCCESS)
throw Error(this.GetErrorMessage(NT_STATUS), -1)
OutputBuf := Buffer(Result, 0)
NT_STATUS := DllCall("bcrypt\BCryptDecrypt", "Ptr",   hKey
, "Ptr",   InputBuf
, "UInt",  InputSize
, "Ptr",   0
, "Ptr",   IVBuf
, "UInt",  IVSize
, "Ptr",   OutputBuf
, "UInt",  OutputBuf.Size
, "UInt*", &Result := 0
, "UInt",  Flags
, "UInt")
if (NT_STATUS = this.NT.SUCCESS)
return OutputBuf.Size
throw Error(this.GetErrorMessage(NT_STATUS), -1)
}
static DeriveKeyPBKDF2(hAlgorithm, Pass, Salt, Iterations, DerivedKey, Encoding := "UTF-8")
{
Passwd := CNG.StrBuf(Pass, Encoding)
Salt   := CNG.StrBuf(Salt, Encoding)
DKey   := Buffer(DerivedKey, 0)
NT_STATUS := DllCall("bcrypt\BCryptDeriveKeyPBKDF2", "Ptr",   hAlgorithm
, "Ptr",   Passwd
, "UInt",  Passwd.Size - 1
, "Ptr",   Salt
, "UInt",  Salt.Size - 1
, "Int64", Iterations
, "Ptr",   DKey
, "UInt",  DerivedKey
, "UInt",  Flags := 0
, "UInt")
if (NT_STATUS = this.NT.SUCCESS)
return DKey
throw Error(this.GetErrorMessage(NT_STATUS), -1)
}
static DestroyHash(hHash)
{
NT_STATUS := DllCall("bcrypt\BCryptDestroyHash", "Ptr", hHash, "UInt")
if (NT_STATUS = this.NT.SUCCESS)
return true
throw Error(this.GetErrorMessage(NT_STATUS), -1)
}
static DestroyKey(hKey)
{
NT_STATUS := DllCall("bcrypt\BCryptDestroyKey", "Ptr", hKey, "UInt")
if (NT_STATUS = this.NT.SUCCESS)
return true
throw Error(this.GetErrorMessage(NT_STATUS), -1)
}
static Encrypt(hKey, InputBuf, InputSize, IVBuf := 0, IVSize := 0, &OutputBuf := 0, Flags := 0)
{
NT_STATUS := DllCall("bcrypt\BCryptEncrypt", "Ptr",   hKey
, "Ptr",   InputBuf
, "UInt",  InputSize
, "Ptr",   0
, "Ptr",   IVBuf
, "UInt",  IVSize
, "Ptr",   0
, "UInt",  0
, "UInt*", &Result := 0
, "UInt",  Flags
, "UInt")
if (NT_STATUS != this.NT.SUCCESS)
throw Error(this.GetErrorMessage(NT_STATUS), -1)
OutputBuf := Buffer(Result, 0)
NT_STATUS := DllCall("bcrypt\BCryptEncrypt", "Ptr",   hKey
, "Ptr",   InputBuf
, "UInt",  InputSize
, "Ptr",   0
, "Ptr",   IVBuf
, "UInt",  IVSize
, "Ptr",   OutputBuf
, "UInt",  OutputBuf.Size
, "UInt*", &Result := 0
, "UInt",  Flags
, "UInt")
if (NT_STATUS = this.NT.SUCCESS)
return OutputBuf.Size
throw Error(this.GetErrorMessage(NT_STATUS), -1)
}
static FinishHash(hHash, &Buf, Size)
{
Buf := Buffer(Size, 0)
NT_STATUS := DllCall("bcrypt\BCryptFinishHash", "Ptr",  hHash
, "Ptr",  Buf
, "UInt", Size
, "UInt", Flags := 0
, "UInt")
if (NT_STATUS = this.NT.SUCCESS)
return Size
throw Error(this.GetErrorMessage(NT_STATUS), -1)
}
static GenerateSymmetricKey(hAlgorithm, Buf := 0, Size := 0)
{
NT_STATUS := DllCall("bcrypt\BCryptGenerateSymmetricKey", "Ptr",  hAlgorithm
, "Ptr*", &hKey := 0
, "Ptr",  0
, "UInt", 0
, "Ptr",  Buf
, "UInt", Size
, "UInt", Flags := 0
, "UInt")
if (NT_STATUS = this.NT.SUCCESS)
return hKey
throw Error(this.GetErrorMessage(NT_STATUS), -1)
}
static GetProperty(hObject, Property, Size)
{
NT_STATUS := DllCall("bcrypt\BCryptGetProperty", "Ptr",   hObject
, "Ptr",   StrPtr(Property)
, "Ptr*",  &Buf := 0
, "UInt",  Size
, "UInt*", &Result := 0
, "UInt",  Flags := 0
, "UInt")
if (NT_STATUS = this.NT.SUCCESS)
return Buf
throw Error(this.GetErrorMessage(NT_STATUS), -1)
}
static HashData(hHash, Buf, Size)
{
NT_STATUS := DllCall("bcrypt\BCryptHashData", "Ptr",  hHash
, "Ptr",  Buf
, "UInt", Size
, "UInt", Flags := 0
, "UInt")
if (NT_STATUS = this.NT.SUCCESS)
return true
throw Error(this.GetErrorMessage(NT_STATUS), -1)
}
static OpenAlgorithmProvider(AlgId, Flags := 0)
{
NT_STATUS := DllCall("bcrypt\BCryptOpenAlgorithmProvider", "Ptr*", &hAlgorithm := 0
, "Str",  AlgId
, "Ptr",  Implementation := 0
, "UInt", Flags
, "UInt")
if (NT_STATUS = this.NT.SUCCESS)
return hAlgorithm
throw Error(this.GetErrorMessage(NT_STATUS), -1)
}
static SetProperty(hObject, Property, Input)
{
NT_STATUS := DllCall("bcrypt\BCryptSetProperty", "Ptr",  hObject
, "Ptr",  StrPtr(Property)
, "Ptr",  StrPtr(Input)
, "UInt", StrLen(Input)
, "UInt", Flags := 0
, "UInt")
if (NT_STATUS = this.NT.SUCCESS)
return true
throw Error(this.GetErrorMessage(NT_STATUS), -1)
}
static GetErrorMessage(STATUS_CODE)
{
switch STATUS_CODE
{
case this.NT.AUTH_TAG_MISMATCH:
return "The computed authentication tag did not match the input authentication tag."
case this.NT.BUFFER_TOO_SMALL:
return "The buffer is too small to contain the entry. No information has been written to the buffer."
case this.NT.INVALID_BUFFER_SIZE:
return "The size of the buffer is invalid for the specified operation."
case this.NT.INVALID_HANDLE:
return "An invalid HANDLE was specified."
case this.NT.INVALID_PARAMETER:
return "An invalid parameter was passed to a service or function."
case this.NT.NOT_FOUND:
return "The object was not found."
case this.NT.NOT_SUPPORTED:
return "The request is not supported."
case this.NT.NO_MEMORY:
return "Not enough virtual memory or paging file quota is available to complete the specified operation."
default:
return "BCrypt failed " STATUS_CODE
}
}
class Constants
{
static BCRYPT_ALG_HANDLE_HMAC_FLAG            := 0x00000008
static BCRYPT_HASH_REUSABLE_FLAG              := 0x00000020
static BCRYPT_BLOCK_PADDING                   := 0x00000001
static BCRYPT_CIPHER_OPERATION                := 0x00000001
static BCRYPT_HASH_OPERATION                  := 0x00000002
static BCRYPT_ASYMMETRIC_ENCRYPTION_OPERATION := 0x00000004
static BCRYPT_SECRET_AGREEMENT_OPERATION      := 0x00000008
static BCRYPT_SIGNATURE_OPERATION             := 0x00000010
static BCRYPT_RNG_OPERATION                   := 0x00000020
static BCRYPT_KEY_DERIVATION_OPERATION        := 0x00000040
static BCRYPT_3DES_ALGORITHM                  := "3DES"
static BCRYPT_3DES_112_ALGORITHM              := "3DES_112"
static BCRYPT_AES_ALGORITHM                   := "AES"
static BCRYPT_AES_CMAC_ALGORITHM              := "AES-CMAC"
static BCRYPT_AES_GMAC_ALGORITHM              := "AES-GMAC"
static BCRYPT_DES_ALGORITHM                   := "DES"
static BCRYPT_DESX_ALGORITHM                  := "DESX"
static BCRYPT_MD2_ALGORITHM                   := "MD2"
static BCRYPT_MD4_ALGORITHM                   := "MD4"
static BCRYPT_MD5_ALGORITHM                   := "MD5"
static BCRYPT_RC2_ALGORITHM                   := "RC2"
static BCRYPT_RC4_ALGORITHM                   := "RC4"
static BCRYPT_RNG_ALGORITHM                   := "RNG"
static BCRYPT_SHA1_ALGORITHM                  := "SHA1"
static BCRYPT_SHA256_ALGORITHM                := "SHA256"
static BCRYPT_SHA384_ALGORITHM                := "SHA384"
static BCRYPT_SHA512_ALGORITHM                := "SHA512"
static BCRYPT_PBKDF2_ALGORITHM                := "PBKDF2"
static BCRYPT_XTS_AES_ALGORITHM               := "XTS-AES"
static BCRYPT_BLOCK_LENGTH                    := "BlockLength"
static BCRYPT_CHAINING_MODE                   := "ChainingMode"
static BCRYPT_CHAIN_MODE_CBC                  := "ChainingModeCBC"
static BCRYPT_CHAIN_MODE_CCM                  := "ChainingModeCCM"
static BCRYPT_CHAIN_MODE_CFB                  := "ChainingModeCFB"
static BCRYPT_CHAIN_MODE_ECB                  := "ChainingModeECB"
static BCRYPT_CHAIN_MODE_GCM                  := "ChainingModeGCM"
static BCRYPT_HASH_LENGTH                     := "HashDigestLength"
static BCRYPT_OBJECT_LENGTH                   := "ObjectLength"
}
class NT
{
static SUCCESS             := 0x00000000
static AUTH_TAG_MISMATCH   := 0xC000A002
static BUFFER_TOO_SMALL    := 0xC0000023
static INVALID_BUFFER_SIZE := 0xC0000206
static INVALID_HANDLE      := 0xC0000008
static INVALID_PARAMETER   := 0xC000000D
static NO_MEMORY           := 0xC0000017
static NOT_FOUND           := 0xC0000225
static NOT_SUPPORTED       := 0xC00000BB
}
static EncryptionAlgorithm(Algorithm)
{
switch Algorithm
{
case "AES": return this.Constants.BCRYPT_AES_ALGORITHM
case "DES": return this.Constants.BCRYPT_DES_ALGORITHM
case "RC2": return this.Constants.BCRYPT_RC2_ALGORITHM
case "RC4": return this.Constants.BCRYPT_RC4_ALGORITHM
default: return ""
}
}
static ChainingMode(ChainMode)
{
switch ChainMode
{
case "CBC", "ChainingModeCBC": return this.Constants.BCRYPT_CHAIN_MODE_CBC
case "ECB", "ChainingModeECB": return this.Constants.BCRYPT_CHAIN_MODE_ECB
default: return ""
}
}
static HashAlgorithm(Algorithm)
{
switch Algorithm
{
case "MD2":               return this.Constants.BCRYPT_MD2_ALGORITHM
case "MD4":               return this.Constants.BCRYPT_MD4_ALGORITHM
case "MD5":               return this.Constants.BCRYPT_MD5_ALGORITHM
case "SHA1", "SHA-1":     return this.Constants.BCRYPT_SHA1_ALGORITHM
case "SHA256", "SHA-256": return this.Constants.BCRYPT_SHA256_ALGORITHM
case "SHA384", "SHA-384": return this.Constants.BCRYPT_SHA384_ALGORITHM
case "SHA512", "SHA-512": return this.Constants.BCRYPT_SHA512_ALGORITHM
default: return ""
}
}
}
class Crypt
{
#DllLoad "*i crypt32.dll"
static BinaryToString(BufIn, SizeIn, Flags := "BASE64")
{
static CRYPT_STRING :=  { BASE64: 0x1, BINARY: 0x2, HEX: 0x4, HEXRAW: 0xc }
static CRYPT_STRING_NOCRLF := 0x40000000
if !(DllCall("crypt32\CryptBinaryToStringW", "Ptr",   BufIn
, "UInt",  SizeIn
, "UInt",  (CRYPT_STRING.%Flags% | CRYPT_STRING_NOCRLF)
, "Ptr",   0
, "UInt*", &Size := 0))
throw Error("Can't compute the destination buffer size, error: " A_LastError, -1)
BufOut := Buffer(Size << 1, 0)
if !(DllCall("crypt32\CryptBinaryToStringW", "Ptr",   BufIn
, "UInt",  SizeIn
, "UInt",  (CRYPT_STRING.%Flags% | CRYPT_STRING_NOCRLF)
, "Ptr",   BufOut
, "UInt*", Size))
throw Error("Can't convert source buffer to " Flags ", error: " A_LastError, -1)
return StrGet(BufOut)
}
static StringToBinary(String, &Binary, Flags := "BASE64")
{
static CRYPT_STRING := { BASE64: 0x1, BINARY: 0x2, HEX: 0x4, HEXRAW: 0xc }
if !(DllCall("crypt32\CryptStringToBinaryW", "Ptr",   StrPtr(String)
, "UInt",  0
, "UInt",  CRYPT_STRING.%Flags%
, "Ptr",   0
, "UInt*", &Size := 0
, "Ptr",   0
, "Ptr",   0))
throw Error("Can't compute the destination buffer size, error: " A_LastError, -1)
Binary := Buffer(Size, 0)
if !(DllCall("crypt32\CryptStringToBinaryW", "Ptr",   StrPtr(String)
, "UInt",  0
, "UInt",  CRYPT_STRING.%Flags%
, "Ptr",   Binary
, "UInt*", Binary.Size
, "Ptr",   0
, "Ptr",   0))
throw Error("Can't convert source buffer to " Flags ", error: " A_LastError, -1)
return Binary.Size
}
}
static StrBuf(Str, Encoding := "UTF-8")
{
Buf := Buffer(StrPut(Str, Encoding))
StrPut(Str, Buf, Encoding)
return Buf
}
}
#Requires AutoHotkey v2.0
RLM_Key := "18859983396574618054551711972106940813179101630242145860094430427419269285409308595060959490670783149791737138433897542458013691100614972502017016165958173463047853368178593202627118286854444191980430392543333068129537028212847201036269295061491798221931210291659059415150878130025043170149785846557690831840746267217579634447304079136896766587680792594972140929036742853053941676798539858609982456429370651319596803312302061563723126422990215538513490198698642886685434615867492961134585819633633631297955029922673348484005886077465335731741909452579258348569103211188294526888318885840943219576983505223551917279981"
RLM_Key2 := "12211456295458319825591187483671208555462285970553676720451503608378266042439803684585496117330791427756071689931799670036474778930077907448212092202523391842235977942987587032721645194997128441330168326975243899050428924185047629541106041867716314442712517923543801261797371056490463924608831252866885810390128834928656442198581102355373676135583657756748832476817274652357047663014559483006640935400808572754166099846642431566413626751390590081986811448154541748659445535821941111463041226654959256637851772283137819204188380501877203810924268440035114004364934206473522429860126821999868268779461576482803393231567"
#Requires AutoHotkey v2.0
ToggleTheme(GuiCtrlObj, *)
{
switch GuiCtrlObj.Text
{
case "DarkMode":
{
SetWindowAttribute(Main)
SetWindowTheme(Main)
}
default:
{
SetWindowAttribute(Main, False)
SetWindowTheme(Main, False)
}
}
}
SetWindowAttribute(GuiObj, DarkMode := True)
{
global DarkColors          := Map("Background", "0x202020", "Controls", "0x404040", "Font", "0xE0E0E0")
global TextBackgroundBrush := DllCall("gdi32\CreateSolidBrush", "UInt", DarkColors["Background"], "Ptr")
static PreferredAppMode    := Map("Default", 0, "AllowDark", 1, "ForceDark", 2, "ForceLight", 3, "Max", 4)
if (VerCompare(A_OSVersion, "10.0.17763") >= 0)
{
DWMWA_USE_IMMERSIVE_DARK_MODE := 19
if (VerCompare(A_OSVersion, "10.0.18985") >= 0)
{
DWMWA_USE_IMMERSIVE_DARK_MODE := 20
}
uxtheme := DllCall("kernel32\GetModuleHandle", "Str", "uxtheme", "Ptr")
SetPreferredAppMode := DllCall("kernel32\GetProcAddress", "Ptr", uxtheme, "Ptr", 135, "Ptr")
FlushMenuThemes     := DllCall("kernel32\GetProcAddress", "Ptr", uxtheme, "Ptr", 136, "Ptr")
switch DarkMode
{
case True:
{
DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", GuiObj.hWnd, "Int", DWMWA_USE_IMMERSIVE_DARK_MODE, "Int*", True, "Int", 4)
DllCall(SetPreferredAppMode, "Int", PreferredAppMode["ForceDark"])
DllCall(FlushMenuThemes)
GuiObj.BackColor := DarkColors["Background"]
}
default:
{
DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", GuiObj.hWnd, "Int", DWMWA_USE_IMMERSIVE_DARK_MODE, "Int*", False, "Int", 4)
DllCall(SetPreferredAppMode, "Int", PreferredAppMode["Default"])
DllCall(FlushMenuThemes)
GuiObj.BackColor := "Default"
}
}
}
}
SetWindowTheme(GuiObj, DarkMode := True)
{
static GWL_WNDPROC        := -4
static GWL_STYLE          := -16
static ES_MULTILINE       := 0x0004
static LVM_GETTEXTCOLOR   := 0x1023
static LVM_SETTEXTCOLOR   := 0x1024
static LVM_GETTEXTBKCOLOR := 0x1025
static LVM_SETTEXTBKCOLOR := 0x1026
static LVM_GETBKCOLOR     := 0x1000
static LVM_SETBKCOLOR     := 0x1001
static LVM_GETHEADER      := 0x101F
static GetWindowLong      := A_PtrSize = 8 ? "GetWindowLongPtr" : "GetWindowLong"
static SetWindowLong      := A_PtrSize = 8 ? "SetWindowLongPtr" : "SetWindowLong"
static Init               := False
static LV_Init            := False
global IsDarkMode         := DarkMode
Mode_Explorer  := (DarkMode ? "DarkMode_Explorer"  : "Explorer" )
Mode_CFD       := (DarkMode ? "DarkMode_CFD"       : "CFD"      )
Mode_ItemsView := (DarkMode ? "DarkMode_ItemsView" : "ItemsView")
for hWnd, GuiCtrlObj in GuiObj
{
switch GuiCtrlObj.Type
{
case "Button", "CheckBox", "ListBox", "UpDown":
{
DllCall("uxtheme\SetWindowTheme", "Ptr", GuiCtrlObj.hWnd, "Str", Mode_Explorer, "Ptr", 0)
}
case "ComboBox", "DDL":
{
DllCall("uxtheme\SetWindowTheme", "Ptr", GuiCtrlObj.hWnd, "Str", Mode_CFD, "Ptr", 0)
}
case "Edit":
{
if (DllCall("user32\" GetWindowLong, "Ptr", GuiCtrlObj.hWnd, "Int", GWL_STYLE) & ES_MULTILINE)
{
DllCall("uxtheme\SetWindowTheme", "Ptr", GuiCtrlObj.hWnd, "Str", Mode_Explorer, "Ptr", 0)
}
else
{
DllCall("uxtheme\SetWindowTheme", "Ptr", GuiCtrlObj.hWnd, "Str", Mode_CFD, "Ptr", 0)
}
}
case "ListView":
{
if !(LV_Init)
{
static LV_TEXTCOLOR   := SendMessage(LVM_GETTEXTCOLOR,   0, 0, GuiCtrlObj.hWnd)
static LV_TEXTBKCOLOR := SendMessage(LVM_GETTEXTBKCOLOR, 0, 0, GuiCtrlObj.hWnd)
static LV_BKCOLOR     := SendMessage(LVM_GETBKCOLOR,     0, 0, GuiCtrlObj.hWnd)
LV_Init := True
}
GuiCtrlObj.Opt("-Redraw")
switch DarkMode
{
case True:
{
SendMessage(LVM_SETTEXTCOLOR,   0, DarkColors["Font"],       GuiCtrlObj.hWnd)
SendMessage(LVM_SETTEXTBKCOLOR, 0, DarkColors["Background"], GuiCtrlObj.hWnd)
SendMessage(LVM_SETBKCOLOR,     0, DarkColors["Background"], GuiCtrlObj.hWnd)
}
default:
{
SendMessage(LVM_SETTEXTCOLOR,   0, LV_TEXTCOLOR,   GuiCtrlObj.hWnd)
SendMessage(LVM_SETTEXTBKCOLOR, 0, LV_TEXTBKCOLOR, GuiCtrlObj.hWnd)
SendMessage(LVM_SETBKCOLOR,     0, LV_BKCOLOR,     GuiCtrlObj.hWnd)
}
}
DllCall("uxtheme\SetWindowTheme", "Ptr", GuiCtrlObj.hWnd, "Str", Mode_Explorer, "Ptr", 0)
LV_Header := SendMessage(LVM_GETHEADER, 0, 0, GuiCtrlObj.hWnd)
DllCall("uxtheme\SetWindowTheme", "Ptr", LV_Header, "Str", Mode_ItemsView, "Ptr", 0)
GuiCtrlObj.Opt("+Redraw")
}
}
}
if !(Init)
{
global WindowProcNew := CallbackCreate(WindowProc)
global WindowProcOld := DllCall("user32\" SetWindowLong, "Ptr", GuiObj.Hwnd, "Int", GWL_WNDPROC, "Ptr", WindowProcNew, "Ptr")
Init := True
}
}
WindowProc(hwnd, uMsg, wParam, lParam)
{
critical
static WM_CTLCOLOREDIT    := 0x0133
static WM_CTLCOLORLISTBOX := 0x0134
static WM_CTLCOLORBTN     := 0x0135
static WM_CTLCOLORSTATIC  := 0x0138
static DC_BRUSH           := 18
if (IsDarkMode)
{
switch uMsg
{
case WM_CTLCOLOREDIT, WM_CTLCOLORLISTBOX:
{
DllCall("gdi32\SetTextColor", "Ptr", wParam, "UInt", DarkColors["Font"])
DllCall("gdi32\SetBkColor", "Ptr", wParam, "UInt", DarkColors["Controls"])
DllCall("gdi32\SetDCBrushColor", "Ptr", wParam, "UInt", DarkColors["Controls"], "UInt")
return DllCall("gdi32\GetStockObject", "Int", DC_BRUSH, "Ptr")
}
case WM_CTLCOLORBTN:
{
DllCall("gdi32\SetDCBrushColor", "Ptr", wParam, "UInt", DarkColors["Background"], "UInt")
return DllCall("gdi32\GetStockObject", "Int", DC_BRUSH, "Ptr")
}
case WM_CTLCOLORSTATIC:
{
DllCall("gdi32\SetTextColor", "Ptr", wParam, "UInt", DarkColors["Font"])
DllCall("gdi32\SetBkColor", "Ptr", wParam, "UInt", DarkColors["Background"])
return TextBackgroundBrush
}
}
}
return DllCall("user32\CallWindowProc", "Ptr", WindowProcOld, "Ptr", hwnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam)
}
Version := "1.8"
Title := "ROSE Mod Launcher v" Version
StartingY :=	25
Gap :=			35
EditMode :=		0
CfgDataPath := A_AppData "\RLM\"
DataPathCfg := CfgDataPath "data.cfg"
TROSEPathCfg := CfgDataPath "trose.cfg"
SettingPathCfg := CfgDataPath "settings.cfg"
Launcher_InitGlobals()
Onload()
OnLoad() {
global DisplayMode, CheckUpdates, DarkMode, ClientTitleRename
DetectOldCfg()
try DisplayMode := IniRead(SettingPathCfg, "RLM", "DisplayMode")
catch {
DisplayMode := 0
}
try CheckUpdates := IniRead(SettingPathCfg, "RLM", "CheckUpdates")
catch {
CheckUpdates := 1
}
try DarkMode := IniRead(SettingPathCfg, "RLM", "DarkMode")
catch {
DarkMode := 0
}
try ClientTitleRename := IniRead(SettingPathCfg, "RLM", "ClientTitleRename")
catch {
ClientTitleRename := 0
}
ReadCfg()
BuildUI()
ResetROSEClient_DDL()
DisplayModeSwitch()
If CheckUpdates = 1
CheckForUpdate()
}
ReadCfg() {
ReadLoginCfg()
ReadROSECfg()
}
ReadLoginCfg() {
global LoginData, LoginDisplay, LoginEmail
Accounts_Dedupe()
LoginEmail := []
LoginDisplay := Map()
LoginData := Map()
if FileExist(DataPathCfg) {
Loop Read DataPathCfg {
DisEm := StrSplit(A_LoopReadLine,'"|"')
EmPass := StrSplit(DisEm[2],'","')
LoginEmailTrimmed := Trim(EmPass[1])
LoginEmail.Push(LoginEmailTrimmed)
LoginData.Set(LoginEmailTrimmed,EmPass[2])
LoginDisplay.Set(LoginEmailTrimmed,DisEm[1])
}
}
}
ExportLogins(*) {
plaintextToggle := 0
ExportPassword := InputBox("Enter a password to encrypt the exported file (remember this password, as its needed to decrypt the file later).", "Export Logins Password")
if ExportPassword.Result = "Cancel" || ExportPassword.Value = ""
return
if ExportPassword.Value = "Bypass Safety and Export plaintext." {
Result := MsgBox("Are you sure you want to export all logins in plaintext? (press Yes or No)",, "YesNo")
if Result != "Yes"
return
plaintextToggle := 1
}
ExportPath := FileSelect("S", , "Select where to save the exported login file.", "RLM Export Files (*.export)")
if ExportPath = ""
return
SplitPath ExportPath, &name, &dir, &ext
if !ext
ExportPath .= ".export"
if FileExist(ExportPath) {
Result := MsgBox("The file " ExportPath " already exists. Would you like to overwrite it? (press Yes or No)",, "YesNo")
if Result != "Yes"
return
FileDelete ExportPath
}
ExportData := ""
Loop Read DataPathCfg {
DisEm := StrSplit(A_LoopReadLine,'"|"')
EmPass := StrSplit(DisEm[2],'","')
LoginEmailTrimmed := Trim(EmPass[1])
UsablePW := DecryptPassword(EmPass[2])
if plaintextToggle = 1
EncryptedPW := UsablePW
else
EncryptedPW := EncryptData(UsablePW, ExportPassword.Value)
ExportData .= DisEm[1] '"|"' LoginEmailTrimmed '","' EncryptedPW "`n"
}
WriteCfg(ExportData, ExportPath)
MsgBox("Exported logins to " ExportPath ".`n`nPasswords are encrypted with the provided password.")
}
EncryptData(Data, Password) {
return Encrypt.String("AES", "CBC", Data, RLM_Key, Password)
}
DecryptData(Data, Password) {
return Decrypt.String("AES", "CBC", Data, RLM_Key, Password)
}
ImportLogins(*) {
Accounts_Backup()
ImportPath := FileSelect(, , "Select the exported login file to import.", "RLM Export Files (*.export)")
if ImportPath = ""
return
ImportPassword := InputBox("Enter the password used to encrypt the imported file.", "Import Logins Password")
if ImportPassword.Result = "Cancel" || ImportPassword.Value = ""
return
Loop Read ImportPath {
DisEm := StrSplit(A_LoopReadLine,'"|"')
if !DisEm.Has(2)
continue
EmPass := StrSplit(DisEm[2],'","')
LoginEmailTrimmed := Trim(EmPass[1])
UsablePW := DecryptData(EmPass[2], ImportPassword.Value)
EncryptedPW := EncryptPassword(UsablePW)
WriteCfg(DisEm[1] '"|"' LoginEmailTrimmed '","' EncryptedPW, DataPathCfg)
}
MsgBox("Imported logins from " ImportPath ".")
Reload()
}
CheckforOverRide(Email) {
return IniRead(SettingPathCfg, "OverRides", Email, "0")
}
ReadROSECfg() {
global TROSEData, TROSEDisplay, TROSEPath
TROSEDisplay := []
TROSEPath := Map()
TROSEData := Map()
if FileExist(TROSEPathCfg) {
Loop Read TROSEPathCfg {
Display := StrSplit(A_LoopReadLine,'"|"')
Path := StrSplit(Display[2],'","')
TROSEDisplay.Push(Display[1])
TROSEData.Set(Display[1],Path[2])
TROSEPath.Set(Display[1],Path[1])
}
} else {
FindDefaultROSE()
}
}
WriteCfg(Data2Write,Path) {
if !DirExist(CfgDataPath)
DirCreate CfgDataPath
FileAppend Data2Write "`n", Path
}
NewLoginUI(*) {
NewLogin := GUI(,"New Login")
NewLogin.Add("Text","x10 y5","Display Name:")
NewLogin.Add("Edit","x10 y25 w250 vDN", "")
NewLogin.Add("Text","x10 y55","Username (Email):")
NewLogin.Add("Edit","x10 y75 w250 vEA", "")
NewLogin.Add("Text","x10 y110","Password:")
NewLogin.Add("Edit","x10 y130 w250 vPW", "")
NewLogin.Add("Button","x10 y165 w100 h30 Default","Add").onEvent("Click", NewLogin_handler)
NewLogin.Add("Button","x160 y165 w100 h30","Cancel").onEvent("Click", (*) => NewLogin.Destroy())
If DarkMode = 2
DarkMode_Setter(NewLogin)
NewLogin.Show
}
EditLoginUI(Account,*) {
global EditLogin
EditLogin := GUI(,"Edit Login")
EditLogin.Add("Text","x10 y5 0x200","Display Name:")
EditLogin.Add("Edit","x10 y25 w250 0x200 vDN", LoginDisplay[Account])
EditLogin.Add("Text","x10 y55 0x200","Username (Email):")
EditLogin.Add("Edit","x10 y75 w250 0x200 disabled vEA", Account)
EditLogin.Add("Text","x10 y110 0x200","Password:")
EditLogin.Add("Edit","x10 y130 w250 0x200 vPW", "")
EditLogin.Add("Text","x10 y165","Client Override:")
EditLoginDDL := EditLogin.Add("DropDownList","x10 y185 w250 vCO", TROSEDisplay)
EditLoginDDL.Add(["None"])
EditLogin.Add("Button","x10 y220 w80 h30","Save").onEvent("Click", EditFromDataFile.bind(Account))
EditLogin.Add("Button","x95 y220 w80 h30","Delete").onEvent("Click", RemoveFromDataFile.bind(Account))
EditLogin.Add("Button","x180 y220 w80 h30 Default","Cancel").onEvent("Click", EditLoginDestroy.bind(EditLogin))
if CheckforOverRide(Account) = "0"
EditLoginDDL.Text := "None"
Else if CheckforOverRide(Account)
try EditLoginDDL.Text := CheckforOverRide(Account)
catch {
EditLoginDDL.Text := "None"
try IniDelete(SettingPathCfg, "OverRides", Account)
}
If DarkMode = 2
DarkMode_Setter(EditLogin)
EditLogin.Show
}
EditLoginDestroy(EditLogin,*) {
EditLogin.Destroy
EditModeToggle()
}
NewLogin_handler(ctrl, *) {
Accounts_Backup()
output := ctrl.gui.submit()
EmailTrimmed := Trim(output.EA)
if HasVal(LoginEmail, EmailTrimmed) {
MsgBox("That email address has already used.")
return
}
if !InStr(EmailTrimmed, "@") {
MsgBox("You didn't enter a correctly formated Email address.")
return
}
if EmailTrimmed = "" {
MsgBox("You forgot to entered an email address.")
return
}
if output.PW = "" {
MsgBox("You forgot to entered a password.")
return
}
new_password := EncryptPassword(output.PW)
NewLogin := output.DN '"|"' EmailTrimmed '","' new_password
WriteCfg(NewLogin,DataPathCfg)
Main.Destroy
ReadCfg()
BuildUI()
}
NewTROSE_handler(*) {
DisTROSE := InputBox("Name for this ROSE Client?`n`n`nAfter enter a name, you will select the ROSE Client Execute Usually TROSE.exe")
if DisTROSE.Result = "Cancel"
return
if HasVal(TROSEDisplay, DisTROSE.Value) {
MsgBox("That Name is already in use.")
return
}
if DisTROSE.Value = "" {
MsgBox("You forgot to entered a Name")
return
}
Path := FileSelect(, , "Select the ROSE Client Execute Usually TROSE.exe", "Executable (*.exe)")
SplitPath Path, &name, &dir
PrePath := %&dir%
NewPath := PrePath "\"
NewExe := %&name%
NewClient := DisTROSE.Value '"|"' NewPath '","' NewExe
WriteCfg(NewClient,TROSEPathCfg)
ROSElist.Destroy
ReadCfg()
ROSEClientsUI()
}
HasVal(haystack, needle) {
if !(IsObject(haystack)) || (haystack.Length = 0)
return 0
for index, value in haystack
if (value = needle)
return index
return 0
}
SetOverRideMarker(n) {
if CheckforOverRide(n)
return "*"
else
return ""
}
BuildMoreUI() {
global
MoreUI := GUI(,Title " - More Stuff and Option")
MoreUI.Opt("+Theme")
MoreUI.Add("Button","x10 y5 w80 h30","Reload").onEvent("Click", (*) => Reload())
MoreUI.Add("Button","x585 y5 w80 h30","Close").onEvent("Click", (*) => MoreUIClose())
MoreUI.Add("Text","x50 y45 w530 h2 +0x10")
MoreUI.Add("Button","x10 y" StartingY + Gap * 1 " w160 h30 vCheckUpdatesBtn","Check for Updates").onEvent("Click", MoreUICheckUpdate)
MoreUI.Add("Button","x175 y" StartingY + Gap * 1 " w160 h30 0x1 vDarkModeBtn","DarkMode").onEvent("Click", MoreUILauncher.bind("DarkModeLauncher"))
MoreUI.Add("Button","x340 y" StartingY + Gap * 1 " w160 h30 0x1 vClientTitleRenameBtn","Rename Client Title").OnEvent("Click", MoreUIClientTitleRename)
MoreUI.Add("Button","x505 y" StartingY + Gap * 1 " w160 h30 0x1","Fix XML").onEvent("Click", DeleteXML)
MoreUI.Add("Button","x10 y" StartingY + Gap * 2 " w160 h30 0x1","Open RLM Forum Post").onEvent("Click", MoreUILauncher.bind("ForumPost"))
MoreUI.Add("Button","x175 y" StartingY + Gap * 2 " w160 h30 0x1","Open Current ROSE Folder").onEvent("Click", MoreUILauncher.bind("RoseFolder"))
MoreUI.Add("Button","x340 y" StartingY + Gap * 2 " w160 h30 0x1 vExportBtn","Export").OnEvent("Click", ExportLogins)
MoreUI.Add("Button","x505 y" StartingY + Gap * 2 " w160 h30 0x1 vImportBtn","Import").OnEvent("Click", ImportLogins)
MoreUI.Add("Button","x10 y" StartingY + Gap * 3 " w160 h30 0x1","Factory Reset App").OnEvent("Click", MoreUILauncher.bind("ResetAll"))
MoreUI.Add("Button","x175 y" StartingY + Gap * 3 " w160 h30 0x1","Clear all ROSE Accounts").OnEvent("Click", MoreUILauncher.bind("ResetData"))
MoreUI.Add("Button","x340 y" StartingY + Gap * 3 " w160 h30 0x1","Reset to Default Clients").OnEvent("Click", MoreUILauncher.bind("ResetClients"))
MoreUI.Add("Button","x505 y" StartingY + Gap * 3 " w160 h30 0x1","Reset to Default Settings").OnEvent("Click", MoreUILauncher.bind("ResetSettings"))
DarkMode_Setter(MoreUI)
MoreUI.Show("AutoSize")
MoreUI_CheckUpdatesSwitch()
MoreUI_ClientTitleRenameSwitch()
}
MoreUICheckUpdate(*) {
global CheckUpdates
CheckUpdates:=!CheckUpdates
MoreUI_CheckUpdatesSwitch()
Try IniWrite CheckUpdates, SettingPathCfg, "RLM", "CheckUpdates"
if CheckUpdates = 1
CheckForUpdate()
}
MoreUIClientTitleRename(*) {
global ClientTitleRename
ClientTitleRename:=!ClientTitleRename
MoreUI_ClientTitleRenameSwitch()
Try IniWrite ClientTitleRename, SettingPathCfg, "RLM", "ClientTitleRename"
}
MoreUI_CheckUpdatesSwitch() {
global CheckUpdates
if CheckUpdates = 1 {
MoreUI["CheckUpdatesBtn"].Text := "Checking for Updates: On"
}
if CheckUpdates = 0 {
MoreUI["CheckUpdatesBtn"].Text := "Checking for Updates: Off"
}
}
MoreUI_ClientTitleRenameSwitch() {
global ClientTitleRename
if ClientTitleRename = 1 {
MoreUI["ClientTitleRenameBtn"].Text := "Rename Client Titles: On"
}
if ClientTitleRename = 0 {
MoreUI["ClientTitleRenameBtn"].Text := "Rename Client Titles: Off"
}
}
MoreUIClose(*) {
MoreUI.Destroy()
}
DarkMode_Setter(GUIvar) {
switch DarkMode
{
case "2":
{
SetWindowAttribute(GUIvar)
SetWindowTheme(GUIvar)
Try MoreUI["DarkModeBtn"].Text := "Darkmode: Forced All"
}
case "1":
{
SetWindowAttribute(GUIvar)
SetWindowTheme(GUIvar)
Try MoreUI["DarkModeBtn"].Text := "Darkmode: On"
}
case "0":
{
SetWindowAttribute(GUIvar, False)
SetWindowTheme(GUIvar, False)
Try MoreUI["DarkModeBtn"].Text := "Darkmode: Off"
}
}
}
MoreUILauncher(ToRun,*) {
global DarkMode
Switch ToRun {
case "DarkModeLauncher":
DarkMode := !DarkMode
DarkMode_Setter(MoreUI)
Try IniWrite DarkMode, SettingPathCfg, "RLM", "DarkMode"
case "ForumPost":
Run "https://forum.roseonlinegame.com/topic/4975-tool-rose-login-manager-v11-10232023/"
case "RoseFolder":
Run CurrentTROSEPath
case "RoseRegistration":
Run "https://www.roseonlinegame.com/register"
case "ResetAll":
if AreYouSure("Factory Reset ROSE Login Manager. This means all settings and accounts are removed") = "Yes" {
if (FileExist(DataPathCfg))
FileDelete(DataPathCfg)
if (FileExist(SettingPathCfg))
FileDelete(SettingPathCfg)
if (FileExist(TROSEPathCfg))
FileDelete(TROSEPathCfg)
Reload
}
case "ResetData":
if AreYouSure("Clear all ROSE accounts?") = "Yes" {
if (FileExist(DataPathCfg))
FileDelete(DataPathCfg)
Reload
}
case "ResetClients":
if AreYouSure("Reset ROSE Client list to defaults") = "Yes" {
if (FileExist(TROSEPathCfg))
FileDelete(TROSEPathCfg)
Reload
}
case "ResetSettings":
if AreYouSure("Reset Settings to defaults") = "Yes" {
if (FileExist(SettingPathCfg))
FileDelete(SettingPathCfg)
Reload
}
}
}
AreYouSure(What) {
Result := MsgBox("Would you like to " What "? (press Yes or No)",, "YesNo")
Return Result
}
ROSEClientsUI() {
global ROSElist
ROSElist := GUI(,Title " - Client List")
ROSElist.Opt("+Theme")
ROSElist.Add("Button","x5 y5 w80 h30","New").onEvent("Click", NewTROSE_handler)
ROSElist.Add("Button","x250 y5 w160 h30","Reset to Defaults").onEvent("Click", RemoveTROSECfg)
ROSElist.Add("Button","x580 y5 w80 h30","Close").onEvent("Click", (*) => ROSElistClose())
ROSElist.Add("Text","x50 y45 w530 h2 +0x10")
loop (TROSEDisplay.Length) {
ROSElist.Add("Text","x5 y" StartingY + Gap * A_Index " w30 h30 0x1",A_Index ")")
ROSElist.Add("Text","x45 y" StartingY + Gap * A_Index " w150 h30 0x0",TROSEDisplay[A_Index])
ROSElist.Add("Text","x230 y" StartingY + Gap * A_Index " w305 h30 0x0",TROSEPath[TROSEDisplay[A_Index]])
ROSElist.Add("Text","x400 y" StartingY + Gap * A_Index " w160 h30 0x2",TROSEData[TROSEDisplay[A_Index]])
ROSElist.Add("Button","x580 y" StartingY - 5 + Gap * A_Index " w80 h30 0x1","Delete").OnEvent("Click", RemoveFromTROSEFile.bind(TROSEDisplay[A_Index]))
ROSElist.Add("Text","x50 y" 25 + StartingY + Gap * A_Index " w500 h2 +0x10")
}
If DarkMode = 2
DarkMode_Setter(ROSElist)
ROSElist.Show("AutoSize")
}
RemoveTROSECfg(*) {
if (FileExist(TROSEPathCfg)) {
FileDelete(TROSEPathCfg)
Reload
}
}
ROSElistClose(*) {
ROSElist.Destroy()
Main.Destroy()
ReadCfg()
BuildUI()
}
DisplayModeBtn(*) {
global DisplayMode
DisplayMode:=!DisplayMode
DisplayModeSwitch()
Try IniWrite DisplayMode, SettingPathCfg, "RLM", "DisplayMode"
}
ResetROSEClient_DDL() {
global CurrentTROSEPath, CurrentTROSE, CurrentTROSEDisplay
Try {
TestName := IniRead(SettingPathCfg, "RLM", "CurrentClient")
loop TROSEDisplay.Length {
if TestName = TROSEDisplay[A_Index]
DDL.Value := TestIndex := A_Index
}
if TestIndex = ""
DDL.Value := TestIndex := 1
} Catch {
DDL.Value := TestIndex := 1
} finally {
DDL.Value := TestIndex
CurrentTROSEPath := TROSEPath[TROSEDisplay[TestIndex]]
CurrentTROSE := TROSEData[TROSEDisplay[TestIndex]]
CurrentTROSEDisplay := TROSEDisplay[TestIndex]
DisplayModeSwitch()
ModsRow_Refresh()
}
}
TROSEddl(*) {
Global CurrentTROSEPath, CurrentTROSE, CurrentTROSEDisplay
Switch
{
case InStr(DDL.Text, "------------------------------"):
ResetROSEClient_DDL()
return
case  InStr(DDL.Text, "Add/Remove ROSE"):
ResetROSEClient_DDL()
ROSEClientsUI()
return
}
CurrentTROSEPath := TROSEPath[TROSEDisplay[DDL.Value]]
CurrentTROSE := TROSEData[TROSEDisplay[DDL.Value]]
CurrentTROSEDisplay := DDL.Text
Try IniWrite TROSEDisplay[DDL.Value], SettingPathCfg, "RLM", "CurrentClient"
ModsRow_Refresh()
}
LaunchROSE(Account,*) {
global EditMode, CurrentTROSEPath, CurrentTROSE, CurrentTROSEDisplay
if EditMode = 1 {
EditLoginUI(Account)
EditMode := 0
Exit
}
ORC := CheckforOverRide(Account)
if (ORC != "0" and ORC != "") {
if TROSEPath.has(ORC) {
if TROSEPath[ORC] {
CurrentTROSEPath := TROSEPath[ORC]
CurrentTROSE := TROSEData[ORC]
CurrentTROSEDisplay := ORC
}
} else {
IniDelete(SettingPathCfg, "OverRides", Account)
DisplayModeSwitch()
MsgBox("Override no longer exists, removing from account.")
return
}
}
if CheckandFail() {
Mods_BeforeLaunch()
AccountData := LoginData.Get(Account)
UsablePW := DecryptPassword(AccountData)
SetWorkingDir CurrentTROSEPath
Command := '"' CurrentTROSEPath CurrentTROSE '"'
Param := " --login --server connect.roseonlinegame.com --username " Account " --password " UsablePW
try Run Command Param
catch
Msgbox "Missing ROSE Client, try Reset to Default Clients in More."
}
if (ClientTitleRename)
SetROSETitle(Account)
UsablePW := ""
}
SetROSETitle(Account) {
if WinWait("ROSE Online (Early Access)", , 5)
WinSetTitle(LoginDisplay[Account], "ROSE Online (Early Access)")
else
MsgBox("ROSE Window not found.")
}
CheckandFail() {
global CurrentTROSEPath, CurrentTROSE, CurrentTROSEDisplay
DoRednimsWork()
if !FileExist(CurrentTROSEPath CurrentTROSE) {
RemoveFromTROSEFile(CurrentTROSEDisplay, 1)
CurrentTROSEPath := TROSEPath[TROSEDisplay[1]]
CurrentTROSE := TROSEData[TROSEDisplay[1]]
CurrentTROSEDisplay := TROSEDisplay[1]
Try IniWrite TROSEDisplay[1], SettingPathCfg, "RLM", "CurrentClient"
ResetROSEClient_DDL()
Msgbox "Selected ROSE Client is missing.`n`nIts been Removed and Switching back to Default, please try again.`n`nIf you continue to have issues, try Reset to Default Clients in More."
Return 0
}
Return 1
}
DoRednimsWork() {
global CurrentTROSE, CurrentTROSEPath
if (CurrentTROSE = "trose-new.exe") {
if (FileExist(CurrentTROSEPath CurrentTROSE)) {
TestTROSE := Hash.File("SHA1", CurrentTROSEPath CurrentTROSE)
if (TestTROSE = "0E46A6C6D8FF74F64F6E8D2E58A2586D04437388") {
FileDelete CurrentTROSEPath CurrentTROSE
Msgbox "Old TROSE found.`n`nRemoving it, so it doesnt show up in the Client List."
}
}
}
}
EncryptPassword(Password) {
prenew_password := Encrypt.String("AES", "CBC", Password, RLM_Key, A_UserName)
new_password := Encrypt.String("AES", "CBC", prenew_password, RLM_Key2, A_UserName)
return new_password
}
DecryptPassword(Password) {
PreUsablePW := Decrypt.String("AES", "CBC", Password, RLM_Key2, A_UserName)
UsablePW := Decrypt.String("AES", "CBC", PreUsablePW, RLM_Key, A_UserName)
return UsablePW
}
LaunchPatcher(*) {
SetWorkingDir CurrentTROSEPath
if IsWine() {
Command := CurrentTROSEPath "swamp_rose_updater"
} else {
Command := CurrentTROSEPath "rose-updater.exe"
}
Run Command
}
IsWine() {
static runningInWine := ""
if (runningInWine !== "")
return runningInWine
hModule := DllCall("GetModuleHandle", "Str", "ntdll.dll", "Ptr")
if (hModule) {
runningInWine := !!DllCall("GetProcAddress", "Ptr", hModule, "AStr", "wine_get_version", "Ptr")
} else {
runningInWine := false
}
return runningInWine
}
DeleteXML(*) {
Result := MsgBox("Do you want to delete both the 3ddata and updater folder? Patcher will run after",, "YesNo")
if Result = "Yes" {
SetWorkingDir CurrentTROSEPath
if DirExist("3ddata")
DirDelete "3ddata", 1
if DirExist("updater")
DirDelete "updater", 1
sleep 500
LaunchPatcher()
if DirExist("mods") {
sleep 30000
WinWaitClose "ROSE Online Updater"
FileCopy "mods\*.xml", "3ddata\control\xml", 1
}
}
}
EditFromDataFile(EditTarget, ctrl, *) {
Accounts_Backup()
output := ctrl.gui.submit()
if output.PW != "" {
LoginData[EditTarget] := EncryptPassword(output.PW)
}
if output.DN != LoginDisplay[EditTarget] {
LoginDisplay[EditTarget] := output.DN
}
EditedLogin := LoginDisplay[EditTarget] '"|"' EditTarget '","' LoginData[EditTarget]
Result := MsgBox("Do you want to save " EditTarget " ( " LoginDisplay[EditTarget] " ) ",, "YesNo Default2")
if Result = "Yes" {
if FileExist(DataPathCfg)
Loop Read DataPathCfg {
if output.CO != "None" {
IniWrite(output.CO, SettingPathCfg, "OverRides", EditTarget)
} else {
try IniDelete(SettingPathCfg, "OverRides", EditTarget)
}
if InStr(A_LoopReadLine,EditTarget,,1)
FileAppend EditedLogin "`n", DataPathCfg "new"
else
FileAppend A_LoopReadLine "`n", DataPathCfg "new"
}
FileDelete DataPathCfg
if FileExist(DataPathCfg "new")
FileMove DataPathCfg "new", DataPathCfg
Main.Destroy
Try EditLogin.Destroy
ReadCfg()
BuildUI()
}
if Result = "No" {
EditModeToggle()
Try EditLogin.Destroy
}
}
RemoveFromDataFile(Remove, *) {
Result := MsgBox("Delete this auto-login button?`n`n" (LoginDisplay.Has(Remove) ? LoginDisplay[Remove] "`n" : "") Remove "`n`nA backup of your accounts is kept first, so it can be brought back with Settings > Recover.", Title " - Delete account", "YesNo Icon! Default2")
if Result = "Yes" {
Accounts_Backup()
if FileExist(DataPathCfg)
Loop Read DataPathCfg {
if InStr(A_LoopReadLine,'"|"' Remove '","',,1)
Continue
FileAppend A_LoopReadLine "`n", DataPathCfg "new"
}
if FileExist(DataPathCfg)
FileDelete DataPathCfg
if FileExist(DataPathCfg "new")
FileMove DataPathCfg "new", DataPathCfg
Main.Destroy
Try EditLogin.Destroy
ReadCfg()
BuildUI()
}
}
RemoveFromTROSEFile(Remove, Skip := 0, Result := 0, *) {
if !Skip
Result := MsgBox("Do you want to delete " Remove,, "YesNo Default2")
if Result = "Yes" or Skip {
if FileExist(TROSEPathCfg)
Loop Read TROSEPathCfg {
if InStr(A_LoopReadLine,Remove,,1)
Continue
FileAppend A_LoopReadLine "`n", TROSEPathCfg "new"
}
if FileExist(TROSEPathCfg)
FileDelete TROSEPathCfg
if FileExist(TROSEPathCfg "new")
FileMove TROSEPathCfg "new", TROSEPathCfg
if !Skip {
Try ROSElist.Destroy
ReadCfg()
ROSEClientsUI()
}
}
}
DetectOldCfg() {
if FileExist(SettingPathCfg) {
TestFile := FileRead(SettingPathCfg)
if !InStr(SubStr(TestFile,1,1),"[",,1)
FileDelete SettingPathCfg
}
}
FindDefaultROSE() {
Try TROSEPath := RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{975CAD98-4A32-4E44-8681-29A2C4BE0B93}_is1", "InstallLocation")
catch {
TROSEPath := FileSelect("D", , "Select ROSE install folder")
if TROSEPath = ""
QuitReloadQuestion()
TROSEPath := TROSEPath "\"
if FileExist(TROSEPath "trose.exe") {
DisplayName := "Default Selected"
if !DirExist(CfgDataPath)
DirCreate CfgDataPath
} else {
QuitReloadQuestion()
}
} else {
DisplayName := "Default Client"
} finally {
newTROSEPath := DisplayName '"|"' TROSEPath '","trose.exe'
WriteCfg(newTROSEPath,TROSEPathCfg)
FindOtherROSE(TROSEPath)
Reload
}
}
FindOtherROSE(Path) {
Loop Files Path "trose-*.exe" {
SplitPath A_LoopFileName, , , , &name_no_ext
Name_Trimmed := Trim(name_no_ext)
Name_BaseWords := strsplit(Name_Trimmed, "-", "-")
Name := ""
Loop Name_BaseWords.Length {
if A_Index = 1
Continue
if IsSet(Name) {
Name_Renamed := ForceRename(Name_BaseWords[A_Index])
Name := Name " " Name_Renamed
} else {
Name := Name_BaseWords[A_Index]
}
}
Name_Cased := StrTitle(Name)
newTROSEPath := "Default" Name_Cased '"|"' Path '","' A_LoopFileName
WriteCfg(newTROSEPath,TROSEPathCfg)
}
}
ForceRename(Name) {
if Name = "new"
Name := "beta"
Return Name
}
QuitReloadQuestion() {
Result := MsgBox("No ROSE install was selected, would you like to try again?  Cancel will quit the app..",,"0x5")
if Result = "Cancel"
ExitApp
else
Reload
}
EditBtn(*) {
global EditMode
EditMode:=!EditMode
EditModeToggle()
}

CheckForUpdate() {
}

; =============================================================================
;  ROSE Mod Launcher  -  launcher skin, news, settings and mods
;  Built on ROSE Login Manager v1.9 by zeropoke. Everything above this line is the
;  original program (logins, encryption, clients, More window) left as it was,
;  apart from BuildUI / DisplayModeSwitch / EditModeToggle, which live here now.
;
;  Files used next to the exe:
;    Launcher Files\          the window art (bg.png, buttons, banner.png)
;  Files used in each game folder:
;    Launcher Mods\<Mod>\mod.ini            Name, Version, Author, Group, Description,
;                                      Priority, UpdateUrl
;    Launcher Mods\<Mod>\files\...          laid out like the game folder
;    Launcher Mods\_state.ini               which mods are on
;    Launcher Mods\_installed.txt           what is copied into the game right now
;    Launcher Mods\_backup\...              the game's own files while a mod is on
; =============================================================================

Launcher_InitGlobals() {
    global PatchBusy := false, PatchThen := "", PatchRetry := 0
    global AcctPage := 0, NewsItems := [], NewsIdx := 1, NewsQueue := []
    global ModsList := [], ModsBusy := false, ModsDirty := false, ThemeChoices := [""]
}

Asset(Name) {
    global SkinDir
    if (IsSet(SkinDir) && SkinDir != "" && FileExist(SkinDir Name))
        return SkinDir Name
    return A_ScriptDir "\Launcher Files\" Name
}

Launcher_Url(Key) {
    switch Key {
        case "website": return "https://www.roseonlinegame.com/"
        case "forum":   return "https://forum.roseonlinegame.com/"
        case "support": return "https://forum.roseonlinegame.com/support/"
        case "powerup": return "https://www.roseonlinegame.com/shop"
        case "news":    return "https://www.roseonlinegame.com/news"
    }
    return ""
}

; -----------------------------------------------------------------------------
;  Main window
; -----------------------------------------------------------------------------
BuildUI() {
    global Main, DDL, ThemeDDL, ModsBtn, NewsPic, NewsCap, NewsRows, NewsDates, StatusText, Prog
    global AcctSlots, AcctDots, AcctEmpty, AcctPrev, AcctNext, HoverMap, HoverLast, MainX, MainY
    static Started := false
    global ServerText
    Skin_Resolve()
    if !FileExist(Asset("bg.png")) {
        MsgBox("The 'Launcher Files' folder with the launcher art is missing.`n`nPut it next to " A_ScriptName " and start it again.", Title)
        ExitApp
    }
    if !Started {
        try {
            MainX := IniRead(SettingPathCfg, "Launcher", "X")
            MainY := IniRead(SettingPathCfg, "Launcher", "Y")
            vx := SysGet(76), vy := SysGet(77), vw := SysGet(78), vh := SysGet(79)
            if (MainX < vx - 600 || MainX > vx + vw - 80 || MainY < vy || MainY > vy + vh - 60)
                MainX := "", MainY := ""
        } catch {
            MainX := "", MainY := ""
        }
    }
    HoverMap := Map()
    HoverLast := 0
    AcctSlots := [], AcctDots := [], NewsRows := [], NewsDates := []

    Main := Gui("-Caption +Border", Title)
    Main.OnEvent("Close", (*) => Main_Exit())
    Main.BackColor := Skin_C("Face")
    Main.MarginX := 0
    Main.MarginY := 0
    Main.SetFont("s9", "Segoe UI")
    Main.Add("Picture", "x0 y0 w760 h500", Asset("bg.png"))

    ; --- top bar -------------------------------------------------------------
    x := 12
    for key in ["website", "forum", "support", "powerup", "settings"] {
        p := Main.Add("Picture", "x" x " y8 w100 h28", Asset("nav_" key "_n.png"))
        p.OnEvent("Click", Nav_Click.Bind(key))
        HoverMap[p.Hwnd] := Pic_Hover(p, "nav_" key)
        x += 106
    }
    Main.SetFont("s9 bold c" Skin_C("Title") "")
    Main.Add("Text", "x548 y14 w156 h18 Background" Skin_C("Face") "", "ROSE Mod Launcher")
    Main.SetFont("s9 norm c" Skin_C("Text") "")
    p := Main.Add("Picture", "x708 y11 w22 h22", Asset("min_n.png"))
    p.OnEvent("Click", (*) => Main.Minimize())
    HoverMap[p.Hwnd] := Pic_Hover(p, "min")
    p := Main.Add("Picture", "x732 y11 w22 h22", Asset("close_n.png"))
    p.OnEvent("Click", (*) => Main_Exit())
    HoverMap[p.Hwnd] := Pic_Hover(p, "close")

    ; --- news picture and caption ---------------------------------------------
    NewsPic := Main.Add("Picture", "x30 y62 w444 h250", Asset("banner.png"))
    NewsPic.OnEvent("Click", (*) => News_Open())
    Main.SetFont("s10 bold c" Skin_C("Arrow") "")
    t := Main.Add("Text", "x32 y319 w18 h20 Center Background" Skin_C("Panel") "", "<")
    t.OnEvent("Click", (*) => News_Step(-1))
    HoverMap[t.Hwnd] := Text_Hover(t, Skin_C("Arrow"), Skin_C("Hot"))
    t := Main.Add("Text", "x454 y319 w18 h20 Center Background" Skin_C("Panel") "", ">")
    t.OnEvent("Click", (*) => News_Step(1))
    HoverMap[t.Hwnd] := Text_Hover(t, Skin_C("Arrow"), Skin_C("Hot"))
    Main.SetFont("s9 norm c" Skin_C("Caption") "")
    NewsCap := Main.Add("Text", "x54 y321 w396 h18 Center Background" Skin_C("Panel") " 0x4000", "Loading news...")
    NewsCap.OnEvent("Click", (*) => News_Open())
    HoverMap[NewsCap.Hwnd] := Text_Hover(NewsCap, Skin_C("Caption"), Skin_C("Head"))

    ; --- notices ----------------------------------------------------------------
    Main.SetFont("s10 bold c" Skin_C("Head") "")
    Main.Add("Text", "x504 y61 w140 h20 Background" Skin_C("Panel") "", "Notices")
    Main.SetFont("s8 norm c" Skin_C("Link") "")
    t := Main.Add("Text", "x660 y64 w70 h16 Right Background" Skin_C("Panel") "", "view all")
    t.OnEvent("Click", (*) => Run(Launcher_Url("news")))
    HoverMap[t.Hwnd] := Text_Hover(t, Skin_C("Link"), Skin_C("Head"))
    Loop 5 {
        y := 88 + (A_Index - 1) * 22
        Main.SetFont("s8 norm c" Skin_C("Text") "")
        r := Main.Add("Text", "x504 y" y " w176 h17 Background" Skin_C("Panel") " 0x4000", "")
        r.OnEvent("Click", News_RowClick.Bind(A_Index))
        HoverMap[r.Hwnd] := News_RowHover(A_Index)
        NewsRows.Push(r)
        Main.SetFont("s8 norm c" Skin_C("Dim") "")
        NewsDates.Push(Main.Add("Text", "x682 y" y " w48 h17 Right Background" Skin_C("Panel") "", ""))
    }

    ; --- client, theme, mods -----------------------------------------------------
    ; The Client picker is hidden: the launcher keeps using the client already
    ; chosen (the game folder it found), so nothing else changes.
    Main.SetFont("s9 bold c" Skin_C("Head") "")
    Main.Add("Text", "x504 y240 w120 h18 Background" Skin_C("Panel") "", "UI Theme")
    Main.SetFont("s8 norm c" Skin_C("Dim") "")
    ServerText := Main.Add("Text", "x584 y242 w146 h16 Right Background" Skin_C("Panel") "", "")
    Main.SetFont("s9 norm c000000")
    DDL := Main.Add("DropDownList", "x504 y228 w226 Hidden vTROSEChoice", TROSEDisplay)
    DDL.Add(["------------------------------", "Add/Remove ROSE"])
    DDL.OnEvent("Change", TROSEddl)
    ThemeDDL := Main.Add("DropDownList", "x504 y259 w226 vThemeChoice")
    ThemeDDL.OnEvent("Change", ThemeDDL_Change)
    ModsBtn := Btn_Add(Main, 504, 300, 110, 30, "Mods", (*) => ModsUI_Show())
    Btn_Add(Main, 620, 300, 110, 30, "Update Game", (*) => Patch_Run())

    ; --- auto-login strip ------------------------------------------------------------
    Loop 8 {
        col := Mod(A_Index - 1, 4), row := (A_Index - 1) // 4
        x := 36 + col * 164, y := 371 + row * 23
        ; each account is a small glass button (acct_n/acct_h.png) with its name on top
        b := Main.Add("Picture", "x" x " y" y " w156 h21", Asset("acct_n.png"))
        b.OnEvent("Click", Acct_Click.Bind(A_Index))
        HoverMap[b.Hwnd] := Acct_Hover(A_Index)
        AcctDots.Push(b)
        Main.SetFont("s9 norm c" Skin_C("BtnText") "")
        s := Main.Add("Text", "x" (x + 6) " y" y " w144 h21 Center 0x200 BackgroundTrans 0x4000", "")
        s.OnEvent("Click", Acct_Click.Bind(A_Index))
        HoverMap[s.Hwnd] := Acct_Hover(A_Index)
        AcctSlots.Push(s)
    }
    Main.SetFont("s9 norm c" Skin_C("Dim") "")
    AcctEmpty := Main.Add("Text", "x40 y384 w600 h18 Background" Skin_C("Strip") "", "No auto-login buttons yet. Press Settings at the top to add your accounts.")
    Main.SetFont("s10 bold c" Skin_C("Arrow") "")
    AcctPrev := Main.Add("Text", "x698 y383 w16 h20 Center Background" Skin_C("Strip") "", "<")
    AcctPrev.OnEvent("Click", (*) => Acct_Page(-1))
    HoverMap[AcctPrev.Hwnd] := Text_Hover(AcctPrev, Skin_C("Arrow"), Skin_C("Hot"))
    AcctNext := Main.Add("Text", "x716 y383 w16 h20 Center Background" Skin_C("Strip") "", ">")
    AcctNext.OnEvent("Click", (*) => Acct_Page(1))
    HoverMap[AcctNext.Hwnd] := Text_Hover(AcctNext, Skin_C("Arrow"), Skin_C("Hot"))

    ; --- bottom row -------------------------------------------------------------------
    Prog := Main.Add("Progress", "x11 y445 w596 h16 c" Skin_C("Bar") " Background" Skin_C("BarBg") " Range0-100", 0)
    Main.SetFont("s9 norm c" Skin_C("Status") "")
    StatusText := Main.Add("Text", "x12 y468 w596 h18 Background" Skin_C("Face") " 0x4000", "Ready")
    p := Main.Add("Picture", "x616 y438 w46 h54", Asset("repair_n.png"))
    p.OnEvent("Click", Repair_Click)
    HoverMap[p.Hwnd] := Pic_Hover(p, "repair")
    p := Main.Add("Picture", "x668 y438 w82 h54", Asset("start_n.png"))
    p.OnEvent("Click", Start_Click)
    HoverMap[p.Hwnd] := Pic_Hover(p, "start")

    if (MainX != "")
        Main.Show("x" MainX " y" MainY " w760 h500")
    else
        Main.Show("w760 h500")
    ResetROSEClient_DDL()
    Acct_Fill()
    News_Render()
    ModsRow_Refresh()
    SettingsUI_Fill()
    if !Started {
        Started := true
        OnMessage(0x201, Main_LButton)
        SetTimer(Hover_Poll, 100)
        SetTimer(Launcher_Startup, -300)
        SetTimer(() => Server_Check(), -4000)
        SetTimer(Server_Check, 120000)
    }
}

Launcher_Startup() {
    Launcher_CleanOld()
    Launcher_SelfUpdate(true)
    News_Init()
    if Patch_AutoOn()
        Patch_Run(() => Mods_UpdateAll(true))
    else
        Mods_UpdateAll(true)
}

Main_Exit() {
    global Main
    try {
        WinGetPos(&x, &y, , , Main.Hwnd)
        if (x > -10000) {
            IniWrite(x, SettingPathCfg, "Launcher", "X")
            IniWrite(y, SettingPathCfg, "Launcher", "Y")
        }
    }
    ExitApp
}

; Drag the borderless window from any empty spot.
Main_LButton(wParam, lParam, Msg, Hwnd) {
    global Main
    try {
        if (Hwnd = Main.Hwnd) {
            PostMessage(0xA1, 2, 0, , Main.Hwnd)
            return 0
        }
    }
}

; Hover highlights: one timer looks at the control under the mouse.
Hover_Poll() {
    global HoverMap, HoverLast, Main, MainX, MainY
    ctl := 0
    try MouseGetPos(, , , &ctl, 2)
    if (ctl = "")
        ctl := 0
    if (ctl != HoverLast) {
        if HoverMap.Has(HoverLast)
            try HoverMap[HoverLast].Call(false)
        HoverLast := ctl
        if HoverMap.Has(ctl)
            try HoverMap[ctl].Call(true)
    }
    try {
        WinGetPos(&x, &y, , , Main.Hwnd)
        if (x > -10000)
            MainX := x, MainY := y
    }
}

; Picture buttons drawn like the game's own buttons (btn_n/btn_h.png, skin-aware),
; with the label on top. Returns the label, so .Text can change it.
Btn_Add(G, X, Y, W, H, Label, Fn) {
    global HoverMap
    pic := G.Add("Picture", "x" X " y" Y " w" W " h" H, Asset("btn_n.png"))
    G.SetFont("s9 bold c" Skin_C("BtnText"))
    t := G.Add("Text", "x" X " y" Y " w" W " h" H " Center 0x200 BackgroundTrans", Label)
    t.OnEvent("Click", Fn)
    pic.OnEvent("Click", Fn)
    hov := Btn_Hover(pic, t)
    HoverMap[t.Hwnd] := hov
    HoverMap[pic.Hwnd] := hov
    return t
}

Btn_Hover(Pic, T) {
    return (On) => Btn_Light(Pic, T, On)
}

Btn_Light(Pic, T, On) {
    Pic.Value := Asset(On ? "btn_h.png" : "btn_n.png")
    T.GetPos(&x, &y, &w, &h)
    Area_Redraw(x, y, w, h, T.Gui.Hwnd)
}

Btn_SetText(T, Text) {
    if (T.Text = Text)
        return
    T.Text := Text
    T.GetPos(&x, &y, &w, &h)
    Area_Redraw(x, y, w, h, T.Gui.Hwnd)
}

Pic_Hover(Pic, Key) {
    return (On) => (Pic.Value := Asset(Key (On ? "_h.png" : "_n.png")))
}

Text_Hover(Ctl, Normal, Hot) {
    return (On) => Ctl.SetFont("c" (On ? Hot : Normal))
}

Nav_Click(Key, *) {
    if (Key = "settings")
        SettingsUI_Show()
    else
        Run(Launcher_Url(Key))
}

Status_Set(Text, Percent := -1, Force := false) {
    global StatusText, Prog, PatchBusy
    if (PatchBusy && !Force)
        return
    try StatusText.Text := Text
    if (Percent >= 0)
        try Prog.Value := Percent
}

Area_Redraw(X, Y, W, H, Hwnd := 0) {
    global Main
    rc := Buffer(16)
    NumPut("Int", X, "Int", Y, "Int", X + W, "Int", Y + H, rc)
    try DllCall("RedrawWindow", "Ptr", Hwnd ? Hwnd : Main.Hwnd, "Ptr", rc, "Ptr", 0, "UInt", 0x185)
}

; START opens the game the same way the official updater does: no auto-login.
Start_Click(*) {
    global PatchBusy, PatchThen
    if PatchBusy {
        PatchThen := Start_Now
        Status_Set("The game is updating - it will start as soon as that's done.", -1, true)
        return
    }
    Start_Now()
}

Start_Now() {
    global CurrentTROSEPath, CurrentTROSE
    if !CheckandFail()
        return
    Mods_BeforeLaunch()
    try {
        SetWorkingDir CurrentTROSEPath
        Run('"' CurrentTROSEPath CurrentTROSE '" --init --server connect.roseonlinegame.com', CurrentTROSEPath)
        Status_Set("Starting ROSE Online...", 100)
    } catch {
        MsgBox("Could not start " CurrentTROSE ". Check the client picked under Client.", Title)
    }
}

; -----------------------------------------------------------------------------
;  Auto-login strip
; -----------------------------------------------------------------------------
DisplayModeSwitch() {
    Acct_Fill()
}

EditModeToggle() {
    global EditMode
    EditMode := 0
}

Acct_Fill() {
    global AcctSlots, AcctDots, AcctEmpty, AcctPrev, AcctNext, AcctPage
    if !IsSet(AcctSlots) || AcctSlots.Length = 0
        return
    total := IsSet(LoginEmail) ? LoginEmail.Length : 0
    pages := Max(1, Ceil(total / 8))
    if (AcctPage >= pages)
        AcctPage := pages - 1
    if (AcctPage < 0)
        AcctPage := 0
    for k, s in AcctSlots {
        i := AcctPage * 8 + k
        if (i <= total) {
            e := LoginEmail[i]
            s.Text := (DisplayMode = 1 ? e : LoginDisplay[e]) SetOverRideMarker(e)
            s.SetFont("norm c" Skin_C("BtnText") "")
            s.Visible := true
            AcctDots[k].Value := Asset("acct_n.png")
            AcctDots[k].Visible := true
        } else {
            s.Visible := false
            AcctDots[k].Visible := false
        }
    }
    AcctEmpty.Visible := (total = 0)
    AcctPrev.Visible := (pages > 1)
    AcctNext.Visible := (pages > 1)
    Area_Redraw(24, 366, 714, 52)
}

Acct_Page(Dir) {
    global AcctPage
    AcctPage += Dir
    total := LoginEmail.Length
    pages := Max(1, Ceil(total / 8))
    if (AcctPage < 0)
        AcctPage := pages - 1
    if (AcctPage >= pages)
        AcctPage := 0
    Acct_Fill()
}

Acct_Hover(Slot) {
    return (On) => Acct_Light(Slot, On)
}

Acct_Light(Slot, On) {
    global AcctSlots, AcctDots
    try {
        AcctSlots[Slot].SetFont(On ? "bold c" Skin_C("BtnText") "" : "norm c" Skin_C("BtnText") "")
        AcctDots[Slot].Value := Asset(On ? "acct_h.png" : "acct_n.png")
        AcctDots[Slot].GetPos(&x, &y, &w, &h)
        Area_Redraw(x, y, w, h)
    }
}

Acct_Click(Slot, *) {
    global AcctPage, PatchBusy, PatchThen
    i := AcctPage * 8 + Slot
    if (i > LoginEmail.Length)
        return
    e := LoginEmail[i]
    if PatchBusy {
        PatchThen := LaunchROSE.Bind(e)
        Status_Set("The game is updating - " LoginDisplay[e] " will log in as soon as that's done.", -1, true)
        return
    }
    Status_Set("Logging in " LoginDisplay[e] "...", 100)
    LaunchROSE(e)
}

; -----------------------------------------------------------------------------
;  Settings: the auto-login buttons
; -----------------------------------------------------------------------------
SettingsUI_Show(*) {
    global SetUI, SetLV
    try SetUI.Destroy()
    SetUI := Gui(, Title " - Settings")
    SetUI.SetFont("s9", "Segoe UI")
    SetUI.Add("Text", "x10 y10 w640", "These are your auto-login buttons. Clicking one on the main window logs straight in to that account.`nSTART on the main window opens the game normally, without logging in.")
    SetLV := SetUI.Add("ListView", "x10 y48 w520 h230 -Multi Grid NoSortHdr", ["Button name", "Account (email)", "Client"])
    SetLV.OnEvent("DoubleClick", (LV, Row) => (Row ? SettingsUI_Edit() : 0))
    SetUI.Add("Button", "x540 y48 w110 h28", "New...").OnEvent("Click", (*) => NewLoginUI())
    SetUI.Add("Button", "x540 y82 w110 h28", "Edit...").OnEvent("Click", (*) => SettingsUI_Edit())
    SetUI.Add("Button", "x540 y116 w110 h28", "Delete").OnEvent("Click", (*) => SettingsUI_Delete())
    SetUI.Add("Button", "x540 y164 w110 h28", "Move Up").OnEvent("Click", (*) => SettingsUI_Move(-1))
    SetUI.Add("Button", "x540 y198 w110 h28", "Move Down").OnEvent("Click", (*) => SettingsUI_Move(1))
    SetUI.Add("Button", "x540 y232 w110 h28", "Recover...").OnEvent("Click", Recover_Show)
    SetUI.Add("Button", "x540 y266 w110 h28", "Back Up Settings").OnEvent("Click", Backup_Make)
    SetUI.Add("Button", "x540 y300 w110 h28", "Restore Settings").OnEvent("Click", Backup_Restore)
    chk := SetUI.Add("CheckBox", "x10 y288 w520", "Show emails on the buttons instead of names")
    chk.Value := DisplayMode
    chk.OnEvent("Click", SettingsUI_Emails)
    chk2 := SetUI.Add("CheckBox", "x10 y308 w520", "Update the game when the launcher opens")
    chk2.Value := Patch_AutoOn()
    chk2.OnEvent("Click", (c, *) => IniWrite(c.Value, SettingPathCfg, "Launcher", "AutoPatch"))
    chk3 := SetUI.Add("CheckBox", "x10 y328 w520", "Match the launcher's look to the UI theme")
    chk3.Value := (IniRead(SettingPathCfg, "Launcher", "MatchSkin", "1") = "1")
    chk3.OnEvent("Click", (c, *) => (IniWrite(c.Value, SettingPathCfg, "Launcher", "MatchSkin"), SetTimer(Launcher_Reskin, -100)))
    SetUI.Add("Text", "x10 y350 w520", "Edit... also sets which client an account opens. A * after a name means it has its own client.")
    SetUI.Add("Button", "x10 y376 w140 h28", "More options...").OnEvent("Click", (*) => BuildMoreUI())
    SetUI.Add("Button", "x155 y376 w185 h28", "Check for Launcher Update").OnEvent("Click", (*) => Launcher_SelfUpdate(false))
    SetUI.Add("Button", "x345 y376 w185 h28", "Make Launcher Update List").OnEvent("Click", ModsUI_MakeLauncherManifest)
    SetUI.Add("Button", "x540 y376 w110 h28", "Close").OnEvent("Click", (*) => SetUI.Destroy())
    If DarkMode = 2
        DarkMode_Setter(SetUI)
    SettingsUI_Fill()
    SetUI.Show("AutoSize")
}

SettingsUI_Fill() {
    global SetLV
    if !IsSet(SetLV)
        return
    try {
        SetLV.Delete()
        for e in LoginEmail {
            o := CheckforOverRide(e)
            SetLV.Add(, LoginDisplay[e], e, (o = "0" || o = "") ? "(picked on main window)" : o)
        }
        SetLV.ModifyCol(1, 150)
        SetLV.ModifyCol(2, 220)
        SetLV.ModifyCol(3, 140)
    }
}

SettingsUI_Selected() {
    global SetLV
    row := 0
    try row := SetLV.GetNext(0)
    if !row {
        MsgBox("Pick an account in the list first.", Title)
        return ""
    }
    return SetLV.GetText(row, 2)
}

SettingsUI_Edit() {
    e := SettingsUI_Selected()
    if (e != "")
        EditLoginUI(e)
}

SettingsUI_Delete() {
    e := SettingsUI_Selected()
    if (e != "")
        RemoveFromDataFile(e)
}

SettingsUI_Emails(Ctrl, *) {
    global DisplayMode
    DisplayMode := Ctrl.Value
    Try IniWrite DisplayMode, SettingPathCfg, "RLM", "DisplayMode"
    Acct_Fill()
}

SettingsUI_Move(Dir) {
    global SetLV
    Accounts_Backup()
    row := 0
    try row := SetLV.GetNext(0)
    if !row
        return
    lines := []
    Loop Read DataPathCfg {
        if (A_LoopReadLine != "")
            lines.Push(A_LoopReadLine)
    }
    j := row + Dir
    if (j < 1 || j > lines.Length)
        return
    t := lines[row]
    lines[row] := lines[j]
    lines[j] := t
    out := ""
    for l in lines
        out .= l "`n"
    FileDelete DataPathCfg
    FileAppend out, DataPathCfg
    ReadCfg()
    Acct_Fill()
    SettingsUI_Fill()
    try SetLV.Modify(j, "Select Focus Vis")
}

; -----------------------------------------------------------------------------
;  News from roseonlinegame.com/news (cached in %AppData%\RLM\news)
; -----------------------------------------------------------------------------
News_Dir() {
    d := CfgDataPath "news\"
    if !DirExist(d)
        DirCreate d
    return d
}

News_Init() {
    global NewsItems
    NewsItems := News_ReadCache()
    News_Render()
    Status_Set("Checking the news...")
    SetTimer(News_Load, -100)
}

News_ReadCache() {
    items := []
    ini := News_Dir() "news.ini"
    n := 0
    try n := Integer(IniRead(ini, "News", "Count", 0))
    Loop n {
        sec := "Item" A_Index
        it := {Id: IniRead(ini, sec, "Id", ""), Url: IniRead(ini, sec, "Url", ""), Title: IniRead(ini, sec, "Title", ""), Date: IniRead(ini, sec, "Date", ""), Image: IniRead(ini, sec, "Image", ""), File: IniRead(ini, sec, "File", "")}
        if (it.Url != "")
            items.Push(it)
    }
    return items
}

News_WriteCache() {
    global NewsItems
    ini := News_Dir() "news.ini"
    try FileDelete ini
    IniWrite(NewsItems.Length, ini, "News", "Count")
    for i, it in NewsItems {
        sec := "Item" i
        IniWrite(it.Id, ini, sec, "Id")
        IniWrite(it.Url, ini, sec, "Url")
        IniWrite(it.Title, ini, sec, "Title")
        IniWrite(it.Date, ini, sec, "Date")
        IniWrite(it.Image, ini, sec, "Image")
        IniWrite(it.File, ini, sec, "File")
    }
}

Http_Get(Url) {
    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", Url, true)
        whr.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) ROSE-Mod-Launcher")
        whr.SetRequestHeader("Cache-Control", "no-cache")
        whr.Send()
        if !whr.WaitForResponse(12)
            return ""
        if (whr.Status != 200)
            return ""
        return whr.ResponseText
    }
    return ""
}

Html_Text(S) {
    S := RegExReplace(S, "s)<[^>]*>", " ")
    S := StrReplace(S, "&amp;", "&")
    S := StrReplace(S, "&quot;", '"')
    S := StrReplace(S, "&#039;", "'")
    S := StrReplace(S, "&#39;", "'")
    S := StrReplace(S, "&apos;", "'")
    S := StrReplace(S, "&lt;", "<")
    S := StrReplace(S, "&gt;", ">")
    S := StrReplace(S, "&nbsp;", " ")
    S := RegExReplace(S, "\s+", " ")
    return Trim(S)
}

Url_Full(U) {
    if (SubStr(U, 1, 2) = "//")
        return "https:" U
    if (SubStr(U, 1, 1) = "/")
        return "https://www.roseonlinegame.com" U
    return U
}

News_Load() {
    global NewsItems, NewsQueue, NewsIdx
    html := Http_Get(Launcher_Url("news"))
    if (html = "") {
        Status_Set(NewsItems.Length ? "Ready (offline - showing saved news)" : "Ready (could not reach the news page)")
        if NewsItems.Length
            SetTimer(News_Next, 9000)
        return
    }
    old := Map()
    for it in NewsItems
        old[it.Id] := it
    items := []
    seen := Map()
    pos := 1
    linkRe := 'i)href="((?:https?://(?:www\.)?roseonlinegame\.com)?/news/(\d+)-[^"#?]*)"'
    while (pos := RegExMatch(html, linkRe, &m, pos)) {
        id := m[2]
        start := m.Pos
        pos += m.Len
        if seen.Has(id)
            continue
        seen[id] := true
        ; the chunk runs to the next link for a different post
        stop := StrLen(html) + 1
        p2 := pos
        while (p2 := RegExMatch(html, linkRe, &m2, p2)) {
            if (m2[2] != id) {
                stop := m2.Pos
                break
            }
            p2 += m2.Len
        }
        chunk := SubStr(html, start, stop - start)
        it := {Id: id, Url: Url_Full(m[1]), Title: "", Date: "", Image: "", File: ""}
        if RegExMatch(chunk, 'is)<h[1-4][^>]*>(.*?)</h[1-4]>', &t)
            it.Title := Html_Text(t[1])
        if (it.Title = "" && RegExMatch(chunk, 'i)<img[^>]*\salt="([^"]+)"', &t))
            it.Title := Html_Text(t[1])
        if RegExMatch(chunk, 'i)(?:data-src|src)="([^"]+\.(?:png|jpe?g|gif|bmp)(?:\?[^"]*)?)"', &t)
            it.Image := Url_Full(t[1])
        if RegExMatch(chunk, "(January|February|March|April|May|June|July|August|September|October|November|December) \d{1,2}, \d{4}", &t)
            it.Date := t[0]
        if old.Has(id) {
            o := old[id]
            if (it.Image = "")
                it.Image := o.Image
            if (o.File != "" && FileExist(o.File))
                it.File := o.File
            if (it.Title = "")
                it.Title := o.Title
        }
        if (it.Title = "")
            it.Title := StrTitle(StrReplace(RegExReplace(m[1], ".*/\d+-"), "-", " "))
        items.Push(it)
        if (items.Length >= 8)
            break
    }
    if (items.Length = 0) {
        Status_Set("Ready (the news page has changed - showing saved news)")
        return
    }
    NewsItems := items
    NewsIdx := 1
    News_WriteCache()
    News_Render()
    NewsQueue := []
    for i, it in NewsItems {
        if (it.File = "")
            NewsQueue.Push(i)
    }
    Status_Set("Ready")
    SetTimer(News_Next, 9000)
    if NewsQueue.Length
        SetTimer(News_FetchNext, -200)
}

; Pictures are fetched one at a time so the window stays responsive.
News_FetchNext() {
    global NewsItems, NewsQueue, NewsIdx
    if (NewsQueue.Length = 0)
        return
    i := NewsQueue.RemoveAt(1)
    if (i <= NewsItems.Length) {
        it := NewsItems[i]
        if (it.Image = "") {
            page := Http_Get(it.Url)
            if (RegExMatch(page, 'i)<meta[^>]+property="og:image"[^>]+content="([^"]+)"', &t) || RegExMatch(page, 'i)<meta[^>]+content="([^"]+)"[^>]+property="og:image"', &t))
                it.Image := Url_Full(t[1])
        }
        if (it.Image != "" && RegExMatch(it.Image, "i)\.(png|jpe?g|gif|bmp)(?:\?|$)", &e)) {
            file := News_Dir() it.Id "." StrLower(e[1])
            if !FileExist(file)
                try Download(it.Image, file)
            if FileExist(file) && FileGetSize(file) > 0 {
                it.File := file
                News_WriteCache()
                if (i = NewsIdx)
                    News_Show(i)
            }
        }
    }
    if NewsQueue.Length
        SetTimer(News_FetchNext, -50)
}

News_Render() {
    global NewsItems, NewsRows, NewsDates, NewsIdx
    if !IsSet(NewsRows) || NewsRows.Length = 0
        return
    for k, r in NewsRows {
        if (k <= NewsItems.Length) {
            r.Text := NewsItems[k].Title
            NewsDates[k].Text := News_Short(NewsItems[k].Date)
        } else {
            r.Text := ""
            NewsDates[k].Text := ""
        }
    }
    if NewsItems.Length
        News_Show(NewsIdx)
}

News_Short(D) {
    if RegExMatch(D, "^(\w{3})\w* (\d+)", &m)
        return m[1] " " m[2]
    return D
}

News_Show(I) {
    global NewsItems, NewsIdx, NewsPic, NewsCap
    if (NewsItems.Length = 0)
        return
    if (I < 1)
        I := NewsItems.Length
    if (I > NewsItems.Length)
        I := 1
    NewsIdx := I
    it := NewsItems[I]
    file := (it.File != "" && FileExist(it.File)) ? it.File : Asset("banner.png")
    Pic_Fit(NewsPic, file, 30, 62, 444, 250)
    try NewsCap.Text := it.Title (it.Date != "" ? "   -   " it.Date : "")
    Loop 5
        News_RowColor(A_Index, false)
}

News_RowColor(K, Hot) {
    global NewsRows, NewsIdx
    try NewsRows[K].SetFont(Hot ? "c" Skin_C("Head") " underline" : (K = NewsIdx ? "c" Skin_C("Caption") " norm" : "c" Skin_C("Text") " norm"))
}

News_RowHover(K) {
    return (On) => News_RowColor(K, On)
}

News_RowClick(K, *) {
    global NewsItems
    if (K > NewsItems.Length)
        return
    News_Show(K)
    SetTimer(News_Next, 9000)
}

News_Step(Dir) {
    global NewsIdx
    News_Show(NewsIdx + Dir)
    SetTimer(News_Next, 9000)
}

News_Next() {
    global NewsIdx, Main
    try {
        if (WinGetMinMax(Main.Hwnd) = -1)
            return
    }
    News_Show(NewsIdx + 1)
}

News_Open() {
    global NewsItems, NewsIdx
    if (NewsItems.Length && NewsIdx <= NewsItems.Length)
        Run(NewsItems[NewsIdx].Url)
    else
        Run(Launcher_Url("news"))
}

; Show a picture as large as it fits in the box, centred, keeping its shape.
Pic_Fit(Pic, File, X, Y, W, H) {
    bw := W, bh := H
    try {
        hb := LoadPicture(File)
        bm := Buffer(32, 0)
        DllCall("gdi32\GetObjectW", "Ptr", hb, "Int", 32, "Ptr", bm)
        iw := NumGet(bm, 4, "Int"), ih := NumGet(bm, 8, "Int")
        DllCall("gdi32\DeleteObject", "Ptr", hb)
        if (iw > 0 && ih > 0) {
            sc := Min(W / iw, H / ih)
            bw := Round(iw * sc), bh := Round(ih * sc)
        }
    }
    try {
        Pic.Value := "*w" bw " *h" bh " " File
        Pic.Move(X + (W - bw) // 2, Y + (H - bh) // 2, bw, bh)
    }
    Area_Redraw(X, Y, W, H)
}

; -----------------------------------------------------------------------------
;  Mods
; -----------------------------------------------------------------------------
Mods_Game() {
    global CurrentTROSEPath
    if (IsSet(CurrentTROSEPath) && CurrentTROSEPath != "") {
        g := CurrentTROSEPath
    } else {
        n := IniRead(SettingPathCfg, "RLM", "CurrentClient", "")
        g := TROSEPath.Has(n) ? TROSEPath[n] : (TROSEDisplay.Length ? TROSEPath[TROSEDisplay[1]] : "")
    }
    if (SubStr(g, -1) != "\")
        g .= "\"
    return g
}

Mods_Dir(Game := "") {
    if (Game = "")
        Game := Mods_Game()
    return Game "Launcher Mods\"
}

Mods_Num(S, D) {
    return IsNumber(S) ? Number(S) : D
}

Mods_Scan(Game) {
    list := []
    dir := Mods_Dir(Game)
    if !DirExist(dir)
        return list
    state := dir "_state.ini"
    Loop Files dir "*", "D" {
        folder := A_LoopFileName
        if (SubStr(folder, 1, 1) = "_")
            continue
        path := A_LoopFileFullPath "\"
        if !DirExist(path "files")
            continue
        ini := path "mod.ini"
        m := {Folder: folder, Path: path}
        m.Name := IniRead(ini, "Mod", "Name", folder)
        m.Version := IniRead(ini, "Mod", "Version", "")
        m.Author := IniRead(ini, "Mod", "Author", "")
        m.Group := IniRead(ini, "Mod", "Group", "")
        m.Description := StrReplace(IniRead(ini, "Mod", "Description", ""), "\n", "`n")
        m.UpdateUrl := IniRead(ini, "Mod", "UpdateUrl", "")
        m.Changes := StrReplace(IniRead(ini, "Mod", "Changes", ""), "\n", "`n")
        m.Priority := Mods_Num(IniRead(ini, "Mod", "Priority", ""), m.Group = "UI Theme" ? 10 : 50)
        m.Enabled := (IniRead(state, "Enabled", folder, "0") = "1")
        list.Push(m)
    }
    return Mods_Sort(list)
}

; Lower priority goes in first, so a higher one wins when two mods share a file.
Mods_Sort(List) {
    n := List.Length
    if (n < 2)
        return List
    Loop n - 1 {
        i := A_Index + 1
        cur := List[i]
        j := i - 1
        while (j >= 1 && Mods_Before(cur, List[j])) {
            List[j + 1] := List[j]
            j--
        }
        List[j + 1] := cur
    }
    return List
}

Mods_Before(A, B) {
    if (A.Priority != B.Priority)
        return A.Priority < B.Priority
    return StrCompare(A.Name, B.Name) < 0
}

Mods_SaveEnabled(Game, List) {
    dir := Mods_Dir(Game)
    if !DirExist(dir)
        DirCreate dir
    for m in List
        IniWrite(m.Enabled ? 1 : 0, dir "_state.ini", "Enabled", m.Folder)
    IniWrite(1, dir "_state.ini", "State", "Pending")
}

Mods_Sha(Path) {
    try return Hash.File("SHA1", Path)
    return ""
}

Mods_EnsureDir(FilePath) {
    SplitPath FilePath, , &d
    if (d != "" && !DirExist(d))
        DirCreate d
}

; Put the game's own files back for everything the mods copied in. A file that
; changed since (a game patch) is kept as the new original.
Mods_Restore(Game) {
    dir := Mods_Dir(Game)
    man := dir "_installed.txt"
    if !FileExist(man)
        return
    for line in StrSplit(FileRead(man, "UTF-8"), "`n", "`r") {
        p := StrSplit(line, "|", , 3)
        if (p.Length < 3)
            continue
        target := Game p[3]
        backup := dir "_backup\" p[3]
        now := FileExist(target) ? Mods_Sha(target) : ""
        if (now != "" && now = p[2]) {
            if (p[1] = "B" && FileExist(backup))
                FileCopy backup, target, 1
            else if (p[1] = "N")
                FileDelete target
        }
        if FileExist(backup)
            FileDelete backup
    }
    FileDelete man
    try DirDelete dir "_backup", 1
}

Mods_Apply(Game) {
    dir := Mods_Dir(Game)
    if !DirExist(dir)
        DirCreate dir
    Status_Set("Putting the game's own files back...", 0)
    Mods_Restore(Game)
    plan := Map()
    for m in Mods_Scan(Game) {
        if !m.Enabled
            continue
        src := m.Path "files\"
        Loop Files src "*", "FR" {
            rel := SubStr(A_LoopFileFullPath, StrLen(src) + 1)
            plan[rel] := A_LoopFileFullPath
        }
    }
    total := plan.Count
    done := 0
    out := FileOpen(dir "_installed.txt", "w", "UTF-8-RAW")
    try {
        for rel, from in plan {
            target := Game rel
            if FileExist(target) {
                backup := dir "_backup\" rel
                Mods_EnsureDir(backup)
                FileCopy target, backup, 1
                flag := "B"
            } else {
                Mods_EnsureDir(target)
                flag := "N"
            }
            FileCopy from, target, 1
            out.WriteLine(flag "|" Mods_Sha(target) "|" rel)
            done++
            if (Mod(done, 10) = 0)
                Status_Set("Copying mod files... " done " / " total, Round(done * 100 / total))
        }
    } finally {
        out.Close()
    }
    IniWrite(0, dir "_state.ini", "State", "Pending")
    Status_Set("Mods ready (" total " files)", 100)
    return total
}

; True when the mods need copying again: changes not applied yet, or a game
; patch replaced one of the mod's files.
Mods_NeedsApply(Game) {
    dir := Mods_Dir(Game)
    if !DirExist(dir)
        return false
    if (IniRead(dir "_state.ini", "State", "Pending", "0") = "1")
        return true
    man := dir "_installed.txt"
    if !FileExist(man)
        return false
    for line in StrSplit(FileRead(man, "UTF-8"), "`n", "`r") {
        p := StrSplit(line, "|", , 3)
        if (p.Length < 3)
            continue
        if !FileExist(Game p[3]) || Mods_Sha(Game p[3]) != p[2]
            return true
    }
    return false
}

Mods_BeforeLaunch() {
    try {
        g := Mods_Game()
        if Mods_NeedsApply(g)
            Mods_Apply(g)
    } catch as e {
        MsgBox("The mods could not be put in place:`n" e.Message, Title)
    }
}

Mods_ApplyNow(Game) {
    try {
        Mods_Apply(Game)
        if ProcessExist(CurrentTROSE)
            Status_Set("Mods applied. Restart ROSE to see the change.", 100)
    } catch as e {
        Status_Set("Mods could not be applied")
        MsgBox("The mods could not be put in place:`n" e.Message, Title)
    }
}

; Remove the old in-game theme switch left by earlier Steampunk versions.
Mods_OfferCleanup(Game) {
    static Asked := Map()
    old := Game "Data\ui\themes\rose\_themes"
    if !DirExist(old) || Asked.Has(Game)
        return
    Asked[Game] := true
    r := MsgBox("This game folder still has the old in-game theme switch (Data\ui\themes\rose\_themes).`n`nThe launcher's UI Theme and Mods list replace it. Remove the old switch now?", Title " - Mods", "YesNo")
    if (r = "Yes")
        try DirDelete old, 1
}

ModsRow_Refresh() {
    global ThemeDDL, ModsBtn, ThemeChoices
    if !IsSet(ThemeDDL)
        return
    try {
        list := Mods_Scan(Mods_Game())
        ThemeChoices := [""]
        names := ["Default (the game's own look)"]
        pick := 1
        on := 0
        for m in list {
            if m.Enabled
                on++
            if (m.Group = "UI Theme") {
                ThemeChoices.Push(m.Folder)
                names.Push(m.Name (m.Version != "" ? " v" m.Version : ""))
                if m.Enabled
                    pick := names.Length
            }
        }
        ThemeDDL.Delete()
        ThemeDDL.Add(names)
        ThemeDDL.Value := pick
        Btn_SetText(ModsBtn, on ? "Mods (" on " on)" : "Mods")
    }
}

ThemeDDL_Change(Ctrl, *) {
    global ThemeChoices
    g := Mods_Game()
    Mods_OfferCleanup(g)
    want := ThemeChoices[Ctrl.Value]
    list := Mods_Scan(g)
    changed := false
    for m in list {
        if (m.Group = "UI Theme") {
            on := (m.Folder = want)
            if (on != m.Enabled) {
                m.Enabled := on
                changed := true
            }
        }
    }
    if !changed
        return
    Mods_SaveEnabled(g, list)
    Mods_ApplyNow(g)
    ModsRow_Refresh()
    ModsUI_Fill()
    SetTimer(Launcher_Reskin, -100)
}

; --- Mods window -----------------------------------------------------------------
ModsUI_Show(*) {
    global ModsUI, ModsLV, ModsInfo, ModsDirty
    try ModsUI.Destroy()
    g := Mods_Game()
    dir := Mods_Dir(g)
    if !DirExist(dir)
        DirCreate dir
    Mods_OfferCleanup(g)
    ModsDirty := false
    ; Same look as the launcher: its panel colour, its glass buttons and text colours
    ModsUI := Gui(, Title " - Mods")
    ModsUI.BackColor := Skin_C("Panel")
    ModsUI.SetFont("s9", "Segoe UI")
    ModsUI.OnEvent("Close", ModsUI_Close)
    x := 10
    btns := []
    btns.Push(["Apply", ModsUI_Apply])
    btns.Push(["Open Mods Folder", (*) => Run('"' Mods_Dir() '"')])
    btns.Push(["Check for Updates", (*) => Mods_UpdateAll(false)])
    btns.Push(["Turn All Off", ModsUI_AllOff])
    btns.Push(["Make Update List", ModsUI_MakeManifest])
    btns.Push(["Close", ModsUI_Close])
    for b in btns {
        Btn_Add(ModsUI, x, 8, 110, 30, b[1], b[2])
        x += 116
    }
    ModsUI.SetFont("s9 bold c" Skin_C("Head"))
    ModsUI.Add("Text", "x10 y48 w686 Background" Skin_C("Panel"), "Client: " CurrentTROSEDisplay "    (" g ")")
    ModsUI.SetFont("s9 norm c" Skin_C("Text"))
    ModsLV := ModsUI.Add("ListView", "x10 y68 w686 h220 Checked -Multi Grid NoSortHdr Background" Skin_C("Strip") " c" Skin_C("Text"), ["Mod", "Version", "Type", "Author", "Updates"])
    ModsLV.OnEvent("ItemCheck", ModsLV_Check)
    ModsLV.OnEvent("ItemSelect", ModsLV_Select)
    ModsInfo := ModsUI.Add("Text", "x10 y296 w686 h48 Background" Skin_C("Panel"), "Tick a mod to turn it on, then press Apply. Mods of the same type (like UI Theme) can't be on together.")
    ModsUI.SetFont("s8 norm c" Skin_C("Dim"))
    ModsUI.Add("Text", "x10 y348 w686 Background" Skin_C("Panel"), "To add a mod, put its folder in " dir)
    ModsUI_Fill()
    ModsUI.Show("AutoSize")
}

ModsUI_Fill() {
    global ModsLV, ModsList, ModsBusy
    if !IsSet(ModsLV)
        return
    try {
        ModsBusy := true
        ModsList := Mods_Scan(Mods_Game())
        ModsLV.Delete()
        for m in ModsList
            ModsLV.Add(m.Enabled ? "Check" : "", m.Name, m.Version, m.Group = "" ? "Mod" : m.Group, m.Author, m.UpdateUrl != "" ? "Automatic" : "-")
        ModsLV.ModifyCol(1, 266)
        ModsLV.ModifyCol(2, 70)
        ModsLV.ModifyCol(3, 110)
        ModsLV.ModifyCol(4, 130)
        ModsLV.ModifyCol(5, 85)
        clash := Mods_Clashes(ModsList)
        if (clash != "")
            ModsInfo.Text := clash
    }
    ModsBusy := false
}

ModsLV_Check(LV, Item, Checked) {
    global ModsList, ModsBusy, ModsDirty
    if (ModsBusy || Item < 1 || Item > ModsList.Length)
        return
    m := ModsList[Item]
    m.Enabled := Checked ? 1 : 0
    ModsDirty := true
    if (Checked && m.Group != "") {
        ModsBusy := true
        for i, o in ModsList {
            if (i != Item && o.Group = m.Group && o.Enabled) {
                o.Enabled := 0
                LV.Modify(i, "-Check")
            }
        }
        ModsBusy := false
    }
}

ModsLV_Select(LV, Item, Selected) {
    global ModsList, ModsInfo
    if (!Selected || Item < 1 || Item > ModsList.Length)
        return
    m := ModsList[Item]
    ModsInfo.Text := m.Name (m.Version != "" ? " v" m.Version : "") (m.Author != "" ? " by " m.Author : "") "`n" (m.Description != "" ? m.Description : "(no description)") (m.Changes != "" ? "`nNew in this version: " StrReplace(m.Changes, "`n", " / ") : "")
}

ModsUI_Apply(*) {
    global ModsList, ModsDirty
    g := Mods_Game()
    Mods_SaveEnabled(g, ModsList)
    Mods_ApplyNow(g)
    ModsDirty := false
    ModsUI_Fill()
    ModsRow_Refresh()
    SetTimer(Launcher_Reskin, -100)
}

ModsUI_AllOff(*) {
    global ModsList, ModsLV, ModsBusy, ModsDirty
    ModsBusy := true
    for i, m in ModsList {
        m.Enabled := 0
        ModsLV.Modify(i, "-Check")
    }
    ModsBusy := false
    ModsDirty := true
}

ModsUI_Close(*) {
    global ModsUI, ModsDirty
    if ModsDirty {
        r := MsgBox("Apply your mod changes before closing?", Title " - Mods", "YesNoCancel")
        if (r = "Cancel")
            return true
        if (r = "Yes")
            ModsUI_Apply()
    }
    ModsDirty := false
    try ModsUI.Destroy()
    return true
}

; --- automatic updates ------------------------------------------------------------
; A mod with UpdateUrl= in its mod.ini points at a manifest.txt online (for
; example a raw GitHub link). The manifest lists every file of the mod folder
; with its SHA1; the files sit next to the manifest at the same paths.
;   version=1.1
;   base=https://...            (optional, defaults to the manifest's folder)
;   <sha1>|files/Data/ui/themes/rose/game/hud.html
Url_EncodePath(S) {
    out := ""
    buf := Buffer(StrPut(S, "UTF-8"))
    StrPut(S, buf, "UTF-8")
    Loop buf.Size - 1 {
        b := NumGet(buf, A_Index - 1, "UChar")
        if ((b >= 48 && b <= 57) || (b >= 65 && b <= 90) || (b >= 97 && b <= 122) || b = 45 || b = 46 || b = 95 || b = 126 || b = 47)
            out .= Chr(b)
        else
            out .= "%" Format("{:02X}", b)
    }
    return out
}

Mods_UpdateOne(M) {
    url := StrReplace(M.UpdateUrl, " ", "%20")
    text := Http_Get(url (InStr(url, "?") ? "&" : "?") "t=" A_Now A_MSec)
    if (text = "" || !InStr(text, "|"))
        return -1
    cache := M.Path "_manifest.last"
    if FileExist(cache) && FileRead(cache, "UTF-8") == text
        return 0
    base := RegExReplace(url, "\?.*$")
    base := SubStr(base, 1, InStr(base, "/", , -1))
    files := Map()
    version := ""
    for line in StrSplit(text, "`n", "`r") {
        line := Trim(line)
        if (line = "" || SubStr(line, 1, 1) = ";")
            continue
        if RegExMatch(line, "i)^version\s*=\s*(.*)$", &v) {
            version := v[1]
            continue
        }
        if RegExMatch(line, "i)^base\s*=\s*(.+)$", &v) {
            base := StrReplace(v[1], " ", "%20")
            if (SubStr(base, -1) != "/")
                base .= "/"
            continue
        }
        p := StrSplit(line, "|", , 2)
        if (p.Length = 2 && !InStr(p[2], "..") && !InStr(p[2], ":"))
            files[StrReplace(p[2], "/", "\")] := p[1]
    }
    if (files.Count = 0)
        return -1
    changed := 0
    for rel, sha in files {
        lp := M.Path rel
        if FileExist(lp) && Mods_Sha(lp) = sha
            continue
        tmp := lp ".rlmnew"
        Mods_EnsureDir(tmp)
        try {
            Download(base Url_EncodePath(StrReplace(rel, "\", "/")) "?t=" A_Now A_MSec, tmp)
        } catch {
            try FileDelete tmp
            return -1
        }
        if (Mods_Sha(tmp) != sha) {
            try FileDelete tmp
            return -1
        }
        FileMove tmp, lp, 1
        changed++
    }
    ; files the mod no longer has
    Loop Files M.Path "files\*", "FR" {
        rel := SubStr(A_LoopFileFullPath, StrLen(M.Path) + 1)
        if !files.Has(rel) {
            FileDelete A_LoopFileFullPath
            changed++
        }
    }
    try FileDelete cache
    FileAppend text, cache, "UTF-8-RAW"
    M.NewVersion := version
    return changed
}

; -----------------------------------------------------------------------------
;  Launcher self-update. "Launcher Files\update.ini" holds
;    [Update]
;    Url=https://raw.githubusercontent.com/<you>/<repo>/main/Launcher/manifest.txt
;  The manifest lists the launcher folder (exe, .ahk, Launcher Files\...) in
;  the same format as a mod's. A newer version= than this build is offered on
;  start; the running exe is renamed aside, replaced, and the launcher restarts.
; -----------------------------------------------------------------------------
Launcher_UpdateUrl() {
    return Trim(IniRead(Asset("update.ini"), "Update", "Url", ""))
}

; Only the launcher's own files - it may live inside the game folder.
Launcher_OwnFiles() {
    list := []
    for name in ["ROSE Mod Launcher.exe", "ROSE Mod Launcher.ahk"] {
        if FileExist(A_ScriptDir "\" name)
            list.Push(name)
    }
    Loop Files A_ScriptDir "\Launcher Files\*", "FR"
        list.Push(SubStr(A_LoopFileFullPath, StrLen(A_ScriptDir) + 2))
    return list
}

Launcher_CleanOld() {
    for pat in ["\*.rlmold", "\*.rlmnew", "\Launcher Files\*.rlmold", "\Launcher Files\*.rlmnew"] {
        Loop Files A_ScriptDir pat, (InStr(pat, "Launcher Files") ? "FR" : "F")
            try FileDelete A_LoopFileFullPath
    }
}

Launcher_ParseManifest(Text, Url) {
    man := {Version: "", BaseUrl: "", Files: Map(), Changes: ""}
    b := RegExReplace(Url, "\?.*$")
    man.BaseUrl := SubStr(b, 1, InStr(b, "/", , -1))
    for line in StrSplit(Text, "`n", "`r") {
        line := Trim(line)
        if (line = "" || SubStr(line, 1, 1) = ";")
            continue
        if RegExMatch(line, "i)^version\s*=\s*(.*)$", &v) {
            man.Version := Trim(v[1])
            continue
        }
        if RegExMatch(line, "i)^changes\s*=\s*(.*)$", &v) {
            man.Changes .= "- " Trim(v[1]) "`n"
            continue
        }
        if RegExMatch(line, "i)^base\s*=\s*(.+)$", &v) {
            man.BaseUrl := StrReplace(Trim(v[1]), " ", "%20")
            if (SubStr(man.BaseUrl, -1) != "/")
                man.BaseUrl .= "/"
            continue
        }
        p := StrSplit(line, "|", , 2)
        if (p.Length = 2 && !InStr(p[2], "..") && !InStr(p[2], ":"))
            man.Files[StrReplace(p[2], "/", "\")] := p[1]
    }
    return man
}

Launcher_SelfUpdate(Quiet) {
    url := StrReplace(Launcher_UpdateUrl(), " ", "%20")
    if (url = "") {
        if !Quiet
            MsgBox("No update link is set yet.`n`nPut the raw GitHub link of the launcher's manifest.txt in:`n" Asset("update.ini"), Title)
        return
    }
    Status_Set("Checking for a launcher update...")
    text := Http_Get(url (InStr(url, "?") ? "&" : "?") "t=" A_Now A_MSec)
    man := Launcher_ParseManifest(text, url)
    if (text = "" || man.Files.Count = 0 || man.Version = "") {
        Status_Set("Ready")
        if !Quiet
            MsgBox("Could not read the launcher's update list. Check the link in " Asset("update.ini"), Title)
        return
    }
    if (VerCompare(man.Version, Version) <= 0) {
        Status_Set("Ready")
        if !Quiet
            MsgBox("The launcher is up to date (v" Version ").", Title)
        return
    }
    r := MsgBox("ROSE Mod Launcher v" man.Version " is available (you have v" Version ")." (man.Changes != "" ? "`n`nWhat's new:`n" RTrim(man.Changes, "`n") : "") "`n`nUpdate now? The launcher will restart.", Title, "YesNo")
    if (r != "Yes") {
        Status_Set("Launcher update v" man.Version " skipped")
        return
    }
    staged := []
    n := 0
    for rel, sha in man.Files {
        n++
        lp := A_ScriptDir "\" rel
        if FileExist(lp) && Mods_Sha(lp) = sha
            continue
        Status_Set("Downloading launcher update... " n " / " man.Files.Count, Round(n * 100 / man.Files.Count))
        tmp := lp ".rlmnew"
        Mods_EnsureDir(tmp)
        ok := false
        try {
            Download(man.BaseUrl Url_EncodePath(StrReplace(rel, "\", "/")) "?t=" A_Now A_MSec, tmp)
            ok := (Mods_Sha(tmp) = sha)
        }
        if !ok {
            try FileDelete tmp
            for s in staged
                try FileDelete A_ScriptDir "\" s ".rlmnew"
            Status_Set("Launcher update failed")
            MsgBox("The update could not be downloaded (" rel "). Nothing was changed; try again later.", Title)
            return
        }
        staged.Push(rel)
    }
    ; Windows lets a running exe be renamed, so move the old files aside first.
    for rel in staged {
        lp := A_ScriptDir "\" rel
        try {
            if FileExist(lp)
                FileMove lp, lp ".rlmold", 1
            FileMove lp ".rlmnew", lp, 1
        } catch as e {
            MsgBox("Could not replace " rel ":`n" e.Message "`n`nIf the launcher is in Program Files, move it to another folder.", Title)
            return
        }
    }
    Status_Set("Updated to v" man.Version " - restarting...", 100)
    Reload
}

ModsUI_MakeLauncherManifest(*) {
    text := "; Update list for ROSE Mod Launcher. Upload this next to the launcher files.`n"
    text .= "version=" Version "`n"
    for rel in Launcher_OwnFiles() {
        if (RegExMatch(rel, "i)\\update\.ini$") || RegExMatch(rel, "i)\.(rlmold|rlmnew)$"))
            continue
        text .= Mods_Sha(A_ScriptDir "\" rel) "|" StrReplace(rel, "\", "/") "`n"
    }
    try FileDelete A_ScriptDir "\manifest.txt"
    FileAppend text, A_ScriptDir "\manifest.txt", "UTF-8-RAW"
    r := MsgBox("manifest.txt for launcher v" Version " was written in " A_ScriptDir "`n`nUpload the launcher folder (the exe, the .ahk, Launcher Files and manifest.txt) to your GitHub repo. Everyone whose update.ini points at that manifest.txt will be offered the update.`n`nOpen the folder now?", Title, "YesNo")
    if (r = "Yes")
        Run('"' A_ScriptDir '"')
}

Mods_UpdateAll(Quiet) {
    g := Mods_Game()
    list := Mods_Scan(g)
    report := []
    failed := []
    whatsnew := ""
    reapply := false
    for m in list {
        if (m.UpdateUrl = "")
            continue
        Status_Set("Checking " m.Name " for updates...")
        n := Mods_UpdateOne(m)
        if (n < 0) {
            failed.Push(m.Name)
        } else if (n > 0) {
            v := (m.HasOwnProp("NewVersion") && m.NewVersion != "") ? " to v" m.NewVersion : ""
            report.Push(m.Name " updated" v " (" n " file" (n = 1 ? "" : "s") ")")
            ch := StrReplace(IniRead(m.Path "mod.ini", "Mod", "Changes", ""), "\n", "`n")
            whatsnew .= m.Name v ":`n" (ch != "" ? ch : "(no notes)") "`n`n"
            if m.Enabled
                reapply := true
        }
    }
    if reapply {
        IniWrite(1, Mods_Dir(g) "_state.ini", "State", "Pending")
        Mods_ApplyNow(g)
    }
    msg := ""
    for r in report
        msg .= (msg = "" ? "" : ", ") r
    if (msg = "")
        msg := failed.Length ? "Ready (could not check " failed[1] " for updates)" : "Ready"
    Status_Set(msg)
    if (whatsnew != "")
        MsgBox("What's new`n`n" RTrim(whatsnew, "`n"), Title " - What's new", "T30")
    if !Quiet {
        MsgBox((report.Length ? msg : "All mods with automatic updates are up to date.") (failed.Length ? "`n`nCould not check: " failed.Length " mod(s). Check the UpdateUrl in their mod.ini." : ""), Title " - Mods")
    }
    ModsRow_Refresh()
    ModsUI_Fill()
}

; For mod makers: write manifest.txt for the selected mod, ready to upload.
ModsUI_MakeManifest(*) {
    global ModsLV, ModsList
    row := 0
    try row := ModsLV.GetNext(0)
    if !row {
        MsgBox("Pick the mod in the list first.", Title " - Mods")
        return
    }
    m := ModsList[row]
    text := "; Update list for " m.Name ". Upload this next to mod.ini and the files folder.`n"
    text .= "version=" m.Version "`n"
    Loop Files m.Path "*", "FR" {
        rel := SubStr(A_LoopFileFullPath, StrLen(m.Path) + 1)
        if (rel = "manifest.txt" || SubStr(A_LoopFileName, 1, 1) = "_" || SubStr(rel, -7) = ".rlmnew")
            continue
        text .= Mods_Sha(A_LoopFileFullPath) "|" StrReplace(rel, "\", "/") "`n"
    }
    try FileDelete m.Path "manifest.txt"
    FileAppend text, m.Path "manifest.txt", "UTF-8-RAW"
    r := MsgBox("manifest.txt was written in " m.Path "`n`nUpload the whole mod folder (mod.ini, manifest.txt and files) to your GitHub repo, and set UpdateUrl in mod.ini to the raw link of manifest.txt, for example:`nhttps://raw.githubusercontent.com/<you>/<repo>/main/" m.Folder "/manifest.txt`n`nOpen the folder now?", Title " - Mods", "YesNo")
    if (r = "Yes")
        Run('"' m.Path '"')
}

; -----------------------------------------------------------------------------
;  Game patching without the Rednim window: the official rose-updater.exe has
;  a --headless mode that prints its progress as JSON lines. The launcher runs
;  it hidden, writes its output to %AppData%\RLM\patch.log and reads it back.
;  Stages: start, fetching-metadata, updating-updater, checking-files,
;  downloading-updates, verifying-files, play.
; -----------------------------------------------------------------------------
Patch_AutoOn() {
    return IniRead(SettingPathCfg, "Launcher", "AutoPatch", "1") = "1"
}

Patch_Count(Name) {
    n := 0
    try {
        for p in ComObjGet("winmgmts:").ExecQuery("Select ProcessId from Win32_Process where Name='" Name "'")
            n++
    }
    return n
}

Patch_Run(Then := "") {
    global PatchBusy, PatchThen, PatchPid, PatchLog, PatchPos, PatchBuf, PatchStage, PatchError, PatchGames, PatchRetry
    if PatchBusy
        return
    g := Mods_Game()
    upd := g "rose-updater.exe"
    if !FileExist(upd) {
        Status_Set("Game updater (rose-updater.exe) not found in the game folder - skipping the update")
        if IsObject(Then)
            Then.Call()
        return
    }
    if !DirExist(CfgDataPath)
        DirCreate CfgDataPath
    PatchLog := CfgDataPath "patch.log"
    try FileDelete PatchLog
    PatchPos := 0, PatchBuf := "", PatchStage := "", PatchError := ""
    PatchThen := Then
    PatchGames := Patch_Count(CurrentTROSE)
    PatchBusy := true
    try {
        Run(A_ComSpec ' /c ""' upd '" --headless > "' PatchLog '" 2>&1"', g, "Hide", &pid)
        PatchPid := pid
    } catch as e {
        PatchBusy := false
        Status_Set("Could not run the game updater: " e.Message)
        return
    }
    Status_Set("Checking for game updates...", 0, true)
    SetTimer(Patch_Poll, 250)
}

Patch_Poll() {
    global PatchPid, PatchLog, PatchPos, PatchBuf, PatchStage
    try {
        f := FileOpen(PatchLog, "r", "UTF-8-RAW")
        if f {
            f.Pos := PatchPos
            PatchBuf .= f.Read()
            PatchPos := f.Pos
            f.Close()
        }
    }
    while (i := InStr(PatchBuf, "`n")) {
        line := Trim(SubStr(PatchBuf, 1, i - 1), " `r`t")
        PatchBuf := SubStr(PatchBuf, i + 1)
        if (line != "")
            Patch_Line(line)
    }
    ; keep reading while the updater (or the copy it restarts as) is running
    if ProcessExist(PatchPid) || ProcessExist("rose-updater.exe")
        return
    if (Trim(PatchBuf) != "")
        Patch_Line(Trim(PatchBuf, " `r`n`t"))
    PatchBuf := ""
    SetTimer(Patch_Poll, 0)
    Patch_Done()
}

Patch_Line(Line) {
    global PatchStage, PatchError
    static Names := Map("start", "Starting the game update...", "fetching-metadata", "Checking for game updates...", "updating-updater", "Updating the game updater...", "checking-files", "Checking game files...", "downloading-updates", "Downloading game updates...", "verifying-files", "Verifying game files...", "play", "The game is up to date", "done", "The game is up to date")
    ; Only the JSON lines matter, e.g.
    ;   {"event":"progress","stage":"downloading-updates","current":12,"max":80}
    ;   {"event":"done"}
    if (SubStr(Line, 1, 1) != "{")
        return
    ev := RegExMatch(Line, 'i)"event"\s*:\s*"([a-z_-]+)"', &m) ? StrLower(m[1]) : ""
    if (ev = "done" || ev = "finished" || ev = "complete" || ev = "completed") {
        PatchStage := "done"
        Status_Set(Names["done"], 100, true)
        return
    }
    if (ev = "error" || ev = "failed" || ev = "failure") {
        if RegExMatch(Line, 'i)"(?:message|error|msg|reason)"\s*:\s*"([^"]+)"', &m)
            PatchError := m[1]
        else
            PatchError := "the updater reported an error"
        return
    }
    if RegExMatch(Line, 'i)"stage"\s*:\s*"([a-z_-]+)"', &m) && Names.Has(StrLower(m[1]))
        PatchStage := StrLower(m[1])
    pct := -1
    if RegExMatch(Line, 'i)"current"\s*:\s*(\d+)', &c) && RegExMatch(Line, 'i)"(?:max|total)"\s*:\s*(\d+)', &t) && Number(t[1]) > 0
        pct := Min(100, Number(c[1]) * 100 / Number(t[1]))
    text := (PatchStage != "") ? Names[PatchStage] : "Updating the game..."
    if (pct >= 0 && PatchStage != "play")
        text .= " " Round(pct) "%"
    Status_Set(text, pct >= 0 ? Round(pct) : -1, true)
    ; The game is ready: stop the updater before it opens the game itself.
    if (PatchStage = "play")
        try ProcessClose("rose-updater.exe")
}

Patch_Done() {
    global PatchBusy, PatchThen, PatchStage, PatchError, PatchGames, PatchRetry
    ; The updater restarts itself after updating itself; run it once more.
    if (PatchStage = "updating-updater" && PatchRetry < 1) {
        PatchRetry++
        PatchBusy := false
        Patch_Run(PatchThen)
        return
    }
    PatchRetry := 0
    PatchBusy := false
    then := PatchThen
    PatchThen := ""
    ok := (PatchError = "") && (PatchStage = "done" || PatchStage = "play")
    if ok {
        Status_Set("The game is up to date", 100)
    } else {
        Status_Set("Game update failed" (PatchError != "" ? ": " PatchError : "") " - see %AppData%\RLM\patch.log")
        r := MsgBox("The game update did not finish" (PatchError != "" ? ":`n" PatchError : ".") "`n`nOpen the official updater instead?", Title, "YesNo")
        if (r = "Yes")
            try LaunchPatcher()
        return
    }
    Mods_BeforeLaunch()
    if (Patch_Count(CurrentTROSE) > PatchGames) {
        Status_Set("The updater has already opened the game", 100)
        return
    }
    if IsObject(then)
        then.Call()
}

; -----------------------------------------------------------------------------
;  One auto-login button per account: drop repeated emails from data.cfg
;  (imports used to add an account again even when it was already there).
;  The first copy is kept, so its name, password and position stay.
; -----------------------------------------------------------------------------
Accounts_Dedupe() {
    if !FileExist(DataPathCfg)
        return
    seen := Map()
    keep := ""
    dropped := 0
    Loop Read DataPathCfg {
        line := A_LoopReadLine
        if (Trim(line) = "")
            continue
        parts := StrSplit(line, '"|"')
        if (parts.Length < 2) {
            keep .= line "`n"
            continue
        }
        email := StrLower(Trim(StrSplit(parts[2], '","')[1]))
        if seen.Has(email) {
            dropped++
            continue
        }
        seen[email] := true
        keep .= line "`n"
    }
    if (dropped = 0)
        return
    Accounts_Backup()
    try FileCopy DataPathCfg, DataPathCfg ".before-dedupe", 1
    FileDelete DataPathCfg
    FileAppend keep, DataPathCfg
}

; -----------------------------------------------------------------------------
;  Recover Accounts: read an older copy of data.cfg (a Previous Versions copy,
;  a file brought back with a recovery tool, data.cfg.before-dedupe, ...) and
;  add back the accounts that are missing now. Passwords in data.cfg are tied
;  to this Windows user, so only copies made on this PC can be read.
; -----------------------------------------------------------------------------
Recover_Candidates() {
    list := Accounts_Backups()
    seen := Map()
    dirs := [CfgDataPath, A_Desktop "\", A_MyDocuments "\", EnvGet("USERPROFILE") "\Downloads\"]
    for d in dirs {
        if !DirExist(d)
            continue
        Loop Files d "*", "F" {
            n := A_LoopFileName
            if (A_LoopFileFullPath = DataPathCfg)
                continue
            if !(InStr(n, "data") && (InStr(n, ".cfg") || InStr(n, "cfgnew")))
                continue
            if seen.Has(A_LoopFileFullPath)
                continue
            seen[A_LoopFileFullPath] := true
            list.Push(A_LoopFileFullPath)
        }
    }
    return list
}

Recover_Show(*) {
    global RecUI, RecDDL, RecLV, RecFiles, RecRows
    try RecUI.Destroy()
    RecFiles := Recover_Candidates()
    RecRows := []
    RecUI := Gui(, Title " - Recover Accounts")
    RecUI.SetFont("s9", "Segoe UI")
    RecUI.Add("Text", "x10 y10 w620", "Pick an older copy of your accounts file (data.cfg). Accounts in it that are missing now can be added back.`nCopies found on this PC are in the list; use Choose File... for one you restored yourself.")
    RecDDL := RecUI.Add("DropDownList", "x10 y50 w500", RecFiles.Length ? RecFiles : ["(no older copies found - use Choose File...)"])
    RecDDL.OnEvent("Change", (*) => (RecFiles.Length ? Recover_Load(RecFiles[RecDDL.Value]) : 0))
    RecUI.Add("Button", "x515 y49 w115 h26", "Choose File...").OnEvent("Click", Recover_Pick)
    RecLV := RecUI.Add("ListView", "x10 y84 w620 h200 Checked -Multi Grid NoSortHdr", ["Name", "Email", "Status"])
    RecUI.Add("Button", "x10 y292 w150 h28", "Add Back Ticked").OnEvent("Click", Recover_Add)
    RecUI.Add("Button", "x165 y292 w150 h28", "Show Password").OnEvent("Click", Recover_ShowPw)
    RecUI.Add("Button", "x550 y292 w80 h28", "Close").OnEvent("Click", (*) => RecUI.Destroy())
    If DarkMode = 2
        DarkMode_Setter(RecUI)
    RecUI.Show("AutoSize")
    if RecFiles.Length {
        RecDDL.Value := 1
        Recover_Load(RecFiles[1])
    }
}

Recover_Pick(*) {
    global RecDDL, RecFiles
    f := FileSelect(1, CfgDataPath, "Pick an older copy of data.cfg", "Accounts file (*.cfg; *.cfg*; *.*)")
    if (f = "")
        return
    RecFiles.InsertAt(1, f)
    RecDDL.Delete()
    RecDDL.Add(RecFiles)
    RecDDL.Value := 1
    Recover_Load(f)
}

Recover_Load(File) {
    global RecLV, RecRows
    RecRows := []
    RecLV.Delete()
    try {
        Loop Read File {
            parts := StrSplit(A_LoopReadLine, '"|"')
            if (parts.Length < 2)
                continue
            ep := StrSplit(parts[2], '","')
            if (ep.Length < 2)
                continue
            email := Trim(ep[1])
            readable := true
            try {
                pw := DecryptPassword(ep[2])
                if (pw = "")
                    readable := false
            } catch {
                readable := false
            }
            pw := ""
            here := false
            for e in LoginEmail {
                if (e = email)
                    here := true
            }
            status := !readable ? "Can't be read on this PC" : (here ? "Already in your list" : "Missing - can be added back")
            RecRows.Push({Name: parts[1], Email: email, Enc: ep[2], Here: here, Readable: readable})
            RecLV.Add((!here && readable) ? "Check" : "", parts[1], email, status)
        }
    } catch as e {
        MsgBox("That file could not be read:`n" e.Message, Title)
    }
    RecLV.ModifyCol(1, 170)
    RecLV.ModifyCol(2, 250)
    RecLV.ModifyCol(3, 180)
    if (RecRows.Length = 0)
        MsgBox("No accounts were found in that file.", Title)
}

Recover_Add(*) {
    global RecLV, RecRows, Main
    added := 0
    row := 0
    Accounts_Backup()
    while (row := RecLV.GetNext(row, "Checked")) {
        r := RecRows[row]
        if (r.Here || !r.Readable)
            continue
        WriteCfg(r.Name '"|"' r.Email '","' r.Enc, DataPathCfg)
        r.Here := true
        added++
    }
    if !added {
        MsgBox("Tick the accounts marked 'Missing' first.", Title)
        return
    }
    Main.Destroy()
    ReadCfg()
    BuildUI()
    MsgBox(added " account" (added = 1 ? " was" : "s were") " added back. They are on the login strip again.", Title)
    try RecUI.Destroy()
}

Recover_ShowPw(*) {
    global RecLV, RecRows
    row := RecLV.GetNext(0)
    if !row {
        MsgBox("Click an account in the list first.", Title)
        return
    }
    r := RecRows[row]
    pw := ""
    try pw := DecryptPassword(r.Enc)
    if (pw = "") {
        MsgBox("This password can't be read on this PC (it was saved by another Windows user or computer).", Title)
        return
    }
    if (MsgBox("Account: " r.Email "`nPassword: " pw "`n`nCopy the password to the clipboard?", Title " - " r.Name, "YesNo") = "Yes") {
        A_Clipboard := pw
        SetTimer(() => (A_Clipboard := ""), -60000)
    }
    pw := ""
}

; -----------------------------------------------------------------------------
;  Account backups: a copy of data.cfg goes to %AppData%\RLM\backups\ before
;  every change (new, edit, delete, move, import, recover). The newest 30 are
;  kept, and Settings > Recover lists them.
; -----------------------------------------------------------------------------
Accounts_BackupDir() {
    d := CfgDataPath "backups\"
    if !DirExist(d)
        DirCreate d
    return d
}

Accounts_Backups() {
    names := ""
    Loop Files Accounts_BackupDir() "accounts-*.cfg"
        names .= A_LoopFileName "`n"
    names := Sort(RTrim(names, "`n"), "R")
    list := []
    for n in StrSplit(names, "`n") {
        if (n != "")
            list.Push(Accounts_BackupDir() n)
    }
    return list
}

Accounts_Backup() {
    if !FileExist(DataPathCfg)
        return
    try {
        now := FileRead(DataPathCfg)
        list := Accounts_Backups()
        if (list.Length && FileRead(list[1]) == now)
            return
        FileCopy DataPathCfg, Accounts_BackupDir() "accounts-" FormatTime(, "yyyyMMdd-HHmmss") ".cfg", 1
        list := Accounts_Backups()
        while (list.Length > 30)
            FileDelete list.Pop()
    }
}

; -----------------------------------------------------------------------------
;  Settings backup / restore: one zip with the game's own settings files
;  (rose.toml and any other .toml next to it, the Steampunk sp_*.txt files),
;  which mods are on, and the launcher's settings, clients and accounts.
;  Accounts only work again on this PC under the same Windows user.
; -----------------------------------------------------------------------------
Backup_Stage() {
    st := A_Temp "\RML-settings-backup\"
    try DirDelete st, 1
    DirCreate st "game"
    DirCreate st "launcher"
    g := Mods_Game()
    n := 0
    for pat in ["*.toml", "sp_*.txt", "sp_*.cache"] {
        Loop Files g pat, "F" {
            FileCopy A_LoopFileFullPath, st "game\" A_LoopFileName, 1
            n++
        }
    }
    if FileExist(Mods_Dir(g) "_state.ini") {
        DirCreate st "game\Launcher Mods"
        FileCopy Mods_Dir(g) "_state.ini", st "game\Launcher Mods\_state.ini", 1
        n++
    }
    for f in [SettingPathCfg, TROSEPathCfg, DataPathCfg] {
        if FileExist(f) {
            SplitPath f, &name
            FileCopy f, st "launcher\" name, 1
            n++
        }
    }
    FileAppend "ROSE Mod Launcher settings backup`r`nMade " FormatTime(, "yyyy-MM-dd HH:mm") " from " g "`r`n`r`ngame\     goes into the game folder`r`nlauncher\ goes into %AppData%\RLM`r`n", st "README.txt"
    return [st, n]
}

Backup_Make(*) {
    dir := A_MyDocuments "\ROSE Mod Launcher Backups"
    if !DirExist(dir)
        DirCreate dir
    def := dir "\ROSE settings " FormatTime(, "yyyy-MM-dd HHmm") ".zip"
    out := FileSelect("S16", def, "Save your settings backup", "Zip files (*.zip)")
    if (out = "")
        return
    if !RegExMatch(out, "i)\.zip$")
        out .= ".zip"
    try {
        r := Backup_Stage()
        try FileDelete out
        RunWait('powershell -NoProfile -ExecutionPolicy Bypass -Command "Compress-Archive -Path ' "'" r[1] "*' -DestinationPath '" out "' -Force" '"', , "Hide")
        if !FileExist(out)
            throw Error("the zip was not made")
        MsgBox("Backed up " r[2] " settings files to:`n" out, Title)
    } catch as e {
        MsgBox("The backup could not be made: " e.Message, Title)
    }
}

Backup_Restore(*) {
    f := FileSelect(1, A_MyDocuments "\ROSE Mod Launcher Backups", "Pick a settings backup to restore", "Zip files (*.zip)")
    if (f = "")
        return
    if ProcessExist(CurrentTROSE) {
        MsgBox("Close ROSE first - it saves its settings when it closes and would undo the restore.", Title)
        return
    }
    if (MsgBox("Restore the settings in this backup?`n" f "`n`nYour current settings files are replaced (your current accounts are backed up first).", Title, "YesNo Icon?") != "Yes")
        return
    st := A_Temp "\RML-settings-restore\"
    try DirDelete st, 1
    try {
        RunWait('powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Path ' "'" f "' -DestinationPath '" st "' -Force" '"', , "Hide")
        if !DirExist(st "game") && !DirExist(st "launcher")
            throw Error("that zip is not a ROSE Mod Launcher settings backup")
        Accounts_Backup()
        n := 0
        g := Mods_Game()
        Loop Files st "game\*", "FR" {
            rel := SubStr(A_LoopFileFullPath, StrLen(st "game\") + 1)
            Mods_EnsureDir(g rel)
            FileCopy A_LoopFileFullPath, g rel, 1
            n++
        }
        Loop Files st "launcher\*", "F" {
            FileCopy A_LoopFileFullPath, CfgDataPath A_LoopFileName, 1
            n++
        }
        try DirDelete st, 1
        MsgBox("Restored " n " settings files. The launcher will now restart.", Title)
        Reload
    } catch as e {
        MsgBox("The restore did not finish: " e.Message, Title)
    }
}

; -----------------------------------------------------------------------------
;  Server status light next to "Client": a ping, then a quick connection to
;  the classic ROSE login port. No answer to either shows "no reply" - the
;  server may still be up and just ignore these checks.
; -----------------------------------------------------------------------------
Server_TcpOk(Host, Port, TimeoutMs := 1500) {
    static Started := false
    if !Started {
        wsa := Buffer(408, 0)
        if (DllCall("ws2_32\WSAStartup", "UShort", 0x0202, "Ptr", wsa) != 0)
            return false
        Started := true
    }
    hints := Buffer(48, 0)
    NumPut("Int", 2, hints, 4)
    NumPut("Int", 1, hints, 8)
    NumPut("Int", 6, hints, 12)
    res := 0
    if (DllCall("ws2_32\GetAddrInfoW", "Str", Host, "Str", String(Port), "Ptr", hints, "Ptr*", &res) != 0)
        return false
    ok := false
    sock := DllCall("ws2_32\socket", "Int", 2, "Int", 1, "Int", 6, "Ptr")
    if (sock != -1) {
        mode := 1
        DllCall("ws2_32\ioctlsocket", "Ptr", sock, "Int", 0x8004667E, "UInt*", &mode)
        DllCall("ws2_32\connect", "Ptr", sock, "Ptr", NumGet(res, 32, "Ptr"), "Int", NumGet(res, 16, "UPtr"))
        wr := Buffer(520, 0)
        ex := Buffer(520, 0)
        NumPut("UInt", 1, wr, 0)
        NumPut("Ptr", sock, wr, 8)
        NumPut("UInt", 1, ex, 0)
        NumPut("Ptr", sock, ex, 8)
        tv := Buffer(8, 0)
        NumPut("Int", TimeoutMs // 1000, tv, 0)
        NumPut("Int", Mod(TimeoutMs, 1000) * 1000, tv, 4)
        n := DllCall("ws2_32\select", "Int", 0, "Ptr", 0, "Ptr", wr, "Ptr", ex, "Ptr", tv)
        if (n > 0 && NumGet(wr, 0, "UInt") = 1)
            ok := true
        DllCall("ws2_32\closesocket", "Ptr", sock)
    }
    DllCall("ws2_32\FreeAddrInfoW", "Ptr", res)
    return ok
}

Server_Check() {
    global ServerText, Main
    if !IsSet(ServerText)
        return
    try {
        if (WinGetMinMax(Main.Hwnd) = -1)
            return
    }
    host := "connect.roseonlinegame.com"
    ms := -1
    try {
        for p in ComObjGet("winmgmts:").ExecQuery("Select StatusCode, ResponseTime From Win32_PingStatus Where Address='" host "' AND Timeout=1500") {
            if (p.StatusCode = 0)
                ms := p.ResponseTime
        }
    }
    up := (ms >= 0)
    if !up {
        try up := Server_TcpOk(host, 29000)
    }
    try {
        if up {
            ServerText.Text := Chr(0x25CF) " Server online" (ms >= 0 ? " " ms " ms" : "")
            ServerText.SetFont("c" Skin_C("Online"))
        } else {
            ServerText.Text := Chr(0x25CF) " Server: no reply"
            ServerText.SetFont("c" Skin_C("NoReply"))
        }
    }
}

; -----------------------------------------------------------------------------
;  Mod clashes: on-mods that change the same file. The higher priority wins.
; -----------------------------------------------------------------------------
Mods_Clashes(List) {
    owner := Map()
    count := Map()
    winner := Map()
    for m in List {
        if !m.Enabled
            continue
        src := m.Path "files\"
        Loop Files src "*", "FR" {
            rel := SubStr(A_LoopFileFullPath, StrLen(src) + 1)
            if owner.Has(rel) && owner[rel] != m.Name {
                k := owner[rel] " and " m.Name
                count[k] := (count.Has(k) ? count[k] : 0) + 1
                winner[k] := m.Name
            }
            owner[rel] := m.Name
        }
    }
    text := ""
    for k, v in count
        text .= "Heads-up: " k " both change " v " file" (v = 1 ? "" : "s") " - " winner[k] " wins (higher priority).`n"
    return RTrim(text, "`n")
}

; -----------------------------------------------------------------------------
;  Launcher skins: a UI Theme mod can carry a "launcher" folder with its own
;  versions of the window art and a skin.ini of colours. While that theme is
;  on (and Settings > "Match the launcher to the UI theme" is ticked), the
;  launcher uses them; anything missing falls back to Launcher Files.
; -----------------------------------------------------------------------------
Skin_Defaults() {
    return Map("Face", "EAEEF6", "Title", "1E3C78", "Text", "EBF2FF", "Head", "FFFFFF", "Arrow", "B4D2FA", "Hot", "FFFF90", "Caption", "FFFF96", "Panel", "14305C", "Strip", "122A54", "Link", "96C8FF", "Dim", "96B4DC", "Status", "34405A", "Bar", "46AAF0", "BarBg", "FAFCFF", "Online", "7CD870", "NoReply", "E8B850", "BtnText", "FFFFFF")
}

Skin_Resolve() {
    global SkinDir, SkinColors
    SkinDir := ""
    SkinColors := Skin_Defaults()
    if (IniRead(SettingPathCfg, "Launcher", "MatchSkin", "1") != "1")
        return
    try {
        for m in Mods_Scan(Mods_Game()) {
            if (m.Enabled && m.Group = "UI Theme" && DirExist(m.Path "launcher")) {
                SkinDir := m.Path "launcher\"
                break
            }
        }
    }
    if (SkinDir != "" && FileExist(SkinDir "skin.ini")) {
        for k, v in Skin_Defaults() {
            c := Trim(IniRead(SkinDir "skin.ini", "Colors", k, ""))
            if RegExMatch(c, "i)^[0-9a-f]{6}$")
                SkinColors[k] := c
        }
    }
}

Skin_C(Key) {
    global SkinColors
    if !IsSet(SkinColors)
        SkinColors := Skin_Defaults()
    return SkinColors.Has(Key) ? SkinColors[Key] : "FFFFFF"
}

Launcher_Reskin() {
    global Main, SkinDir
    old := IsSet(SkinDir) ? SkinDir : ""
    Skin_Resolve()
    if (SkinDir != old) {
        try Main.Destroy()
        BuildUI()
        SetTimer(() => Server_Check(), -1500)
    }
}

; -----------------------------------------------------------------------------
;  Repair: put the game's own files back under every mod, let the official
;  updater check and fix the game, then lay the mods on again fresh.
; -----------------------------------------------------------------------------
Repair_Click(*) {
    global PatchBusy, CurrentTROSE
    if PatchBusy {
        Status_Set("Wait for the game update to finish first")
        return
    }
    if (IsSet(CurrentTROSE) && CurrentTROSE != "" && ProcessExist(CurrentTROSE)) {
        MsgBox("Close ROSE first, then press Repair again.", Title " - Repair", "Icon!")
        return
    }
    r := MsgBox("Repair the game?`n`n"
        . "1. Every mod's changes are taken out, so the game's own files are back.`n"
        . "2. The official updater checks the game and downloads anything missing or out of date.`n"
        . "3. Your mods that are on are put back, freshly copied from their folders.`n`n"
        . "Your accounts, settings and keybinds are not touched.", Title " - Repair", "OKCancel Iconi")
    if (r != "OK")
        return
    g := Mods_Game()
    try {
        Mods_Restore(g)
    } catch as e {
        MsgBox("The game's own files could not all be put back:`n" e.Message "`n`nRepair will still run the updater.", Title " - Repair", "Icon!")
    }
    Status_Set("Repair: mods taken out, now checking the game...", 0, true)
    Patch_Run(() => Repair_Done())
}

Repair_Done() {
    ModsRow_Refresh()
    Status_Set("Repair finished - the game is checked and your mods are back on", 100)
}
