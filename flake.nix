{
  description = "The Spdlog C++ logging library, using the built in formatter";

  inputs = {
    nixpkgs.url     = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { 
  	self, 
  	nixpkgs, 
  	flake-utils,
  }: flake-utils.lib.eachDefaultSystem
	   (system:
           let
             	pkgs = import nixpkgs { inherit system; };
             	version = "1.13.0";
		          packageName = "spdlog";
              bear = pkgs.bear;
              tiledb = pkgs.tiledb;
           in {
                packages.${packageName} = pkgs.stdenv.mkDerivation rec {
                  pname = packageName;
                  inherit version;
                
                  src = pkgs.fetchFromGitHub {
                    owner = "gabime";
                    repo  = "spdlog";
                    rev   = "v${version}";
                    hash  = "sha256-3n8BnjZ7uMH8quoiT60yTU7poyOtoEmzNMOLa1+r7X0=";
                  };
                
                  nativeBuildInputs = [ pkgs.cmake ];
                  # Required to build tests, even if they aren't executed
                  buildInputs = [ pkgs.catch2_3 ];
                
                  cmakeFlags = [
                    "-DSPDLOG_BUILD_SHARED=${if pkgs.stdenv.hostPlatform.isStatic then "OFF" else "ON"}"
                    "-DSPDLOG_BUILD_STATIC=${if pkgs.stdenv.hostPlatform.isStatic then "ON" else "OFF"}"
                    "-DSPDLOG_BUILD_EXAMPLE=OFF"
                    "-DSPDLOG_BUILD_BENCH=OFF"
                    "-DSPDLOG_BUILD_TESTS=ON"
                    "-DSPDLOG_FMT_EXTERNAL=OFF"

                  ];
                
                  postInstall = ''
                    mkdir -p $out/share/doc/spdlog
                    cp -rv ../example $out/share/doc/spdlog
                  '';
                
                  doCheck = true;

                  passthru.tests = {
                    inherit bear tiledb;
                  };
                
                  meta = with pkgs.lib; {
                    description    = "Very fast, header only, C++ logging library";
                    homepage       = "https://github.com/gabime/spdlog";
                    license        = licenses.mit;
                    maintainers    = with maintainers; [ obadz ];
                    platforms      = platforms.all;
                  };
        	        
        	      };

                defaultPackage = self.packages.${system}.${packageName};
           }
     );
}
