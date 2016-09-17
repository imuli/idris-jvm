{-# LANGUAGE OverloadedStrings #-}
module IdrisJvm.Assembler where

import           Data.Aeson
import           Data.List  (intercalate)

data Asm = Aaload
         | Aastore
         | Aconstnull
         | Aload Int
         | Anewarray Descriptor
         | Astore Int
         | Areturn
         | Checkcast Descriptor
         | ClassCodeStart Int Access ClassName Signature ClassName [ClassName]
         | ClassCodeEnd String
         | CreateClass ClassOpts
         | CreateLabel String
         | CreateMethod [Access] MethodName Descriptor (Maybe Signature) (Maybe [Exception])
         | Dup
         | Field FieldInsType ClassName FieldName Descriptor
         | Frame FrameType Int [Signature] Int [Signature]
         | Goto Label
         | I2c
         | I2l
         | Iadd
         | Iconst Int
         | Ifeq Label
         | Ificmpge Label
         | Ificmpgt Label
         | Ificmple Label
         | Ificmplt Label
         | Iload Int
         | Imul
         | InvokeMethod InvocType ClassName MethodName Descriptor Bool
         | InvokeDynamic MethodName Descriptor Handle [BsmArg]
         | Istore Int
         | Isub
         | LabelStart Label
         | Ldc Constant
         | LookupSwitch Label [Label] [Int]
         | MaxStackAndLocal Int Int
         | MethodCodeStart
         | MethodCodeEnd
         | New ClassName
         | Pop
         | Return
         | SourceInfo SourceFileName

instance ToJSON Asm where
  toJSON Aaload = object [ "type" .= String "Aaload" ]

  toJSON Aastore = object [ "type" .= String "Aastore" ]

  toJSON Aconstnull = object [ "type" .= String "Aconstnull" ]

  toJSON (Aload index)
    = object [ "type" .= String "Aload"
             , "index" .= toJSON index ]

  toJSON (Anewarray desc)
    = object [ "type" .= String "Anewarray"
             , "desc" .= toJSON desc ]

  toJSON (Astore index)
    = object [ "type" .= String "Astore"
             , "index" .= toJSON index ]

  toJSON Areturn = object [ "type" .= String "Areturn" ]

  toJSON (Checkcast desc)
    = object [ "type" .= String "Checkcast"
             , "desc" .= toJSON desc ]

  toJSON (ClassCodeStart version acc cname sig super intf)
    = object [ "type" .= String "ClassCodeStart"
             , "version" .= toJSON version
             , "acc" .= toJSON acc
             , "name" .= toJSON cname
             , "sig" .= if sig == "null" then Null else toJSON sig
             , "parent" .= toJSON super
             , "interfaces" .= toJSON intf]

  toJSON (ClassCodeEnd out)
    = object [ "type" .= String "ClassCodeEnd"
             , "out" .= toJSON out ]

  toJSON (CreateClass flags)
    = object [ "type" .= String "CreateClass"
             , "flags" .= toJSON flags ]

  toJSON (CreateLabel label)
    = object [ "type" .= String "CreateLabel"
             , "name" .= toJSON label ]

  toJSON (CreateMethod accs mname desc sig excs)
    = object [ "type" .= String "CreateMethod"
             , "acc" .= toJSON (sum $ accessNum <$> accs)
             , "name" .= toJSON mname
             , "desc" .= toJSON desc
             , "sig" .= maybe Null toJSON sig
             , "excs" .= toJSON excs ]

  toJSON Dup = object [ "type" .= String "Dup" ]

  toJSON (Field ftype cname fname desc)
    = object [ "type" .= String "Field"
             , "ftype" .= toJSON ftype
             , "cname" .= toJSON cname
             , "fname" .= toJSON fname
             , "desc" .= toJSON desc ]

  toJSON (Frame frameType nlocal local nstack stack)
    = object [ "type" .= String "Frame"
             , "ftype" .= toJSON frameType
             , "nlocal" .= toJSON nlocal
             , "local" .= toJSON local
             , "nstack" .= toJSON nstack
             , "stack" .= toJSON stack ]

  toJSON (Goto label)
    = object [ "type" .= String "Goto"
             , "label" .= toJSON label ]

  toJSON I2c = object [ "type" .= String "I2c" ]

  toJSON I2l = object [ "type" .= String "I2l" ]

  toJSON Iadd = object [ "type" .= String "Iadd" ]

  toJSON (Iconst n)
    = object [ "type" .= String "Iconst"
             , "n" .= toJSON n ]

  toJSON (Ifeq label)
    = object [ "type" .= String "Ifeq"
             , "label" .= toJSON label ]

  toJSON (Ificmpge label)
    = object [ "type" .= String "Ificmpge"
             , "label" .= toJSON label ]

  toJSON (Ificmpgt label)
    = object [ "type" .= String "Ificmpgt"
             , "label" .= toJSON label ]

  toJSON (Ificmple label)
    = object [ "type" .= String "Ificmple"
             , "label" .= toJSON label ]

  toJSON (Ificmplt label)
    = object [ "type" .= String "Ificmplt"
             , "label" .= toJSON label ]

  toJSON (Iload n)
    = object [ "type" .= String "Iload"
             , "n" .= toJSON n ]

  toJSON Imul = object [ "type" .= String "Imul" ]

  toJSON (InvokeMethod invType cname mname desc isIntf)
    = object [ "type" .= String "InvokeMethod"
             , "invType" .= toJSON invType
             , "cname" .= toJSON cname
             , "mname" .= toJSON mname
             , "desc" .= toJSON desc
             , "isIntf" .= toJSON isIntf ]

  toJSON (InvokeDynamic name desc handle args)
    = object [ "type" .= String "InvokeDynamic"
             , "name" .= toJSON name
             , "desc" .= toJSON desc
             , "handle" .= toJSON handle
             , "args" .= toJSON args ]

  toJSON (Istore n)
    = object [ "type" .= String "Istore"
             , "n" .= toJSON n ]

  toJSON Isub = object [ "type" .= String "Isub" ]

  toJSON (LabelStart label)
    = object [ "type" .= String "LabelStart"
             , "label" .= toJSON label ]

  toJSON (Ldc c)
    = toJSON c

  toJSON (LookupSwitch dlabel clabels vals)
    = object [ "type" .= String "LookupSwitch"
             , "dlabel" .= toJSON dlabel
             , "clabels" .= toJSON clabels
             , "vals" .= toJSON vals ]

  toJSON (MaxStackAndLocal nstack nlocal)
    = object [ "type" .= String "MaxStackAndLocal"
             , "nstack" .= toJSON nstack
             , "nlocal" .= toJSON nlocal ]

  toJSON MethodCodeStart = object [ "type" .= String "MethodCodeStart" ]

  toJSON MethodCodeEnd = object [ "type" .= String "MethodCodeEnd" ]

  toJSON (New name)
    = object [ "type" .= String "New"
             , "name" .= toJSON name ]

  toJSON Pop = object [ "type" .= String "Pop" ]

  toJSON Return = object [ "type" .= String "Return" ]

  toJSON (SourceInfo name)
    = object [ "type" .= String "SourceInfo"
             , "name" .= toJSON name ]

data BsmArg = BsmArgGetType Descriptor | BsmArgHandle Handle

instance ToJSON BsmArg where
  toJSON (BsmArgGetType desc) = object ["type" .= String "BsmArgGetType"
                                    , "desc" .= toJSON desc ]
  toJSON (BsmArgHandle h) = object ["type" .= String "BsmArgHandle"
                                    , "handle" .= toJSON h ]

data Constant = IntegerConst Int | StringConst String

instance ToJSON Constant where
  toJSON (IntegerConst n)
    = object [ "type" .= String "Ldc"
             , "constType" .= String "IntegerConst"
             , "val" .= toJSON n ]
  toJSON (StringConst s)
    = object [ "type" .= String "Ldc"
             , "constType" .= String "StringConst"
             , "val" .= toJSON s ]

class Asmable a where
  asm :: a -> String

data ReferenceTypeDescriptor = ClassDesc ClassName
                             | InterfaceDesc ClassName
                               deriving (Eq, Show)

instance Asmable ReferenceTypeDescriptor where
  asm (ClassDesc c) = "L" ++ c ++ ";"
  asm (InterfaceDesc c) = "L" ++ c ++ ";"

refTyClassName :: ReferenceTypeDescriptor -> ClassName
refTyClassName (ClassDesc c) = c
refTyClassName (InterfaceDesc c) = c

data FieldTypeDescriptor = FieldTyDescByte
                         | FieldTyDescChar
                         | FieldTyDescShort
                         | FieldTyDescBoolean
                         | FieldTyDescArray
                         | FieldTyDescDouble
                         | FieldTyDescFloat
                         | FieldTyDescInt
                         | FieldTyDescLong
                         | FieldTyDescReference ReferenceTypeDescriptor
                           deriving (Eq, Show)

instance Asmable FieldTypeDescriptor where
  asm FieldTyDescByte = "B"
  asm FieldTyDescChar = "C"
  asm FieldTyDescShort = "S"
  asm FieldTyDescBoolean = "Z"
  asm FieldTyDescArray = "["
  asm FieldTyDescDouble = "D"
  asm FieldTyDescFloat = "F"
  asm FieldTyDescInt = "I"
  asm FieldTyDescLong = "J"
  asm (FieldTyDescReference f) = asm f

data TypeDescriptor = FieldDescriptor FieldTypeDescriptor | VoidDescriptor

instance Asmable TypeDescriptor where
  asm (FieldDescriptor t) = asm t
  asm VoidDescriptor = "V"

data MethodDescriptor = MethodDescriptor [FieldTypeDescriptor] TypeDescriptor

instance Asmable MethodDescriptor where
  asm (MethodDescriptor args returns)
    = within "(" as ")" ++ r
      where as = concat $ asm <$> args
            r = asm returns

type ReferenceName = String

data ReferenceType = RefTyClass | RefTyInterface

type Label = String
type Exception = String
type ClassName = String
type FieldName = String
type MethodName = String
type Descriptor = String
type Signature = String
type SourceFileName = String
type Arg = String

data ClassOpts = ComputeMaxs | ComputeFrames

instance ToJSON ClassOpts where
  toJSON ComputeMaxs = toJSON (1 :: Int)
  toJSON ComputeFrames = toJSON (2 :: Int)

data InvocType = InvokeInterface | InvokeSpecial | InvokeStatic | InvokeVirtual
invocTypeNum :: InvocType -> Int
invocTypeNum InvokeInterface = 185
invocTypeNum InvokeSpecial = 183
invocTypeNum InvokeStatic = 184
invocTypeNum InvokeVirtual = 182

instance ToJSON InvocType where
  toJSON = toJSON . invocTypeNum


data FieldInsType = FGetStatic | FPutStatic | FGetField | FPutField
fieldInsTypeNum :: FieldInsType -> Int
fieldInsTypeNum FGetStatic = 178
fieldInsTypeNum FPutStatic = 179
fieldInsTypeNum FGetField = 180
fieldInsTypeNum FPutField = 181

instance ToJSON FieldInsType where
  toJSON = toJSON . fieldInsTypeNum

data FrameType = FFull | FSame | FAppend
frameTypeNum :: FrameType -> Int
frameTypeNum FFull = 0
frameTypeNum FSame = 3
frameTypeNum FAppend = 1

instance ToJSON FrameType where
  toJSON = toJSON . frameTypeNum

data Access = Private | Public | Static | Synthetic
accessNum :: Access -> Int
accessNum Private = 2
accessNum Public = 1
accessNum Static = 8
accessNum Synthetic = 4096

instance ToJSON Access where
  toJSON = toJSON . accessNum

data HandleTag = HGetField
               | HGetStatic
               | HPutField
               | HPutStatic
               | HInvokeVirtual
               | HInvokeStatic
               | HInvokeSpecial
               | HNewInvokeSpecial
               | HInvokeInterface
handleTagOpcode :: HandleTag -> Int
handleTagOpcode HGetField = 1
handleTagOpcode HGetStatic = 2
handleTagOpcode HPutField = 3
handleTagOpcode HPutStatic = 4
handleTagOpcode HInvokeVirtual = 5
handleTagOpcode HInvokeStatic = 6
handleTagOpcode HInvokeSpecial = 7
handleTagOpcode HNewInvokeSpecial = 8
handleTagOpcode HInvokeInterface = 9

instance ToJSON HandleTag where
  toJSON = toJSON . handleTagOpcode

data Handle = Handle { tag         :: HandleTag
                     , hClassName  :: ClassName
                     , hMethodName :: MethodName
                     , hDescriptor :: Descriptor
                     , isInterface :: Bool
                     }

instance ToJSON Handle where
  toJSON (Handle t cname mname desc isIntf)
    = object [ "tag" .= toJSON t
             , "cname" .= toJSON cname
             , "mname" .= toJSON mname
             , "desc" .= toJSON desc
             , "isIntf" .= toJSON isIntf ]

within :: String -> String -> String -> String
within start str end = start ++ str ++ end

quoted :: String -> String
quoted s = within "\"" s "\""

braced :: String -> String
braced s = within "(" s ")"

sqrBracketed :: String -> String
sqrBracketed s = within "[" s "]"

sep :: String -> [String] -> String
sep = intercalate

commaSep :: [String] -> String
commaSep = sep ","
