{
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "gecko";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "JLaferri";
    repo = "gecko";
    rev = "v${version}";
    sha256 = "1jqxcimpl58czvxi52jndrnzhhqmg0i4v5dp6amibg2wxwyy12w3";
  };

  # Upstream is a pre-modules GOPATH project: it ships a single main package
  # with only stdlib imports and no go.mod, so we synthesise a module and
  # skip vendoring entirely.
  postPatch = ''
    go mod init gecko
  '';

  vendorHash = null;
}
