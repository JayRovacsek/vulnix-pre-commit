# vulnix-pre-commit
A simple wrapper for vulnix to check the state of a flake derivation for new or introduced vulnerabilities

## Developing This Flake
To contribute to this flake, please create a meaningful pull request against the repository. If you are utilising
a visual studio code derivative you should be able to include the dev shell within your environment with the use of 
this extension: 
```
Name: Nix Environment Selector
Id: arrterian.nix-env-selector
Description: Allows switch environment for Visual Studio Code and extensions based on Nix config file.
Version: 1.0.9
Publisher: arrterian
```

## Goals Of This Flake
The goal of this flake is to provide a method in which vulnix can be utilised to assess the build output of a flake 
for vulnerabilities.

## Utilisation
This flake leverages [Cachix's pre-commit-hooks repository](https://github.com/cachix/pre-commit-hooks.nix); firstly add it
to your project then you should be able to use the following structure (or an alike one) to determine if the default
build outputs of your project are weak to a select severity of vulnerability. Note that this is currently limited scope and 
intent to augment this capability to be a little smarter about determining if changes have meaningfully eroded the security
of a build are not yet fully realised (see the future section below).

*TODO: CREATE EXAMPLE MVP CODE OF USING IN A FLAKE
```nix
{ 
    #TODO 
}
```

## Future
The future of this project would incorporate the following to the current functionality:

### Diverse CVE Filters
Currently we only apply a CVE severity threshold: it would be preferable that this is configurable so that other elements of 
the detections can be utilised more contextually.

### Deduplication Of CVEs
Current implementation is naive and inefficient - there is current work to resolve this from occurring. As my current use-case
is either single system assessment or package assessment this is not problematic from a computation perspective but certainly is
not going to be appropriate long-term.

### Known Exploitability Application
Stopping CVEs from existing is a lofty goal, however not all CVEs have known exploitation. While CVSSv3 includes this as a component
of scoring under temporal elements, we may want to apply a pre-filter (optionally) if the exploit of a CVE is unproven to reduce 
overhead for a responder. For now this could also be considered an element of `Diverse CVE Filters`