self: super:
with self.python3Packages; {
  simpleobsws = let
    pname = "simpleobsws";
    version = "1.4.3";
  in buildPythonPackage {
    inherit pname version;
    src = self.fetchPypi {
      inherit pname version;
      hash = "sha256-nNH5fkzDmkLP0vXD/9nnhd9ZE8INFz7CWuHCVzvroO0=";
    };
    pyproject = true;
    build-system = [ setuptools ];
    dependencies = [ websockets msgpack ];
  };
}
