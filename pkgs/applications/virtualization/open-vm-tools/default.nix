{stdenv, lib, fetchurl, makeWrapper, 
 libmspack, openssl, pam, xercesc, icu, libdnet, procps, 
 x11, libXinerama, libXi, libXrender, libXrandr, libXtst,
 pkgconfig, glib, gtk, gtkmm }:

let
  majorVersion = "9.10";
  minorVersion = "0";
  patchSet = "2476743";
  version = "${majorVersion}.${minorVersion}-${patchSet}";

in stdenv.mkDerivation {
  name = "open-vm-tools-${version}";
  src = fetchurl {
    url = "http://downloads.sourceforge.net/project/open-vm-tools/open-vm-tools/stable-${majorVersion}.x/open-vm-tools-${version}.tar.gz";
    sha256 = "15lwayrz9bpx4z12fj616hsn25m997y72licwwz7kms4sx9ssip1";
  };

  buildInputs = 
    [ makeWrapper libmspack openssl pam xercesc icu libdnet procps
      pkgconfig glib gtk gtkmm x11 libXinerama libXi libXrender libXrandr libXtst ];

  configureFlags = "--without-kernel-modules --without-xmlsecurity";

  buildPhase = ''
     find -name Makefile -exec sed -i s,-Werror,,g {} \;
     sed -i 's,^confdir = ,confdir = ''${prefix},' scripts/Makefile
     sed -i 's,etc/vmware-tools,''${prefix}/etc/vmware-tools,' services/vmtoolsd/Makefile
     make 
  '';

  meta = {
    description = "Open VMWare guest tools";
    license = "GPL";
    platforms = stdenv.lib.platforms.linux;
    maintainers = [ lib.maintainers.joamaki ];
  };
}
