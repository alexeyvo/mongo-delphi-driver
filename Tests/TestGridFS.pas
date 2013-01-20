unit TestGridFS;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit
  being tested.

}

interface

uses
  TestFramework, MongoDB, MongoBson, GridFS, TestMongoDB;

const
  FSDB = 'fsdb';

type
  // Test methods for class TGridFS

  TestGridFSBase = class(TestMongoBase)
  private
    FMustDropDatabase: Boolean;
  protected
    FGridFS: TGridFS;
    procedure CreateTestFile;
    procedure SetUp; override;
    function StandardRemoteFileName: AnsiString; virtual;
    function StandardTestFileName: AnsiString;
    procedure TearDown; override;
  public
    property MustDropDatabase: Boolean read FMustDropDatabase write
        FMustDropDatabase;
  end;

  TestTGridFS = class(TestGridFSBase)
  protected
    procedure CheckFileExistance(const FileName: AnsiString; ExpectedResult: Boolean =
        True);
    procedure PrepareParamsForStore(var Len: Int64; var FileName: AnsiString; var p:
        Pointer);
  published
    procedure TeststoreFile;
    procedure TeststoreFileWithRemoteName;
    procedure TeststoreFileWithRemoteNameAndContentType;
    procedure TestremoveFile;
    procedure Teststore;
    procedure TeststoreWithContentType;
    procedure TestwriterCreate;
    procedure TestwriterCreateWithContentType;
    procedure Testfind;
    procedure TestfindUsingBsonQuery;
  end;
  // Test methods for class TGridfile
  
  TestTGridfile = class(TestGridFSBase)
  private
    FGridfile: IGridfile;
  protected
    procedure CheckChunkBson(ReturnValue: IBson);
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestgetFilename;
    procedure TestgetChunkSize;
    procedure TestgetLength;
    procedure TestgetContentType;
    procedure TestgetUploadDate;
    procedure TestgetMD5;
    procedure TestgetMetadata;
    procedure TestgetChunkCount;
    procedure TestgetDescriptor;
    procedure TestgetChunk;
    procedure TestgetChunks;
    procedure TestRead;
    procedure TestSeek;
  end;

  // Test methods for class TGridfileWriter
  
  TestTGridfileWriter = class(TestGridFSBase)
  private
    FGridfileWriter: IGridfileWriter;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestWrite;
    procedure TestExpand;
    procedure TestTruncate;
  end;

implementation

uses
  Classes, SysUtils;

const
  TESTFILE = 'TestFile.txt';
  PREFIXREMOTE = 'remote_';
  FILEDATA : AnsiString = 'Hola.this is a test.123';
  FILEDATA2 : AnsiString = 'MoreData';

var
  basepath : AnsiString;

{ TestGridFSBase }

procedure TestGridFSBase.CreateTestFile;
var
  f : TStream;
begin
  f := TFileStream.Create(StandardTestFileName, fmCreate);
  try
    f.Write(PAnsiChar(FILEDATA)^, length(FILEDATA));
  finally
    f.Free;
  end;
end;

procedure TestGridFSBase.SetUp;
begin
  inherited;
  FGridFS := TGridFS.Create(FMongo, FSDB);
  MustDropDatabase := True;
end;

function TestGridFSBase.StandardRemoteFileName: AnsiString;
begin
  Result := PREFIXREMOTE + TESTFILE;
end;

function TestGridFSBase.StandardTestFileName: AnsiString;
begin
  Result := basepath + TESTFILE;
end;

procedure TestGridFSBase.TearDown;
begin
  DeleteFile(StandardTestFileName);
  FGridFS.removeFile(StandardTestFileName);
  FGridFS.removeFile(StandardRemoteFileName);
  FGridFS.Free;
  FGridFS := nil;
  if MustDropDatabase then
    FMongo.dropDatabase(FSDB);
  inherited;
end;

procedure TestTGridFS.CheckFileExistance(const FileName: AnsiString;
    ExpectedResult: Boolean = True);
const
  MsgPrefix : array [False..True] of AnsiString = ('not', '');
var
  gf : IGridFile;
begin
  gf := FGridFS.find(FileName, False);
  Check(assigned(gf) = ExpectedResult, 'After call to StoreFile file should ' + MsgPrefix[ExpectedResult] + ' exist in repository');
  gf := nil;
end;

procedure TestTGridFS.PrepareParamsForStore(var Len: Int64; var FileName:
    AnsiString; var p: Pointer);
begin
  Len := length(FILEDATA);
  FileName := StandardTestFileName;
  p := PAnsiChar(FILEDATA);
end;

procedure TestTGridFS.TeststoreFile;
var
  ReturnValue: Boolean;
  FileName: AnsiString;
begin
  CreateTestFile;
  FileName := StandardTestFileName;
  ReturnValue := FGridFS.storeFile(FileName);
  Check(ReturnValue, 'Call to StoreFile should return True');
  CheckFileExistance(FileName);
end;

procedure TestTGridFS.TeststoreFileWithRemoteName;
var
  ReturnValue: Boolean;
  remoteName: AnsiString;
  FileName: AnsiString;
begin
  CreateTestFile;
  FileName := StandardTestFileName;
  RemoteName := StandardRemoteFileName;
  ReturnValue := FGridFS.storeFile(FileName, remoteName);
  Check(ReturnValue, 'Call to StoreFile should return True');
  CheckFileExistance(RemoteName);
end;

procedure TestTGridFS.TeststoreFileWithRemoteNameAndContentType;
var
  ReturnValue: Boolean;
  contentType: AnsiString;
  remoteName: AnsiString;
  FileName: AnsiString;
begin
  CreateTestFile;
  FileName := StandardTestFileName;
  RemoteName := StandardRemoteFileName;
  contentType := '';
  ReturnValue := FGridFS.storeFile(FileName, remoteName, contentType);
  Check(ReturnValue, 'Call to StoreFile should return True');
  CheckFileExistance(RemoteName);
end;

procedure TestTGridFS.TestremoveFile;
var
  FileName: AnsiString;
begin
  CreateTestFile;
  FileName := StandardTestFileName;
  Check(FGridFS.storeFile(FileName), 'Storing file remotely failed');
  CheckFileExistance(FileName);
  FGridFS.removeFile(FileName);
  CheckFileExistance(FileName, False);
end;

procedure TestTGridFS.Teststore;
var
  ReturnValue: Boolean;
  FileName: AnsiString;
  Len: Int64;
  p: Pointer;
begin
  PrepareParamsForStore(Len, FileName, p);
  ReturnValue := FGridFS.store(p, Len, FileName);
  Check(ReturnValue, 'Call to Store should return True');
  CheckFileExistance(FileName);
end;

procedure TestTGridFS.TeststoreWithContentType;
var
  ReturnValue: Boolean;
  FileName, contentType: AnsiString;
  Len: Int64;
  p: Pointer;
begin
  PrepareParamsForStore(Len, FileName, p);
  contentType := '';
  ReturnValue := FGridFS.store(p, Len, FileName, contentType);
  Check(ReturnValue, 'Call to Store should return True');
  CheckFileExistance(FileName);
end;

procedure TestTGridFS.TestwriterCreate;
var
  ReturnValue: IGridfileWriter;
  FileName: AnsiString;
begin
  FileName := StandardTestFileName;
  ReturnValue := FGridFS.writerCreate(FileName);
  Check(ReturnValue <> nil, 'FileWriter object should be <> nil');
end;

procedure TestTGridFS.TestwriterCreateWithContentType;
var
  ReturnValue: IGridfileWriter;
  contentType: AnsiString;
  FileName: AnsiString;
begin
  contentType := '';
  FileName := StandardTestFileName;
  ReturnValue := FGridFS.writerCreate(FileName, contentType);
  Check(ReturnValue <> nil, 'FileWriter object should be <> nil');
end;

procedure TestTGridFS.Testfind;
var
  ReturnValue: IGridfile;
  FileName: AnsiString;
begin
  FileName := StandardTestFileName;
  ReturnValue := FGridFS.find(FileName, False);
  Check(ReturnValue = nil, 'Call to Find should return nil when fiel doesn''t exist yet');
  CreateTestFile;
  Check(FGridFS.storeFile(FileName), 'Call to storeFile should return True');
  ReturnValue := FGridFS.find(FileName, False);
  Check(ReturnValue <> nil, 'Call to Find should return a non nil IGridFile object when file exists');
end;

procedure TestTGridFS.TestfindUsingBsonQuery;
var
  ReturnValue: IGridfile;
  query: IBson;
  FileName : AnsiString;
begin
  query := BSON(['filename', StandardTestFileName]);
  ReturnValue := FGridFS.find(query, False);
  Check(ReturnValue = nil, 'Call to find with BSON query with non existant file should return IGridFile = nil');
  FileName := StandardTestFileName;
  CreateTestFile;
  Check(FGridFS.storeFile(FileName), 'Call to storeFile should return True');
  query := BSON(['filename', StandardTestFileName]);
  ReturnValue := FGridFS.find(query, False);
  Check(ReturnValue <> nil, 'Call to Find should return a non nil IGridFile object when file exists');
end;

procedure TestTGridfile.CheckChunkBson(ReturnValue: IBson);
var
  Bin : IBsonBinary;
  s : AnsiString;
  Iter : IBsonIterator;
begin
  Check(ReturnValue <> nil, 'Chunk object should be <> nil');
  Iter := ReturnValue.find(PAnsiChar('data'));
  Check(Iter <> nil, 'Iterator with Binary data should be <> nil');
  Bin := Iter.getBinary;
  SetLength(s, Bin.Len);
  move(Bin.Data^, PAnsiChar(s)^, Bin.Len);
  CheckEqualsString(FILEDATA, s, 'Data attribute of chunk doesn''t match');
end;

{ TestTGridfile }

procedure TestTGridfile.SetUp;
begin
  inherited;
  CreateTestFile;
  Check(FGridFS.storeFile(StandardTestFileName), 'Failed storing standard file');
  FGridFile := FGridFS.find(StandardTestFileName, False);
end;

procedure TestTGridfile.TearDown;
begin
  FGridfile := nil;
  inherited;
end;

procedure TestTGridfile.TestgetFilename;
var
  ReturnValue: AnsiString;
begin
  ReturnValue := FGridfile.getFilename;
  CheckEqualsString(StandardTestFileName, ReturnValue, 'Filename of stored file didn''t match');
end;

procedure TestTGridfile.TestgetChunkSize;
var
  ReturnValue: Integer;
begin
  ReturnValue := FGridfile.getChunkSize;
  CheckEquals(262144, ReturnValue, 'getChunkSize returned unexpected value');
end;

procedure TestTGridfile.TestgetLength;
var
  ReturnValue: Int64;
begin
  ReturnValue := FGridfile.getLength;
  CheckEquals(length(FILEDATA), ReturnValue, 'Size of file doesn''t match expected value');
end;

procedure TestTGridfile.TestgetContentType;
var
  ReturnValue: AnsiString;
begin
  ReturnValue := FGridfile.getContentType;
  CheckEqualsString('', ReturnValue, 'getContentType doesn''t match expected value');
end;

procedure TestTGridfile.TestgetUploadDate;
var
  ReturnValue: TDateTime;
begin
  ReturnValue := FGridfile.getUploadDate;
  Check(ReturnValue >= Now, 'getUploadDate should be >= than Now()');
end;

procedure TestTGridfile.TestgetMD5;
var
  ReturnValue: AnsiString;
begin
  ReturnValue := FGridfile.getMD5;
  CheckEqualsString('5f66edb442504c7b5ad71c15a7e57e04', ReturnValue, 'MD5 value of GridFile doesn''t match');
end;

procedure TestTGridfile.TestgetMetadata;
var
  ReturnValue: IBson;
begin
  ReturnValue := FGridfile.getMetadata;
  Check(ReturnValue = nil, 'Metadata object should be nil for stored GridFile');
end;

procedure TestTGridfile.TestgetChunkCount;
var
  ReturnValue: Integer;
begin
  ReturnValue := FGridfile.getChunkCount;
  CheckEquals(1, ReturnValue, 'ChunkCount for stored file should be 1');
end;

procedure TestTGridfile.TestgetDescriptor;
var
  ReturnValue: IBson;
begin
  ReturnValue := FGridfile.getDescriptor;
  Check(ReturnValue <> nil, 'GridFile descriptor should be <> nil');
  CheckEqualsString(StandardTestFileName, ReturnValue.Value(PAnsiChar('filename')), 'filename attribute of descriptor doesn''t match');
end;

procedure TestTGridfile.TestgetChunk;
var
  ReturnValue: IBson;
  i : integer;
begin
  i := 0;
  ReturnValue := FGridfile.getChunk(i);
  CheckChunkBson(ReturnValue);
end;

procedure TestTGridfile.TestgetChunks;
var
  ReturnValue: IMongoCursor;
  Count: Integer;
  i: Integer;
begin
  i := 0;
  Count := 1;
  ReturnValue := FGridfile.getChunks(i, Count);
  Check(ReturnValue <> nil, 'Chunks cursor should be <> nil');
  while ReturnValue.Next do
    begin
      CheckChunkBson(ReturnValue.Value);
    end;
end;

procedure TestTGridfile.TestRead;
var
  ReturnValue: Int64;
  Len: Int64;
  s: AnsiString;
begin
  SetLength(s, length(FILEDATA));
  Len := length(FILEDATA);
  ReturnValue := FGridfile.Read(PAnsiChar(s), Len);
  CheckEquals(Len, ReturnValue, 'Data read should match data requested');
  CheckEqualsString(FILEDATA, AnsiString(s), 'Data read doesn''t match');
end;

procedure TestTGridfile.TestSeek;
var
  ReturnValue: Int64;
  offset: Int64;
  s : AnsiString;
begin
  offset := 2;
  ReturnValue := FGridfile.Seek(offset);
  CheckEquals(2, ReturnValue, 'Return value from seek operation should be equals to 2');
  SetLength(s, length(FILEDATA) - 2);
  CheckEquals(length(s), FGridFile.Read(PAnsiChar(s), length(s)), 'Amount of data read should be data written - 2');
  CheckEqualsString(copy(FILEDATA, 3, length(FILEDATA) - 2), s, 'Data read should be equals to data written starting from char # 2');
end;

{ TestTGridfileWriter }

procedure TestTGridfileWriter.SetUp;
begin
  inherited;
  CreateTestFile;
  FGridfileWriter := FGridFS.writerCreate(StandardTestFileName);
end;

procedure TestTGridfileWriter.TearDown;
begin
  FGridfileWriter := nil;
  inherited;
end;

procedure TestTGridfileWriter.TestWrite;
var
  f : IGridFile;
  s : AnsiString;
begin
  FGridfileWriter.Write(PAnsiChar(FILEDATA2), length(FILEDATA2));
  Check(FGridFileWriter.finish, 'Call to finish should return True');
  f := FGridFS.find(StandardTestFileName, False);
  SetLength(s, f.getLength);
  f.Read(PAnsiChar(s), length(s));
  CheckEqualsString(FILEDATA2, s, 'Data read doesn''t match');
end;

procedure TestTGridfileWriter.TestExpand;
var
  f : IGridFile;
  s : AnsiString;
begin
  FGridfileWriter.Write(PAnsiChar(FILEDATA2), length(FILEDATA2));
  FGridfileWriter.expand(10);
  Check(FGridFileWriter.finish, 'Call to finish should return True');
  f := FGridFS.find(StandardTestFileName, False);
  SetLength(s, length(FILEDATA2));
  CheckEquals(length(FILEDATA2), f.Read(PAnsiChar(s), length(s)));
  CheckEqualsString(FILEDATA2, s, 'Data read doesn''t match');
  CheckEquals(length(FILEDATA2) + 10, f.getLength);
end;

procedure TestTGridfileWriter.TestTruncate;
var
  f : IGridFile;
  s : AnsiString;
begin
  FGridfileWriter.Write(PAnsiChar(FILEDATA2), length(FILEDATA2));
  FGridFileWriter.truncate(5);
  Check(FGridFileWriter.finish, 'Call to finish should return True');
  f := FGridFS.find(StandardTestFileName, False);
  SetLength(s, f.getLength);
  f.Read(PAnsiChar(s), length(s));
  CheckEqualsString(system.Copy(FILEDATA2, 1, 5), s);
  CheckEquals(5, f.getLength);
end;

initialization
  // Register any test cases with the test runner
  BasePath := AnsiString(ExtractFilePath(ParamStr(0)));
  RegisterTest(TestTGridFS.Suite);
  RegisterTest(TestTGridfile.Suite);
  RegisterTest(TestTGridfileWriter.Suite);
end.

