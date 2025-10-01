self: super:
with self.python3Packages; {
  shanokeys = let
    pname = "shanokeys";
    version = "0.0.1";
  in buildPythonApplication {
    inherit pname version;
    src = self.fetchFromGitHub {
      inherit pname version;
      owner = "aastefanov";
      repo = "shanokeys";
      rev = "7d3e8a14732b149651ce3e7f881f3b2b9f8b97a6";
      hash = "sha256-oQWTfsxMJZF/QlrGOShh2KQ0a6mzm2MuwDL+ocw5gLA=";
    };
    pyproject = true;
    build-system = [ setuptools ];

    dependencies = [ pyyaml dataclass-wizard self.simpleobsws ];

    nativeBuildInputs = [ pythonRelaxDepsHook setuptools setuptools-scm ];
    pythonRelaxDeps = [ ];
  };
}
