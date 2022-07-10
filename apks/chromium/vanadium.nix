# SPDX-FileCopyrightText: 2020 Daniel Fullmer and robotnix contributors
# SPDX-License-Identifier: MIT

{ chromium, fetchFromGitHub, git, fetchcipd, linkFarmFromDrvs, fetchurl }:

let
  vanadium_src = fetchFromGitHub {
    owner = "GrapheneOS";
    repo = "Vanadium";
    rev = "SQ3A.220705.003.A1.2022070600";
    sha256 = "sha256-gwRIS8YG8UdD5odm+m0O2Q/NJeASA197ihuzLjVMGGY=";
  };
in (chromium.override {
  name = "vanadium";
  displayName = "Vanadium";
  version = "103.0.5060.71";
  enableRebranding = false; # Patches already include rebranding
  customGnFlags = {
    is_component_build = false;
    is_debug = false;
    is_official_build = true;
    symbol_level = 1;
    disable_fieldtrial_testing_config = true;

    dfmify_dev_ui = false;
    disable_autofill_assistant_dfm = true;
    disable_tab_ui_dfm = true;

    # enable patented codecs
    ffmpeg_branding = "Chrome";
    proprietary_codecs = true;

    is_cfi = true;

    enable_gvr_services = false;
    enable_remoting = false;
    enable_reporting = true; # 83.0.4103.83 build is broken without building this code
  };
}).overrideAttrs (attrs: {
  # Use git apply below since some of these patches use "git binary diff" format
  postPatch = ''
    ( cd src
      for patchfile in ${vanadium_src}/patches/*.patch; do
        ${git}/bin/git apply --unsafe-paths $patchfile
      done
    )
  '' + attrs.postPatch;
})
