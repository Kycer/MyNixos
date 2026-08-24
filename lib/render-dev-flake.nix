{ languages }:

let
  languageTools = import ./dev-language-tools.nix;

  unique = builtins.foldl' (
    result: value:
    if builtins.elem value result then result else result ++ [ value ]
  ) [ ];

  selectedLanguages = unique languages;
  unknownLanguages = builtins.filter (
    language: !(builtins.hasAttr language languageTools)
  ) selectedLanguages;
  selectedTools = map (language: languageTools.${language}) selectedLanguages;
  packages = unique (builtins.concatLists (map (tools: tools.packages) selectedTools));
  shellVariables = unique (
    builtins.concatLists (map (tools: tools.shellVariables or [ ]) selectedTools)
  );

  renderShellVariable =
    variable:
    if variable ? expression then
      variable.name + " = \"" + "$" + "{" + variable.expression + "}\";"
    else
      variable.name + " = " + builtins.toJSON variable.value + ";";

  languageNames = builtins.concatStringsSep ", " selectedLanguages;
  availableLanguages = builtins.concatStringsSep ", " (builtins.attrNames languageTools);

  lines =
    [
      "{"
      "  description = \"Development environment (${languageNames})\";"
      ""
      "  inputs.nixpkgs.url = \"github:NixOS/nixpkgs/nixos-unstable\";"
      ""
      "  outputs ="
      "    { nixpkgs, ... }:"
      "    let"
      "      supportedSystems = ["
      "        \"x86_64-linux\""
      "        \"aarch64-linux\""
      "      ];"
      "      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;"
      "    in"
      "    {"
      "      devShells = forAllSystems ("
      "        system:"
      "        let"
      "          pkgs = import nixpkgs { inherit system; };"
      "        in"
      "        {"
      "          default = pkgs.mkShell {"
      "            packages = with pkgs; ["
    ]
    ++ map (package: "              ${package}") packages
    ++ [
      "            ];"
    ]
    ++ map (variable: "            ${renderShellVariable variable}") shellVariables
    ++ [
      "          };"
      "        }"
      "      );"
      "    };"
      "}"
    ];
in
if selectedLanguages == [ ] then
  throw "Select at least one development language"
else if unknownLanguages != [ ] then
  throw ''
    Unknown development language(s): ${builtins.concatStringsSep ", " unknownLanguages}
    Available languages: ${availableLanguages}
  ''
else
  (builtins.concatStringsSep "\n" lines) + "\n"
